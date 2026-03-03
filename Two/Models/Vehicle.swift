import Foundation
import SwiftData

@Model
final class Vehicle {
    var id: UUID
    var name: String
    var make: String
    var model: String
    var year: Int
    var fuelType: FuelType
    var imageData: Data?
    var dateAdded: Date

    @Relationship(deleteRule: .cascade, inverse: \FillUp.vehicle)
    var fillUps: [FillUp]

    @Relationship(deleteRule: .cascade, inverse: \MaintenanceRecord.vehicle)
    var maintenanceRecords: [MaintenanceRecord]

    init(
        name: String,
        make: String,
        model: String,
        year: Int,
        fuelType: FuelType,
        imageData: Data? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.make = make
        self.model = model
        self.year = year
        self.fuelType = fuelType
        self.imageData = imageData
        self.dateAdded = Date()
        self.fillUps = []
        self.maintenanceRecords = []
    }

    var sortedFillUps: [FillUp] {
        fillUps.sorted { $0.date > $1.date }
    }

    var lastFillUpDate: Date? {
        sortedFillUps.first?.date
    }

    var totalFuelCost: Double {
        fillUps.reduce(0) { $0 + $1.totalCost }
    }

    var totalMaintenanceCost: Double {
        maintenanceRecords.reduce(0) { $0 + $1.cost }
    }

    var totalCost: Double {
        totalFuelCost + totalMaintenanceCost
    }

    var totalDistance: Int {
        guard let maxOdo = fillUps.map(\.odometer).max(),
              let minOdo = fillUps.map(\.odometer).min(),
              maxOdo > minOdo else { return 0 }
        return maxOdo - minOdo
    }

    var averageFuelEconomy: Double? {
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
}
