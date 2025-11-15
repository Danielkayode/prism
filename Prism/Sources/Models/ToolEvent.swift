import Foundation

public enum ToolEventStatus: String, Codable {
    case running
    case success
    case error
    case blocked
}

public struct ToolEvent: Codable, Identifiable {
    public let id: String
    public let tool: String
    public var status: ToolEventStatus
    public var userVisible: Bool
    public var params: [String: String]?
    public let startedAt: Date
    public var durationMs: Int?
    public var resultSummary: String?
    public var errorMessage: String?
    
    public init(id: String = UUID().uuidString,
                tool: String,
                status: ToolEventStatus = .running,
                userVisible: Bool = true,
                params: [String: String]? = nil,
                startedAt: Date = Date(),
                durationMs: Int? = nil,
                resultSummary: String? = nil,
                errorMessage: String? = nil) {
        self.id = id
        self.tool = tool
        self.status = status
        self.userVisible = userVisible
        self.params = params
        self.startedAt = startedAt
        self.durationMs = durationMs
        self.resultSummary = resultSummary
        self.errorMessage = errorMessage
    }
}