import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("useMetric") private var useMetric = true
    @AppStorage("currencySymbol") private var currencySymbol = "$"

    private let currencies = ["$", "\u{20AC}", "\u{00A3}", "\u{00A5}", "\u{20BD}", "\u{20BA}"]

    var body: some View {
        NavigationStack {
            List {
                Section("Units") {
                    Toggle(isOn: $useMetric) {
                        Label(useMetric ? "Metric (L/100km)" : "Imperial (MPG)", systemImage: "ruler.fill")
                    }
                    .tint(.orange)

                    Picker(selection: $currencySymbol) {
                        ForEach(currencies, id: \.self) { currency in
                            Text(currency).tag(currency)
                        }
                    } label: {
                        Label("Currency", systemImage: "dollarsign.circle.fill")
                    }
                }

                Section("About") {
                    HStack {
                        Label("Version", systemImage: "info.circle")
                        Spacer()
                        Text("2.0.0")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Label("Developer", systemImage: "person.fill")
                        Spacer()
                        Text("Fuelwise Team")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Label("Built with", systemImage: "swift")
                        Spacer()
                        Text("SwiftUI + SwiftData")
                            .foregroundStyle(.secondary)
                    }
                }

                Section {
                    Button(role: .destructive) {
                        UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
                    } label: {
                        Label("Reset Onboarding", systemImage: "arrow.counterclockwise")
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                }
            }
        }
    }
}

#Preview {
    SettingsView()
        .preferredColorScheme(.dark)
}
