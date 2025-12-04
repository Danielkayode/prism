import Foundation

private func runProcess(executable: String, arguments: [String]) -> String? {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
    process.arguments = [executable] + arguments

    let pipe = Pipe()
    process.standardOutput = pipe

    try? process.run()
    process.waitUntilExit()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    return String(data: data, encoding: .utf8)
}

public struct VulnScanTool: ToolCallable {
    public let toolID = ToolID.vulnScan
    public let displayName = "Vulnerability Scan"
    public let description = "Scan code for security vulnerabilities"
    
    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        let targetPath = parameters["targetPath"] as? String ?? "."
        
        if let output = runProcess(executable: "mobsfscan", arguments: [targetPath, "--json"]) {
            return .success("Vulnerability scan completed for \(targetPath)", metadata: ["results": output])
        } else {
            return .failure("Failed to get scan results")
        }
    }
}

public struct SecretsDetectTool: ToolCallable {
    public let toolID = ToolID.secretsDetect
    public let displayName = "Secrets Detection"
    public let description = "Detect hardcoded secrets and API keys"
    
    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        let targetPath = parameters["targetPath"] as? String ?? "."
        
        if let output = runProcess(executable: "gitleaks", arguments: ["detect", "-s", targetPath, "-r", "gitleaks.json"]) {
            return .success("Secrets detection completed for \(targetPath)", metadata: ["results": output])
        } else {
            return .failure("Failed to get scan results")
        }
    }
}

public struct DependencyAuditTool: ToolCallable {
    public let toolID = ToolID.dependencyAudit
    public let displayName = "Dependency Audit"
    public let description = "Audit dependencies for known vulnerabilities"
    
    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        let targetPath = parameters["targetPath"] as? String ?? "."
        
        if let output = runProcess(executable: "swift", arguments: ["package", "resolve", "--package-path", targetPath]) {
            return .success("Dependency audit completed for \(targetPath)", metadata: ["results": output])
        } else {
            return .failure("Failed to get scan results")
        }
    }
}
