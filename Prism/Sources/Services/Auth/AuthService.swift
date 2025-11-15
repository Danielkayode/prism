import Foundation
import AuthenticationServices
import CryptoKit
import FirebaseAuth
import FirebaseCore
#if canImport(UIKit)
import UIKit
import GoogleSignIn
#endif
#if canImport(AppKit)
import AppKit
#endif

public final class AuthService: NSObject {
    public static let shared = AuthService()
    private override init() {}
    
    // MARK: - Email/Password
    public func signIn(email: String, password: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { _, error in
            completion(error)
        }
    }
    
    // MARK: - Sign in with Apple
    private var currentNonce: String?
    private var appleCompletion: ((Error?) -> Void)?
    
    public func signInWithApple(completion: @escaping (Error?) -> Void) {
        let nonce = randomNonceString()
        currentNonce = nonce
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        appleCompletion = completion
        controller.performRequests()
    }
    
    // MARK: - Sign in with GitHub (OAuth)
    public func signInWithGitHub(completion: @escaping (Error?) -> Void) {
        let provider = OAuthProvider(providerID: "github.com")
        #if canImport(UIKit)
        let presenter = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?.rootViewController
        provider.getCredentialWith(presenter: presenter) { credential, error in
            if let error = error { completion(error); return }
            guard let credential = credential else {
                completion(NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "No credential"]))
                return
            }
            Auth.auth().signIn(with: credential) { _, error in
                completion(error)
            }
        }
        #elseif canImport(AppKit)
        provider.getCredentialWith(nil) { credential, error in
            if let error = error { completion(error); return }
            guard let credential = credential else {
                completion(NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "No credential"]))
                return
            }
            Auth.auth().signIn(with: credential) { _, error in
                completion(error)
            }
        }
        #else
        completion(NSError(domain: "Auth", code: -2, userInfo: [NSLocalizedDescriptionKey: "Unsupported platform"]))
        #endif
}
    public func signInWithGoogle(completion: @escaping (Error?) -> Void) {
        #if canImport(UIKit)
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            completion(NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Missing Google clientID"]))
            return
        }
        let config = GIDConfiguration(clientID: clientID)
        guard let presenter = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow })?.rootViewController else {
            completion(NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "No presenter"]))
            return
        }
        GIDSignIn.sharedInstance.signIn(with: config, presenting: presenter) { user, error in
            if let error = error { completion(error); return }
            guard
                let authentication = user?.authentication,
                let idToken = authentication.idToken
            else {
                completion(NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Google auth missing tokens"]))
                return
            }
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken)
            Auth.auth().signIn(with: credential) { _, error in
                completion(error)
            }
        }
        #elseif canImport(AppKit)
        // Fallback: generic OAuth on macOS
        let provider = OAuthProvider(providerID: "google.com")
        provider.getCredentialWith(nil) { credential, error in
            if let error = error { completion(error); return }
            guard let credential = credential else {
                completion(NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "No credential"]))
                return
            }
            Auth.auth().signIn(with: credential) { _, error in
                completion(error)
            }
        }
        #else
        completion(NSError(domain: "Auth", code: -2, userInfo: [NSLocalizedDescriptionKey: "Unsupported platform"]))
        #endif
    }
}

// MARK: - ASAuthorizationControllerDelegate
extension AuthService: ASAuthorizationControllerDelegate {
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            appleCompletion?(NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Missing AppleID credential"]))
            appleCompletion = nil
            return
        }
        guard let nonce = currentNonce else {
            appleCompletion?(NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid state: No login request was sent."]))
            appleCompletion = nil
            return
        }
        guard let appleIDToken = appleIDCredential.identityToken, let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            appleCompletion?(NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to fetch identity token"]))
            appleCompletion = nil
            return
        }
        let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
        Auth.auth().signIn(with: credential) { _, error in
            self.appleCompletion?(error)
            self.appleCompletion = nil
        }
    }
    
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        appleCompletion?(error)
        appleCompletion = nil
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding
extension AuthService: ASAuthorizationControllerPresentationContextProviding {
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        #if canImport(UIKit)
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow } ?? UIWindow()
        #elseif canImport(AppKit)
        return NSApplication.shared.windows.first ?? NSWindow()
        #else
        return ASPresentationAnchor()
        #endif
    }
}

// MARK: - Nonce helpers
private func sha256(_ input: String) -> String {
    let inputData = Data(input.utf8)
    let hashed = SHA256.hash(data: inputData)
    return hashed.compactMap { String(format: "%02x", $0) }.joined()
}

private func randomNonceString(length: Int = 32) -> String {
    precondition(length > 0)
    let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
    var result = ""
    var remainingLength = length

    while remainingLength > 0 {
        let randoms: [UInt8] = (0 ..< 16).map { _ in
            var random: UInt8 = 0
            let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
            if errorCode != errSecSuccess {
                fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
            }
            return random
        }

        randoms.forEach { random in
            if remainingLength == 0 { return }
            if random < charset.count { result.append(charset[Int(random)]) ; remainingLength -= 1 }
        }
    }
    return result
}
