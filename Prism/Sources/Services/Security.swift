import Foundation

public struct SecuritySettings: Codable {
    public var allowShellWrite: Bool
    public var allowGitPush: Bool
    public var allowFileDelete: Bool
    public var requireConfirmDestructive: Bool
    
    public init(allowShellWrite: Bool = false, allowGitPush: Bool = false, allowFileDelete: Bool = false, requireConfirmDestructive: Bool = true) {
        self.allowShellWrite = allowShellWrite
        self.allowGitPush = allowGitPush
        self.allowFileDelete = allowFileDelete
        self.requireConfirmDestructive = requireConfirmDestructive
    }
}

public class SecurityService {
    private var settings: SecuritySettings
    private var auditLogs: [AuditLog] = []
    
    public init(settings: SecuritySettings = SecuritySettings()) {
        self.settings = settings
    }
    
    public func canExecute(toolID: ToolID) -> Bool {
        switch toolID {
        case .shellExec where !settings.allowShellWrite:
            return false
        case .gitPush where !settings.allowGitPush:
            return false
        case .fileDelete, .fileRemoveDir where !settings.allowFileDelete:
            return false
        default:
            return true
        }
    }
    
    public func requiresConfirmation(toolID: ToolID) -> Bool {
        return settings.requireConfirmDestructive && toolID.isDestructive
    }
    
    public func logAction(userID: String, action: String, toolID: ToolID?, success: Bool, details: String? = nil) {
        let log = AuditLog(
            userID: userID,
            action: action,
            toolID: toolID?.rawValue,
            success: success,
            details: details
        )
        auditLogs.append(log)
    }
    
    public func getAuditLogs(for userID: String? = nil) -> [AuditLog] {
        if let uid = userID {
            return auditLogs.filter { $0.userID == uid }
        }
        return auditLogs
    }
    
    public func updateSettings(_ newSettings: SecuritySettings) {
        settings = newSettings
    }
    
    public func getSettings() -> SecuritySettings {
        return settings
    }
}
