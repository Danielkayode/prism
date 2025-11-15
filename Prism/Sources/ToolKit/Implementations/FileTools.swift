import Foundation

public struct FileReadTool: ToolCallable {
    public let toolID = ToolID.fileRead
    public let displayName = "File Read"
    public let description = "Read contents of a file"
    
    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        guard let path = parameters["path"] as? String else {
            throw ToolError.invalidParameters("Missing 'path'")
        }
        let url = URL(fileURLWithPath: path)
        let content = try String(contentsOf: url, encoding: .utf8)
        return .success(content)
    }
}

public struct FileWriteTool: ToolCallable {
    public let toolID = ToolID.fileWrite
    public let displayName = "File Write"
    public let description = "Write content to a file"
    
    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        guard let path = parameters["path"] as? String,
              let content = parameters["content"] as? String else {
            throw ToolError.invalidParameters("Missing 'path' or 'content'")
        }
        let url = URL(fileURLWithPath: path)
        try content.write(to: url, atomically: true, encoding: .utf8)
        return .success("Wrote \(content.count) bytes to \(path)")
    }
}

public struct FileDeleteTool: ToolCallable {
    public let toolID = ToolID.fileDelete
    public let displayName = "File Delete"
    public let description = "Delete a file"
    
    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        guard let path = parameters["path"] as? String else {
            throw ToolError.invalidParameters("Missing 'path'")
        }
        let url = URL(fileURLWithPath: path)
        try FileManager.default.removeItem(at: url)
        return .success("Deleted \(path)")
    }
}

public struct FileMoveTool: ToolCallable {
    public let toolID = ToolID.fileMove
    public let displayName = "File Move"
    public let description = "Move or rename a file"
    
    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        guard let source = parameters["source"] as? String,
              let destination = parameters["destination"] as? String else {
            throw ToolError.invalidParameters("Missing 'source' or 'destination'")
        }
        let srcURL = URL(fileURLWithPath: source)
        let dstURL = URL(fileURLWithPath: destination)
        try FileManager.default.moveItem(at: srcURL, to: dstURL)
        return .success("Moved \(source) to \(destination)")
    }
}

public struct FileCopyTool: ToolCallable {
    public let toolID = ToolID.fileCopy
    public let displayName = "File Copy"
    public let description = "Copy a file"
    
    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        guard let source = parameters["source"] as? String,
              let destination = parameters["destination"] as? String else {
            throw ToolError.invalidParameters("Missing 'source' or 'destination'")
        }
        let srcURL = URL(fileURLWithPath: source)
        let dstURL = URL(fileURLWithPath: destination)
        try FileManager.default.copyItem(at: srcURL, to: dstURL)
        return .success("Copied \(source) to \(destination)")
    }
}

public struct FileListTool: ToolCallable {
    public let toolID = ToolID.fileList
    public let displayName = "File List"
    public let description = "List files in a directory"
    
    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        guard let path = parameters["path"] as? String else {
            throw ToolError.invalidParameters("Missing 'path'")
        }
        let url = URL(fileURLWithPath: path)
        let contents = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: [.isDirectoryKey], options: [.skipsHiddenFiles])
        let listing = contents.map { $0.lastPathComponent }.joined(separator: "\n")
        return .success(listing)
    }
}

public struct FileSearchTool: ToolCallable {
    public let toolID = ToolID.fileSearch
    public let displayName = "File Search"
    public let description = "Search for files matching pattern"
    
    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        guard let path = parameters["path"] as? String,
              let pattern = parameters["pattern"] as? String else {
            throw ToolError.invalidParameters("Missing 'path' or 'pattern'")
        }
        
        let url = URL(fileURLWithPath: path)
        let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles])
        
        var matches: [String] = []
        while let fileURL = enumerator?.nextObject() as? URL {
            if fileURL.lastPathComponent.contains(pattern) {
                matches.append(fileURL.path)
            }
        }
        
        return .success(matches.joined(separator: "\n"))
    }
}

public struct FileCreateDirTool: ToolCallable {
    public let toolID = ToolID.fileCreateDir
    public let displayName = "Create Directory"
    public let description = "Create a new directory"
    
    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        guard let path = parameters["path"] as? String else {
            throw ToolError.invalidParameters("Missing 'path'")
        }
        let url = URL(fileURLWithPath: path)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return .success("Created directory \(path)")
    }
}

public struct FileRemoveDirTool: ToolCallable {
    public let toolID = ToolID.fileRemoveDir
    public let displayName = "Remove Directory"
    public let description = "Remove a directory and its contents"
    
    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        guard let path = parameters["path"] as? String else {
            throw ToolError.invalidParameters("Missing 'path'")
        }
        let url = URL(fileURLWithPath: path)
        try FileManager.default.removeItem(at: url)
        return .success("Removed directory \(path)")
    }
}

public struct FileGetInfoTool: ToolCallable {
    public let toolID = ToolID.fileGetInfo
    public let displayName = "File Info"
    public let description = "Get file metadata"
    
    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        guard let path = parameters["path"] as? String else {
            throw ToolError.invalidParameters("Missing 'path'")
        }
        let url = URL(fileURLWithPath: path)
        let attrs = try FileManager.default.attributesOfItem(atPath: path)
        
        var info = [String]()
        if let size = attrs[.size] as? Int {
            info.append("Size: \(size) bytes")
        }
        if let modDate = attrs[.modificationDate] as? Date {
            info.append("Modified: \(modDate)")
        }
        if let isDir = attrs[.type] as? FileAttributeType {
            info.append("Type: \(isDir == .typeDirectory ? "Directory" : "File")")
        }
        
        return .success(info.joined(separator: "\n"))
    }
}

public struct FileSetPermissionsTool: ToolCallable {
    public let toolID = ToolID.fileSetPermissions
    public let displayName = "Set Permissions"
    public let description = "Set file permissions"
    
    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        guard let path = parameters["path"] as? String,
              let permissions = parameters["permissions"] as? Int else {
            throw ToolError.invalidParameters("Missing 'path' or 'permissions'")
        }
        let url = URL(fileURLWithPath: path)
        try FileManager.default.setAttributes([.posixPermissions: permissions], ofItemAtPath: url.path)
        return .success("Set permissions on \(path) to \(String(permissions, radix: 8))")
    }
}

public struct FileWatchTool: ToolCallable {
    public let toolID = ToolID.fileWatch
    public let displayName = "File Watch"
    public let description = "Watch a file or directory for changes"
    
    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        guard let path = parameters["path"] as? String else {
            throw ToolError.invalidParameters("Missing 'path'")
        }
        return .success("File watch started for \(path) (FSEventStream integration required)")
    }
}
