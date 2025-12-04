import SwiftUI
import Combine
import FirebaseAuth

public enum AIModel: String, CaseIterable, Identifiable {
    case gpt5 = "GPT-5"
    case gemini25Pro = "Gemini 2.5 Pro"
    case claudeOpus41 = "Claude Opus 4.1"
    case claudeSonnet45 = "Claude Sonnet 4.5"
    
    public var id: String { rawValue }
    
    public var displayName: String { rawValue }
}

public struct ChatPanelView: View {
    @EnvironmentObject var subscription: SubscriptionService
    @State private var messages: [ChatMessage] = []
    @State private var inputText: String = ""
    @State private var isStreaming: Bool = false
    @State private var selectedModel: AIModel = .gpt5
    @State private var selectedMode: AIMode = .chat
    @State private var contextAttached: Bool = false
    @State private var toolEvents: [ToolEvent] = []
    @State private var showContextDrawer: Bool = false
    @State private var tokenUsage: TokenManager.Usage = .init()
    @State private var showLimitModal: Bool = false
    @State private var apiKeys: [String: String] = [:]
    
    private let sessionID = UUID().uuidString
    private var tokenManager = TokenManager()
    @State private var cancellables: Set<AnyCancellable> = []
    
    public init() {}
    
    public var body: some View {
        ZStack {
            LinearGradient(colors: [PrismTheme.background, PrismTheme.background.opacity(0.95)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            HStack(spacing: 0) {
                VStack(spacing: 0) {
                // Header
                HStack(spacing: 12) {
                    Text("Prism AI")
                        .font(.title3).bold()
                        .foregroundStyle(PrismTheme.primaryGradient)
                    
                    Menu {
                        ForEach(AIMode.allCases, id: \.self) { mode in
                            Button(mode.displayName) { selectedMode = mode }
                        }
                    } label: {
                        HStack { Text(selectedMode.displayName); Image(systemName: "chevron.down") }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(PrismTheme.card)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                    
                    Menu {
                        ForEach(AIModel.allCases) { model in
                            Button(model.displayName) { selectedModel = model }
                        }
                    } label: {
                        HStack { ModelBadge(selectedModel.displayName) }
                    }
                    
                    Spacer()
                    
                    Button(action: { showContextDrawer.toggle() }) {
                        HStack {
                            Image(systemName: showContextDrawer ? "brain.head.profile" : "brain")
                            Text("Context")
                        }
                        .foregroundColor(showContextDrawer ? .purple : .primary)
                    }
                }
                .padding()
                .background(PrismTheme.headerGradient.opacity(0.15))
                .overlay(Divider().background(Color.white.opacity(0.06)), alignment: .bottom)
                
                
                Divider()
                
                // Messages ScrollView
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(messages) { message in
                            MessageBubbleView(message: message)
                        }
                        // Inline tool call inserts
                        ForEach(toolEvents) { ev in
                            if ev.userVisible {
                                ToolCallView(event: ev)
                            }
                        }
                    }
                    .padding()
                }
                
                Divider()
                
                // Input Field
                HStack(spacing: 8) {
                    TextField(selectedMode == .chat ? "Ask Prism…" : "Command the agent…", text: $inputText)
                        .padding(10)
                        .background(PrismTheme.card)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .disabled(isStreaming)
                    Button(action: sendMessage) { Image(systemName: "paperplane.fill").bold() }
                        .buttonStyle(PrismButtonStyle(.primary))
                        .disabled(inputText.isEmpty || isStreaming)
                }
                .padding()
                
            }
            if showContextDrawer {
                Divider()
                ContextDrawerView(tokenUsage: tokenUsage, toolEvents: toolEvents, onResetMemory: {
                    tokenManager.resetSession(sessionID)
                    tokenUsage = .init()
                })
                    .frame(width: 320)
            }
        }
        .onAppear(perform: setupSubscriptions)
        .sheet(isPresented: $showLimitModal) {
            VStack(spacing: 12) {
                Text("You’ve reached your daily free chat limit.")
                    .font(.headline)
                Text("Upgrade to Prism Pro for unlimited messages and full tool access.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                HStack {
                    Button("Remind Me Later") { showLimitModal = false }
                    Spacer()
                    Button("Upgrade with Stripe") {
                        showLimitModal = false
                        SubscriptionService.shared.subscribe(plan: .pro)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
            .frame(width: 420)
        }
    }
    
    private func setupSubscriptions() {
        ToolEventBus.shared.publisher
            .receive(on: RunLoop.main)
            .sink { event in
                toolEvents.insert(event, at: 0)
            }
            .store(in: &cancellables)
    }
    
    private func sendMessage() {
        // Enforce simple free tier limits
        if subscription.subscriptionTier == "free" && (messages.count >= 50 || tokenUsage.totalTokens >= 10000) {
            showLimitModal = true
            return
        }
        let userMessage = ChatMessage(role: "user", content: inputText)
        messages.append(userMessage)
        let prompt = inputText
        inputText = ""
        isStreaming = true
        
        Task {
            await chat(prompt: prompt)
            isStreaming = false
        }
    }
    
    private func chat(prompt: String) async {
        let providerName: String
        switch selectedModel {
        case .gpt5:
            providerName = "openai"
        case .gemini25Pro:
            providerName = "google"
        case .claudeOpus41, .claudeSonnet45:
            providerName = "anthropic"
        }

        let history = messages.map { AIMessage(role: $0.role, content: $0.content) }
        let requestBody: [String: Any] = [
            "messages": history + [AIMessage(role: "user", content: prompt)],
            "model": selectedModel.rawValue,
            "stream": true
        ]

        do {
            let stream = try await AIService.shared.secureAICall(provider: providerName, body: requestBody)
            var response = ""
            for try await line in stream.lines {
                if line.hasPrefix("data: "), let data = line.dropFirst(6).data(using: .utf8) {
                    // This is a simplified parser for SSE. A real implementation would be more robust.
                    if let chunk = String(data: data, encoding: .utf8) {
                        response += chunk
                        let temp = ChatMessage(role: "assistant", content: response)
                        await MainActor.run {
                            if let lastIndex = messages.lastIndex(where: { $0.role == "assistant" }) {
                                messages[lastIndex] = temp
                            } else {
                                messages.append(temp)
                            }
                        }
                    }
                }
            }
        } catch {
            await MainActor.run {
                messages.append(ChatMessage(role: "assistant", content: "Error: \(error.localizedDescription)"))
            }
        }
    }
}

struct MessageBubbleView: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.role == "user" {
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(message.content)
                    .padding()
                    .background(message.role == "user" ? Color.blue : Color.gray.opacity(0.3))
                    .foregroundColor(message.role == "user" ? .white : .primary)
                    .cornerRadius(12)
                
                Text(message.timestamp, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if message.role != "user" {
                Spacer()
            }
        }
    }
}

struct ContextDrawerView: View {
    let tokenUsage: TokenManager.Usage
    let toolEvents: [ToolEvent]
    var onResetMemory: (() -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Awareness")
                .font(.headline)
                .foregroundStyle(PrismTheme.primaryGradient)
            
            // Token usage bar
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Tokens: \(tokenUsage.totalTokens) / 80,000")
                        .font(.subheadline)
                    Spacer()
                    Button("Reset Memory") { onResetMemory?() }
                        .buttonStyle(PrismButtonStyle(.secondary))
                }
                ProgressView(value: min(Float(tokenUsage.totalTokens) / 80000.0, 1.0))
                    .tint(PrismTheme.accent)
            }
            .glassCard()
            
            TodoListView()
                .glassCard()
            
            Text("Recent tool calls")
                .font(.headline)
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(toolEvents.prefix(20)) { ev in
                        ToolCallView(event: ev)
                    }
                }
            }
            Spacer()
        }
        .padding()
        .background(PrismTheme.background.opacity(0.01))
    }
}
