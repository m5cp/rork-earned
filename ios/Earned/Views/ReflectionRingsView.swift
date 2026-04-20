import SwiftUI

struct ReflectionRingsView: View {
    let rings: ReflectionRings
    var lineWidth: CGFloat = 18
    var spacing: CGFloat = 6
    var animate: Bool = true

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var animatedCheckIn: Double = 0
    @State private var animatedReflect: Double = 0
    @State private var animatedMood: Double = 0

    var body: some View {
        GeometryReader { proxy in
            let size = min(proxy.size.width, proxy.size.height)
            ZStack {
                ringView(
                    progress: animatedCheckIn,
                    kind: .checkIn,
                    diameter: size
                )

                ringView(
                    progress: animatedReflect,
                    kind: .reflect,
                    diameter: size - (lineWidth + spacing) * 2
                )

                ringView(
                    progress: animatedMood,
                    kind: .mood,
                    diameter: size - (lineWidth + spacing) * 4
                )
            }
            .frame(width: size, height: size)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .aspectRatio(1, contentMode: .fit)
        .onAppear { apply(animated: animate && !reduceMotion) }
        .onChange(of: rings.checkIn) { _, _ in apply(animated: !reduceMotion) }
        .onChange(of: rings.reflect) { _, _ in apply(animated: !reduceMotion) }
        .onChange(of: rings.mood) { _, _ in apply(animated: !reduceMotion) }
    }

    private func apply(animated: Bool) {
        if animated {
            withAnimation(.spring(response: 0.9, dampingFraction: 0.82).delay(0.05)) {
                animatedCheckIn = rings.checkIn
            }
            withAnimation(.spring(response: 0.9, dampingFraction: 0.82).delay(0.12)) {
                animatedReflect = rings.reflect
            }
            withAnimation(.spring(response: 0.9, dampingFraction: 0.82).delay(0.2)) {
                animatedMood = rings.mood
            }
        } else {
            animatedCheckIn = rings.checkIn
            animatedReflect = rings.reflect
            animatedMood = rings.mood
        }
    }

    private func ringView(progress: Double, kind: RingKind, diameter: CGFloat) -> some View {
        let clamped = max(0, min(progress, 1))
        let isClosed = progress >= 1.0
        return ZStack {
            Circle()
                .stroke(kind.solidColor.opacity(0.18), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: clamped)
                .stroke(
                    kind.gradient,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: isClosed ? kind.solidColor.opacity(0.45) : .clear, radius: 6)
        }
        .frame(width: max(diameter, 0), height: max(diameter, 0))
    }
}

struct MiniReflectionRings: View {
    let rings: ReflectionRings
    var lineWidth: CGFloat = 3
    var spacing: CGFloat = 1.5

    var body: some View {
        GeometryReader { proxy in
            let size = min(proxy.size.width, proxy.size.height)
            ZStack {
                miniRing(progress: rings.checkIn, kind: .checkIn, diameter: size)
                miniRing(progress: rings.reflect, kind: .reflect, diameter: size - (lineWidth + spacing) * 2)
                miniRing(progress: rings.mood, kind: .mood, diameter: size - (lineWidth + spacing) * 4)
            }
            .frame(width: size, height: size)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private func miniRing(progress: Double, kind: RingKind, diameter: CGFloat) -> some View {
        let clamped = max(0, min(progress, 1))
        return ZStack {
            Circle()
                .stroke(kind.solidColor.opacity(0.2), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: clamped)
                .stroke(kind.gradient, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
        .frame(width: max(diameter, 0), height: max(diameter, 0))
    }
}
