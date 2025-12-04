import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import Stripe from "stripe";
import express from "express";

admin.initializeApp();
const db = admin.firestore();
const stripe = new Stripe(process.env.STRIPE_SECRET_KEY as string, {
  apiVersion: "2024-06-20",
});

const webhookApp = express();
webhookApp.use(express.raw({ type: "application/json" }));

webhookApp.post("/stripe/webhook", async (req, res) => {
  const sig = req.headers["stripe-signature"] as string;
  const secret = process.env.STRIPE_WEBHOOK_SECRET as string;
  let event: Stripe.Event;
  try {
    event = stripe.webhooks.constructEvent(req.body, sig, secret);
  } catch (err: any) {
    functions.logger.error("Webhook signature verification failed.", err.message);
    return res.status(400).send(`Webhook Error: ${err.message}`);
  }

  try {
    switch (event.type) {
      case "checkout.session.completed": {
        const session = event.data.object as Stripe.Checkout.Session;
        const customerId = session.customer as string;
        const uid = session.client_reference_id as string; // set this when creating session
        if (uid) {
          await db.collection("users").doc(uid).set(
            {
              subscription_tier: "pro",
              stripe_customer_id: customerId,
              updated_at: admin.firestore.FieldValue.serverTimestamp(),
            },
            { merge: true }
          );
        }
        break;
      }
      case "customer.subscription.deleted":
      case "customer.subscription.paused": {
        const subscription = event.data.object as Stripe.Subscription;
        const customerId = subscription.customer as string;
        const snap = await db
          .collection("users")
          .where("stripe_customer_id", "==", customerId)
          .limit(1)
          .get();
        if (!snap.empty) {
          await snap.docs[0].ref.set(
            {
              subscription_tier: "free",
              updated_at: admin.firestore.FieldValue.serverTimestamp(),
            },
            { merge: true }
          );
        }
        break;
      }
      default:
        break;
    }
    res.json({ received: true });
  } catch (err: any) {
    functions.logger.error("Webhook handler error", err);
    res.status(500).send("Internal error");
  }
});

export const webhook = functions.https.onRequest(webhookApp);

export const createCheckoutSession = functions.https.onRequest(async (req, res) => {
  try {
    if (req.method !== "POST") return res.status(405).send("Method Not Allowed");
    const auth = req.headers.authorization || "";
    const token = auth.startsWith("Bearer ") ? auth.substring(7) : null;
    if (!token) return res.status(401).send("Missing Authorization");

    const decoded = await admin.auth().verifyIdToken(token);
    const uid = decoded.uid;

    const { plan } = typeof req.body === "string" ? JSON.parse(req.body) : req.body;
    if (plan !== "pro" && plan !== "team") {
      return res.status(400).send("Invalid plan specified");
    }
    const priceId = plan === "team" ? process.env.STRIPE_PRICE_TEAM : process.env.STRIPE_PRICE_PRO;
    if (!priceId) return res.status(500).send("Server price not configured");

    // Ensure stripe customer id on user doc
    let customerId: string | undefined;
    const userDoc = await db.collection("users").doc(uid).get();
    if (userDoc.exists) customerId = userDoc.get("stripe_customer_id");
    if (!customerId) {
      const customer = await stripe.customers.create({
        metadata: { firebase_uid: uid },
        email: decoded.email || undefined,
      });
      customerId = customer.id;
      await db.collection("users").doc(uid).set({ stripe_customer_id: customerId }, { merge: true });
    }

    const successUrl = process.env.SUCCESS_URL || "https://example.com/success";
    const cancelUrl = process.env.CANCEL_URL || "https://example.com/cancel";

    const session = await stripe.checkout.sessions.create({
      mode: "subscription",
      client_reference_id: uid,
      customer: customerId,
      line_items: [{ price: priceId, quantity: 1 }],
      success_url: successUrl,
      cancel_url: cancelUrl,
    });

    res.json({ url: session.url });
  } catch (err: any) {
    functions.logger.error("createCheckoutSession error", err);
    res.status(500).send("Internal error");
  }
});

export const secureAICall = functions.https.onRequest(async (req, res) => {
  try {
    if (req.method !== "POST") return res.status(405).send("Method Not Allowed");
    const auth = req.headers.authorization || "";
    const token = auth.startsWith("Bearer ") ? auth.substring(7) : null;
    if (!token) return res.status(401).send("Missing Authorization");
    await admin.auth().verifyIdToken(token);

    const { provider, body } = typeof req.body === "string" ? JSON.parse(req.body) : req.body;
    let apiKey: string | undefined;
    let url: string | undefined;

    switch (provider) {
      case "openai":
        apiKey = process.env.OPENAI_API_KEY;
        url = "https://api.openai.com/v1/chat/completions";
        break;
      case "google":
        apiKey = process.env.GOOGLE_API_KEY;
        url = `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-pro:generateContent?key=${apiKey}`;
        break;
      case "anthropic":
        apiKey = process.env.ANTHROPIC_API_KEY;
        url = "https://api.anthropic.com/v1/messages";
        break;
      default:
        return res.status(400).send("Invalid provider specified");
    }

    if (!apiKey || !url) return res.status(500).send("API key or URL not configured for this provider");

    const headers: { [key: string]: string } = {
      "Content-Type": "application/json",
    };

    if (provider === "anthropic") {
      headers["x-api-key"] = apiKey;
    } else if (provider === "openai") {
      headers["Authorization"] = `Bearer ${apiKey}`;
    }

    const response = await fetch(url, {
      method: "POST",
      headers: headers,
      body: JSON.stringify({ ...body, stream: true })
    });

    if (!response.body) {
      throw new Error("No response body");
    }

    const reader = response.body.getReader();
    const decoder = new TextDecoder();

    while (true) {
      const { done, value } = await reader.read();
      if (done) {
        break;
      }
      res.write(decoder.decode(value));
    }
    res.end();

  } catch (err: any) {
    functions.logger.error("secureAICall error", err);
    res.status(500).send("Internal error");
  }
});