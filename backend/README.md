# Prism backend (Stripe + Firebase)

Endpoints you must provide on your backend:

- POST /create-checkout-session
  - Create a Stripe Checkout Session with client_reference_id = Firebase UID
  - Return { url }

- POST /success (Stripe redirect)
  - Optional: show success page; plan will be set via webhook.

Deploy functions/webhook:

- Set env vars STRIPE_SECRET_KEY and STRIPE_WEBHOOK_SECRET
- Deploy Firebase Functions in backend/functions

Example Node function is provided in backend/functions/src/index.ts
