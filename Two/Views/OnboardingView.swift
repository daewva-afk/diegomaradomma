import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    @State private var path: [OnboardingStep] = []
    @State private var make = ""
    @State private var model = ""
    @State private var name = ""
    @State private var year = Calendar.current.component(.year, from: Date())
    @State private var odometerText = ""
    @State private var fuelType: FuelType = .gasoline

    enum OnboardingStep: Hashable {
        case mileage
        case fuelType
    }

    var body: some View {
        NavigationStack(path: $path) {
            OnboardingStepContainer(
                step: 1,
                totalSteps: 3,
                icon: "car.fill",
                title: "Your Vehicle",
                subtitle: "What do you drive?"
            ) {
                VStack(spacing: 16) {
                    OnboardingTextField(placeholder: "Nickname (e.g. My BMW)", text: $name, icon: "pencil")
                    OnboardingTextField(placeholder: "Make (e.g. BMW)", text: $make, icon: "building.2")
                    OnboardingTextField(placeholder: "Model (e.g. 330i)", text: $model, icon: "car.side")

                    Picker("Year", selection: $year) {
                        ForEach((1970...Calendar.current.component(.year, from: Date()) + 1).reversed(), id: \.self) { y in
                            Text(String(y)).tag(y)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(.systemGray5))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Spacer()

                OnboardingNextButton(label: "Next") {
                    path.append(.mileage)
                }
                .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty || make.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .navigationDestination(for: OnboardingStep.self) { step in
                switch step {
                case .mileage:
                    stepTwoView
                case .fuelType:
                    stepThreeView
                }
            }
        }
    }

    private var stepTwoView: some View {
        OnboardingStepContainer(
            step: 2,
            totalSteps: 3,
            icon: "speedometer",
            title: "Starting Mileage",
            subtitle: "Current odometer reading in kilometers"
        ) {
            VStack(spacing: 16) {
                OnboardingTextField(
                    placeholder: "Current odometer (km)",
                    text: $odometerText,
                    icon: "speedometer",
                    keyboardType: .numberPad
                )

                Text("This helps calculate fuel economy accurately. You can enter 0 if unsure.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 4)
            }

            Spacer()

            OnboardingNextButton(label: "Next") {
                path.append(.fuelType)
            }
        }
    }

    private var stepThreeView: some View {
        OnboardingStepContainer(
            step: 3,
            totalSteps: 3,
            icon: "fuelpump.fill",
            title: "Fuel Type",
            subtitle: "Select your vehicle's fuel type"
        ) {
            VStack(spacing: 10) {
                ForEach(FuelType.allCases) { type in
                    Button {
                        fuelType = type
                    } label: {
                        HStack(spacing: 14) {
                            Image(systemName: type.iconName)
                                .font(.title3)
                                .foregroundStyle(fuelType == type ? .orange : .secondary)
                                .frame(width: 32)

                            Text(type.displayName)
                                .font(.body.weight(.medium))
                                .foregroundStyle(.primary)

                            Spacer()

                            if fuelType == type {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.orange)
                            }
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(fuelType == type ? Color.orange.opacity(0.12) : Color(.systemGray5))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(fuelType == type ? Color.orange : Color.clear, lineWidth: 1.5)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }

            Spacer()

            OnboardingNextButton(label: "Get Started") {
                createVehicleAndFinish()
            }
        }
    }

    private func createVehicleAndFinish() {
        let vehicle = Vehicle(
            name: name.trimmingCharacters(in: .whitespaces),
            make: make.trimmingCharacters(in: .whitespaces),
            model: model.trimmingCharacters(in: .whitespaces),
            year: year,
            fuelType: fuelType
        )
        modelContext.insert(vehicle)

        if let odo = Int(odometerText), odo > 0 {
            let fillUp = FillUp(
                date: Date(),
                liters: 0,
                pricePerLiter: 0,
                totalCost: 0,
                odometer: odo,
                isFull: false,
                vehicle: vehicle
            )
            modelContext.insert(fillUp)
            vehicle.fillUps.append(fillUp)
        }

        withAnimation(AppAnimation.smooth) {
            hasCompletedOnboarding = true
        }
    }
}

struct OnboardingStepContainer<Content: View>: View {
    let step: Int
    let totalSteps: Int
    let icon: String
    let title: String
    let subtitle: String
    @ViewBuilder let content: Content

    @State private var appeared = false

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 6) {
                ForEach(1...totalSteps, id: \.self) { i in
                    Capsule()
                        .fill(i <= step ? Color.orange : Color(.systemGray5))
                        .frame(height: 4)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)

            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 12) {
                        Image(systemName: icon)
                            .font(.system(size: 48))
                            .foregroundStyle(.orange)
                            .scaleEffect(appeared ? 1 : 0.5)
                            .opacity(appeared ? 1 : 0)

                        Text(title)
                            .font(.title.bold())
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 10)

                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 10)
                    }
                    .padding(.top, 32)

                    content
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .background(
            LinearGradient(
                colors: [Color(.systemBackground), Color(.systemGray6)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .navigationBarBackButtonHidden(false)
        .onAppear {
            withAnimation(AppAnimation.cardAppear.delay(0.1)) {
                appeared = true
            }
        }
    }
}

struct OnboardingTextField: View {
    let placeholder: String
    @Binding var text: String
    let icon: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.orange)
                .frame(width: 24)
            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
        }
        .padding(16)
        .background(Color(.systemGray5))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct OnboardingNextButton: View {
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.orange)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(PressableButtonStyle())
        .padding(.bottom, 8)
    }
}

#Preview {
    OnboardingView()
        .modelContainer(for: [Vehicle.self, FillUp.self, MaintenanceRecord.self], inMemory: true)
        .preferredColorScheme(.dark)
}
