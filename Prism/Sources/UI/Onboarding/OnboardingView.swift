import SwiftUI

public struct OnboardingView: View {
    @State private var page = 0
    public var onFinished: () -> Void
    
    public init(onFinished: @escaping () -> Void) {
        self.onFinished = onFinished
    }
    
    public var body: some View {
        ZStack {
            PrismTheme.headerGradient.opacity(0.25).ignoresSafeArea()
            VStack(spacing: 16) {
                TabView(selection: $page) {
                FeatureSlide(title: "Chat + Tools",
                             subtitle: "Ask Prism and watch tool calls run with live cards.",
                             icon: "bubble.left.and.exclamationmark")
                    .tag(0)
                FeatureSlide(title: "AI Models",
                             subtitle: "GPT-5, Claude Sonnet, Gemini 2.5 Pro.",
                             icon: "brain.head.profile")
                    .tag(1)
                FeatureSlide(title: "Subscriptions",
                             subtitle: "Free 10K tokens, Pro unlimited with Stripe.",
                             icon: "creditcard")
                    .tag(2)
                FeatureSlide(title: "Tasks + Context",
                             subtitle: "Track todos, view recent tool events, token usage.",
                             icon: "checklist")
                    .tag(3)
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            .frame(height: 280)
            
            Button(action: finish) {
                Text(page < 3 ? "Next" : "Get Started")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(PrismButtonStyle(.primary))
        }
        .padding()
    }
    
    private func finish() {
        if page < 3 {
            page += 1
        } else {
            UserDefaults.standard.set(true, forKey: "onboarding.done")
            onFinished()
        }
    }
}

private struct FeatureSlide: View {
    let title: String
    let subtitle: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(.purple)
            Text(title)
                .font(.title)
                .bold()
            Text(subtitle)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}
