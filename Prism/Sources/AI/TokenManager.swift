import Foundation

public class TokenManager {
    public struct Usage {
        public var inputTokens: Int
        public var outputTokens: Int
        public var totalTokens: Int { inputTokens + outputTokens }
        
        public init(inputTokens: Int = 0, outputTokens: Int = 0) {
            self.inputTokens = inputTokens
            self.outputTokens = outputTokens
        }
    }
    
    private var sessionUsage: [String: Usage] = [:]
    private let limits: [String: Int]
    
    public init(limits: [String: Int] = ["free": 10000, "pro": 1000000, "team": 5000000]) {
        self.limits = limits
    }
    
    public func recordUsage(sessionID: String, input: Int, output: Int) {
        if var usage = sessionUsage[sessionID] {
            usage.inputTokens += input
            usage.outputTokens += output
            sessionUsage[sessionID] = usage
        } else {
            sessionUsage[sessionID] = Usage(inputTokens: input, outputTokens: output)
        }
    }
    
    public func getUsage(for sessionID: String) -> Usage {
        return sessionUsage[sessionID] ?? Usage()
    }
    
    public func checkLimit(sessionID: String, plan: String) -> Bool {
        guard let limit = limits[plan] else { return false }
        let usage = getUsage(for: sessionID)
        return usage.totalTokens < limit
    }
    
    public func resetSession(_ sessionID: String) {
        sessionUsage.removeValue(forKey: sessionID)
    }
    
    public func getAllUsage() -> [String: Usage] {
        return sessionUsage
    }
}
