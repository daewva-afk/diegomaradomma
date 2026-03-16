import SwiftUI
import SwiftData

struct FillUpRow: View {
    let fillUp: FillUp
    let allFillUps: [FillUp]
    let useMetric: Bool
    let currencySymbol: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "fuelpump.fill")
                .font(.title3)
                .foregroundStyle(.orange)
                .frame(width: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(fillUp.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.subheadline.weight(.medium))
                HStack(spacing: 8) {
                    Text("\(String(format: "%.1f", fillUp.liters)) L")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(currencySymbol)\(String(format: "%.2f", fillUp.totalCost))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                if let economy = fuelEconomy {
                    Text(economyString(economy))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.orange)
                }
                Text("\(fillUp.odometer) km")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var fuelEconomy: Double? {
        let sorted = allFillUps.sorted { $0.odometer < $1.odometer }
        guard let idx = sorted.firstIndex(where: { $0.id == fillUp.id }),
              idx > 0,
              fillUp.isFull else { return nil }
        let prev = sorted[idx - 1]
        let distance = fillUp.odometer - prev.odometer
        guard distance > 0 else { return nil }
        return (fillUp.liters / Double(distance)) * 100.0
    }

    private func economyString(_ lPer100: Double) -> String {
        if useMetric {
            return String(format: "%.1f L/100km", lPer100)
        } else {
            let mpg = 235.215 / lPer100
            return String(format: "%.1f MPG", mpg)
        }
    }
}
