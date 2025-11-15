import SwiftUI

public struct ModeSelectorView: View {
    @Binding var selectedMode: AIMode
    
    public init(selectedMode: Binding<AIMode>) {
        self._selectedMode = selectedMode
    }
    
    public var body: some View {
        Picker("Mode", selection: $selectedMode) {
            ForEach(AIMode.allCases, id: \.self) { mode in
                Text(mode.displayName).tag(mode)
            }
        }
        .pickerStyle(.segmented)
        .padding()
    }
}
