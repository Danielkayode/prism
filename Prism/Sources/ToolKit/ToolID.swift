import Foundation

public enum ToolID: String, Codable, CaseIterable {
    case gitInit = "git_init"
    case gitClone = "git_clone"
    case gitStatus = "git_status"
    case gitAdd = "git_add"
    case gitCommit = "git_commit"
    case gitPush = "git_push"
    case gitPull = "git_pull"
    case gitBranch = "git_branch"
    case gitCheckout = "git_checkout"
    case gitMerge = "git_merge"
    case gitRebase = "git_rebase"
    case gitLog = "git_log"
    case gitDiff = "git_diff"
    case gitStash = "git_stash"
    case gitTag = "git_tag"
    case gitRemote = "git_remote"
    case gitReset = "git_reset"
    case gitRevert = "git_revert"
    case gitCherryPick = "git_cherry_pick"
    case gitBlame = "git_blame"
    
    case fileRead = "file_read"
    case fileWrite = "file_write"
    case fileDelete = "file_delete"
    case fileMove = "file_move"
    case fileCopy = "file_copy"
    case fileList = "file_list"
    case fileSearch = "file_search"
    case fileCreateDir = "file_create_dir"
    case fileRemoveDir = "file_remove_dir"
    case fileGetInfo = "file_get_info"
    case fileSetPermissions = "file_set_permissions"
    case fileWatch = "file_watch"
    
    case shellExec = "shell_exec"
    case shellPipe = "shell_pipe"
    case shellEnv = "shell_env"
    case shellKill = "shell_kill"
    
    case lspInitialize = "lsp_initialize"
    case lspShutdown = "lsp_shutdown"
    case lspDefinition = "lsp_definition"
    case lspReferences = "lsp_references"
    case lspHover = "lsp_hover"
    case lspCompletion = "lsp_completion"
    case lspDiagnostics = "lsp_diagnostics"
    case lspFormat = "lsp_format"
    case lspRename = "lsp_rename"
    case lspSymbols = "lsp_symbols"
    case lspCodeAction = "lsp_code_action"
    
    case buildSwift = "build_swift"
    case buildXcode = "build_xcode"
    case buildMake = "build_make"
    case buildClean = "build_clean"
    case buildArchive = "build_archive"
    
    case testDiscover = "test_discover"
    case testRun = "test_run"
    case testRunSingle = "test_run_single"
    case testCoverage = "test_coverage"
    case testParseResults = "test_parse_results"
    
    case debugStart = "debug_start"
    case debugAttach = "debug_attach"
    case debugStop = "debug_stop"
    case debugBreakpoint = "debug_breakpoint"
    case debugContinue = "debug_continue"
    case debugStepOver = "debug_step_over"
    case debugStepInto = "debug_step_into"
    case debugStepOut = "debug_step_out"
    case debugEvaluate = "debug_evaluate"
    case debugStackTrace = "debug_stack_trace"
    case debugVariables = "debug_variables"
    
    case snapshotCreate = "snapshot_create"
    case snapshotRestore = "snapshot_restore"
    case snapshotList = "snapshot_list"
    case snapshotDelete = "snapshot_delete"
    case snapshotDiff = "snapshot_diff"
    
    case contextRefresh = "context_refresh"
    case contextSearch = "context_search"
    case contextTimeline = "context_timeline"
    case memoryStore = "memory_store"
    case memoryRecall = "memory_recall"
    case memoryDelete = "memory_delete"
    
    case aiStreamMessage = "ai_stream_message"
    case aiGenerateCode = "ai_generate_code"
    case aiExplainCode = "ai_explain_code"
    case aiRefactor = "ai_refactor"
    case aiFixBug = "ai_fix_bug"
    case aiGenerateTests = "ai_generate_tests"
    case aiOptimize = "ai_optimize"
    case aiDocumentCode = "ai_document_code"
    
    // Lint Tools
    case lintRun = "lint_run"
    case lintFix = "lint_fix"
    case securityScan = "security_scan"
    case lintConfigure = "lint_configure"
    
    // Code Quality Tools
    case coverageReport = "coverage_report"
    case staticAnalysis = "static_analysis"
    case cyclomaticComplexity = "cyclomatic_complexity"
    case codeDuplication = "code_duplication"
    case codeMetrics = "code_metrics"
    case codeReviewAuto = "code_review_auto"
    case codeSmells = "code_smells"
    
    // Performance Tools
    case benchmarkRun = "benchmark_run"
    case profileRun = "profile_run"
    case memoryProfile = "memory_profile"
    case cpuProfile = "cpu_profile"
    
    // Security Tools
    case secretsDetect = "secrets_detect"
    case dependencyAudit = "dependency_audit"
    case listDependencies = "list_dependencies"
    
    // Collaboration Tools
    case activeUsers = "active_users"
    case shareProject = "share_project"
    case resolveConflict = "resolve_conflict"
    case sessionInvite = "session_invite"
    case liveCursors = "live_cursors"
    case remotePairing = "remote_pairing"
    case commentThread = "comment_thread"
    case taskAssign = "task_assign"
    case changeRequest = "change_request"
    
    // Package Manager Tools
    case packageSearch = "package_search"
    case packageUpdate = "package_update"
    case packageLock = "package_lock"
    case packageAudit = "package_audit"
    case packageInfo = "package_info"
    
    // Visualization Tools
    case generateFlowchart = "generate_flowchart"
    case generateSequenceDiagram = "generate_sequence_diagram"
    case generateClassDiagram = "generate_class_diagram"
    case generateDependencyGraph = "generate_dependency_graph"
    case generateHeatmap = "generate_heatmap"
    
    // Migration Tools
    case migratePython3 = "migrate_python3"
    case migrateSwift6 = "migrate_swift6"
    case upgradeDependencies = "upgrade_dependencies"
    case migrateNode = "migrate_node"
    case migrateJava = "migrate_java"
    case migrateUIFramework = "migrate_ui_framework"
    
    // UI Automation Tools
    case uiRunTest = "ui_run_test"
    case uiRecordMacro = "ui_record_macro"
    case uiPlayMacro = "ui_play_macro"
    case uiScreenshot = "ui_screenshot"
    case uiVideoRecord = "ui_video_record"
    
    // Accessibility Tools
    case accessibilityScan = "accessibility_scan"
    case altTextSuggest = "alt_text_suggest"
    case contrastCheck = "contrast_check"
    case voiceoverCheck = "voiceover_check"
    
    // Notification Tools
    case notifySuccess = "notify_success"
    case notifyError = "notify_error"
    case notifyAlert = "notify_alert"
    case notifyTaskDone = "notify_task_done"
    
    // Workspace Tools
    case workspaceSync = "workspace_sync"
    case workspaceClone = "workspace_clone"
    case workspaceFork = "workspace_fork"
    case workspaceMerge = "workspace_merge"
    case workspaceClean = "workspace_clean"
    case workspaceStatus = "workspace_status"
    
    // Version Tools
    case versionCheck = "version_check"
    case versionBump = "version_bump"
    case versionTag = "version_tag"
    case versionPublish = "version_publish"
    
    // Terminal Tools
    case terminalFocus = "terminal_focus"
    case terminalResize = "terminal_resize"
    case terminalClear = "terminal_clear"
    case terminalSetEnv = "terminal_set_env"
    
    // Settings Tools
    case settingsExport = "settings_export"
    case settingsImport = "settings_import"
    case settingsReset = "settings_reset"
    case settingsApplyProfile = "settings_apply_profile"
    
    // Extension Tools
    case extensionList = "extension_list"
    case extensionInstall = "extension_install"
    case extensionRemove = "extension_remove"
    case extensionUpdate = "extension_update"
    
    // Theme Tools
    case themeSwitch = "theme_switch"
    case themeCustomize = "theme_customize"
    case themePreview = "theme_preview"
    
    // Keyboard Shortcut Tools
    case shortcutList = "shortcut_list"
    case shortcutCustomize = "shortcut_customize"
    case shortcutReset = "shortcut_reset"
    
    // Cloud Tools
    case dockerBuild = "docker_build"
    case dockerRun = "docker_run"
    case deployAws = "deploy_aws"
    case deployGcp = "deploy_gcp"
    case deployAzure = "deploy_azure"
    case cloudLogin = "cloud_login"
    case cloudLogs = "cloud_logs"
    
    // Doc Tools
    case docGenerate = "doc_generate"
    case readmeToc = "readme_toc"
    case docSearch = "doc_search"
    case docUpdate = "doc_update"
    case docPublish = "doc_publish"
    
    public var isDestructive: Bool {
        switch self {
        case .gitPush, .gitReset, .gitRevert, .gitMerge, .gitRebase,
             .fileWrite, .fileDelete, .fileMove, .fileRemoveDir,
             .shellExec, .shellKill,
             .buildClean, .snapshotRestore, .snapshotDelete,
             .lintFix, .extensionInstall, .extensionRemove, .extensionUpdate,
             .settingsReset, .settingsApplyProfile,
             .dockerBuild, .dockerRun, .deployAws, .deployGcp, .deployAzure,
             .packageUpdate, .upgradeDependencies,
             .migrateSwift6, .migratePython3, .migrateNode, .migrateJava, .migrateUIFramework,
             .workspaceClean, .workspaceMerge,
             .versionBump, .versionTag, .versionPublish,
             .terminalClear, .terminalSetEnv:
            return true
        default:
            return false
        }
    }
    
    public var requiresUserConsent: Bool {
        return isDestructive
    }
}
