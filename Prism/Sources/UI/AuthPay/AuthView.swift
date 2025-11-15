import SwiftUI
import FirebaseAuth

public struct AuthView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    
    public init() {}
    
    public var body: some View {
        ZStack {
            PrismTheme.headerGradient.opacity(0.3)
                .ignoresSafeArea()
            VStack(spacing: 16) {
                VStack(spacing: 6) {
                    Text("Prism")
                        .font(.largeTitle).bold()
                        .foregroundStyle(PrismTheme.primaryGradient)
                    Text("Sign in to continue")
                        .foregroundColor(.secondary)
                }
                .glassCard()
                
                VStack(spacing: 12) {
                    TextField("Email", text: $email)
                        .padding(10)
                        .background(PrismTheme.card)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                    SecureField("Password", text: $password)
                        .padding(10)
                        .background(PrismTheme.card)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .textContentType(.password)
                    if let error = errorMessage {
                        Text(error).foregroundColor(.red).font(.caption)
                    }
                    Button(action: signIn) {
                        if isLoading { ProgressView() } else { Text("Sign In").frame(maxWidth: .infinity) }
                    }
                    .buttonStyle(PrismButtonStyle(.primary))
                    .disabled(isLoading || email.isEmpty || password.isEmpty)
                    HStack(spacing: 12) {
                        Button("Google") { signInWithGoogle() }.buttonStyle(PrismButtonStyle(.secondary))
                        Button("Apple") { signInWithApple() }.buttonStyle(PrismButtonStyle(.secondary))
                        Button("GitHub") { signInWithGitHub() }.buttonStyle(PrismButtonStyle(.secondary))
                    }
                }
                .glassCard()
            }
            .padding()
        }
    }
    
    private func signIn() {
        isLoading = true
        errorMessage = nil
        AuthService.shared.signIn(email: email, password: password) { error in
            isLoading = false
            if let error = error { errorMessage = error.localizedDescription }
        }
    }
    
    private func signInWithApple() {
        isLoading = true
        errorMessage = nil
        AuthService.shared.signInWithApple { error in
            isLoading = false
            if let error = error { errorMessage = error.localizedDescription }
        }
    }
    
    private func signInWithGitHub() {
        isLoading = true
        errorMessage = nil
        AuthService.shared.signInWithGitHub { error in
            isLoading = false
            if let error = error { errorMessage = error.localizedDescription }
        }
    }
    
    private func signInWithGoogle() {
        isLoading = true
        errorMessage = nil
        AuthService.shared.signInWithGoogle { error in
            isLoading = false
            if let error = error { errorMessage = error.localizedDescription }
        }
    }
}
