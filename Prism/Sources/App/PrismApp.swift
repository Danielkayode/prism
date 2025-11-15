import SwiftUI
import FirebaseCore
import FirebaseAuth

@main
struct PrismApp: App {
    @State private var selectedMode: AIMode = .assistant
    @State private var showInlineChat: Bool = false
    @StateObject private var authState = AuthState()
    @StateObject private var subscription = SubscriptionService.shared
    @State private var showSubscription: Bool = false
    @State private var showOnboarding: Bool = !UserDefaults.standard.bool(forKey: "onboarding.done")
    
    init() {
        FirebaseApp.configure()
        AIUserDefaults.registerDefaults()
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if showOnboarding {
                    OnboardingView {
                        showOnboarding = false
                    }
                } else if authState.user == nil {
                    AuthView()
                } else {
                    ContentView(selectedMode: $selectedMode, showInlineChat: $showInlineChat)
                        .sheet(isPresented: $showSubscription) { SubscriptionView().environmentObject(subscription) }
                        .onAppear {
                            subscription.refresh()
                        }
                }
            }
            .environmentObject(subscription)
            .onAppear { setupKeyboardShortcuts() }
            .onChange(of: authState.user != nil) { loggedIn in
                if loggedIn { showSubscription = true }
            }
        }
    }
    
    private func setupKeyboardShortcuts() { }
}

struct ContentView: View {
    @Binding var selectedMode: AIMode
    @Binding var showInlineChat: Bool
    @EnvironmentObject var subscription: SubscriptionService
    @State private var showUpgradeModal: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ModeSelectorView(selectedMode: $selectedMode)
                ChatPanelView()
            }
            .navigationTitle("Prism IDE")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: SettingsView()) { Image(systemName: "gear") }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showUpgradeModal = true }) { Text("Subscribe") }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showInlineChat.toggle() }) {
                        Label("Inline Chat", systemImage: "bubble.left.and.bubble.right")
                    }
                }
            }
        }
        .sheet(isPresented: $showUpgradeModal) {
            SubscriptionView()
                .environmentObject(subscription)
        }
        .overlay {
            if showInlineChat {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture { showInlineChat = false }
                InlineChatOverlay(isPresented: $showInlineChat)
            }
        }
    }
}
