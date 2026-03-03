import Foundation

enum FuelType: String, Codable, CaseIterable, Identifiable {
    case gasoline
    case diesel
    case electric
    case hybrid

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .gasoline: "Gasoline"
        case .diesel: "Diesel"
        case .electric: "Electric"
        case .hybrid: "Hybrid"
        }
    }

    var iconName: String {
        switch self {
        case .gasoline: "fuelpump.fill"
        case .diesel: "fuelpump"
        case .electric: "bolt.car.fill"
        case .hybrid: "leaf.arrow.circlepath"
        }
    }
}

enum MaintenanceType: String, Codable, CaseIterable, Identifiable {
    case oilChange
    case tireRotation
    case brakes
    case battery
    case filter
    case inspection
    case other

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .oilChange: "Oil Change"
        case .tireRotation: "Tire Rotation"
        case .brakes: "Brakes"
        case .battery: "Battery"
        case .filter: "Filter"
        case .inspection: "Inspection"
        case .other: "Other"
        }
    }

    var iconName: String {
        switch self {
        case .oilChange: "drop.fill"
        case .tireRotation: "tire"
        case .brakes: "circle.circle.fill"
        case .battery: "battery.100.bolt"
        case .filter: "aqi.medium"
        case .inspection: "checklist.checked"
        case .other: "wrench.fill"
        }
    }

    var recommendedIntervalDays: Int {
        switch self {
        case .oilChange: 90
        case .tireRotation: 180
        case .brakes: 365
        case .battery: 730
        case .filter: 365
        case .inspection: 365
        case .other: 0
        }
    }
}
