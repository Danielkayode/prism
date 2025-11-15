import SwiftUI

public struct SettingsView: View {
    @AppStorage("preferred.language") private var language: String = Locale.current.language.languageCode?.identifier ?? "en"
    
    public init() {}
    
    public var body: some View {
        Form {
            Section(header: Text("Language")) {
                Picker("App Language", selection: $language) {
                    Text("English").tag("en")
                    Text("System Default").tag("")
                }
            }
            Section(header: Text("Keys & Backend"), footer: Text("Provide API keys via Info.plist or Keychain; set PRISM_BACKEND_URL in Info.plist.")) {
                HStack {
                    Text("Backend URL")
                    Spacer()
                    Text(Bundle.main.infoDictionary?["PRISM_BACKEND_URL"] as? String ?? "-")
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Settings")
    }
}
