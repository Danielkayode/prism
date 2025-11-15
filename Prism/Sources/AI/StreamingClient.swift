import Foundation

public class StreamingClient {
    private let provider: AIProvider
    private let tokenManager: TokenManager
    
    public init(provider: AIProvider, tokenManager: TokenManager = TokenManager()) {
        self.provider = provider
        self.tokenManager = tokenManager
    }
    
    public func chat(sessionID: String, mode: AIMode, messages: [AIMessage]) async throws -> AsyncThrowingStream<String, Error> {
        var fullMessages = [AIMessage]()
        
        fullMessages.append(AIMessage(role: "system", content: SystemPrompt.text))
        fullMessages.append(AIMessage(role: "system", content: mode.systemPromptSuffix))
        fullMessages.append(contentsOf: messages)
        
        let inputTokens = fullMessages.map { provider.countTokens($0.content) }.reduce(0, +)
        
        return AsyncThrowingStream { continuation in
            Task {
                do {
                    var accumulatedOutput = ""
                    
                    let stream = try await provider.sendMessage(fullMessages, stream: true)
                    
                    for try await chunk in stream {
                        accumulatedOutput += chunk
                        continuation.yield(chunk)
                    }
                    
                    let outputTokens = provider.countTokens(accumulatedOutput)
                    tokenManager.recordUsage(sessionID: sessionID, input: inputTokens, output: outputTokens)
                    
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    public func getUsage(sessionID: String) -> TokenManager.Usage {
        return tokenManager.getUsage(for: sessionID)
    }
}
