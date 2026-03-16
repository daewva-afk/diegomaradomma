import SwiftUI
import SwiftData
import Charts

struct CarDashboardView: View {
    @Environment(\.modelContext) private var modelContext
    let vehicle: Vehicle

    @State private var showingFillUpSheet = false
    @State private var showingMaintenanceSheet = false
    @AppStorage("currencySymbol") private var currencySymbol = "$"
    @AppStorage("useMetric") private var useMetric = true

    private var fillUps: [FillUp] {
        vehicle.fillUps.sorted { $0.date < $1.date }
    }

    private var maintenanceRecords: [MaintenanceRecord] {
        vehicle.maintenanceRecords.sorted { $0.date < $1.date }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                carCard
                gaugeWidgets
                actionButtons
                statisticsCharts
                recentFillUpsSection
                maintenanceTimeline
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 30)
        }
        .background(
            LinearGradient(
                colors: [Color(.systemBackground), Color(.systemGray6).opacity(0.5)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .navigationTitle(vehicle.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingFillUpSheet) {
            AddFillUpSheet(vehicle: vehicle)
        }
        .sheet(isPresented: $showingMaintenanceSheet) {
            AddMaintenanceView(vehicle: vehicle)
        }
    }

    private var totalFuelCost: Double {
        fillUps.reduce(0) { $0 + $1.totalCost }
    }

    private var totalMaintenanceCost: Double {
        maintenanceRecords.reduce(0) { $0 + $1.cost }
    }

    private var totalCost: Double {
        totalFuelCost + totalMaintenanceCost
    }

    private var totalDistance: Int {
        guard let maxOdo = fillUps.map(\.odometer).max(),
              let minOdo = fillUps.map(\.odometer).min(),
              maxOdo > minOdo else { return 0 }
        return maxOdo - minOdo
    }

    private var averageFuelEconomy: Double? {
        let sorted = fillUps.sorted { $0.odometer < $1.odometer }
        var totalLiters = 0.0
        var totalKm = 0
        for i in 1..<sorted.count {
            if sorted[i].isFull {
                totalLiters += sorted[i].liters
                totalKm += sorted[i].odometer - sorted[i - 1].odometer
            }
        }
        guard totalKm > 0 else { return nil }
        return (totalLiters / Double(totalKm)) * 100.0
    }

    private var sortedFillUpsByDate: [FillUp] {
        fillUps.sorted { $0.date > $1.date }
    }

    private var carCard: some View {
        VStack(spacing: 0) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [Color(.systemGray4), Color(.systemGray6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 180)

                if let imageData = vehicle.imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 180)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                } else {
                    VStack(spacing: 8) {
                        Image(systemName: "car.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(.orange.opacity(0.5))
                    }
                }
            }
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(vehicle.name)
                        .font(.title3.bold())
                        .foregroundStyle(.white)
                    HStack(spacing: 8) {
                        Text("\(vehicle.make) \(vehicle.model) \(String(vehicle.year))")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.8))
                        Label(vehicle.fuelType.displayName, systemImage: vehicle.fuelType.iconName)
                            .font(.caption2.weight(.medium))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                    }
                }
                .padding(16)
                .background(
                    LinearGradient(
                        colors: [.black.opacity(0.6), .clear],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                    .clipShape(
                        RoundedRectangle(cornerRadius: 20)
                    )
                )
            }

            HStack(spacing: 0) {
                carCardStat(
                    label: "Total Spent",
                    value: "\(currencySymbol)\(String(format: "%.0f", totalCost))",
                    icon: "dollarsign.circle"
                )
                Divider().frame(height: 32)
                carCardStat(
                    label: "Fill-Ups",
                    value: "\(fillUps.count)",
                    icon: "fuelpump"
                )
                Divider().frame(height: 32)
                carCardStat(
                    label: "Mileage",
                    value: mileageText,
                    icon: "speedometer"
                )
            }
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6))
            )
            .padding(.top, -8)
        }
    }

    private var mileageText: String {
        if let maxOdo = fillUps.map(\.odometer).max() {
            return "\(maxOdo) km"
        }
        return "-- km"
    }

    private func carCardStat(label: String, value: String, icon: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.orange)
            Text(value)
                .font(.caption.weight(.bold))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var gaugeWidgets: some View {
        HStack(spacing: 10) {
            GaugeWidgetView(
                title: "Economy",
                value: economyValue,
                subtitle: useMetric ? "L/100km" : "MPG",
                progress: economyProgress,
                icon: "fuelpump.fill",
                color: .orange
            )

            GaugeWidgetView(
                title: "Cost/km",
                value: costPerKmValue,
                subtitle: "per km",
                progress: costPerKmProgress,
                icon: "dollarsign",
                color: .green
            )

            GaugeWidgetView(
                title: "Service",
                value: daysToServiceValue,
                subtitle: daysToServiceSubtitle,
                progress: serviceProgress,
                icon: "wrench.fill",
                color: .blue
            )
        }
    }

    private var economyValue: String {
        guard let avg = averageFuelEconomy else { return "--" }
        if useMetric {
            return String(format: "%.1f", avg)
        } else {
            return String(format: "%.0f", 235.215 / avg)
        }
    }

    private var economyProgress: Double {
        guard let avg = averageFuelEconomy else { return 0 }
        return max(0, min(1, (15 - avg) / 10.0))
    }

    private var costPerKmValue: String {
        let dist = totalDistance
        guard dist > 0 else { return "--" }
        let costPerKm = totalCost / Double(dist)
        return "\(currencySymbol)\(String(format: "%.2f", costPerKm))"
    }

    private var costPerKmProgress: Double {
        let dist = totalDistance
        guard dist > 0 else { return 0 }
        let costPerKm = totalCost / Double(dist)
        return max(0, min(1, 1.0 - costPerKm / 0.5))
    }

    private var nextServiceInfo: (type: MaintenanceType, daysLeft: Int)? {
        var nearest: (type: MaintenanceType, daysLeft: Int)?
        for type in MaintenanceType.allCases where type.recommendedIntervalDays > 0 {
            let lastRecord = maintenanceRecords
                .filter { $0.type == type }
                .sorted { $0.date > $1.date }
                .first
            let baseDate = lastRecord?.date ?? vehicle.dateAdded
            let daysSince = Calendar.current.dateComponents([.day], from: baseDate, to: Date()).day ?? 0
            let daysLeft = type.recommendedIntervalDays - daysSince
            if nearest == nil || daysLeft < (nearest?.daysLeft ?? Int.max) {
                nearest = (type: type, daysLeft: daysLeft)
            }
        }
        return nearest
    }

    private var daysToServiceValue: String {
        guard let info = nextServiceInfo else { return "--" }
        if info.daysLeft <= 0 {
            return "Now"
        }
        return "\(info.daysLeft)"
    }

    private var daysToServiceSubtitle: String {
        guard let info = nextServiceInfo else { return "days left" }
        if info.daysLeft <= 0 {
            return "overdue"
        }
        return "days left"
    }

    private var serviceProgress: Double {
        guard let info = nextServiceInfo else { return 0 }
        let total = Double(info.type.recommendedIntervalDays)
        guard total > 0 else { return 0 }
        let remaining = Double(max(0, info.daysLeft))
        return remaining / total
    }

    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button {
                showingFillUpSheet = true
            } label: {
                Label("Add Fill-Up", systemImage: "plus.circle.fill")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.orange)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(PressableButtonStyle())

            Button {
                showingMaintenanceSheet = true
            } label: {
                Label("Add Service", systemImage: "wrench.fill")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: [Color(.systemGray4), Color(.systemGray5)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .foregroundStyle(.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(PressableButtonStyle())
        }
    }

    private var statisticsCharts: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Costs Overview")
                .font(.headline)

            let monthlyData = lastSixMonthsCosts
            if monthlyData.allSatisfy({ $0.cost == 0 }) {
                Text("No cost data yet. Add fill-ups to see charts.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                Chart(monthlyData, id: \.label) { item in
                    BarMark(
                        x: .value("Month", item.label),
                        y: .value("Cost", item.cost)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.orange, .orange.opacity(0.5)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .cornerRadius(4)
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisValueLabel {
                            if let val = value.as(Double.self) {
                                Text("\(currencySymbol)\(Int(val))")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks { value in
                        AxisValueLabel()
                            .font(.caption2)
                    }
                }
                .frame(height: 160)
            }

            let economyData = fuelEconomyData
            if !economyData.isEmpty {
                Text("Fuel Economy Trend")
                    .font(.subheadline.weight(.semibold))
                    .padding(.top, 8)

                Chart(economyData, id: \.label) { item in
                    LineMark(
                        x: .value("Date", item.label),
                        y: .value("Economy", item.value)
                    )
                    .foregroundStyle(.green)
                    .interpolationMethod(.catmullRom)

                    AreaMark(
                        x: .value("Date", item.label),
                        y: .value("Economy", item.value)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.green.opacity(0.3), .green.opacity(0.0)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.catmullRom)
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisValueLabel {
                            if let val = value.as(Double.self) {
                                Text(String(format: "%.0f", val))
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks { _ in
                        AxisValueLabel()
                            .font(.system(size: 8))
                    }
                }
                .frame(height: 120)

                Text(useMetric ? "L/100km (lower is better)" : "MPG (higher is better)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [Color(.systemGray5), Color(.systemGray6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
    }

    private var lastSixMonthsCosts: [(label: String, cost: Double)] {
        let calendar = Calendar.current
        let now = Date()
        var result: [(label: String, cost: Double)] = []

        for i in (0..<6).reversed() {
            guard let monthDate = calendar.date(byAdding: .month, value: -i, to: now) else { continue }
            let month = calendar.component(.month, from: monthDate)
            let year = calendar.component(.year, from: monthDate)

            let fuelCost = fillUps.filter { fillUp in
                calendar.component(.month, from: fillUp.date) == month &&
                calendar.component(.year, from: fillUp.date) == year
            }.reduce(0.0) { $0 + $1.totalCost }

            let maintCost = maintenanceRecords.filter { record in
                calendar.component(.month, from: record.date) == month &&
                calendar.component(.year, from: record.date) == year
            }.reduce(0.0) { $0 + $1.cost }

            let formatter = DateFormatter()
            formatter.dateFormat = "MMM"
            result.append((label: formatter.string(from: monthDate), cost: fuelCost + maintCost))
        }
        return result
    }

    private var fuelEconomyData: [(label: String, value: Double)] {
        let sorted = fillUps.sorted { $0.odometer < $1.odometer }
        var results: [(label: String, value: Double)] = []

        for i in 1..<sorted.count {
            guard sorted[i].isFull else { continue }
            let distance = sorted[i].odometer - sorted[i - 1].odometer
            guard distance > 0 else { continue }
            let lPer100 = (sorted[i].liters / Double(distance)) * 100.0

            let formatter = DateFormatter()
            formatter.dateFormat = "d MMM"
            let value = useMetric ? lPer100 : 235.215 / lPer100
            results.append((label: formatter.string(from: sorted[i].date), value: value))
        }
        return Array(results.suffix(8))
    }

    private var recentFillUpsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Fill-Ups")
                    .font(.headline)
                Spacer()
                if !fillUps.isEmpty {
                    Text("\(fillUps.count) total")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            let sorted = sortedFillUpsByDate
            if sorted.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "fuelpump")
                            .font(.title2)
                            .foregroundStyle(.secondary.opacity(0.5))
                        Text("No fill-ups recorded yet")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(.vertical, 20)
            } else {
                ForEach(Array(sorted.prefix(5).enumerated()), id: \.element.id) { index, fillUp in
                    FillUpRow(fillUp: fillUp, allFillUps: fillUps, useMetric: useMetric, currencySymbol: currencySymbol)
                        .staggeredAppear(index: index)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [Color(.systemGray5), Color(.systemGray6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
    }

    private var maintenanceTimeline: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Maintenance Timeline")
                    .font(.headline)
                Spacer()
                if !maintenanceRecords.isEmpty {
                    Text("\(maintenanceRecords.count) records")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            let records = maintenanceRecords.sorted { $0.date > $1.date }
            if records.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "wrench.and.screwdriver")
                            .font(.title2)
                            .foregroundStyle(.secondary.opacity(0.5))
                        Text("No service records yet")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(.vertical, 20)
            } else {
                MaintenanceTimelineView(records: records, currencySymbol: currencySymbol)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [Color(.systemGray5), Color(.systemGray6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
    }
}

struct AddFillUpSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let vehicle: Vehicle
    @AppStorage("currencySymbol") private var currencySymbol = "$"

    @State private var fillDate = Date()
    @State private var litersText = ""
    @State private var pricePerLiterText = ""
    @State private var odometerText = ""
    @State private var isFullTank = true

    private var totalCost: Double {
        let liters = Double(litersText) ?? 0
        let price = Double(pricePerLiterText) ?? 0
        return liters * price
    }

    private var canSave: Bool {
        guard let liters = Double(litersText), liters > 0 else { return false }
        guard let price = Double(pricePerLiterText), price > 0 else { return false }
        guard let odo = Int(odometerText), odo > 0 else { return false }
        return true
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Fill-Up Details") {
                    DatePicker("Date", selection: $fillDate, displayedComponents: .date)

                    HStack {
                        Text("Liters")
                            .foregroundStyle(.secondary)
                        Spacer()
                        TextField("0.0", text: $litersText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }

                    HStack {
                        Text("Price per liter")
                            .foregroundStyle(.secondary)
                        Spacer()
                        TextField("0.00", text: $pricePerLiterText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }

                    HStack {
                        Text("Total Cost")
                        Spacer()
                        Text("\(currencySymbol)\(String(format: "%.2f", totalCost))")
                            .foregroundStyle(.orange)
                            .fontWeight(.semibold)
                    }
                }

                Section("Odometer") {
                    HStack {
                        Text("Odometer (km)")
                            .foregroundStyle(.secondary)
                        Spacer()
                        TextField("0", text: $odometerText)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }

                    Toggle(isOn: $isFullTank) {
                        Label("Full Tank", systemImage: "fuelpump.fill")
                    }
                    .tint(.orange)
                }
            }
            .navigationTitle("New Fill-Up")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveFillUp() }
                        .disabled(!canSave)
                        .fontWeight(.semibold)
                }
            }
        }
    }

    private func saveFillUp() {
        guard let liters = Double(litersText),
              let price = Double(pricePerLiterText),
              let odometer = Int(odometerText) else { return }

        let fillUp = FillUp(
            date: fillDate,
            liters: liters,
            pricePerLiter: price,
            totalCost: liters * price,
            odometer: odometer,
            isFull: isFullTank,
            vehicle: vehicle
        )
        modelContext.insert(fillUp)
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    NavigationStack {
        CarDashboardView(
            vehicle: Vehicle(name: "My BMW", make: "BMW", model: "330i", year: 2023, fuelType: .gasoline)
        )
    }
    .modelContainer(for: [Vehicle.self, FillUp.self, MaintenanceRecord.self], inMemory: true)
    .preferredColorScheme(.dark)
}
