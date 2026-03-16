import Foundation
import SwiftData

@Model
final class MaintenanceRecord {
    var id: UUID
    var date: Date
    var type: MaintenanceType
    var cost: Double
    var odometer: Int
    var notes: String
    var vehicle: Vehicle?

    init(
        date: Date = Date(),
        type: MaintenanceType,
        cost: Double,
        odometer: Int,
        notes: String = "",
        vehicle: Vehicle? = nil
    ) {
        self.id = UUID()
        self.date = date
        self.type = type
        self.cost = cost
        self.odometer = odometer
        self.notes = notes
        self.vehicle = vehicle
    }
}
