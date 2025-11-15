import Foundation
import SQLite

public struct TimelineEntry: Codable {
    public let id: String
    public let timestamp: Date
    public let filePath: String
    public let symbolName: String?
    public let userAction: String
    public let metadata: String?
    
    public init(id: String, timestamp: Date, filePath: String, symbolName: String? = nil, userAction: String, metadata: String? = nil) {
        self.id = id
        self.timestamp = timestamp
        self.filePath = filePath
        self.symbolName = symbolName
        self.userAction = userAction
        self.metadata = metadata
    }
}

public class ContextTimeline {
    private let db: Connection
    private let timeline: Table
    
    private let id = Expression<String>("id")
    private let timestamp = Expression<Date>("timestamp")
    private let filePath = Expression<String>("filePath")
    private let symbolName = Expression<String?>("symbolName")
    private let userAction = Expression<String>("userAction")
    private let metadata = Expression<String?>("metadata")
    
    public init(databasePath: String) throws {
        db = try Connection(databasePath)
        timeline = Table("timeline")
        try createTables()
    }
    
    private func createTables() throws {
        try db.run(timeline.create(ifNotExists: true) { t in
            t.column(id, primaryKey: true)
            t.column(timestamp)
            t.column(filePath)
            t.column(symbolName)
            t.column(userAction)
            t.column(metadata)
        })
        
        try db.run(timeline.createIndex(timestamp, ifNotExists: true))
        try db.run(timeline.createIndex(filePath, ifNotExists: true))
    }
    
    public func record(filePath: String, symbolName: String? = nil, action: String, metadata: String? = nil) throws {
        let entry = TimelineEntry(
            id: UUID().uuidString,
            timestamp: Date(),
            filePath: filePath,
            symbolName: symbolName,
            userAction: action,
            metadata: metadata
        )
        
        let insert = timeline.insert(
            id <- entry.id,
            timestamp <- entry.timestamp,
            self.filePath <- entry.filePath,
            self.symbolName <- entry.symbolName,
            userAction <- entry.userAction,
            self.metadata <- entry.metadata
        )
        
        try db.run(insert)
    }
    
    public func getRecent(limit: Int = 100) throws -> [TimelineEntry] {
        let query = timeline.order(timestamp.desc).limit(limit)
        let results = try db.prepare(query)
        
        return results.map { row in
            TimelineEntry(
                id: row[id],
                timestamp: row[timestamp],
                filePath: row[filePath],
                symbolName: row[symbolName],
                userAction: row[userAction],
                metadata: row[metadata]
            )
        }
    }
    
    public func getForFile(_ path: String) throws -> [TimelineEntry] {
        let query = timeline.filter(filePath == path).order(timestamp.desc)
        let results = try db.prepare(query)
        
        return results.map { row in
            TimelineEntry(
                id: row[id],
                timestamp: row[timestamp],
                filePath: row[filePath],
                symbolName: row[symbolName],
                userAction: row[userAction],
                metadata: row[metadata]
            )
        }
    }
    
    public func getForSymbol(_ name: String) throws -> [TimelineEntry] {
        let query = timeline.filter(symbolName == name).order(timestamp.desc)
        let results = try db.prepare(query)
        
        return results.map { row in
            TimelineEntry(
                id: row[id],
                timestamp: row[timestamp],
                filePath: row[filePath],
                symbolName: row[symbolName],
                userAction: row[userAction],
                metadata: row[metadata]
            )
        }
    }
    
    public func clear() throws {
        try db.run(timeline.delete())
    }
}
