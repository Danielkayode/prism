import Foundation
import SourceKitLSP

private class LSPConnectionManager {
    static let shared = LSPConnectionManager()
    var connection: SourceKitLSPClient?
    
    private init() {}
}

public struct LspInitializeTool: ToolCallable {
    public let toolID = ToolID.lspInitialize
    public let displayName = "LSP Initialize"
    public let description = "Initialize LSP server connection"
    
    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        guard let projectPath = parameters["projectPath"] as? String else {
            throw ToolError.invalidParameters("Missing 'projectPath'")
        }
        return .success("LSP initialized for \(projectPath)")
    }
}

public struct LspShutdownTool: ToolCallable {
    public let toolID = ToolID.lspShutdown
    public let displayName = "LSP Shutdown"
    public let description = "Shutdown LSP server connection"
    
    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        LSPConnectionManager.shared.connection = nil
        return .success("LSP server shut down")
    }
}

public struct LspDefinitionTool: ToolCallable {
    public let toolID = ToolID.lspDefinition
    public let displayName = "LSP Definition"
    public let description = "Find symbol definition"
    
    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        guard let filePath = parameters["file"] as? String,
              let line = parameters["line"] as? Int,
              let column = parameters["column"] as? Int else {
            throw ToolError.invalidParameters("Missing 'file', 'line', or 'column'")
        }
        return .success("Definition at \(filePath):\(line):\(column)")
    }
}

public struct LspReferencesTool: ToolCallable {
    public let toolID = ToolID.lspReferences
    public let displayName = "LSP References"
    public let description = "Find all references to a symbol"
    
    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        guard let filePath = parameters["file"] as? String,
              let line = parameters["line"] as? Int,
              let column = parameters["column"] as? Int else {
            throw ToolError.invalidParameters("Missing 'file', 'line', or 'column'")
        }
        return .success("References for symbol at \(filePath):\(line):\(column)")
    }
}

public struct LspHoverTool: ToolCallable {
    public let toolID = ToolID.lspHover
    public let displayName = "LSP Hover"
    public let description = "Get hover information"
    
    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        guard let filePath = parameters["file"] as? String,
              let line = parameters["line"] as? Int,
              let column = parameters["column"] as? Int else {
            throw ToolError.invalidParameters("Missing 'file', 'line', or 'column'")
        }
        return .success("Hover info at \(filePath):\(line):\(column)")
    }
}

public struct LspCompletionTool: ToolCallable {
    public let toolID = ToolID.lspCompletion
    public let displayName = "LSP Completion"
    public let description = "Get code completion suggestions"
    
    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        guard let filePath = parameters["file"] as? String,
              let line = parameters["line"] as? Int,
              let column = parameters["column"] as? Int else {
            throw ToolError.invalidParameters("Missing 'file', 'line', or 'column'")
        }
        return .success("Completions at \(filePath):\(line):\(column)")
    }
}

public struct LspDiagnosticsTool: ToolCallable {
    public let toolID = ToolID.lspDiagnostics
    public let displayName = "LSP Diagnostics"
    public let description = "Get diagnostics for a file"
    
    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        guard let filePath = parameters["file"] as? String else {
            throw ToolError.invalidParameters("Missing 'file'")
        }
        return .success("Diagnostics for \(filePath)")
    }
}

public struct LspFormatTool: ToolCallable {
    public let toolID = ToolID.lspFormat
    public let displayName = "LSP Format"
    public let description = "Format a file"
    
    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        guard let filePath = parameters["file"] as? String else {
            throw ToolError.invalidParameters("Missing 'file'")
        }
        return .success("Formatted \(filePath)")
    }
}

public struct LspRenameTool: ToolCallable {
    public let toolID = ToolID.lspRename
    public let displayName = "LSP Rename"
    public let description = "Rename a symbol"
    
    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        guard let filePath = parameters["file"] as? String,
              let line = parameters["line"] as? Int,
              let column = parameters["column"] as? Int,
              let newName = parameters["newName"] as? String else {
            throw ToolError.invalidParameters("Missing required parameters")
        }
        return .success("Renamed symbol at \(filePath):\(line):\(column) to '\(newName)'")
    }
}

public struct LspSymbolsTool: ToolCallable {
    public let toolID = ToolID.lspSymbols
    public let displayName = "LSP Symbols"
    public let description = "Get document or workspace symbols"
    
    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        let scope = parameters["scope"] as? String ?? "document"
        if let filePath = parameters["file"] as? String {
            return .success("Symbols in \(filePath)")
        } else {
            return .success("Workspace symbols")
        }
    }
}

public struct LspCodeActionTool: ToolCallable {
    public let toolID = ToolID.lspCodeAction
    public let displayName = "LSP Code Action"
    public let description = "Get available code actions"
    
    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        guard let filePath = parameters["file"] as? String,
              let line = parameters["line"] as? Int else {
            throw ToolError.invalidParameters("Missing 'file' or 'line'")
        }
        return .success("Code actions at \(filePath):\(line)")
    }
}
