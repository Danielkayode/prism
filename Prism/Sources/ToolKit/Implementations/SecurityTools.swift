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