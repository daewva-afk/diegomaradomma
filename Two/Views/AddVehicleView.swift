import SwiftUI
import SwiftData
import PhotosUI

struct AddVehicleView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var make = ""
    @State private var model = ""
    @State private var year = Calendar.current.component(.year, from: Date())
    @State private var fuelType: FuelType = .gasoline
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var imageData: Data?

    private var yearRange: ClosedRange<Int> {
        1970...Calendar.current.component(.year, from: Date()) + 1
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        if let imageData, let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        } else {
                            VStack(spacing: 12) {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 36))
                                    .foregroundStyle(.orange)
                                Text("Add Photo")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 160)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .onChange(of: selectedPhoto) { _, newValue in
                        Task {
                            if let data = try? await newValue?.loadTransferable(type: Data.self) {
                                imageData = data
                            }
                        }
                    }
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())

                Section("Vehicle Info") {
                    TextField("Nickname (e.g., My Honda)", text: $name)
                    TextField("Make (e.g., Honda)", text: $make)
                    TextField("Model (e.g., Civic)", text: $model)
                    Picker("Year", selection: $year) {
                        ForEach(yearRange.reversed(), id: \.self) { y in
                            Text(String(y)).tag(y)
                        }
                    }
                }

                Section("Fuel Type") {
                    Picker("Fuel Type", selection: $fuelType) {
                        ForEach(FuelType.allCases) { type in
                            Label(type.displayName, systemImage: type.iconName)
                                .tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
            .navigationTitle("New Vehicle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveVehicle()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty || make.trimmingCharacters(in: .whitespaces).isEmpty)
                    .fontWeight(.semibold)
                }
            }
        }
    }

    private func saveVehicle() {
        let vehicle = Vehicle(
            name: name.trimmingCharacters(in: .whitespaces),
            make: make.trimmingCharacters(in: .whitespaces),
            model: model.trimmingCharacters(in: .whitespaces),
            year: year,
            fuelType: fuelType,
            imageData: imageData
        )
        modelContext.insert(vehicle)
        dismiss()
    }
}

#Preview {
    AddVehicleView()
        .modelContainer(for: [Vehicle.self, FillUp.self, MaintenanceRecord.self], inMemory: true)
        .preferredColorScheme(.dark)
}
