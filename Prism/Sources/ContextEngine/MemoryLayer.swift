import Foundation
import SQLite

public struct MemoryEntry: Codable {
    public let userID: String
    public let key: String
    public let value: String
    public let updatedAt: Date
    
    public init(userID: String, key: String, value: String, updatedAt: Date) {
        self.userID = userID
        self.key = key
        self.value = value
        self.updatedAt = updatedAt
    }
}

public class MemoryLayer {
    private let db: Connection
    private let memory: Table
    
    private let userID = Expression<String>("userID")
    private let key = Expression<String>("key")
    private let value = Expression<String>("value")
    private let updatedAt = Expression<Date>("updatedAt")
    
    public init(databasePath: String) throws {
        db = try Connection(databasePath)
        memory = Table("memory")
        try createTables()
    }
    
    private func createTables() throws {
        try db.run(memory.create(ifNotExists: true) { t in
            t.column(userID)
            t.column(key)
            t.column(value)
            t.column(updatedAt)
            t.primaryKey(userID, key)
        })
        
        try db.run(memory.createIndex(userID, ifNotExists: true))
    }
    
    public func remember(userID: String, key: String, value: String) throws {
        let entry = memory.filter(self.userID == userID && self.key == key)
        
        if try db.pluck(entry) != nil {
            try db.run(entry.update(
                self.value <- value,
                updatedAt <- Date()
            ))
        } else {
            let insert = memory.insert(
                self.userID <- userID,
                self.key <- key,
                self.value <- value,
                updatedAt <- Date()
            )
            try db.run(insert)
        }
    }
    
    public func recall(userID: String, key: String) throws -> String? {
        let query = memory.filter(self.userID == userID && self.key == key)
        if let row = try db.pluck(query) {
            return row[value]
        }
        return nil
    }
    
    public func getAllMemories(for userID: String) throws -> [MemoryEntry] {
        let query = memory.filter(self.userID == userID).order(updatedAt.desc)
        let results = try db.prepare(query)
        
        return results.map { row in
            MemoryEntry(
                userID: row[self.userID],
                key: row[key],
                value: row[value],
                updatedAt: row[updatedAt]
            )
        }
    }
    
    public func forget(userID: String, key: String) throws {
        let entry = memory.filter(self.userID == userID && self.key == key)
        try db.run(entry.delete())
    }
    
    public func clearAll(for userID: String) throws {
        let entries = memory.filter(self.userID == userID)
        try db.run(entries.delete())
    }
}
