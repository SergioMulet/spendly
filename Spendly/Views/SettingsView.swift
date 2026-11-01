import SwiftUI

struct SettingsView: View {
    @State private var viewModel = SettingsViewModel()
    var body: some View {
        NavigationStack {
            List {
                Section("General") {
                    Picker(selection: $viewModel.currencyCode) {
                        Text("Euro (€)").tag("EUR")
                        Text("US Dollar ($)").tag("USD")
                        Text("British Pound (£)").tag("GBP")
                    } label: {
                        SettingsLabel("Currency", systemImage: "eurosign", color: .orange)
                    }
                    
                    Picker(selection: $viewModel.language) {
                        ForEach(Language.allCases, id: \.self) { language in
                            Text(verbatim: language.displayName).tag(language)
                        }
                    } label: {
                        SettingsLabel("Language", systemImage: "globe", color: .teal)
                    }
                }
                
                Section {
                    Toggle(isOn: $viewModel.iCloudSync) {
                        SettingsLabel("iCloud sync", systemImage: "icloud.fill", color: .blue)
                    }
                    
                    Button {
                        // TODO: export expenses
                    }
                    label: {
                        HStack {
                            SettingsLabel("Export data", systemImage: "square.and.arrow.down", color: .green)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .foregroundStyle(.primary)
                } header: {
                    Text("Data")
                } footer: {
                    Text("Expenses stay in sync across your devices")
                } //section
                
                Section("Privacy") {
                    Toggle(isOn: $viewModel.faceIDLock){
                        SettingsLabel("Face Id lock", systemImage: "faceid", color: .indigo)
                    }
                }
            }
        }
    }
}

struct SettingsLabel: View {
    let title: LocalizedStringKey
    let systemImage: String
    let color: Color
    
    init(_ title: LocalizedStringKey, systemImage: String, color: Color) {
        self.title = title
        self.systemImage = systemImage
        self.color = color
    }
    
    var body: some View {
        Label {
            Text(title)
        } icon: {
            Image(systemName: systemImage)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 30, height: 30)
                .background(color, in:RoundedRectangle(cornerRadius: 7))
        }
    }
}

#Preview {
    SettingsView()
}
