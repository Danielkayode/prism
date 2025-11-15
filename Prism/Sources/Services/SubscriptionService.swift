import Foundation
import FirebaseAuth
import FirebaseFirestore
#if canImport(UIKit)
import UIKit
#endif
#if canImport(AppKit)
import AppKit
#endif

public final class SubscriptionService: ObservableObject {
    public static let shared = SubscriptionService()
    @Published public private(set) var subscriptionTier: String = "free"
    @Published public private(set) var stripeCustomerID: String?
    private let db = Firestore.firestore()
    
    private init() {}
    
    public func refresh() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        db.collection("users").document(uid).getDocument { snapshot, _ in
            if let data = snapshot?.data() {
                self.subscriptionTier = (data["subscription_tier"] as? String) ?? "free"
                self.stripeCustomerID = data["stripe_customer_id"] as? String
            }
        }
    }
    
    public func subscribe(plan: SubscriptionPlan = .pro) {
        guard let user = Auth.auth().currentUser else { return }
        user.getIDToken { idToken, _ in
            guard let idToken = idToken else { return }
            guard let base = Bundle.main.infoDictionary?["PRISM_BACKEND_URL"] as? String,
                  let url = URL(string: base + "/create-checkout-session") else { return }
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
            request.httpBody = try? JSONSerialization.data(withJSONObject: ["plan": plan.rawValue])
            
            let task = URLSession.shared.dataTask(with: request) { data, _, _ in
                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let sessionURL = json["url"] as? String,
                      let url = URL(string: sessionURL) else { return }
                #if canImport(UIKit)
                DispatchQueue.main.async { UIApplication.shared.open(url) }
                #elseif canImport(AppKit)
                DispatchQueue.main.async { NSWorkspace.shared.open(url) }
                #endif
            }
            task.resume()
        }
    }
}
