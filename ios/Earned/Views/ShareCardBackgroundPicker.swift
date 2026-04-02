import SwiftUI

struct ShareCardBackgroundPicker: View {
    let onTakePhoto: () -> Void
    let onChoosePhoto: () -> Void
    let onUseDefault: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text("Your Card")
                    .font(.system(.title2, design: .default, weight: .heavy))
                    .padding(.top, 4)

                Text("Choose a powerful background")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(EarnedColors.accent.opacity(0.7))
            }

            VStack(spacing: 12) {
                backgroundOption(
                    title: "Take Photo",
                    subtitle: "Capture the moment",
                    icon: "camera.fill",
                    gradient: LinearGradient(colors: [EarnedColors.accent, EarnedColors.accentGlow], startPoint: .topLeading, endPoint: .bottomTrailing),
                    action: onTakePhoto
                )

                backgroundOption(
                    title: "Choose Photo",
                    subtitle: "From your library",
                    icon: "photo.fill",
                    gradient: LinearGradient(colors: [EarnedColors.momentum, Color(red: 0.7, green: 0.4, blue: 1.0)], startPoint: .topLeading, endPoint: .bottomTrailing),
                    action: onChoosePhoto
                )

                backgroundOption(
                    title: "Bold Default",
                    subtitle: "Deep gradient with energy",
                    icon: "sparkles",
                    gradient: LinearGradient(colors: [Color(red: 0.15, green: 0.2, blue: 0.45), Color(red: 0.25, green: 0.15, blue: 0.5)], startPoint: .topLeading, endPoint: .bottomTrailing),
                    action: onUseDefault
                )
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 24)
    }

    private func backgroundOption(title: String, subtitle: String, icon: String, gradient: LinearGradient, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(gradient)
                        .frame(width: 52, height: 52)

                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.body.weight(.bold))
                        .foregroundStyle(.primary)

                    Text(subtitle)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(EarnedColors.accent.opacity(0.5))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(EarnedColors.accent.opacity(0.4))
            }
            .padding(16)
            .background(Color(.secondarySystemBackground))
            .clipShape(.rect(cornerRadius: 16))
        }
    }
}
