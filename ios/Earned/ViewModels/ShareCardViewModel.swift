import SwiftUI
import PhotosUI
import Photos

@Observable
@MainActor
class ShareCardViewModel {
    var backgroundImage: UIImage?
    var selectedFilter: PhotoFilter = .natural
    var filterIntensity: Float = 0.7
    var filteredImage: UIImage?
    var customText: String = ""
    var stickers: [CardSticker] = []
    var showPhotoPicker: Bool = false
    var showCamera: Bool = false
    var showBackgroundPicker: Bool = true
    var showStickerPicker: Bool = false
    var isSaving: Bool = false
    var savedToPhotos: Bool = false
    var renderedCard: UIImage?

    var textOffset: CGSize = .zero
    var textStylePreset: TextStylePreset = .solidWhite
    var textAlignment: TextAlignmentOption = .center
    var textScale: CGFloat = 1.0

    let wins: [Win]
    let earnedCount: Int
    let streak: Int
    let trendLabel: String
    var statement: String

    private let filterService = PhotoFilterService()

    init(wins: [Win], earnedCount: Int, streak: Int, trendLabel: String, statement: String) {
        self.wins = wins
        self.earnedCount = earnedCount
        self.streak = streak
        self.trendLabel = trendLabel
        self.statement = statement
    }

    var hasBackground: Bool { backgroundImage != nil }

    var displayImage: UIImage? { filteredImage ?? backgroundImage }

    func useDefaultBackground() {
        backgroundImage = nil
        filteredImage = nil
        showBackgroundPicker = false
    }

    func setPhoto(_ image: UIImage) {
        let resized = resizeIfNeeded(image, maxDimension: 1200)
        backgroundImage = resized
        applyCurrentFilter()
        showBackgroundPicker = false
    }

    func selectFilter(_ filter: PhotoFilter) {
        selectedFilter = filter
        applyCurrentFilter()
    }

    func updateIntensity(_ value: Float) {
        filterIntensity = value
        applyCurrentFilter()
    }

    func addSticker(_ symbol: String) {
        let randomX = CGFloat.random(in: -40...40)
        let randomY = CGFloat.random(in: -40...40)
        let sticker = CardSticker(symbol: symbol, offset: CGSize(width: randomX, height: randomY))
        stickers.append(sticker)
    }

    func removeSticker(_ id: String) {
        stickers.removeAll { $0.id == id }
    }

    func updateStickerOffset(_ id: String, offset: CGSize) {
        guard let index = stickers.firstIndex(where: { $0.id == id }) else { return }
        stickers[index].offset = offset
    }

    func saveToPhotos() async {
        guard let card = renderedCard else { return }
        isSaving = true
        defer { isSaving = false }

        let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        guard status == .authorized || status == .limited else { return }

        do {
            try await PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAsset(from: card)
            }
            savedToPhotos = true
            try? await Task.sleep(for: .seconds(2))
            savedToPhotos = false
        } catch {}
    }

    private func applyCurrentFilter() {
        guard let bg = backgroundImage else {
            filteredImage = nil
            return
        }
        if selectedFilter == .natural && filterIntensity == 0 {
            filteredImage = bg
            return
        }
        filteredImage = filterService.apply(filter: selectedFilter, intensity: filterIntensity, to: bg)
    }

    private func resizeIfNeeded(_ image: UIImage, maxDimension: CGFloat) -> UIImage {
        let size = image.size
        guard size.width > maxDimension || size.height > maxDimension else { return image }
        let scale = maxDimension / max(size.width, size.height)
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
