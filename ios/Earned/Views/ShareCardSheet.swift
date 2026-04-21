import SwiftUI
import PhotosUI

struct ShareCardSheet: View {
    @Environment(\.dismiss) private var dismiss
    let wins: [Win]
    let affirmation: String
    let earnedCount: Int
    let streak: Int
    let trendLabel: String

    @State private var viewModel: ShareCardViewModel?
    @State private var photoPickerItem: PhotosPickerItem?
    @State private var renderedImage: UIImage?
    @State private var activeTab: EditorTab? = nil
    @State private var isEditingText: Bool = false
    @State private var editingField: EditingField? = nil

    nonisolated enum EditorTab: String, CaseIterable, Identifiable {
        case filters, text, stickers
        var id: String { rawValue }
        var icon: String {
            switch self {
            case .filters: "camera.filters"
            case .text: "textformat"
            case .stickers: "star.fill"
            }
        }
        var label: String {
            switch self {
            case .filters: "Filters"
            case .text: "Text"
            case .stickers: "Stickers"
            }
        }
    }

    nonisolated enum EditingField: Hashable {
        case headline, extra
    }

    var body: some View {
        Group {
            if let vm = viewModel {
                if vm.showBackgroundPicker {
                    NavigationStack {
                        backgroundPickerContent(vm)
                            .navigationTitle("Share Card")
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbar {
                                ToolbarItem(placement: .cancellationAction) {
                                    Button("Cancel") { dismiss() }
                                }
                            }
                    }
                } else {
                    fullScreenEditor(vm)
                }
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = ShareCardViewModel(
                    wins: wins,
                    earnedCount: earnedCount,
                    streak: streak,
                    trendLabel: trendLabel,
                    statement: affirmation
                )
            }
        }
        .onChange(of: photoPickerItem) { _, newValue in
            guard let item = newValue else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    viewModel?.setPhoto(image)
                }
                photoPickerItem = nil
            }
        }
        .sheet(isPresented: Binding(
            get: { viewModel?.showStickerPicker ?? false },
            set: { viewModel?.showStickerPicker = $0 }
        )) {
            if let vm = viewModel {
                StickerPickerView { symbol in
                    vm.addSticker(symbol)
                }
            }
        }
    }

    private func backgroundPickerContent(_ vm: ShareCardViewModel) -> some View {
        ScrollView {
            ShareCardBackgroundPicker(
                onTakePhoto: { vm.showCamera = true },
                onChoosePhoto: { vm.showPhotoPicker = true },
                onUseDefault: { vm.useDefaultBackground() }
            )
            .frame(maxWidth: .infinity)
        }
        .scrollIndicators(.hidden)
        .photosPicker(isPresented: Binding(
            get: { vm.showPhotoPicker },
            set: { vm.showPhotoPicker = $0 }
        ), selection: $photoPickerItem, matching: .images)
        .fullScreenCover(isPresented: Binding(
            get: { vm.showCamera },
            set: { vm.showCamera = $0 }
        )) {
            CameraProxyView { image in
                vm.setPhoto(image)
                vm.showCamera = false
            } onCancel: {
                vm.showCamera = false
            }
        }
    }

    @ViewBuilder
    private func fullScreenEditor(_ vm: ShareCardViewModel) -> some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                topBar(vm)

                ZStack {
                    ShareCardCanvasView(viewModel: vm, isRendering: false)
                        .clipShape(.rect(cornerRadius: 20))
                        .padding(.horizontal, 16)
                        .shadow(color: .black.opacity(0.5), radius: 20, y: 8)

                    if activeTab != nil {
                        Color.black.opacity(0.001)
                            .onTapGesture {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                                    activeTab = nil
                                    isEditingText = false
                                    editingField = nil
                                }
                            }
                            .allowsHitTesting(activeTab != nil)
                    }
                }
                .frame(maxHeight: .infinity)

                toolBar(vm)

                Spacer().frame(height: 16)

                bottomBar(vm)
            }

            if activeTab != nil {
                VStack {
                    Spacer()
                    toolPanel(vm)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .ignoresSafeArea(.container, edges: .bottom)
            }
        }
        .onAppear { renderCard(vm) }
        .onChange(of: vm.filteredImage) { _, _ in renderCard(vm) }
        .onChange(of: vm.customText) { _, _ in renderCard(vm) }
        .onChange(of: vm.statement) { _, _ in renderCard(vm) }
        .onChange(of: vm.stickers) { _, _ in renderCard(vm) }
        .onChange(of: vm.selectedFilter) { _, _ in renderCard(vm) }
        .onChange(of: vm.backgroundImage) { _, _ in renderCard(vm) }
        .onChange(of: vm.textStylePreset) { _, _ in renderCard(vm) }
        .onChange(of: vm.textAlignment) { _, _ in renderCard(vm) }
        .onChange(of: vm.textScale) { _, _ in renderCard(vm) }
        .onChange(of: vm.textOffset.width) { _, _ in renderCard(vm) }
        .onChange(of: vm.textOffset.height) { _, _ in renderCard(vm) }
    }

    private func topBar(_ vm: ShareCardViewModel) -> some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Text("Cancel")
                    .font(.body.weight(.medium))
                    .foregroundStyle(.white)
            }

            Spacer()

            Text("Share Card")
                .font(.headline.weight(.bold))
                .foregroundStyle(.white)

            Spacer()

            Button {
                vm.showBackgroundPicker = true
            } label: {
                Image(systemName: "photo.badge.plus")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(.white.opacity(0.15))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    private func toolBar(_ vm: ShareCardViewModel) -> some View {
        HStack(spacing: 0) {
            ForEach(EditorTab.allCases) { tab in
                let isActive = activeTab == tab
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                        if activeTab == tab {
                            activeTab = nil
                            isEditingText = false
                            editingField = nil
                        } else {
                            activeTab = tab
                            isEditingText = tab == .text
                        }
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 18, weight: .semibold))
                            .frame(width: 44, height: 44)
                            .background(
                                isActive
                                    ? EarnedColors.accent
                                    : .white.opacity(0.12)
                            )
                            .foregroundStyle(isActive ? .white : .white.opacity(0.8))
                            .clipShape(Circle())

                        Text(tab.label)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(isActive ? EarnedColors.accent : .white.opacity(0.6))
                    }
                    .frame(maxWidth: .infinity)
                }
                .sensoryFeedback(.selection, trigger: activeTab)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
        .padding(.bottom, 4)
    }

    @ViewBuilder
    private func toolPanel(_ vm: ShareCardViewModel) -> some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(.white.opacity(0.3))
                .frame(width: 36, height: 4)
                .padding(.top, 10)
                .padding(.bottom, 8)

            Group {
                switch activeTab {
                case .filters:
                    filtersPanel(vm)
                case .text:
                    textPanel(vm)
                case .stickers:
                    stickersPanel(vm)
                case .none:
                    EmptyView()
                }
            }
            .padding(.bottom, 34)
        }
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .environment(\.colorScheme, .dark)
                .ignoresSafeArea(edges: .bottom)
        )
    }

    private func filtersPanel(_ vm: ShareCardViewModel) -> some View {
        VStack(spacing: 12) {
            if vm.hasBackground {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(PhotoFilter.allCases) { filter in
                            let isSelected = filter == vm.selectedFilter
                            Button {
                                vm.selectFilter(filter)
                            } label: {
                                VStack(spacing: 5) {
                                    Image(systemName: filter.icon)
                                        .font(.system(size: 16, weight: .semibold))
                                        .frame(width: 48, height: 48)
                                        .background(isSelected ? EarnedColors.accent : .white.opacity(0.1))
                                        .foregroundStyle(isSelected ? .white : .white.opacity(0.7))
                                        .clipShape(Circle())

                                    Text(filter.displayName)
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundStyle(isSelected ? .white : .white.opacity(0.5))
                                }
                            }
                        }
                    }
                }
                .contentMargins(.horizontal, 20)

                if vm.selectedFilter != .natural {
                    HStack(spacing: 10) {
                        Image(systemName: "circle.lefthalf.filled")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.4))

                        Slider(value: Binding(
                            get: { vm.filterIntensity },
                            set: { vm.updateIntensity($0) }
                        ), in: 0...1)
                        .tint(EarnedColors.accent)

                        Text("\(Int(vm.filterIntensity * 100))")
                            .font(.caption.monospacedDigit().weight(.semibold))
                            .foregroundStyle(.white.opacity(0.6))
                            .frame(width: 30, alignment: .trailing)
                    }
                    .padding(.horizontal, 20)
                }
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "photo")
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.4))
                    Text("Add a photo to use filters")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white.opacity(0.5))

                    Button {
                        viewModel?.showBackgroundPicker = true
                    } label: {
                        Text("Change Background")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(EarnedColors.accent)
                    }
                    .padding(.top, 2)
                }
                .padding(.vertical, 8)
            }
        }
    }

    private func textPanel(_ vm: ShareCardViewModel) -> some View {
        VStack(spacing: 14) {
            HStack(spacing: 10) {
                VStack(spacing: 4) {
                    TextField("I owned today.", text: Binding(
                        get: { vm.statement },
                        set: { vm.statement = String($0.prefix(40)) }
                    ))
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 11)
                    .background(.white.opacity(0.1))
                    .clipShape(.rect(cornerRadius: 12))
                    .onTapGesture { editingField = .headline }

                    Text("HEADLINE · \(vm.statement.count)/40")
                        .font(.system(size: 9, weight: .heavy))
                        .tracking(0.5)
                        .foregroundStyle(.white.opacity(0.35))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 4)
                }

                VStack(spacing: 4) {
                    TextField("Extra text...", text: Binding(
                        get: { vm.customText },
                        set: { vm.customText = String($0.prefix(60)) }
                    ))
                    .font(.subheadline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 11)
                    .background(.white.opacity(0.1))
                    .clipShape(.rect(cornerRadius: 12))
                    .onTapGesture { editingField = .extra }

                    Text("EXTRA · \(vm.customText.count)/60")
                        .font(.system(size: 9, weight: .heavy))
                        .tracking(0.5)
                        .foregroundStyle(.white.opacity(0.35))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 4)
                }
            }
            .padding(.horizontal, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(TextStylePreset.allCases) { preset in
                        let isSelected = vm.textStylePreset == preset
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                vm.textStylePreset = preset
                            }
                        } label: {
                            Text(preset.label)
                                .font(.system(size: 12, weight: .bold))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(isSelected ? EarnedColors.accent : .white.opacity(0.1))
                                .foregroundStyle(isSelected ? .white : .white.opacity(0.7))
                                .clipShape(Capsule())
                        }
                    }
                }
            }
            .contentMargins(.horizontal, 16)

            HStack(spacing: 12) {
                HStack(spacing: 2) {
                    ForEach(TextAlignmentOption.allCases) { option in
                        let isSelected = vm.textAlignment == option
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                vm.textAlignment = option
                            }
                        } label: {
                            Image(systemName: option.icon)
                                .font(.system(size: 13, weight: .bold))
                                .frame(width: 36, height: 32)
                                .background(isSelected ? EarnedColors.accent : .white.opacity(0.1))
                                .foregroundStyle(isSelected ? .white : .white.opacity(0.7))
                                .clipShape(.rect(cornerRadius: 8))
                        }
                    }
                }

                HStack(spacing: 6) {
                    Image(systemName: "textformat.size.smaller")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white.opacity(0.4))

                    Slider(
                        value: Binding(
                            get: { vm.textScale },
                            set: { vm.textScale = $0 }
                        ),
                        in: 0.7...1.4,
                        step: 0.1
                    )
                    .tint(EarnedColors.accent)

                    Image(systemName: "textformat.size.larger")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white.opacity(0.4))
                }

                if vm.textOffset != .zero {
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            vm.textOffset = .zero
                        }
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 13, weight: .bold))
                            .frame(width: 32, height: 32)
                            .background(.white.opacity(0.1))
                            .foregroundStyle(EarnedColors.accent)
                            .clipShape(Circle())
                    }
                }
            }
            .padding(.horizontal, 16)

            HStack(spacing: 5) {
                Image(systemName: "hand.draw.fill")
                    .font(.system(size: 10))
                Text("Drag text on card to reposition")
                    .font(.system(size: 11, weight: .semibold))
            }
            .foregroundStyle(.white.opacity(0.35))
        }
    }

    private func stickersPanel(_ vm: ShareCardViewModel) -> some View {
        VStack(spacing: 12) {
            Button {
                vm.showStickerPicker = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "plus.circle.fill")
                        .font(.body.weight(.semibold))
                    Text("Add Sticker")
                        .font(.subheadline.weight(.bold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(EarnedColors.accent)
                .clipShape(.rect(cornerRadius: 12))
            }
            .padding(.horizontal, 16)

            if !vm.stickers.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(vm.stickers) { sticker in
                            HStack(spacing: 6) {
                                Image(systemName: sticker.symbol)
                                    .font(.subheadline)
                                    .foregroundStyle(.white)

                                Button {
                                    vm.removeSticker(sticker.id)
                                } label: {
                                    Image(systemName: "xmark")
                                        .font(.caption2.weight(.bold))
                                        .foregroundStyle(.white.opacity(0.5))
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(.white.opacity(0.12))
                            .clipShape(Capsule())
                        }
                    }
                }
                .contentMargins(.horizontal, 16)

                HStack(spacing: 5) {
                    Image(systemName: "hand.draw.fill")
                        .font(.system(size: 10))
                    Text("Drag stickers on card to reposition")
                        .font(.system(size: 11, weight: .semibold))
                }
                .foregroundStyle(.white.opacity(0.35))
            }
        }
    }

    private func bottomBar(_ vm: ShareCardViewModel) -> some View {
        HStack(spacing: 10) {
            Button {
                Task { await vm.saveToPhotos() }
            } label: {
                HStack(spacing: 5) {
                    if vm.savedToPhotos {
                        Image(systemName: "checkmark")
                        Text("Saved")
                    } else if vm.isSaving {
                        ProgressView()
                            .controlSize(.small)
                            .tint(.white)
                    } else {
                        Image(systemName: "square.and.arrow.down")
                        Text("Save")
                    }
                }
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(.white.opacity(0.15))
                .clipShape(.rect(cornerRadius: 14))
            }

            if let card = vm.renderedCard {
                ShareLink(
                    item: Image(uiImage: card),
                    message: Text("Day \(streak) earned. ✨ — Earned app"),
                    preview: SharePreview("Day \(streak) earned — Earned", image: Image(uiImage: card))
                ) {
                    HStack(spacing: 5) {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share")
                    }
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(.white)
                    .clipShape(.rect(cornerRadius: 14))
                }
            } else {
                HStack(spacing: 5) {
                    Image(systemName: "square.and.arrow.up")
                    Text("Share")
                }
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.black.opacity(0.3))
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(.white.opacity(0.3))
                .clipShape(.rect(cornerRadius: 14))
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }

    @MainActor
    private func renderCard(_ vm: ShareCardViewModel) {
        let renderView = ShareCardCanvasView(viewModel: vm, isRendering: true)
            .frame(width: 390, height: 520)

        let renderer = ImageRenderer(content: renderView)
        renderer.scale = 3
        let image = renderer.uiImage
        vm.renderedCard = image
        renderedImage = image
    }
}
