import Foundation

public enum AIUserDefaults {
    // Registration
    public static func registerDefaults() {
        guard let url = Bundle.main.url(forResource: "Root", withExtension: "plist", subdirectory: "Settings.bundle"),
              let data = try? Data(contentsOf: url),
              let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
              let specs = plist["PreferenceSpecifiers"] as? [[String: Any]]
        else { return }
        var defaults: [String: Any] = [:]
        for item in specs {
            if let key = item["Key"] as? String, let def = item["DefaultValue"] {
                defaults[key] = def
            }
        }
        UserDefaults.standard.register(defaults: defaults)
    }

    // 1. AI / Model
    public static var aiModelDefault: String { get { UserDefaults.standard.string(forKey: "ai_model_default") ?? "gpt-5" } set { UserDefaults.standard.set(newValue, forKey: "ai_model_default") } }
    public static var aiStreamingEnabled: Bool { get { UserDefaults.standard.bool(forKey: "ai_streaming_enabled") } set { UserDefaults.standard.set(newValue, forKey: "ai_streaming_enabled") } }
    public static var aiMaxTokens: Int { get { max(0, Int(UserDefaults.standard.double(forKey: "ai_max_tokens"))) } set { UserDefaults.standard.set(newValue, forKey: "ai_max_tokens") } }
    public static var aiTemperature: Double { get { UserDefaults.standard.double(forKey: "ai_temperature") } set { UserDefaults.standard.set(newValue, forKey: "ai_temperature") } }
    public static var aiTopP: Double { get { UserDefaults.standard.double(forKey: "ai_top_p") } set { UserDefaults.standard.set(newValue, forKey: "ai_top_p") } }
    public static var aiSystemPrompt: String { get { UserDefaults.standard.string(forKey: "ai_system_prompt") ?? "" } set { UserDefaults.standard.set(newValue, forKey: "ai_system_prompt") } }
    public static var aiAutoAttachContext: Bool { get { UserDefaults.standard.bool(forKey: "ai_auto_attach_context") } set { UserDefaults.standard.set(newValue, forKey: "ai_auto_attach_context") } }
    public static var aiAutoGenerateTests: Bool { get { UserDefaults.standard.bool(forKey: "ai_auto_generate_tests") } set { UserDefaults.standard.set(newValue, forKey: "ai_auto_generate_tests") } }
    public static var aiAutoFormatCode: Bool { get { UserDefaults.standard.bool(forKey: "ai_auto_format_code") } set { UserDefaults.standard.set(newValue, forKey: "ai_auto_format_code") } }

    // 2. Context Engine
    public static var ctxIndexOnOpen: Bool { get { UserDefaults.standard.bool(forKey: "ctx_index_on_open") } set { UserDefaults.standard.set(newValue, forKey: "ctx_index_on_open") } }
    public static var ctxMaxFileSizeKB: Int { get { Int(UserDefaults.standard.string(forKey: "ctx_max_file_size_kb") ?? "512") ?? 512 } set { UserDefaults.standard.set("\(newValue)", forKey: "ctx_max_file_size_kb") } }
    public static var ctxSkipFolders: [String] { get { (UserDefaults.standard.string(forKey: "ctx_skip_folders") ?? "node_modules,.git,build").split(separator: ",").map{ $0.trimmingCharacters(in: .whitespaces) } } set { UserDefaults.standard.set(newValue.joined(separator: ","), forKey: "ctx_skip_folders") } }
    public static var ctxSymbolExtraction: Bool { get { UserDefaults.standard.bool(forKey: "ctx_symbol_extraction") } set { UserDefaults.standard.set(newValue, forKey: "ctx_symbol_extraction") } }
    public static var ctxSemanticRanking: Bool { get { UserDefaults.standard.bool(forKey: "ctx_semantic_ranking") } set { UserDefaults.standard.set(newValue, forKey: "ctx_semantic_ranking") } }

    // 3. Shell / Tool Security
    public static var shellEnabled: Bool { get { UserDefaults.standard.bool(forKey: "ai_shell_enabled") } set { UserDefaults.standard.set(newValue, forKey: "ai_shell_enabled") } }
    public static var shellWhitelist: [String] { get { (UserDefaults.standard.string(forKey: "ai_shell_whitelist") ?? "").split(separator: ",").map{ $0.trimmingCharacters(in: .whitespaces) } } set { UserDefaults.standard.set(newValue.joined(separator: ","), forKey: "ai_shell_whitelist") } }
    public static var shellBlacklist: [String] { get { (UserDefaults.standard.string(forKey: "ai_shell_blacklist") ?? "rm,sudo").split(separator: ",").map{ $0.trimmingCharacters(in: .whitespaces) } } set { UserDefaults.standard.set(newValue.joined(separator: ","), forKey: "ai_shell_blacklist") } }
    public static var shellConfirmDestructive: Bool { get { UserDefaults.standard.bool(forKey: "ai_shell_confirm_destructive") } set { UserDefaults.standard.set(newValue, forKey: "ai_shell_confirm_destructive") } }
    public static var shellMaxRuntime: Int { get { Int(UserDefaults.standard.string(forKey: "ai_shell_max_runtime") ?? "30") ?? 30 } set { UserDefaults.standard.set("\(newValue)", forKey: "ai_shell_max_runtime") } }
    public static var shellMaxOutput: Int { get { Int(UserDefaults.standard.string(forKey: "ai_shell_max_output") ?? "2048") ?? 2048 } set { UserDefaults.standard.set("\(newValue)", forKey: "ai_shell_max_output") } }
    public static var shellNetworkAllowed: Bool { get { UserDefaults.standard.bool(forKey: "ai_shell_network_allowed") } set { UserDefaults.standard.set(newValue, forKey: "ai_shell_network_allowed") } }
    public static var dockerEnabled: Bool { get { UserDefaults.standard.bool(forKey: "ai_docker_enabled") } set { UserDefaults.standard.set(newValue, forKey: "ai_docker_enabled") } }
    public static var cloudDeployEnabled: Bool { get { UserDefaults.standard.bool(forKey: "ai_cloud_deploy_enabled") } set { UserDefaults.standard.set(newValue, forKey: "ai_cloud_deploy_enabled") } }

    // 4. Editor / UI
    public static var editorTabSize: Int { get { Int(UserDefaults.standard.string(forKey: "editor_tab_size") ?? "4") ?? 4 } set { UserDefaults.standard.set("\(newValue)", forKey: "editor_tab_size") } }
    public static var editorWrapLines: Bool { get { UserDefaults.standard.bool(forKey: "editor_wrap_lines") } set { UserDefaults.standard.set(newValue, forKey: "editor_wrap_lines") } }
    public static var editorShowInvisibles: Bool { get { UserDefaults.standard.bool(forKey: "editor_show_invisibles") } set { UserDefaults.standard.set(newValue, forKey: "editor_show_invisibles") } }
    public static var editorMinimapEnabled: Bool { get { UserDefaults.standard.bool(forKey: "editor_minimap_enabled") } set { UserDefaults.standard.set(newValue, forKey: "editor_minimap_enabled") } }
    public static var editorFontSize: Int { get { Int(UserDefaults.standard.string(forKey: "editor_font_size") ?? "15") ?? 15 } set { UserDefaults.standard.set("\(newValue)", forKey: "editor_font_size") } }
    public static var editorFontFamily: String { get { UserDefaults.standard.string(forKey: "editor_font_family") ?? "SF Mono" } set { UserDefaults.standard.set(newValue, forKey: "editor_font_family") } }
    public static var editorTheme: String { get { UserDefaults.standard.string(forKey: "editor_theme") ?? "prism-dark" } set { UserDefaults.standard.set(newValue, forKey: "editor_theme") } }
    public static var inlineSuggestEnabled: Bool { get { UserDefaults.standard.bool(forKey: "ai_inline_suggest_enabled") } set { UserDefaults.standard.set(newValue, forKey: "ai_inline_suggest_enabled") } }
    public static var inlineChatOnCmdK: Bool { get { UserDefaults.standard.bool(forKey: "ai_inline_chat_on_cmd_k") } set { UserDefaults.standard.set(newValue, forKey: "ai_inline_chat_on_cmd_k") } }

    // 5. Collaboration & Presence
    public static var collabEnabled: Bool { get { UserDefaults.standard.bool(forKey: "collab_enabled") } set { UserDefaults.standard.set(newValue, forKey: "collab_enabled") } }
    public static var collabShowCursors: Bool { get { UserDefaults.standard.bool(forKey: "collab_show_cursors") } set { UserDefaults.standard.set(newValue, forKey: "collab_show_cursors") } }
    public static var collabShowStatusBar: Bool { get { UserDefaults.standard.bool(forKey: "collab_show_status_bar") } set { UserDefaults.standard.set(newValue, forKey: "collab_show_status_bar") } }
    public static var collabAutoSave: Bool { get { UserDefaults.standard.bool(forKey: "collab_auto_save") } set { UserDefaults.standard.set(newValue, forKey: "collab_auto_save") } }
    public static var collabConflictStrategy: String { get { UserDefaults.standard.string(forKey: "collab_conflict_strategy") ?? "ask" } set { UserDefaults.standard.set(newValue, forKey: "collab_conflict_strategy") } }

    // 6. Debugger
    public static var debuggerEnabled: Bool { get { UserDefaults.standard.bool(forKey: "debugger_enabled") } set { UserDefaults.standard.set(newValue, forKey: "debugger_enabled") } }
    public static var debuggerStopOnEntry: Bool { get { UserDefaults.standard.bool(forKey: "debugger_stop_on_entry") } set { UserDefaults.standard.set(newValue, forKey: "debugger_stop_on_entry") } }
    public static var debuggerShowVariables: Bool { get { UserDefaults.standard.bool(forKey: "debugger_show_variables") } set { UserDefaults.standard.set(newValue, forKey: "debugger_show_variables") } }
    public static var debuggerMaxChildren: Int { get { Int(UserDefaults.standard.string(forKey: "debugger_max_children") ?? "100") ?? 100 } set { UserDefaults.standard.set("\(newValue)", forKey: "debugger_max_children") } }
    public static var debuggerConsoleFontSize: Int { get { Int(UserDefaults.standard.string(forKey: "debugger_console_font_size") ?? "13") ?? 13 } set { UserDefaults.standard.set("\(newValue)", forKey: "debugger_console_font_size") } }

    // 7. Git & VCS
    public static var gitAutoFetch: Bool { get { UserDefaults.standard.bool(forKey: "git_auto_fetch") } set { UserDefaults.standard.set(newValue, forKey: "git_auto_fetch") } }
    public static var gitAutoPull: Bool { get { UserDefaults.standard.bool(forKey: "git_auto_pull") } set { UserDefaults.standard.set(newValue, forKey: "git_auto_pull") } }
    public static var gitCommitSigning: Bool { get { UserDefaults.standard.bool(forKey: "git_commit_signing") } set { UserDefaults.standard.set(newValue, forKey: "git_commit_signing") } }
    public static var gitDefaultBranch: String { get { UserDefaults.standard.string(forKey: "git_default_branch") ?? "main" } set { UserDefaults.standard.set(newValue, forKey: "git_default_branch") } }
    public static var aiGenerateCommitMsg: Bool { get { UserDefaults.standard.bool(forKey: "ai_generate_commit_msg") } set { UserDefaults.standard.set(newValue, forKey: "ai_generate_commit_msg") } }
    public static var aiPrReviewEnabled: Bool { get { UserDefaults.standard.bool(forKey: "ai_pr_review_enabled") } set { UserDefaults.standard.set(newValue, forKey: "ai_pr_review_enabled") } }

    // 8. Keybindings
    public static var kbQuickChat: String { get { UserDefaults.standard.string(forKey: "kb_quick_chat") ?? "⌘K" } set { UserDefaults.standard.set(newValue, forKey: "kb_quick_chat") } }
    public static var kbRunTests: String { get { UserDefaults.standard.string(forKey: "kb_run_tests") ?? "⌘U" } set { UserDefaults.standard.set(newValue, forKey: "kb_run_tests") } }
    public static var kbFormatFile: String { get { UserDefaults.standard.string(forKey: "kb_format_file") ?? "⌘⇧F" } set { UserDefaults.standard.set(newValue, forKey: "kb_format_file") } }
    public static var kbAiRefactor: String { get { UserDefaults.standard.string(forKey: "kb_ai_refactor") ?? "⌘⌥R" } set { UserDefaults.standard.set(newValue, forKey: "kb_ai_refactor") } }

    // 9. Privacy / Telemetry
    public static var telemetryEnabled: Bool { get { UserDefaults.standard.bool(forKey: "telemetry_enabled") } set { UserDefaults.standard.set(newValue, forKey: "telemetry_enabled") } }
    public static var crashReportsEnabled: Bool { get { UserDefaults.standard.bool(forKey: "crash_reports_enabled") } set { UserDefaults.standard.set(newValue, forKey: "crash_reports_enabled") } }
    public static var aiPromptHistoryCloud: Bool { get { UserDefaults.standard.bool(forKey: "ai_prompt_history_cloud") } set { UserDefaults.standard.set(newValue, forKey: "ai_prompt_history_cloud") } }

    // 10. Developer / Debug
    public static var dbgLogLevel: String { get { UserDefaults.standard.string(forKey: "dbg_log_level") ?? "info" } set { UserDefaults.standard.set(newValue, forKey: "dbg_log_level") } }
    public static var dbgMockAI: Bool { get { UserDefaults.standard.bool(forKey: "dbg_mock_ai") } set { UserDefaults.standard.set(newValue, forKey: "dbg_mock_ai") } }
    public static var dbgBypassShellChecks: Bool { get { UserDefaults.standard.bool(forKey: "dbg_bypass_shell_checks") } set { UserDefaults.standard.set(newValue, forKey: "dbg_bypass_shell_checks") } }
    public static var dbgShowTokens: Bool { get { UserDefaults.standard.bool(forKey: "dbg_show_tokens") } set { UserDefaults.standard.set(newValue, forKey: "dbg_show_tokens") } }
    public static var dbgSlowRequests: Int { get { Int(UserDefaults.standard.string(forKey: "dbg_slow_requests") ?? "0") ?? 0 } set { UserDefaults.standard.set("\(newValue)", forKey: "dbg_slow_requests") } }
}
