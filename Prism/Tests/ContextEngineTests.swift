import XCTest
@testable import Prism

final class ContextEngineTests: XCTestCase {
    var tempDBPath: String!
    
    override func setUp() {
        super.setUp()
        tempDBPath = NSTemporaryDirectory() + "test_\(UUID().uuidString).db"
    }
    
    override func tearDown() {
        try? FileManager.default.removeItem(atPath: tempDBPath)
        super.tearDown()
    }
    
    func testContextIndexer() throws {
        let indexer = try ContextIndexer(databasePath: tempDBPath)
        let tempDir = NSTemporaryDirectory() + "test_project_\(UUID().uuidString)"
        try FileManager.default.createDirectory(atPath: tempDir, withIntermediateDirectories: true)
        
        let testFile = tempDir + "/Test.swift"
        try "func testFunction() {}\nclass TestClass {}".write(toFile: testFile, atomically: true, encoding: .utf8)
        
        try indexer.indexProject(at: tempDir)
        
        let results = try indexer.searchSymbols(query: "test")
        XCTAssertGreaterThan(results.count, 0)
        
        try FileManager.default.removeItem(atPath: tempDir)
    }
    
    func testContextTimeline() throws {
        let timeline = try ContextTimeline(databasePath: tempDBPath)
        
        try timeline.record(filePath: "/test.swift", symbolName: "testFunc", action: "modified")
        
        let entries = try timeline.getRecent(limit: 10)
        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(entries.first?.action, "modified")
    }
    
    func testMemoryLayer() throws {
        let memory = try MemoryLayer(databasePath: tempDBPath)
        
        try memory.remember(userID: "user1", key: "lastRefactor", value: "UseCase1")
        
        let value = try memory.recall(userID: "user1", key: "lastRefactor")
        XCTAssertEqual(value, "UseCase1")
        
        try memory.forget(userID: "user1", key: "lastRefactor")
        let deleted = try memory.recall(userID: "user1", key: "lastRefactor")
        XCTAssertNil(deleted)
    }
}
