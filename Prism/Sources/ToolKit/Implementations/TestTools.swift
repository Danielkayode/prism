import Foundation

public struct TestDiscoverTool: ToolCallable {
    public let toolID = ToolID.testDiscover
    public let displayName = "Test Discover"
    public let description = "Discover available tests"
    
    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        guard let projectPath = parameters["projectPath"] as? String else {
            throw ToolError.invalidParameters("Missing 'projectPath'")
        }
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/swift")
        process.arguments = ["test", "list"]
        process.currentDirectoryURL = URL(fileURLWithPath: projectPath)
        
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        
        try process.run()
        process.waitUntilExit()
        
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: outputData, encoding: .utf8) ?? ""
        
        return .success(output)
    }
}

public struct TestRunTool: ToolCallable {
    public let toolID = ToolID.testRun
    public let displayName = "Test Run"
    public let description = "Run all tests"
    
    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        guard let projectPath = parameters["projectPath"] as? String else {
            throw ToolError.invalidParameters("Missing 'projectPath'")
        }
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/swift")
        process.arguments = ["test"]
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
        
        let combined = output + "\n" + error
        
        if process.terminationStatus == 0 {
            return .success("All tests passed\n\(combined)")
        } else {
            return .failure("Tests failed\n\(combined)")
        }
    }
}

public struct TestRunSingleTool: ToolCallable {
    public let toolID = ToolID.testRunSingle
    public let displayName = "Test Run Single"
    public let description = "Run a specific test"
    
    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        guard let projectPath = parameters["projectPath"] as? String,
              let testName = parameters["testName"] as? String else {
            throw ToolError.invalidParameters("Missing 'projectPath' or 'testName'")
        }
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/swift")
        process.arguments = ["test", "--filter", testName]
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
        
        let combined = output + "\n" + error
        
        if process.terminationStatus == 0 {
            return .success("Test passed\n\(combined)")
        } else {
            return .failure("Test failed\n\(combined)")
        }
    }
}

public struct TestCoverageTool: ToolCallable {
    public let toolID = ToolID.testCoverage
    public let displayName = "Test Coverage"
    public let description = "Generate test coverage report"
    
    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        guard let projectPath = parameters["projectPath"] as? String else {
            throw ToolError.invalidParameters("Missing 'projectPath'")
        }
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/swift")
        process.arguments = ["test", "--enable-code-coverage"]
        process.currentDirectoryURL = URL(fileURLWithPath: projectPath)
        
        let outputPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = outputPipe
        
        try process.run()
        process.waitUntilExit()
        
        return .success("Coverage report generated")
    }
}

public struct TestParseResultsTool: ToolCallable {
    public let toolID = ToolID.testParseResults
    public let displayName = "Test Parse Results"
    public let description = "Parse test results from XCTest output"
    
    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        guard let output = parameters["output"] as? String else {
            throw ToolError.invalidParameters("Missing 'output'")
        }
        
        let lines = output.components(separatedBy: .newlines)
        var passed = 0
        var failed = 0
        var failedTests: [String] = []
        
        for line in lines {
            if line.contains("Test Case") && line.contains("passed") {
                passed += 1
            } else if line.contains("Test Case") && line.contains("failed") {
                failed += 1
                failedTests.append(line)
            }
        }
        
        var summary = "Passed: \(passed), Failed: \(failed)"
        if !failedTests.isEmpty {
            summary += "\n\nFailed tests:\n" + failedTests.joined(separator: "\n")
        }
        
        return .success(summary)
    }
}
