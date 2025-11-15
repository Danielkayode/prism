import Foundation
import FirebaseAuth

public final class AuthState: ObservableObject {
    @Published public private(set) var user: User?
    private var handle: AuthStateDidChangeListenerHandle?
    
    public init() {
        handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.user = user
        }
    }
    
    deinit {
        if let handle = handle { Auth.auth().removeStateDidChangeListener(handle) }
    }
}
