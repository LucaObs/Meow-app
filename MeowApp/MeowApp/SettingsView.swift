import SwiftUI

struct SettingsView: View {
    @AppStorage("claude_api_key") private var apiKey = ""

    var body: some View {
        Form {
            Section {
                SecureField("sk-ant-...", text: $apiKey)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .font(.system(.body, design: .monospaced))
            } header: {
                Text("Chiave API Claude")
            } footer: {
                Text("Ottieni la tua chiave API su console.anthropic.com. La chiave viene salvata solo sul tuo dispositivo.")
            }

            if !apiKey.isEmpty {
                Section {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Chiave API configurata")
                            .foregroundColor(.green)
                    }
                }
            }

            Section {
                Button(role: .destructive) {
                    apiKey = ""
                } label: {
                    Label("Rimuovi Chiave API", systemImage: "trash")
                }
                .disabled(apiKey.isEmpty)
            }
        }
        .navigationTitle("Impostazioni")
    }
}
