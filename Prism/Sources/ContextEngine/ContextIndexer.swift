import Foundation
import SQLite

public struct Symbol: Codable {
    public let id: String
    public let name: String
    public let kind: String
    public let filePath: String
    public let line: Int
    public let column: Int
    public let signature: String?
    
    public init(id: String, name: String, kind: String, filePath: String, line: Int, column: Int, signature: String? = nil) {
        self.id = id
        self.name = name
        self.kind = kind
        self.filePath = filePath
        self.line = line
        self.column = column
        self.signature = signature
    }
}

public class ContextIndexer {
    private let db: Connection
    private let symbols: Table
    
    private let id = Expression<String>("id")
    private let name = Expression<String>("name")
    private let kind = Expression<String>("kind")
    private let filePath = Expression<String>("filePath")
    private let line = Expression<Int>("line")
    private let column = Expression<Int>("column")
    private let signature = Expression<String?>("signature")
    private let indexedAt = Expression<Date>("indexedAt")
    
    public init(databasePath: String) throws {
        db = try Connection(databasePath)
        symbols = Table("symbols")
        try createTables()
    }
    
    private func createTables() throws {
        try db.run(symbols.create(ifNotExists: true) { t in
            t.column(id, primaryKey: true)
            t.column(name)
            t.column(kind)
            t.column(filePath)
            t.column(line)
            t.column(column)
            t.column(signature)
            t.column(indexedAt)
        })
        
        try db.run(symbols.createIndex(name, ifNotExists: true))
        try db.run(symbols.createIndex(filePath, ifNotExists: true))
    }
    
    public func indexProject(at projectPath: String) throws {
        let fileManager = FileManager.default
        guard let enumerator = fileManager.enumerator(atPath: projectPath) else {
            throw ContextError.invalidPath(projectPath)
        }
        
        var symbolsToIndex: [Symbol] = []
        
        for case let relativePath as String in enumerator {
            let fullPath = (projectPath as NSString).appendingPathComponent(relativePath)
            
            if relativePath.hasSuffix(".swift") {
                let extractedSymbols = try extractSymbols(from: fullPath)
                symbolsToIndex.append(contentsOf: extractedSymbols)
            }
        }
        
        try storeSymbols(symbolsToIndex)
    }
    
    private func extractSymbols(from filePath: String) throws -> [Symbol] {
        guard let content = try? String(contentsOfFile: filePath, encoding: .utf8) else {
            return []
        }
        
        var extractedSymbols: [Symbol] = []
        let lines = content.components(separatedBy: .newlines)
        
        for (lineNumber, lineText) in lines.enumerated() {
            if lineText.contains("func ") {
                if let funcName = extractFunctionName(from: lineText) {
                    let symbol = Symbol(
                        id: UUID().uuidString,
                        name: funcName,
                        kind: "function",
                        filePath: filePath,
                        line: lineNumber + 1,
                        column: 0,
                        signature: lineText.trimmingCharacters(in: .whitespaces)
                    )
                    extractedSymbols.append(symbol)
                }
            } else if lineText.contains("class ") || lineText.contains("struct ") || lineText.contains("enum ") {
                if let typeName = extractTypeName(from: lineText) {
                    let kind = lineText.contains("class") ? "class" : (lineText.contains("struct") ? "struct" : "enum")
                    let symbol = Symbol(
                        id: UUID().uuidString,
                        name: typeName,
                        kind: kind,
                        filePath: filePath,
                        line: lineNumber + 1,
                        column: 0,
                        signature: lineText.trimmingCharacters(in: .whitespaces)
                    )
                    extractedSymbols.append(symbol)
                }
            }
        }
        
        return extractedSymbols
    }
    
    private func extractFunctionName(from line: String) -> String? {
        let pattern = "func\\s+(\\w+)"
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)) else {
            return nil
        }
        
        if let range = Range(match.range(at: 1), in: line) {
            return String(line[range])
        }
        return nil
    }
    
    private func extractTypeName(from line: String) -> String? {
        let pattern = "(class|struct|enum)\\s+(\\w+)"
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)) else {
            return nil
        }
        
        if let range = Range(match.range(at: 2), in: line) {
            return String(line[range])
        }
        return nil
    }
    
    private func storeSymbols(_ symbolsToStore: [Symbol]) throws {
        try db.transaction {
            for symbol in symbolsToStore {
                let insert = symbols.insert(
                    id <- symbol.id,
                    name <- symbol.name,
                    kind <- symbol.kind,
                    filePath <- symbol.filePath,
                    line <- symbol.line,
                    column <- symbol.column,
                    signature <- symbol.signature,
                    indexedAt <- Date()
                )
                try db.run(insert)
            }
        }
    }
    
    public func searchSymbols(query: String) throws -> [Symbol] {
        let results = try db.prepare(symbols.filter(name.like("%\(query)%")))
        return results.map { row in
            Symbol(
                id: row[id],
                name: row[name],
                kind: row[kind],
                filePath: row[filePath],
                line: row[line],
                column: row[column],
                signature: row[signature]
            )
        }
    }
    
    public func getSymbolsInFile(_ path: String) throws -> [Symbol] {
        let results = try db.prepare(symbols.filter(filePath == path))
        return results.map { row in
            Symbol(
                id: row[id],
                name: row[name],
                kind: row[kind],
                filePath: row[filePath],
                line: row[line],
                column: row[column],
                signature: row[signature]
            )
        }
    }
    
    public func clearIndex() throws {
        try db.run(symbols.delete())
    }
}

public enum ContextError: LocalizedError {
    case invalidPath(String)
    case indexingFailed(String)
    
    public var errorDescription: String? {
        switch self {
        case .invalidPath(let path): return "Invalid path: \(path)"
        case .indexingFailed(let msg): return "Indexing failed: \(msg)"
        }
    }
}
