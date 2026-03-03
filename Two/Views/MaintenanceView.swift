import SwiftUI
import SwiftData

struct AddMaintenanceView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let vehicle: Vehicle

    @State private var maintenanceDate = Date()
    @State private var maintenanceType: MaintenanceType = .oilChange
    @State private var costText = ""
    @State private var odometerText = ""
    @State private var notes = ""

    private var canSave: Bool {
        guard let cost = Double(costText), cost >= 0 else { return false }
        guard let odo = Int(odometerText), odo > 0 else { return false }
        return true
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Service Details") {
                    Picker("Type", selection: $maintenanceType) {
                        ForEach(MaintenanceType.allCases) { type in
                            Label(type.displayName, systemImage: type.iconName)
                                .tag(type)
                        }
                    }

                    DatePicker("Date", selection: $maintenanceDate, displayedComponents: .date)
                }

                Section("Cost & Odometer") {
                    TextField("Cost", text: $costText)
                        .keyboardType(.decimalPad)
                    TextField("Odometer (km)", text: $odometerText)
                        .keyboardType(.numberPad)
                }

                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
                }
            }
            .navigationTitle("New Service")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveRecord()
                    }
                    .disabled(!canSave)
                    .fontWeight(.semibold)
                }
            }
        }
    }

    private func saveRecord() {
        guard let cost = Double(costText),
              let odometer = Int(odometerText) else { return }

        let record = MaintenanceRecord(
            date: maintenanceDate,
            type: maintenanceType,
            cost: cost,
            odometer: odometer,
            notes: notes.trimmingCharacters(in: .whitespaces),
            vehicle: vehicle
        )
        modelContext.insert(record)
        vehicle.maintenanceRecords.append(record)
        dismiss()
    }
}

#Preview {
    let vehicle = Vehicle(name: "Test", make: "Honda", model: "Civic", year: 2022, fuelType: .gasoline)
    AddMaintenanceView(vehicle: vehicle)
        .modelContainer(for: [Vehicle.self, FillUp.self, MaintenanceRecord.self], inMemory: true)
        .preferredColorScheme(.dark)
}
