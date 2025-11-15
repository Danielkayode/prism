import Foundation

public struct ContextRefreshTool: ToolCallable {
    public let toolID = ToolID.contextRefresh
    public let displayName = "Context Refresh"
    public let description = "Incrementally re-index changed files"
    
    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        guard let projectPath = parameters["projectPath"] as? String,
              let databasePath = parameters["databasePath"] as? String else {
            throw ToolError.invalidParameters("Missing 'projectPath' or 'databasePath'")
        }
        
        let indexer = try ContextIndexer(databasePath: databasePath)
        try indexer.indexProject(at: projectPath)
        
        return .success("Context refreshed for \(projectPath)")
    }
}

public struct ContextSearchTool: ToolCallable {
    public let toolID = ToolID.contextSearch
    public let displayName = "Context Search"
    public let description = "Search symbols in context"
    
    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        guard let query = parameters["query"] as? String,
              let databasePath = parameters["databasePath"] as? String else {
            throw ToolError.invalidParameters("Missing 'query' or 'databasePath'")
        }
        
        let indexer = try ContextIndexer(databasePath: databasePath)
        let results = try indexer.searchSymbols(query: query)
        
        let output = results.map { "\($0.name) (\($0.kind)) at \($0.filePath):\($0.line)" }
            .joined(separator: "\n")
        
        return .success(output.isEmpty ? "No symbols found" : output)
    }
}

public struct ContextTimelineTool: ToolCallable {
    public let toolID = ToolID.contextTimeline
    public let displayName = "Context Timeline"
    public let description = "Get context timeline history"
    
    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        guard let databasePath = parameters["databasePath"] as? String else {
            throw ToolError.invalidParameters("Missing 'databasePath'")
        }
        
        let limit = parameters["limit"] as? Int ?? 50
        let timeline = try ContextTimeline(databasePath: databasePath)
        let entries = try timeline.getRecent(limit: limit)
        
        let output = entries.map { "\($0.timestamp): \($0.userAction) on \($0.filePath)" }
            .joined(separator: "\n")
        
        return .success(output.isEmpty ? "No timeline entries" : output)
    }
}

public struct MemoryStoreTool: ToolCallable {
    public let toolID = ToolID.memoryStore
    public let displayName = "Memory Store"
    public let description = "Store a value in memory"
    
    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        guard let databasePath = parameters["databasePath"] as? String,
              let userID = parameters["userID"] as? String,
              let key = parameters["key"] as? String,
              let value = parameters["value"] as? String else {
            throw ToolError.invalidParameters("Missing required parameters")
        }
        
        let memory = try MemoryLayer(databasePath: databasePath)
        try memory.remember(userID: userID, key: key, value: value)
        
        return .success("Stored '\(key)' in memory")
    }
}

public struct MemoryRecallTool: ToolCallable {
    public let toolID = ToolID.memoryRecall
    public let displayName = "Memory Recall"
    public let description = "Recall a value from memory"
    
    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        guard let databasePath = parameters["databasePath"] as? String,
              let userID = parameters["userID"] as? String,
              let key = parameters["key"] as? String else {
            throw ToolError.invalidParameters("Missing required parameters")
        }
        
        let memory = try MemoryLayer(databasePath: databasePath)
        if let value = try memory.recall(userID: userID, key: key) {
            return .success(value)
        } else {
            return .failure("Key '\(key)' not found in memory")
        }
    }
}

public struct MemoryDeleteTool: ToolCallable {
    public let toolID = ToolID.memoryDelete
    public let displayName = "Memory Delete"
    public let description = "Delete a value from memory"
    
    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        guard let databasePath = parameters["databasePath"] as? String,
              let userID = parameters["userID"] as? String,
              let key = parameters["key"] as? String else {
            throw ToolError.invalidParameters("Missing required parameters")
        }
        
        let memory = try MemoryLayer(databasePath: databasePath)
        try memory.forget(userID: userID, key: key)
        
        return .success("Deleted '\(key)' from memory")
    }
}
