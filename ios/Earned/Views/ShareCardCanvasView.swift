import SwiftUI

struct ShareCardCanvasView: View {
    let viewModel: ShareCardViewModel
    let isRendering: Bool

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: .now)
    }

    var body: some View {
        ZStack {
            backgroundLayer

            if isRendering {
                renderingContent
            } else {
                interactiveContent
            }
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(3.0 / 4.0, contentMode: .fit)
        .clipShape(.rect(cornerRadius: isRendering ? 0 : 24))
    }

    @ViewBuilder
    private var backgroundLayer: some View {
        if let image = viewModel.displayImage {
            Color.clear
                .overlay {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .allowsHitTesting(false)
                }
                .clipped()
                .overlay {
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.7)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
        } else {
            defaultPremiumBackground
        }
    }

    private var defaultPremiumBackground: some View {
        ZStack {
            LinearGradient(
                stops: [
                    .init(color: Color(red: 0.06, green: 0.04, blue: 0.18), location: 0),
                    .init(color: Color(red: 0.08, green: 0.06, blue: 0.24), location: 0.3),
                    .init(color: Color(red: 0.12, green: 0.08, blue: 0.30), location: 0.6),
                    .init(color: Color(red: 0.04, green: 0.03, blue: 0.12), location: 1.0)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialGradient(
                colors: [
                    Color(red: 0.25, green: 0.15, blue: 0.65).opacity(0.5),
                    Color(red: 0.15, green: 0.10, blue: 0.45).opacity(0.25),
                    .clear
                ],
                center: .init(x: 0.65, y: 0.35),
                startRadius: 10,
                endRadius: 280
            )

            RadialGradient(
                colors: [
                    EarnedColors.accent.opacity(0.3),
                    EarnedColors.accent.opacity(0.08),
                    .clear
                ],
                center: .init(x: 0.3, y: 0.55),
                startRadius: 5,
                endRadius: 200
            )

            EllipticalGradient(
                colors: [
                    Color(red: 0.4, green: 0.2, blue: 0.8).opacity(0.18),
                    .clear
                ],
                center: .init(x: 0.8, y: 0.7),
                startRadiusFraction: 0,
                endRadiusFraction: 0.5
            )

            LinearGradient(
                colors: [
                    .black.opacity(0.3),
                    .clear,
                    .clear,
                    .black.opacity(0.25)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            Rectangle()
                .fill(
                    RadialGradient(
                        colors: [.clear, .black.opacity(0.15)],
                        center: .center,
                        startRadius: 100,
                        endRadius: 350
                    )
                )

            Canvas { context, size in
                for i in 0..<60 {
                    let x = CGFloat((i * 37 + 13) % Int(size.width))
                    let y = CGFloat((i * 53 + 7) % Int(size.height))
                    let opacity = Double((i * 17) % 10) / 100.0
                    let dotSize = CGFloat((i * 3) % 3 + 1)
                    context.opacity = opacity
                    context.fill(
                        Path(ellipseIn: CGRect(x: x, y: y, width: dotSize, height: dotSize)),
                        with: .color(.white)
                    )
                }
            }
            .allowsHitTesting(false)
        }
    }

    private var renderingContent: some View {
        VStack(spacing: 0) {
            Spacer()

            styledTextBlock
                .offset(viewModel.textOffset)

            Spacer()
                .frame(height: 24)

            statsRow
                .padding(.horizontal, 28)

            if !viewModel.customText.isEmpty {
                Text(viewModel.customText)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.white.opacity(0.85))
                    .multilineTextAlignment(viewModel.textAlignment.alignment)
                    .shadow(color: .black.opacity(0.3), radius: 3, y: 1)
                    .padding(.horizontal, 28)
                    .padding(.top, 8)
            }

            brandMark
                .padding(.top, 12)
                .padding(.bottom, 24)
        }
        .padding(.horizontal, 4)
    }

    private var interactiveContent: some View {
        ZStack {
            VStack(spacing: 0) {
                Spacer()
                Spacer()
                Spacer()

                statsRow
                    .padding(.horizontal, 28)

                if !viewModel.customText.isEmpty {
                    Text(viewModel.customText)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.white.opacity(0.85))
                        .multilineTextAlignment(viewModel.textAlignment.alignment)
                        .shadow(color: .black.opacity(0.3), radius: 3, y: 1)
                        .padding(.horizontal, 28)
                        .padding(.top, 8)
                }

                brandMark
                    .padding(.top, 12)
                    .padding(.bottom, 24)
            }
            .padding(.horizontal, 4)

            draggableTextBlock
        }
    }

    private var draggableTextBlock: some View {
        styledTextBlock
            .offset(viewModel.textOffset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        viewModel.textOffset = CGSize(
                            width: value.translation.width,
                            height: value.translation.height
                        )
                    }
                    .onEnded { value in
                        let clamped = CGSize(
                            width: max(-120, min(120, value.translation.width)),
                            height: max(-180, min(100, value.translation.height))
                        )
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            viewModel.textOffset = clamped
                        }
                    }
            )
    }

    @ViewBuilder
    private var styledTextBlock: some View {
        let textContent = VStack(spacing: 8) {
            Text(viewModel.statement)
                .font(.system(size: 24 * viewModel.textScale, weight: .heavy, design: .default))
                .multilineTextAlignment(viewModel.textAlignment.alignment)
                .frame(maxWidth: .infinity, alignment: viewModel.textAlignment.horizontalAlignment == .leading ? .leading : viewModel.textAlignment.horizontalAlignment == .trailing ? .trailing : .center)
                .lineLimit(3)
                .minimumScaleFactor(0.6)

            Text(formattedDate)
                .font(.system(.caption, design: .rounded, weight: .semibold))
                .opacity(0.55)
        }
        .padding(.horizontal, 28)

        switch viewModel.textStylePreset {
        case .solidWhite:
            textContent
                .foregroundStyle(.white)

        case .solidBlack:
            textContent
                .foregroundStyle(.black)

        case .whiteShadow:
            textContent
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.6), radius: 8, y: 4)
                .shadow(color: .black.opacity(0.3), radius: 16, y: 6)

        case .blurPanel:
            textContent
                .foregroundStyle(.white)
                .padding(.vertical, 16)
                .padding(.horizontal, 20)
                .background(.ultraThinMaterial.opacity(0.8))
                .clipShape(.rect(cornerRadius: 16))
                .padding(.horizontal, 8)

        case .darkOverlay:
            textContent
                .foregroundStyle(.white)
                .padding(.vertical, 16)
                .padding(.horizontal, 20)
                .background(Color.black.opacity(0.55))
                .clipShape(.rect(cornerRadius: 16))
                .padding(.horizontal, 8)

        case .boldContrast:
            textContent
                .foregroundStyle(.white)
                .shadow(color: .black, radius: 2, y: 1)
                .shadow(color: .black.opacity(0.8), radius: 12, y: 4)
                .shadow(color: .black.opacity(0.4), radius: 24, y: 8)
        }
    }

    private var statsRow: some View {
        HStack(spacing: 0) {
            statPill(value: "\(viewModel.earnedCount)", label: "EARNED")
            Spacer()
            statPill(value: "\(viewModel.streak)", label: "STREAK")
            Spacer()
            statPill(value: viewModel.trendLabel, label: "MOMENTUM")
        }
    }

    private func statPill(value: String, label: String) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.system(.title3, design: .rounded, weight: .black))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(label)
                .font(.system(size: 9, weight: .heavy, design: .rounded))
                .tracking(1.5)
                .foregroundStyle(.white.opacity(0.5))
        }
    }

    private var brandMark: some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 1)
                .fill(.white.opacity(0.2))
                .frame(width: 16, height: 2)

            Text("MVM EARNED")
                .font(.system(size: 9, weight: .heavy, design: .rounded))
                .tracking(3)
                .foregroundStyle(.white.opacity(0.3))

            RoundedRectangle(cornerRadius: 1)
                .fill(.white.opacity(0.2))
                .frame(width: 16, height: 2)
        }
    }

    @ViewBuilder
    private var stickerLayer: some View {
        ForEach(viewModel.stickers) { sticker in
            StickerView(sticker: sticker) { newOffset in
                viewModel.updateStickerOffset(sticker.id, offset: newOffset)
            } onRemove: {
                viewModel.removeSticker(sticker.id)
            }
        }
    }
}

struct StickerView: View {
    let sticker: CardSticker
    let onMove: (CGSize) -> Void
    let onRemove: () -> Void

    @State private var dragOffset: CGSize = .zero

    var body: some View {
        Image(systemName: sticker.symbol)
            .font(.system(size: 36))
            .foregroundStyle(.white)
            .shadow(color: .black.opacity(0.4), radius: 4, y: 2)
            .offset(x: sticker.offset.width + dragOffset.width, y: sticker.offset.height + dragOffset.height)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        dragOffset = value.translation
                    }
                    .onEnded { value in
                        let final = CGSize(
                            width: sticker.offset.width + value.translation.width,
                            height: sticker.offset.height + value.translation.height
                        )
                        dragOffset = .zero
                        onMove(final)
                    }
            )
            .contextMenu {
                Button(role: .destructive) {
                    onRemove()
                } label: {
                    Label("Remove", systemImage: "trash")
                }
            }
    }
}
