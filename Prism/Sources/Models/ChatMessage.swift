import Foundation

public struct ChatMessage: Codable, Identifiable {
    public let id: String
    public let timestamp: Date
    public let role: String
    public let content: String
    public let metadata: [String: String]?
    
    public init(id: String = UUID().uuidString, timestamp: Date = Date(), role: String, content: String, metadata: [String: String]? = nil) {
        self.id = id
        self.timestamp = timestamp
        self.role = role
        self.content = content
        self.metadata = metadata
    }
}
