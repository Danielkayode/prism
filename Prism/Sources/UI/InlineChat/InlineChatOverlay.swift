import SwiftUI

public struct InlineChatOverlay: View {
    @Binding var isPresented: Bool
    @State private var prompt: String = ""
    @State private var showDiff: Bool = false
    @State private var diffContent: String = ""
    
    public init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            if showDiff {
                DiffViewer(content: diffContent, onAccept: acceptChanges, onReject: rejectChanges)
            } else {
                promptView
            }
        }
        .frame(maxWidth: 600)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 20)
        .padding()
    }
    
    private var promptView: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Inline AI")
                    .font(.headline)
                Spacer()
                Button(action: { isPresented = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
            
            TextField("What would you like to do?", text: $prompt)
                .textFieldStyle(.roundedBorder)
            
            HStack {
                Button("Cancel") {
                    isPresented = false
                }
                .keyboardShortcut(.escape)
                
                Spacer()
                
                Button("Generate") {
                    generateDiff()
                }
                .keyboardShortcut(.return)
                .disabled(prompt.isEmpty)
            }
        }
        .padding()
    }
    
    private func generateDiff() {
        diffContent = """
        - old line
        + new line
        """
        showDiff = true
    }
    
    private func acceptChanges() {
        isPresented = false
    }
    
    private func rejectChanges() {
        showDiff = false
    }
}

struct DiffViewer: View {
    let content: String
    let onAccept: () -> Void
    let onReject: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Changes")
                .font(.headline)
            
            ScrollView {
                Text(content)
                    .font(.system(.body, design: .monospaced))
                    .padding()
            }
            .frame(height: 200)
            
            HStack {
                Button("Reject", action: onReject)
                Spacer()
                Button("Accept", action: onAccept)
                    .keyboardShortcut(.return)
            }
        }
        .padding()
    }
}
