import Foundation
import FirebaseAuth

public struct AIProviderConfig: Codable {
    let apiKey: String
}

public class AIService {
    public static let shared = AIService()
    private var apiKeys: [String: String] = [:]

    private init() {}

    public func secureAICall(provider: String, body: [String: Any]) async throws -> URLSession.AsyncBytes {
        guard let user = Auth.auth().currentUser else {
            throw AIServiceError.notAuthenticated
        }

        let idToken = try await user.getIDToken()
        guard let base = Bundle.main.infoDictionary?["PRISM_BACKEND_URL"] as? String,
              let url = URL(string: base + "/secureAICall") else {
            throw AIServiceError.backendNotConfigured
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")

        var requestBody = body
        requestBody["provider"] = provider

        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)

        let (stream, response) = try await URLSession.shared.bytes(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw AIServiceError.badResponse(response)
        }
        return stream
    }
}

public enum AIServiceError: Error {
    case notAuthenticated
    case backendNotConfigured
    case badResponse(URLResponse)
}
