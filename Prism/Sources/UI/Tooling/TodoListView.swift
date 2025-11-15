import SwiftUI

public struct TodoListView: View {
    @ObservedObject var store = TodoStore.shared
    
    public init() {}
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Tasks")
                    .font(.headline)
                    .foregroundStyle(PrismTheme.primaryGradient)
                Spacer()
                Button(action: { store.add(title: "New Task") }) { Image(systemName: "plus") }
                    .buttonStyle(PrismButtonStyle(.secondary))
            }
            ForEach(store.todos) { todo in
                HStack(spacing: 8) {
                    Button(action: { store.toggle(todo.id) }) {
                        Image(systemName: todo.isDone ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(todo.isDone ? .green : PrismTheme.accent)
                    }
                    .buttonStyle(.plain)
                    Text(todo.title)
                        .strikethrough(todo.isDone)
                    Spacer()
                    Button(role: .destructive, action: { store.remove(todo.id) }) { Image(systemName: "trash") }
                        .buttonStyle(.plain)
                        .foregroundColor(.red)
                }
                .glassCard()
            }
        }
    }
}
