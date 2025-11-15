import Foundation

public struct AuditLog: Codable, Identifiable {
    public let id: String
    public let timestamp: Date
    public let userID: String
    public let action: String
    public let toolID: String?
    public let success: Bool
    public let details: String?
    
    public init(id: String = UUID().uuidString, timestamp: Date = Date(), userID: String, action: String, toolID: String? = nil, success: Bool, details: String? = nil) {
        self.id = id
        self.timestamp = timestamp
        self.userID = userID
        self.action = action
        self.toolID = toolID
        self.success = success
        self.details = details
    }
}
