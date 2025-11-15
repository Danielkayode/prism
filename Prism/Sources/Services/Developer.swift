import Foundation

public class DeveloperService {
    private let registry = ToolRegistry.shared
    
    public init() {}
    
    public func gitStatus(at path: String) async throws -> String {
        let result = try await registry.execute(toolID: .gitStatus, parameters: ["path": path])
        return result.output ?? ""
    }
    
    public func buildProject(at path: String, type: String = "swift") async throws -> String {
        let toolID: ToolID = type == "xcode" ? .buildXcode : .buildSwift
        let result = try await registry.execute(toolID: toolID, parameters: ["projectPath": path])
        return result.output ?? ""
    }
    
    public func runTests(at path: String) async throws -> String {
        let result = try await registry.execute(toolID: .testRun, parameters: ["projectPath": path])
        return result.output ?? ""
    }
    
    public func readFile(at path: String) async throws -> String {
        let result = try await registry.execute(toolID: .fileRead, parameters: ["path": path])
        return result.output ?? ""
    }
    
    public func writeFile(at path: String, content: String) async throws {
        _ = try await registry.execute(toolID: .fileWrite, parameters: ["path": path, "content": content])
    }
}
