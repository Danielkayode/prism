import Foundation

public enum AIMode: String, Codable, CaseIterable {
    case assistant
    case agent
    case chat
    
    public var displayName: String {
        switch self {
        case .assistant: return "Assistant"
        case .agent: return "Agent"
        case .chat: return "Chat"
        }
    }
    
    public var systemPromptSuffix: String {
        switch self {
        case .assistant:
            return "Provide helpful suggestions and answer questions. Do not execute actions without explicit user confirmation."
        case .agent:
            return "You are an autonomous agent. Execute multi-step workflows to completion. Ask for confirmation only on destructive operations."
        case .chat:
            return "You are a conversational AI assistant. Focus on natural dialogue and explanation rather than code execution."
        }
    }
    
    public var requiresProSubscription: Bool {
        switch self {
        case .assistant, .chat: return false
        case .agent: return true
        }
    }
}
