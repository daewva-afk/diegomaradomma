import SwiftUI

struct ArcShape: Shape {
    var progress: Double
    var lineWidth: CGFloat

    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2 - lineWidth / 2
        let startAngle = Angle(degrees: 135)
        let endAngle = Angle(degrees: 135 + 270 * progress)

        var path = Path()
        path.addArc(
            center: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false
        )
        return path
    }
}

struct GaugeWidgetView: View {
    let title: String
    let value: String
    let subtitle: String
    let progress: Double
    let icon: String
    let color: Color

    @State private var animatedProgress: Double = 0

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                ArcShape(progress: 1.0, lineWidth: 6)
                    .stroke(
                        Color(.systemGray5),
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .frame(width: 80, height: 80)

                ArcShape(progress: min(animatedProgress, 1.0), lineWidth: 6)
                    .stroke(
                        LinearGradient(
                            colors: [color, color.opacity(0.6)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .frame(width: 80, height: 80)

                VStack(spacing: 0) {
                    Image(systemName: icon)
                        .font(.caption)
                        .foregroundStyle(color)
                    Text(value)
                        .font(.system(.caption, design: .rounded, weight: .bold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                }
            }

            Text(title)
                .font(.caption2.weight(.medium))
                .lineLimit(1)

            Text(subtitle)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 4)
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
        .onAppear {
            withAnimation(.easeOut(duration: 1.0).delay(0.3)) {
                animatedProgress = progress
            }
        }
    }
}

#Preview {
    HStack(spacing: 12) {
        GaugeWidgetView(
            title: "Economy",
            value: "7.2",
            subtitle: "L/100km",
            progress: 0.6,
            icon: "fuelpump.fill",
            color: .orange
        )
        GaugeWidgetView(
            title: "Cost/km",
            value: "$0.12",
            subtitle: "per km",
            progress: 0.35,
            icon: "dollarsign",
            color: .green
        )
        GaugeWidgetView(
            title: "Service",
            value: "42",
            subtitle: "days left",
            progress: 0.7,
            icon: "wrench.fill",
            color: .blue
        )
    }
    .padding()
    .preferredColorScheme(.dark)
}
