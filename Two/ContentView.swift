import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Vehicle.dateAdded, order: .reverse) private var vehicles: [Vehicle]
    @State private var selectedVehicleID: UUID?
    @State private var showingAddVehicle = false
    @State private var showingSettings = false
    @State private var columnVisibility: NavigationSplitViewVisibility = .automatic

    var body: some View {
        if vehicles.isEmpty {
            EmptyGarageView(showingAddVehicle: $showingAddVehicle)
                .sheet(isPresented: $showingAddVehicle) {
                    AddVehicleView()
                }
        } else {
            NavigationSplitView(columnVisibility: $columnVisibility) {
                sidebar
            } detail: {
                detail
            }
            .tint(.orange)
            .sheet(isPresented: $showingAddVehicle) {
                AddVehicleView()
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .onAppear {
                if selectedVehicleID == nil {
                    selectedVehicleID = vehicles.first?.id
                }
            }
            .onChange(of: vehicles.count) { oldCount, newCount in
                if newCount > oldCount, let newest = vehicles.first {
                    selectedVehicleID = newest.id
                }
                if vehicles.isEmpty {
                    selectedVehicleID = nil
                }
            }
        }
    }

    private var sidebar: some View {
        List(selection: $selectedVehicleID) {
            ForEach(vehicles) { vehicle in
                SidebarVehicleRow(vehicle: vehicle)
                    .tag(vehicle.id)
                    .listRowBackground(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(selectedVehicleID == vehicle.id
                                  ? Color.orange.opacity(0.15)
                                  : Color.clear)
                            .padding(.vertical, 2)
                    )
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            deleteVehicle(vehicle)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("Garage")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    showingSettings = true
                } label: {
                    Image(systemName: "gearshape.fill")
                        .foregroundStyle(.orange)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingAddVehicle = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.orange)
                }
            }
        }
    }

    @ViewBuilder
    private var detail: some View {
        if let id = selectedVehicleID, let vehicle = vehicles.first(where: { $0.id == id }) {
            CarDashboardView(vehicle: vehicle)
        } else {
            VStack(spacing: 16) {
                Image(systemName: "car.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(.secondary.opacity(0.4))
                Text("Select a vehicle")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func deleteVehicle(_ vehicle: Vehicle) {
        if selectedVehicleID == vehicle.id {
            selectedVehicleID = vehicles.first(where: { $0.id != vehicle.id })?.id
        }
        withAnimation {
            modelContext.delete(vehicle)
        }
    }
}

struct SidebarVehicleRow: View {
    let vehicle: Vehicle

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        LinearGradient(
                            colors: [Color(.systemGray4), Color(.systemGray6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)

                if let imageData = vehicle.imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 44, height: 44)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                } else {
                    Image(systemName: vehicle.fuelType.iconName)
                        .font(.body)
                        .foregroundStyle(.orange)
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(vehicle.name)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                Text("\(vehicle.make) \(vehicle.model)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct EmptyGarageView: View {
    @Binding var showingAddVehicle: Bool

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.orange.opacity(0.2), Color.orange.opacity(0.05)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 160, height: 160)

                Image(systemName: "car.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(.orange)
            }

            VStack(spacing: 8) {
                Text("Add Your First Car")
                    .font(.title.bold())

                Text("Start tracking fuel costs, maintenance,\nand vehicle statistics.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Button {
                showingAddVehicle = true
            } label: {
                Label("Add Vehicle", systemImage: "plus")
                    .font(.headline)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 14)
                    .background(Color.orange)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
            .buttonStyle(PressableButtonStyle())

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                colors: [Color(.systemBackground), Color(.systemGray6)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Vehicle.self, FillUp.self, MaintenanceRecord.self], inMemory: true)
}
