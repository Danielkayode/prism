import SwiftUI

public struct SubscriptionView: View {
    @EnvironmentObject var subscription: SubscriptionService
    
    public init() {}
    
    public var body: some View {
        ZStack {
            PrismTheme.headerGradient.opacity(0.25).ignoresSafeArea()
            VStack(spacing: 16) {
                Text("Choose Your Plan")
                    .font(.largeTitle)
                    .bold()
                    .foregroundStyle(PrismTheme.primaryGradient)
                
                HStack(spacing: 16) {
                PlanCard(title: "Free", price: "$0", features: SubscriptionPlan.free.features, actionTitle: "Current", action: {})
                    .opacity(subscription.subscriptionTier == "free" ? 1 : 0.6)
                PlanCard(title: "Pro", price: "$20/mo", features: SubscriptionPlan.pro.features, actionTitle: "Subscribe") {
                    subscription.subscribe(plan: .pro)
                }
                PlanCard(title: "Team", price: "$50/mo", features: SubscriptionPlan.team.features, actionTitle: "Contact Sales") {
                    let url = URL(string: "mailto:sales@prism.dev") ?? URL(string: "https://prism.dev/contact")!
                    #if canImport(UIKit)
                    UIApplication.shared.open(url)
                    #elseif canImport(AppKit)
                    NSWorkspace.shared.open(url)
                    #endif
                }
            }
            .frame(maxWidth: .infinity)
            }
            .padding()
        }
        .onAppear { subscription.refresh() }
    }
}

struct PlanCard: View {
    let title: String
    let price: String
    let features: [String]
    let actionTitle: String
    let action: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).font(.title2).bold()
            Text(price).font(.title)
                .foregroundStyle(PrismTheme.primaryGradient)
            Divider()
            ForEach(features, id: \.self) { f in
                HStack { Image(systemName: "checkmark.circle.fill").foregroundColor(PrismTheme.accent); Text(f) }
            }
            Spacer()
            Button(actionTitle, action: action)
                .buttonStyle(PrismButtonStyle(.primary))
                .frame(maxWidth: .infinity)
        }
        .padding()
        .frame(width: 260, height: 320)
        .background(PrismTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }
}
