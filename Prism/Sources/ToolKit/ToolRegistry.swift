import Foundation

public final class ToolRegistry {
    public static let shared = ToolRegistry()
    
    private var tools: [ToolID: ToolCallable] = [:]
    
    private init() {
        registerAllTools()
    }
    
    private func registerAllTools() {
        register(GitInitTool())
        register(GitCloneTool())
        register(GitStatusTool())
        register(GitAddTool())
        register(GitCommitTool())
        register(GitPushTool())
        register(GitPullTool())
        register(GitBranchTool())
        register(GitCheckoutTool())
        register(GitMergeTool())
        register(GitRebaseTool())
        register(GitLogTool())
        register(GitDiffTool())
        register(GitStashTool())
        register(GitTagTool())
        register(GitRemoteTool())
        register(GitResetTool())
        register(GitRevertTool())
        register(GitCherryPickTool())
        register(GitBlameTool())
        
        register(FileReadTool())
        register(FileWriteTool())
        register(FileDeleteTool())
        register(FileMoveTool())
        register(FileCopyTool())
        register(FileListTool())
        register(FileSearchTool())
        register(FileCreateDirTool())
        register(FileRemoveDirTool())
        register(FileGetInfoTool())
        register(FileSetPermissionsTool())
        register(FileWatchTool())
        
        register(ShellExecTool())
        register(ShellPipeTool())
        register(ShellEnvTool())
        register(ShellKillTool())
        
        register(LspInitializeTool())
        register(LspShutdownTool())
        register(LspDefinitionTool())
        register(LspReferencesTool())
        register(LspHoverTool())
        register(LspCompletionTool())
        register(LspDiagnosticsTool())
        register(LspFormatTool())
        register(LspRenameTool())
        register(LspSymbolsTool())
        register(LspCodeActionTool())
        
        register(BuildSwiftTool())
        register(BuildXcodeTool())
        register(BuildMakeTool())
        register(BuildCleanTool())
        register(BuildArchiveTool())
        
        register(TestDiscoverTool())
        register(TestRunTool())
        register(TestRunSingleTool())
        register(TestCoverageTool())
        register(TestParseResultsTool())
        
        register(DebugStartTool())
        register(DebugAttachTool())
        register(DebugStopTool())
        register(DebugBreakpointTool())
        register(DebugContinueTool())
        register(DebugStepOverTool())
        register(DebugStepIntoTool())
        register(DebugStepOutTool())
        register(DebugEvaluateTool())
        register(DebugStackTraceTool())
        register(DebugVariablesTool())
        
        register(SnapshotCreateTool())
        register(SnapshotRestoreTool())
        register(SnapshotListTool())
        register(SnapshotDeleteTool())
        register(SnapshotDiffTool())
        
        register(ContextRefreshTool())
        register(ContextSearchTool())
        register(ContextTimelineTool())
        register(MemoryStoreTool())
        register(MemoryRecallTool())
        register(MemoryDeleteTool())
        
        register(AIStreamMessageTool())
        register(AIGenerateCodeTool())
        register(AIExplainCodeTool())
        register(AIRefactorTool())
        register(AIFixBugTool())
        register(AIGenerateTestsTool())
        register(AIOptimizeTool())
        register(AIDocumentCodeTool())
        
        // Lint Tools
        register(LintRunTool())
        register(LintFixTool())
        register(SecurityScanTool())
        register(LintConfigureTool())
        
        // Code Quality Tools
        register(CoverageReportTool())
        register(StaticAnalysisTool())
        register(CyclomaticComplexityTool())
        register(CodeDuplicationTool())
        register(CodeMetricsTool())
        register(CodeReviewAutoTool())
        register(CodeSmellsTool())
        
        // Performance Tools
        register(BenchmarkRunTool())
        register(ProfileRunTool())
        register(MemoryProfileTool())
        register(CPUProfileTool())
        
        // Security Tools
        register(VulnScanTool())
        register(SecretsDetectTool())
        register(DependencyAuditTool())
        register(SecurityReportTool())
        register(ThreatModelTool())
        register(AccessAuditTool())
        
        // Collaboration Tools
        register(ActiveUsersTool())
        register(ShareProjectTool())
        register(ResolveConflictTool())
        register(SessionInviteTool())
        register(LiveCursorsTool())
        register(RemotePairingTool())
        register(CommentThreadTool())
        register(TaskAssignTool())
        register(ChangeRequestTool())
        
        // Package Manager Tools
        register(PackageSearchTool())
        register(PackageUpdateTool())
        register(PackageLockTool())
        register(PackageAuditTool())
        register(PackageInfoTool())
        
        // Visualization Tools
        register(GenerateFlowchartTool())
        register(GenerateSequenceDiagramTool())
        register(GenerateClassDiagramTool())
        register(GenerateDependencyGraphTool())
        register(GenerateHeatmapTool())
        
        // Workspace Tools
        register(WorkspaceSyncTool())
        register(WorkspaceCloneTool())
        register(WorkspaceForkTool())
        register(WorkspaceMergeTool())
        register(WorkspaceCleanTool())
        register(WorkspaceStatusTool())
        
        // UI Automation Tools
        register(UIRunTestTool())
        register(UIRecordMacroTool())
        register(UIPlayMacroTool())
        register(UIScreenshotTool())
        register(UIVideoRecordTool())
        
        // Migration Tools
        register(MigratePython3Tool())
        register(MigrateSwift6Tool())
        register(UpgradeDependenciesTool())
        
        // Accessibility Tools
        register(AccessibilityScanTool())
        register(AltTextSuggestTool())
        register(ContrastCheckTool())
        register(VoiceoverCheckTool())
        
        // Notification Tools
        register(NotifySuccessTool())
        register(NotifyErrorTool())
        register(NotifyAlertTool())
        register(NotifyTaskDoneTool())
        
        // Settings Tools
        register(SettingsExportTool())
        register(SettingsImportTool())
        register(SettingsResetTool())
        register(SettingsApplyProfileTool())
    }
    
    private func register(_ tool: ToolCallable) {
        tools[tool.toolID] = tool
    }
    
    public func getTool(for toolID: ToolID) -> ToolCallable? {
        return tools[toolID]
    }
    
    public func execute(toolID: ToolID, parameters: [String: Any]) async throws -> ToolResult {
        guard let tool = getTool(for: toolID) else {
            throw ToolError.notFound("Tool '\(toolID.rawValue)' not found")
        }
        // Settings gating
        let shellTools: Set<ToolID> = [.shellExec, .shellPipe, .shellEnv, .shellKill]
        let dockerTools: Set<ToolID> = [.dockerBuild, .dockerRun]
        let cloudDeployTools: Set<ToolID> = [.deployAws, .deployGcp, .deployAzure]
        let paramsString: [String: String] = parameters.reduce(into: [:]) { acc, kv in acc[kv.key] = String(describing: kv.value) }
        if shellTools.contains(toolID) && !AIUserDefaults.shellEnabled && !AIUserDefaults.dbgBypassShellChecks {
            var blocked = ToolEvent(tool: toolID.rawValue, status: .blocked, userVisible: true, params: paramsString, startedAt: Date())
            blocked.resultSummary = "Shell tools are disabled in Settings"
            ToolEventBus.shared.publish(blocked)
            throw ToolError.permissionDenied("Shell disabled by user settings")
        }
        if dockerTools.contains(toolID) && !AIUserDefaults.dockerEnabled {
            var blocked = ToolEvent(tool: toolID.rawValue, status: .blocked, userVisible: true, params: paramsString, startedAt: Date())
            blocked.resultSummary = "Docker tools disabled"
            ToolEventBus.shared.publish(blocked)
            throw ToolError.permissionDenied("Docker tools disabled by settings")
        }
        if cloudDeployTools.contains(toolID) && !AIUserDefaults.cloudDeployEnabled {
            var blocked = ToolEvent(tool: toolID.rawValue, status: .blocked, userVisible: true, params: paramsString, startedAt: Date())
            blocked.resultSummary = "Cloud deploy disabled"
            ToolEventBus.shared.publish(blocked)
            throw ToolError.permissionDenied("Cloud deploy disabled by settings")
        }
        
        // Free tier gating: allow only basic AI tools
        let tier = SubscriptionService.shared.subscriptionTier
        if tier == "free" {
            let allowed: Set<ToolID> = [.aiStreamMessage, .aiExplainCode]
            if !allowed.contains(toolID) {
                var blocked = ToolEvent(tool: toolID.rawValue, status: .blocked, userVisible: true, params: paramsString, startedAt: Date())
                blocked.resultSummary = "Upgrade required to use this tool"
                ToolEventBus.shared.publish(blocked)
                throw ToolError.permissionDenied("Free plan only allows chat and explain code. Please upgrade.")
            }
        }
        // Publish running event
        let paramsString: [String: String] = parameters.reduce(into: [:]) { acc, kv in
            acc[kv.key] = String(describing: kv.value)
        }
        var event = ToolEvent(tool: toolID.rawValue, status: .running, userVisible: true, params: paramsString, startedAt: Date())
        ToolEventBus.shared.publish(event)
        let start = Date()
        do {
            let result = try await tool.execute(parameters: parameters)
            let duration = Int(Date().timeIntervalSince(start) * 1000)
            event.status = .success
            event.durationMs = duration
            if let output = result.output {
                let summary = output.count > 0 ? "Output (\(min(output.count, 120)) chars)" : ""
                event.resultSummary = result.metadata?["summary"] ?? summary
            } else if let metaSummary = result.metadata?["summary"] {
                event.resultSummary = metaSummary
            } else {
                event.resultSummary = "Completed"
            }
            ToolEventBus.shared.publish(event)
            return result
        } catch {
            let duration = Int(Date().timeIntervalSince(start) * 1000)
            event.status = .error
            event.durationMs = duration
            event.errorMessage = error.localizedDescription
            ToolEventBus.shared.publish(event)
            throw error
        }
    }
    
    public func listAllTools() -> [ToolCallable] {
        return Array(tools.values)
    }
}
