import SwiftUI

struct MaintenanceTimelineView: View {
    let records: [MaintenanceRecord]
    let currencySymbol: String

    private var groupedByMonth: [(key: String, records: [MaintenanceRecord])] {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"

        let grouped = Dictionary(grouping: records) { record in
            formatter.string(from: record.date)
        }

        return grouped.map { (key: $0.key, records: $0.value.sorted { $0.date > $1.date }) }
            .sorted { group1, group2 in
                guard let d1 = group1.records.first?.date, let d2 = group2.records.first?.date else { return false }
                return d1 > d2
            }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(groupedByMonth.enumerated()), id: \.element.key) { groupIndex, group in
                Text(group.key)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.orange)
                    .padding(.leading, 36)
                    .padding(.bottom, 8)
                    .padding(.top, groupIndex > 0 ? 16 : 0)

                ForEach(Array(group.records.enumerated()), id: \.element.id) { recordIndex, record in
                    let isLast = groupIndex == groupedByMonth.count - 1 && recordIndex == group.records.count - 1

                    HStack(alignment: .top, spacing: 12) {
                        VStack(spacing: 0) {
                            ZStack {
                                Circle()
                                    .fill(Color.orange)
                                    .frame(width: 24, height: 24)

                                Image(systemName: record.type.iconName)
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(.white)
                            }

                            if !isLast {
                                Rectangle()
                                    .fill(Color(.systemGray4))
                                    .frame(width: 2)
                                    .frame(maxHeight: .infinity)
                            }
                        }
                        .frame(width: 24)

                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(record.type.displayName)
                                    .font(.subheadline.weight(.semibold))
                                Spacer()
                                Text("\(currencySymbol)\(String(format: "%.2f", record.cost))")
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(.orange)
                            }

                            HStack(spacing: 12) {
                                Label(
                                    record.date.formatted(date: .abbreviated, time: .omitted),
                                    systemImage: "calendar"
                                )
                                .font(.caption)
                                .foregroundStyle(.secondary)

                                Label("\(record.odometer) km", systemImage: "speedometer")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            if !record.notes.isEmpty {
                                Text(record.notes)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                                    .padding(.top, 2)
                            }
                        }
                        .padding(12)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.bottom, isLast ? 0 : 8)
                    }
                    .staggeredAppear(index: groupIndex * 3 + recordIndex)
                }
            }
        }
    }
}

#Preview {
    let records = [
        MaintenanceRecord(date: Date(), type: .oilChange, cost: 45.0, odometer: 55000, notes: "Synthetic oil"),
        MaintenanceRecord(date: Date().addingTimeInterval(-86400 * 30), type: .tireRotation, cost: 25.0, odometer: 53000),
        MaintenanceRecord(date: Date().addingTimeInterval(-86400 * 90), type: .brakes, cost: 320.0, odometer: 50000, notes: "Front pads replaced"),
    ]

    ScrollView {
        MaintenanceTimelineView(records: records, currencySymbol: "$")
            .padding()
    }
    .preferredColorScheme(.dark)
}
