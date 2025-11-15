# Prism — AI-Powered iPad IDE

A production-grade, Swift-only iPad IDE with AI-assisted coding, real-time collaboration, and 100+ tool-call actions.

## Features

### AI Modes
- **Assistant Mode**: Helpful suggestions and code explanations
- **Agent Mode**: Autonomous multi-step workflows (Pro subscription)
- **Chat Mode**: Natural dialogue and problem-solving

### Tool System (100+ Actions)
- **Git**: init, clone, status, add, commit, push, pull, branch, checkout, merge, rebase, log, diff, stash, tag, remote, reset, revert, cherry-pick, blame
- **File Operations**: read, write, delete, move, copy, list, search, mkdir, rmdir, info, permissions, watch
- **Shell**: exec, pipe, env, kill
- **LSP**: initialize, shutdown, definition, references, hover, completion, diagnostics, format, rename, symbols, code-action
- **Build**: Swift, Xcode, Make, clean, archive
- **Test**: discover, run, run-single, coverage, parse-results
- **Debug**: start, attach, stop, breakpoint, continue, step-over, step-into, step-out, evaluate, stack-trace, variables
- **Snapshot**: create, restore, list, delete, diff
- **Context**: refresh, search, timeline
- **Memory**: store, recall, delete
- **AI Helpers**: stream-message, generate-code, explain-code, refactor, fix-bug, generate-tests, optimize, document-code

### Context Engine
- **Real-time Indexing**: SourceKit-powered symbol extraction with SQLite persistence
- **Timeline Tracking**: File and symbol modification history
- **Memory Layer**: AI remembers patterns and preferences per user

### Security
- All API keys stored in iOS Keychain
- Destructive actions require explicit user consent
- Audit logging for compliance
- Sandboxed file operations

### Subscriptions (Stripe)
- **Free**: 10K tokens/month, Assistant mode, basic tools
- **Pro**: 1M tokens/month, Agent mode, all tools, priority support ($20/mo)
- **Team**: 5M tokens/month, team collaboration, shared context ($50/mo)

### Authentication (Firebase)
- Email/Password
- Google Sign-In
- Apple Sign-In

## Build Instructions

### Prerequisites
- macOS 14+ with Xcode 15+
- Active Apple Developer account
- Firebase project (for Auth/Firestore)
- Stripe account (for payments)

### One-Line Build
```bash
git clone <repo-url> && cd Prism && swift build
```

### Xcode
```bash
open Package.swift
# Select iPad target, Product → Run
```

### Configuration
1. Add `GoogleService-Info.plist` to `Sources/App/`
2. Set Stripe publishable key in app settings
3. Configure Firebase Cloud Functions for webhook handling

## Architecture

```
Prism/
├── AI/                    OpenAI/Anthropic/Vertex providers, token management
├── ContextEngine/         SQLite-backed indexer, timeline, memory layer
├── ToolKit/               100+ ToolCallable implementations, registry
├── UI/                    SwiftUI chat, inline overlay, mode selector, auth
├── Services/              Orchestrator (DAG execution), Developer, Security
└── Models/                Codable data types
```

### Key Components

**ToolRegistry**: Maps every `ToolID` enum case to its concrete `ToolCallable` implementation. All tools execute real binaries via `Process`.

**Orchestrator**: Manages multi-step agent workflows with dependency resolution and rollback support via snapshots.

**StreamingClient**: Injects system prompt, streams AI responses, and tracks token usage against subscription limits.

**SecurityService**: Enforces permission gates (default-deny for destructive actions) and maintains audit logs.

## Testing

```bash
swift test                          # Unit tests
xcodebuild test -scheme PrismUITests # UI tests
```

## Screenshots

![Chat Panel](docs/chat.png)  
![Inline Chat](docs/inline.png)  
![Mode Selector](docs/modes.png)

## License

MIT

## Contributing

PRs welcome. Please ensure all tests pass and code follows Swift API Design Guidelines.

## Support

- Documentation: [docs.prism.dev](https://docs.prism.dev)
- Community: [discord.gg/prism](https://discord.gg/prism)
- Email: support@prism.dev
