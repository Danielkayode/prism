import Foundation

public protocol ToolCallable {
    var toolID: ToolID { get }
    var displayName: String { get }
    var description: String { get }
    
    func execute(parameters: [String: Any]) async throws -> ToolResult
}

public struct ToolResult: Codable {
    public let success: Bool
    public let output: String?
    public let error: String?
    public let metadata: [String: String]?
    
    public init(success: Bool, output: String? = nil, error: String? = nil, metadata: [String: String]? = nil) {
        self.success = success
        self.output = output
        self.error = error
        self.metadata = metadata
    }
    
    public static func success(_ output: String, metadata: [String: String]? = nil) -> ToolResult {
        return ToolResult(success: true, output: output, metadata: metadata)
    }
    
    public static func failure(_ error: String) -> ToolResult {
        return ToolResult(success: false, error: error)
    }
}

public enum ToolError: LocalizedError {
    case invalidParameters(String)
    case executionFailed(String)
    case permissionDenied(String)
    case notFound(String)
    case timeout
    
    public var errorDescription: String? {
        switch self {
        case .invalidParameters(let msg): return "Invalid parameters: \(msg)"
        case .executionFailed(let msg): return "Execution failed: \(msg)"
        case .permissionDenied(let msg): return "Permission denied: \(msg)"
        case .notFound(let msg): return "Not found: \(msg)"
        case .timeout: return "Operation timed out"
        }
    }
}
