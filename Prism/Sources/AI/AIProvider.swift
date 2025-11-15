import Foundation

public enum AIProviderType: String, Codable, CaseIterable {
    case openai
    case anthropic
    case googleVertex
}

public struct AIMessage: Codable {
    public let role: String
    public let content: String
    
    public init(role: String, content: String) {
        self.role = role
        self.content = content
    }
}

public protocol AIProvider {
    func sendMessage(_ messages: [AIMessage], stream: Bool) async throws -> AsyncThrowingStream<String, Error>
    func countTokens(_ text: String) -> Int
}

public class OpenAIProvider: AIProvider {
    private let apiKey: String
    private let model: String
    
    public init(apiKey: String, model: String = "gpt-5") {
        self.apiKey = apiKey
        self.model = model
    }
    
    public func sendMessage(_ messages: [AIMessage], stream: Bool) async throws -> AsyncThrowingStream<String, Error> {
        return AsyncThrowingStream { continuation in
            Task {
                do {
                    var request = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
                    request.httpMethod = "POST"
                    request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    
                    let body: [String: Any] = [
                        "model": model,
                        "messages": messages.map { ["role": $0.role, "content": $0.content] },
                        "stream": stream
                    ]
                    
                    request.httpBody = try JSONSerialization.data(withJSONObject: body)
                    
                    let (data, _) = try await URLSession.shared.data(for: request)
                    
                    if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let choices = json["choices"] as? [[String: Any]],
                       let firstChoice = choices.first,
                       let message = firstChoice["message"] as? [String: Any],
                       let content = message["content"] as? String {
                        continuation.yield(content)
                    }
                    
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    public func countTokens(_ text: String) -> Int {
        return text.split(separator: " ").count
    }
}

public class AnthropicProvider: AIProvider {
    private let apiKey: String
    private let model: String
    
    public init(apiKey: String, model: String = "claude-opus-4.1") {
        self.apiKey = apiKey
        self.model = model
    }
    
    public func sendMessage(_ messages: [AIMessage], stream: Bool) async throws -> AsyncThrowingStream<String, Error> {
        return AsyncThrowingStream { continuation in
            Task {
                do {
                    var request = URLRequest(url: URL(string: "https://api.anthropic.com/v1/messages")!)
                    request.httpMethod = "POST"
                    request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
                    
                    let body: [String: Any] = [
                        "model": model,
                        "messages": messages.map { ["role": $0.role, "content": $0.content] },
                        "max_tokens": 4096,
                        "stream": stream
                    ]
                    
                    request.httpBody = try JSONSerialization.data(withJSONObject: body)
                    
                    let (data, _) = try await URLSession.shared.data(for: request)
                    
                    if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let content = json["content"] as? [[String: Any]],
                       let firstContent = content.first,
                       let text = firstContent["text"] as? String {
                        continuation.yield(text)
                    }
                    
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    public func countTokens(_ text: String) -> Int {
        return text.split(separator: " ").count
    }
}

public class GoogleVertexProvider: AIProvider {
    private let apiKey: String
    private let model: String
    
    public init(apiKey: String, model: String = "gemini-2.5-pro") {
        self.apiKey = apiKey
        self.model = model
    }
    
    public func sendMessage(_ messages: [AIMessage], stream: Bool) async throws -> AsyncThrowingStream<String, Error> {
        return AsyncThrowingStream { continuation in
            Task {
                do {
                    var request = URLRequest(url: URL(string: "https://generativelanguage.googleapis.com/v1beta/models/\(model):generateContent?key=\(apiKey)")!)
                    request.httpMethod = "POST"
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    
                    let body: [String: Any] = [
                        "contents": messages.map { ["role": $0.role, "parts": [["text": $0.content]]] }
                    ]
                    
                    request.httpBody = try JSONSerialization.data(withJSONObject: body)
                    
                    let (data, _) = try await URLSession.shared.data(for: request)
                    
                    if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let candidates = json["candidates"] as? [[String: Any]],
                       let firstCandidate = candidates.first,
                       let content = firstCandidate["content"] as? [String: Any],
                       let parts = content["parts"] as? [[String: Any]],
                       let firstPart = parts.first,
                       let text = firstPart["text"] as? String {
                        continuation.yield(text)
                    }
                    
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    public func countTokens(_ text: String) -> Int {
        return text.split(separator: " ").count
    }
}

public class ClaudeSonnetProvider: AIProvider {
    private let apiKey: String
    private let model: String
    
    public init(apiKey: String, model: String = "claude-sonnet-4.5") {
        self.apiKey = apiKey
        self.model = model
    }
    
    public func sendMessage(_ messages: [AIMessage], stream: Bool) async throws -> AsyncThrowingStream<String, Error> {
        return AsyncThrowingStream { continuation in
            Task {
                do {
                    var request = URLRequest(url: URL(string: "https://api.anthropic.com/v1/messages")!)
                    request.httpMethod = "POST"
                    request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
                    
                    let body: [String: Any] = [
                        "model": model,
                        "messages": messages.map { ["role": $0.role, "content": $0.content] },
                        "max_tokens": 4096,
                        "stream": stream
                    ]
                    
                    request.httpBody = try JSONSerialization.data(withJSONObject: body)
                    
                    let (data, _) = try await URLSession.shared.data(for: request)
                    
                    if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let content = json["content"] as? [[String: Any]],
                       let firstContent = content.first,
                       let text = firstContent["text"] as? String {
                        continuation.yield(text)
                    }
                    
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    public func countTokens(_ text: String) -> Int {
        return text.split(separator: " ").count
    }
}
