import Foundation

public struct ShellExecTool: ToolCallable {
    public let toolID = ToolID.shellExec
    public let displayName = "Shell Execute"
    public let description = "Execute a shell command"
    
    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        guard let command = parameters["command"] as? String else {
            throw ToolError.invalidParameters("Missing 'command'")
        }
        
        let workingDir = parameters["workingDirectory"] as? String
        let shell = parameters["shell"] as? String ?? "/bin/zsh"
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: shell)
        process.arguments = ["-c", command]
        
        if let workDir = workingDir {
            process.currentDirectoryURL = URL(fileURLWithPath: workDir)
        }
        
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        
        try process.run()
        process.waitUntilExit()
        
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        
        let output = String(data: outputData, encoding: .utf8) ?? ""
        let error = String(data: errorData, encoding: .utf8) ?? ""
        
        guard process.terminationStatus == 0 else {
            throw ToolError.executionFailed(error.isEmpty ? output : error)
        }
        
        return .success(output.trimmingCharacters(in: .whitespacesAndNewlines))
    }
}

public struct ShellPipeTool: ToolCallable {
    public let toolID = ToolID.shellPipe
    public let displayName = "Shell Pipe"
    public let description = "Execute piped shell commands"
    
    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        guard let commands = parameters["commands"] as? [String] else {
            throw ToolError.invalidParameters("Missing 'commands' array")
        }
        
        let pipelined = commands.joined(separator: " | ")
        return try await ShellExecTool().execute(parameters: ["command": pipelined])
    }
}

public struct ShellEnvTool: ToolCallable {
    public let toolID = ToolID.shellEnv
    public let displayName = "Shell Environment"
    public let description = "Get or set environment variables"
    
    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        if let key = parameters["key"] as? String {
            if let value = ProcessInfo.processInfo.environment[key] {
                return .success("\(key)=\(value)")
            } else {
                return .failure("Environment variable '\(key)' not found")
            }
        } else {
            let allVars = ProcessInfo.processInfo.environment
                .map { "\($0.key)=\($0.value)" }
                .sorted()
                .joined(separator: "\n")
            return .success(allVars)
        }
    }
}

public struct ShellKillTool: ToolCallable {
    public let toolID = ToolID.shellKill
    public let displayName = "Shell Kill"
    public let description = "Kill a process by PID"
    
    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        guard let pid = parameters["pid"] as? Int else {
            throw ToolError.invalidParameters("Missing 'pid'")
        }
        
        let signal = parameters["signal"] as? Int ?? 15
        let result = kill(pid_t(pid), Int32(signal))
        
        if result == 0 {
            return .success("Sent signal \(signal) to process \(pid)")
        } else {
            throw ToolError.executionFailed("Failed to kill process \(pid)")
        }
    }
}
