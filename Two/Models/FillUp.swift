import Foundation
import SwiftData

@Model
final class FillUp {
    var id: UUID
    var date: Date
    var liters: Double
    var pricePerLiter: Double
    var totalCost: Double
    var odometer: Int
    var isFull: Bool
    var vehicle: Vehicle?

    init(
        date: Date = Date(),
        liters: Double,
        pricePerLiter: Double,
        totalCost: Double,
        odometer: Int,
        isFull: Bool = true,
        vehicle: Vehicle? = nil
    ) {
        self.id = UUID()
        self.date = date
        self.liters = liters
        self.pricePerLiter = pricePerLiter
        self.totalCost = totalCost
        self.odometer = odometer
        self.isFull = isFull
        self.vehicle = vehicle
    }
}
