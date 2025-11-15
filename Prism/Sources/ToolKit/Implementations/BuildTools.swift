import Foundation

public struct BuildSwiftTool: ToolCallable {
    public let toolID = ToolID.buildSwift
    public let displayName = "Build Swift"
    public let description = "Build a Swift package"
    
    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        guard let projectPath = parameters["projectPath"] as? String else {
            throw ToolError.invalidParameters("Missing 'projectPath'")
        }
        
        let configuration = parameters["configuration"] as? String ?? "debug"
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/swift")
        process.arguments = ["build", "-c", configuration]
        process.currentDirectoryURL = URL(fileURLWithPath: projectPath)
        
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
        
        return .success("Build succeeded\n\(output)")
    }
}

public struct BuildXcodeTool: ToolCallable {
    public let toolID = ToolID.buildXcode
    public let displayName = "Build Xcode"
    public let description = "Build an Xcode project"
    
    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        guard let projectPath = parameters["projectPath"] as? String,
              let scheme = parameters["scheme"] as? String else {
            throw ToolError.invalidParameters("Missing 'projectPath' or 'scheme'")
        }
        
        let configuration = parameters["configuration"] as? String ?? "Debug"
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/xcodebuild")
        process.arguments = ["-scheme", scheme, "-configuration", configuration]
        process.currentDirectoryURL = URL(fileURLWithPath: projectPath)
        
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
        
        return .success("Build succeeded\n\(output)")
    }
}

public struct BuildMakeTool: ToolCallable {
    public let toolID = ToolID.buildMake
    public let displayName = "Build Make"
    public let description = "Build using Make"
    
    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        guard let projectPath = parameters["projectPath"] as? String else {
            throw ToolError.invalidParameters("Missing 'projectPath'")
        }
        
        let target = parameters["target"] as? String
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/make")
        process.arguments = target.map { [$0] } ?? []
        process.currentDirectoryURL = URL(fileURLWithPath: projectPath)
        
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
        
        return .success("Make succeeded\n\(output)")
    }
}

public struct BuildCleanTool: ToolCallable {
    public let toolID = ToolID.buildClean
    public let displayName = "Build Clean"
    public let description = "Clean build artifacts"
    
    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        guard let projectPath = parameters["projectPath"] as? String else {
            throw ToolError.invalidParameters("Missing 'projectPath'")
        }
        
        let buildType = parameters["buildType"] as? String ?? "swift"
        let process = Process()
        
        switch buildType {
        case "swift":
            process.executableURL = URL(fileURLWithPath: "/usr/bin/swift")
            process.arguments = ["package", "clean"]
        case "xcode":
            process.executableURL = URL(fileURLWithPath: "/usr/bin/xcodebuild")
            process.arguments = ["clean"]
        default:
            throw ToolError.invalidParameters("Unknown buildType '\(buildType)'")
        }
        
        process.currentDirectoryURL = URL(fileURLWithPath: projectPath)
        
        let outputPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = outputPipe
        
        try process.run()
        process.waitUntilExit()
        
        return .success("Clean completed")
    }
}

public struct BuildArchiveTool: ToolCallable {
    public let toolID = ToolID.buildArchive
    public let displayName = "Build Archive"
    public let description = "Create an archive for distribution"
    
    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        guard let projectPath = parameters["projectPath"] as? String,
              let scheme = parameters["scheme"] as? String else {
            throw ToolError.invalidParameters("Missing 'projectPath' or 'scheme'")
        }
        
        let archivePath = parameters["archivePath"] as? String ?? "\(projectPath)/build/archive.xcarchive"
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/xcodebuild")
        process.arguments = ["archive", "-scheme", scheme, "-archivePath", archivePath]
        process.currentDirectoryURL = URL(fileURLWithPath: projectPath)
        
        let outputPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = outputPipe
        
        try process.run()
        process.waitUntilExit()
        
        guard process.terminationStatus == 0 else {
            throw ToolError.executionFailed("Archive failed")
        }
        
        return .success("Archive created at \(archivePath)")
    }
}
