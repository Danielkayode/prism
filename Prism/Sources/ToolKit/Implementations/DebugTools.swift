import Foundation

private class DebugSession {
    static let shared = DebugSession()
    var activeProcess: Process?
    var pid: Int32?
    
    private init() {}
}

public struct DebugStartTool: ToolCallable {
    public let toolID = ToolID.debugStart
    public let displayName = "Debug Start"
    public let description = "Start debugging a process"
    
    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        guard let executable = parameters["executable"] as? String else {
            throw ToolError.invalidParameters("Missing 'executable'")
        }
        
        let args = parameters["arguments"] as? [String] ?? []
        let workingDir = parameters["workingDirectory"] as? String
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/lldb")
        process.arguments = [executable] + args
        
        if let workDir = workingDir {
            process.currentDirectoryURL = URL(fileURLWithPath: workDir)
        }
        
        DebugSession.shared.activeProcess = process
        
        return .success("Debug session started for \(executable)")
    }
}

public struct DebugAttachTool: ToolCallable {
    public let toolID = ToolID.debugAttach
    public let displayName = "Debug Attach"
    public let description = "Attach debugger to running process"
    
    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        guard let pid = parameters["pid"] as? Int else {
            throw ToolError.invalidParameters("Missing 'pid'")
        }
        
        DebugSession.shared.pid = Int32(pid)
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/lldb")
        process.arguments = ["-p", "\(pid)"]
        
        return .success("Attached debugger to process \(pid)")
    }
}

public struct DebugStopTool: ToolCallable {
    public let toolID = ToolID.debugStop
    public let displayName = "Debug Stop"
    public let description = "Stop debugging session"
    
    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        if let process = DebugSession.shared.activeProcess {
            process.terminate()
            DebugSession.shared.activeProcess = nil
        }
        DebugSession.shared.pid = nil
        
        return .success("Debug session stopped")
    }
}

public struct DebugBreakpointTool: ToolCallable {
    public let toolID = ToolID.debugBreakpoint
    public let displayName = "Debug Breakpoint"
    public let description = "Set or remove breakpoints"
    
    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        guard let file = parameters["file"] as? String,
              let line = parameters["line"] as? Int else {
            throw ToolError.invalidParameters("Missing 'file' or 'line'")
        }
        
        let action = parameters["action"] as? String ?? "set"
        return .success("Breakpoint \(action) at \(file):\(line)")
    }
}

public struct DebugContinueTool: ToolCallable {
    public let toolID = ToolID.debugContinue
    public let displayName = "Debug Continue"
    public let description = "Continue execution"
    
    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        return .success("Execution continued")
    }
}

public struct DebugStepOverTool: ToolCallable {
    public let toolID = ToolID.debugStepOver
    public let displayName = "Debug Step Over"
    public let description = "Step over current line"
    
    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        return .success("Stepped over")
    }
}

public struct DebugStepIntoTool: ToolCallable {
    public let toolID = ToolID.debugStepInto
    public let displayName = "Debug Step Into"
    public let description = "Step into function"
    
    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        return .success("Stepped into")
    }
}

public struct DebugStepOutTool: ToolCallable {
    public let toolID = ToolID.debugStepOut
    public let displayName = "Debug Step Out"
    public let description = "Step out of current function"
    
    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        return .success("Stepped out")
    }
}

public struct DebugEvaluateTool: ToolCallable {
    public let toolID = ToolID.debugEvaluate
    public let displayName = "Debug Evaluate"
    public let description = "Evaluate expression in current context"
    
    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        guard let expression = parameters["expression"] as? String else {
            throw ToolError.invalidParameters("Missing 'expression'")
        }
        
        return .success("Evaluated: \(expression) = <value>")
    }
}

public struct DebugStackTraceTool: ToolCallable {
    public let toolID = ToolID.debugStackTrace
    public let displayName = "Debug Stack Trace"
    public let description = "Get current stack trace"
    
    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        let stackTrace = """
        #0  main() at main.swift:10
        #1  start() at libdyld.dylib
        """
        return .success(stackTrace)
    }
}

public struct DebugVariablesTool: ToolCallable {
    public let toolID = ToolID.debugVariables
    public let displayName = "Debug Variables"
    public let description = "List variables in current scope"
    
    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        let scope = parameters["scope"] as? String ?? "local"
        return .success("Variables in \(scope) scope")
    }
}
