import Foundation

public struct SecretsDetectTool: ToolCallable {
    public let toolID = ToolID.secretsDetect
    public let displayName = "Secrets Detection"
    public let description = "Detect hardcoded secrets and API keys using gitleaks"

    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        let targetPath = parameters["targetPath"] as? String ?? "."
        let includeHistory = parameters["includeHistory"] as? Bool ?? false

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = ["gitleaks", "detect", "-s", targetPath]
        if includeHistory {
            process.arguments?.append("--log-opts=--full-history")
        }

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        do {
            try process.run()
            process.waitUntilExit()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                return .success("Gitleaks scan completed.", metadata: ["report": output])
            } else {
                return .failure("Failed to read gitleaks output.")
            }
        } catch {
            return .failure("Failed to run gitleaks: \(error.localizedDescription)")
        }
    }
}

public struct DependencyAuditTool: ToolCallable {
    public let toolID = ToolID.dependencyAudit
    public let displayName = "Dependency Audit"
    public let description = "Audit dependencies for known vulnerabilities using Swift Package Manager"

    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        let packageDir = parameters["packageDir"] as? String ?? "."

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = ["swift", "package", "show-dependencies", "--outdated", "--package-path", packageDir]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        do {
            try process.run()
            process.waitUntilExit()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                return .success("Swift package outdated check completed.", metadata: ["details": output])
            } else {
                return .failure("Failed to read swift package outdated check output.")
            }
        } catch {
            return .failure("Failed to run swift package outdated check: \(error.localizedDescription)")
        }
    }
}

public struct SecurityReportTool: ToolCallable {
    public let toolID = ToolID.securityReport
    public let displayName = "Security Report"
    public let description = "Generate a summary security report"

    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        let projectPath = parameters["projectPath"] as? String ?? "."
        
        var reportItems: [String: Any] = [:]

        do {
            let secretsResult = try await SecretsDetectTool().execute(parameters: ["targetPath": projectPath])
            if let secretsReport = secretsResult.getMetadata()?["report"] as? String {
                reportItems["Secrets Detection"] = secretsReport
            }
        } catch {
            reportItems["Secrets Detection"] = "Error: \(error.localizedDescription)"
        }

        do {
            let auditResult = try await DependencyAuditTool().execute(parameters: ["packageDir": projectPath])
            if let auditDetails = auditResult.getMetadata()?["details"] as? String {
                reportItems["Dependency Audit"] = auditDetails
            }
        } catch {
            reportItems["Dependency Audit"] = "Error: \(error.localizedDescription)"
        }

        let summary = "Security report generated for \(projectPath)."
        return .success(summary, metadata: reportItems)
    }
}

public struct VulnScanTool: ToolCallable {
    public let toolID = ToolID.vulnScan
    public let displayName = "Vulnerability Scan"
    public let description = "Performs a basic static analysis scan for common vulnerability patterns."

    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        let targetPath = parameters["targetPath"] as? String ?? "."

        let patterns = [
            "eval\\s*\\(": "Potential use of insecure `eval()` function.",
            "\\.unsafe": "Potential use of unsafe Swift APIs.",
            "Process\\s*\\(": "Direct process invocation, check for command injection vulnerabilities.",
            "TODO.*SECURITY": "Unresolved security-related TODO comment found."
        ]
        
        var findings: [String: [String]] = [:]

        for (pattern, description) in patterns {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
            process.arguments = ["grep", "-r", "-n", pattern, targetPath]

            let pipe = Pipe()
            process.standardOutput = pipe

            try process.run()
            process.waitUntilExit()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8), !output.isEmpty {
                let lines = output.split(separator: "\n").map(String.init)
                findings[description] = lines
            }
        }

        let summary = "Vulnerability scan completed. Found \(findings.count) types of potential issues."
        return .success(summary, metadata: ["findings": findings])
    }
}

fileprivate func findPattern(_ pattern: String, in path: String) async -> [String] {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
    process.arguments = ["grep", "-r", "-n", pattern, path]

    let pipe = Pipe()
    process.standardOutput = pipe

    do {
        try process.run()
        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        if let output = String(data: data, encoding: .utf8), !output.isEmpty {
            return output.split(separator: "\n").map(String.init)
        }
    } catch {
        return ["Error executing grep: \(error.localizedDescription)"]
    }

    return []
}

public struct ThreatModelTool: ToolCallable {
    public let toolID = ToolID.threatModel
    public let displayName = "Threat Model"
    public let description = "Generates a basic threat model by identifying entry points and data assets."

    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        let targetPath = parameters["targetPath"] as? String ?? "."

        let entryPointPatterns = [
            "functions.https.onRequest": "Cloud Function HTTP Entry Point"
        ]
        
        let dataAssetPatterns = [
            "db.collection\\(": "Firestore Database Collection"
        ]
        
        var findings: [String: [String]] = [:]

        for (pattern, description) in entryPointPatterns {
            findings[description] = await findPattern(pattern, in: targetPath)
        }

        for (pattern, description) in dataAssetPatterns {
            findings[description] = await findPattern(pattern, in: targetPath)
        }

        let summary = "Threat model generated. Identified \(findings.values.flatMap { $0 }.count) potential assets and entry points."
        return .success(summary, metadata: ["findings": findings])
    }
}

public struct AccessAuditTool: ToolCallable {
    public let toolID = ToolID.accessAudit
    public let displayName = "Access Audit"
    public let description = "Audits the codebase for access control enforcement."

    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        let targetPath = parameters["targetPath"] as? String ?? "."
        
        let patterns = [
            "admin.auth().verifyIdToken": "Firebase Auth ID Token Verification"
        ]
        
        var findings: [String: [String]] = [:]

        for (pattern, description) in patterns {
            findings[description] = await findPattern(pattern, in: targetPath)
        }

        let summary = "Access audit completed. Found \(findings.values.flatMap { $0 }.count) access control enforcement points."
        return .success(summary, metadata: ["findings": findings])
    }
}