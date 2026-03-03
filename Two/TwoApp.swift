import SwiftUI
import SwiftData

@main
struct TwoApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some Scene {
        WindowGroup {
            Group {
                if hasCompletedOnboarding {
                    ContentView()
                } else {
                    OnboardingView()
                }
            }
            .preferredColorScheme(.dark)
        }
        .modelContainer(for: [Vehicle.self, FillUp.self, MaintenanceRecord.self])
    }
}
