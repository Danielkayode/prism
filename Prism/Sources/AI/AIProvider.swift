import Foundation

public protocol AIProvider {
    func generateContent(prompt: String, model: String) -> AsyncThrowingStream<String, Error>
}

public class SecureAIProvider: AIProvider {
    private let backendURL: URL
    private let authToken: String

    public init(backendURL: URL, authToken: String) {
        self.backendURL = backendURL
        self.authToken = authToken
    }

    public func generateContent(prompt: String, model: String) -> AsyncThrowingStream<String, Error> {
        return AsyncThrowingStream { continuation in
            Task {
                var request = URLRequest(url: backendURL.appendingPathComponent("secureAICall"))
                request.httpMethod = "POST"
                request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")

                let body: [String: Any] = [
                    "provider": modelToProvider(model),
                    "body": [
                        "prompt": prompt,
                        "model": model,
                        "stream": true
                    ]
                ]
                request.httpBody = try JSONSerialization.data(withJSONObject: body)

                let (data, response) = try await URLSession.shared.bytes(for: request)

                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    continuation.finish(throwing: NSError(domain: "AIProviderError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch content from backend"]))
                    return
                }

                for try await line in data.lines {
                    continuation.yield(line)
                }
                continuation.finish()
            }
        }
    }

    private func modelToProvider(_ model: String) -> String {
        if model.starts(with: "gpt") {
            return "openai"
        } else if model.starts(with: "gemini") {
            return "google"
        } else if model.starts(with: "claude") {
            return "anthropic"
        }
        return "openai"
    }
}
