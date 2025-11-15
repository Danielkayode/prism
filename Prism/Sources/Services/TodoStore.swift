import Foundation
import Combine

public final class TodoStore: ObservableObject {
    public static let shared = TodoStore()
    @Published public private(set) var todos: [TodoItem] = []
    private var cancellable: AnyCancellable?
    
    private init() {
        cancellable = ToolEventBus.shared.publisher
            .sink { [weak self] event in
                guard event.tool == ToolID.taskAssign.rawValue, let params = event.params, let title = params["title"] else { return }
                self?.add(title: title)
            }
    }
    
    public func add(title: String) {
        todos.append(TodoItem(title: title))
    }
    
    public func toggle(_ id: String) {
        if let idx = todos.firstIndex(where: { $0.id == id }) { todos[idx].isDone.toggle() }
    }
    
    public func remove(_ id: String) {
        todos.removeAll { $0.id == id }
    }
}
