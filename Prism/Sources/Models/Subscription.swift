import Foundation

public enum SubscriptionPlan: String, Codable, CaseIterable {
    case free
    case pro
    case team
    
    public var displayName: String {
        switch self {
        case .free: return "Free"
        case .pro: return "Pro"
        case .team: return "Team"
        }
    }
    
    public var monthlyPrice: Decimal {
        switch self {
        case .free: return 0
        case .pro: return 20
        case .team: return 50
        }
    }
    
    public var features: [String] {
        switch self {
        case .free:
            return ["10K tokens/month", "Assistant mode", "Basic tools"]
        case .pro:
            return ["1M tokens/month", "Agent mode", "All tools", "Priority support"]
        case .team:
            return ["5M tokens/month", "Team collaboration", "Shared context", "Advanced analytics"]
        }
    }
}

public struct Subscription: Codable {
    public let id: String
    public let userID: String
    public let plan: SubscriptionPlan
    public let status: String
    public let currentPeriodStart: Date
    public let currentPeriodEnd: Date
    
    public init(id: String, userID: String, plan: SubscriptionPlan, status: String, currentPeriodStart: Date, currentPeriodEnd: Date) {
        self.id = id
        self.userID = userID
        self.plan = plan
        self.status = status
        self.currentPeriodStart = currentPeriodStart
        self.currentPeriodEnd = currentPeriodEnd
    }
}
