import SwiftUI

nonisolated enum TextStylePreset: String, CaseIterable, Identifiable, Sendable {
    case solidWhite
    case solidBlack
    case whiteShadow
    case blurPanel
    case darkOverlay
    case boldContrast

    var id: String { rawValue }

    var label: String {
        switch self {
        case .solidWhite: "White"
        case .solidBlack: "Black"
        case .whiteShadow: "Shadow"
        case .blurPanel: "Blur"
        case .darkOverlay: "Box"
        case .boldContrast: "Bold"
        }
    }

    var icon: String {
        switch self {
        case .solidWhite: "textformat"
        case .solidBlack: "textformat"
        case .whiteShadow: "shadow"
        case .blurPanel: "rectangle.on.rectangle"
        case .darkOverlay: "rectangle.fill"
        case .boldContrast: "bold"
        }
    }
}

nonisolated enum TextAlignmentOption: String, CaseIterable, Identifiable, Sendable {
    case leading
    case center
    case trailing

    var id: String { rawValue }

    var alignment: TextAlignment {
        switch self {
        case .leading: .leading
        case .center: .center
        case .trailing: .trailing
        }
    }

    var horizontalAlignment: HorizontalAlignment {
        switch self {
        case .leading: .leading
        case .center: .center
        case .trailing: .trailing
        }
    }

    var icon: String {
        switch self {
        case .leading: "text.alignleft"
        case .center: "text.aligncenter"
        case .trailing: "text.alignright"
        }
    }
}
