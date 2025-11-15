import Foundation

public struct SnapshotCreateTool: ToolCallable {
    public let toolID = ToolID.snapshotCreate
    public let displayName = "Snapshot Create"
    public let description = "Create a snapshot of current state"
    
    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        guard let projectPath = parameters["projectPath"] as? String else {
            throw ToolError.invalidParameters("Missing 'projectPath'")
        }
        
        let label = parameters["label"] as? String ?? "snapshot_\(Date().timeIntervalSince1970)"
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        process.arguments = ["stash", "push", "-u", "-m", label]
        process.currentDirectoryURL = URL(fileURLWithPath: projectPath)
        
        let outputPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = outputPipe
        
        try process.run()
        process.waitUntilExit()
        
        return .success("Snapshot '\(label)' created")
    }
}

public struct SnapshotRestoreTool: ToolCallable {
    public let toolID = ToolID.snapshotRestore
    public let displayName = "Snapshot Restore"
    public let description = "Restore a previous snapshot"
    
    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        guard let projectPath = parameters["projectPath"] as? String,
              let snapshotID = parameters["snapshotID"] as? String else {
            throw ToolError.invalidParameters("Missing 'projectPath' or 'snapshotID'")
        }
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        process.arguments = ["stash", "apply", snapshotID]
        process.currentDirectoryURL = URL(fileURLWithPath: projectPath)
        
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        
        try process.run()
        process.waitUntilExit()
        
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        let error = String(data: errorData, encoding: .utf8) ?? ""
        
        guard process.terminationStatus == 0 else {
            throw ToolError.executionFailed(error)
        }
        
        return .success("Snapshot '\(snapshotID)' restored")
    }
}

public struct SnapshotListTool: ToolCallable {
    public let toolID = ToolID.snapshotList
    public let displayName = "Snapshot List"
    public let description = "List all snapshots"
    
    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        guard let projectPath = parameters["projectPath"] as? String else {
            throw ToolError.invalidParameters("Missing 'projectPath'")
        }
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        process.arguments = ["stash", "list"]
        process.currentDirectoryURL = URL(fileURLWithPath: projectPath)
        
        let outputPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = outputPipe
        
        try process.run()
        process.waitUntilExit()
        
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: outputData, encoding: .utf8) ?? ""
        
        return .success(output.isEmpty ? "No snapshots found" : output)
    }
}

public struct SnapshotDeleteTool: ToolCallable {
    public let toolID = ToolID.snapshotDelete
    public let displayName = "Snapshot Delete"
    public let description = "Delete a snapshot"
    
    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        guard let projectPath = parameters["projectPath"] as? String,
              let snapshotID = parameters["snapshotID"] as? String else {
            throw ToolError.invalidParameters("Missing 'projectPath' or 'snapshotID'")
        }
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        process.arguments = ["stash", "drop", snapshotID]
        process.currentDirectoryURL = URL(fileURLWithPath: projectPath)
        
        let outputPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = outputPipe
        
        try process.run()
        process.waitUntilExit()
        
        guard process.terminationStatus == 0 else {
            throw ToolError.executionFailed("Failed to delete snapshot")
        }
        
        return .success("Snapshot '\(snapshotID)' deleted")
    }
}

public struct SnapshotDiffTool: ToolCallable {
    public let toolID = ToolID.snapshotDiff
    public let displayName = "Snapshot Diff"
    public let description = "Show diff between snapshots"
    
    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        guard let projectPath = parameters["projectPath"] as? String else {
            throw ToolError.invalidParameters("Missing 'projectPath'")
        }
        
        let snapshotID = parameters["snapshotID"] as? String ?? "stash@{0}"
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        process.arguments = ["stash", "show", "-p", snapshotID]
        process.currentDirectoryURL = URL(fileURLWithPath: projectPath)
        
        let outputPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = outputPipe
        
        try process.run()
        process.waitUntilExit()
        
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: outputData, encoding: .utf8) ?? ""
        
        return .success(output)
    }
}
