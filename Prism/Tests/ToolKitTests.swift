import XCTest
@testable import Prism

final class ToolKitTests: XCTestCase {
    func testToolRegistry() {
        let registry = ToolRegistry.shared
        let allTools = registry.listAllTools()
        
        XCTAssertGreaterThan(allTools.count, 80)
        
        let gitStatusTool = registry.getTool(for: .gitStatus)
        XCTAssertNotNil(gitStatusTool)
        XCTAssertEqual(gitStatusTool?.toolID, .gitStatus)
    }
    
    func testFileReadTool() async throws {
        let tempFile = NSTemporaryDirectory() + "test_\(UUID().uuidString).txt"
        let content = "Test content"
        try content.write(toFile: tempFile, atomically: true, encoding: .utf8)
        
        defer {
            try? FileManager.default.removeItem(atPath: tempFile)
        }
        
        let tool = FileReadTool()
        let result = try await tool.execute(parameters: ["path": tempFile])
        
        XCTAssertTrue(result.success)
        XCTAssertEqual(result.output, content)
    }
    
    func testGitToolIsDestructive() {
        XCTAssertTrue(ToolID.gitPush.isDestructive)
        XCTAssertFalse(ToolID.gitStatus.isDestructive)
    }
}
