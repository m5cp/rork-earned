import SwiftUI

struct FilterStripView: View {
    let selectedFilter: PhotoFilter
    let intensity: Float
    let onSelectFilter: (PhotoFilter) -> Void
    let onIntensityChange: (Float) -> Void

    var body: some View {
        VStack(spacing: 16) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(PhotoFilter.allCases) { filter in
                        filterChip(filter)
                    }
                }
            }
            .contentMargins(.horizontal, 20)

            if selectedFilter != .natural {
                HStack(spacing: 12) {
                    Image(systemName: "circle.lefthalf.filled")
                        .font(.caption)
                        .foregroundStyle(.tertiary)

                    Slider(value: Binding(
                        get: { intensity },
                        set: { onIntensityChange($0) }
                    ), in: 0...1)
                    .tint(.primary)

                    Text("\(Int(intensity * 100))")
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                        .frame(width: 30, alignment: .trailing)
                }
                .padding(.horizontal, 20)
            }
        }
    }

    private func filterChip(_ filter: PhotoFilter) -> some View {
        let isSelected = filter == selectedFilter
        return Button {
            onSelectFilter(filter)
        } label: {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(isSelected ? Color(.label) : Color(.tertiarySystemFill))
                        .frame(width: 52, height: 52)

                    Image(systemName: filter.icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(isSelected ? Color(.systemBackground) : .secondary)
                }

                Text(filter.displayName)
                    .font(.caption2.weight(isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? .primary : .secondary)
            }
        }
        .sensoryFeedback(.selection, trigger: selectedFilter)
        .accessibilityLabel("\(filter.displayName) filter")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
