import Foundation

public struct TodoItem: Identifiable, Codable, Equatable {
    public let id: String
    public var title: String
    public var isDone: Bool
    public var createdAt: Date
    
    public init(id: String = UUID().uuidString, title: String, isDone: Bool = false, createdAt: Date = Date()) {
        self.id = id
        self.title = title
        self.isDone = isDone
        self.createdAt = createdAt
    }
}
