import Foundation

nonisolated struct WeeklyMomentum: Sendable {
    let daysActive: Int
    let totalEarned: Int
    let comebackCount: Int
    let sayItOutLoudCount: Int
    let hadComeback: Bool
    let weekStartDate: Date
    let weekEndDate: Date

    var highlights: [MomentumHighlight] {
        var result: [MomentumHighlight] = []

        if hadComeback {
            result.append(.comeback)
        }

        if daysActive >= 7 {
            result.append(.fullWeek)
        } else if daysActive >= 5 {
            result.append(.strongWeek)
        } else if daysActive >= 3 {
            result.append(.consistentWeek)
        } else if daysActive >= 1 {
            result.append(.showedUp)
        }

        if sayItOutLoudCount >= 3 {
            result.append(.voiceStrong)
        } else if sayItOutLoudCount >= 1 {
            result.append(.usedVoice)
        }

        if totalEarned >= 20 {
            result.append(.highVolume)
        } else if totalEarned >= 10 {
            result.append(.solidVolume)
        }

        return result
    }

    var isEmpty: Bool {
        daysActive == 0 && totalEarned == 0
    }
}

nonisolated enum MomentumHighlight: String, Sendable, CaseIterable, Identifiable {
    case fullWeek
    case strongWeek
    case consistentWeek
    case showedUp
    case comeback
    case voiceStrong
    case usedVoice
    case highVolume
    case solidVolume

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .fullWeek: "flame.fill"
        case .strongWeek: "bolt.fill"
        case .consistentWeek: "checkmark.circle.fill"
        case .showedUp: "arrow.counterclockwise"
        case .comeback: "heart.fill"
        case .voiceStrong: "quote.opening"
        case .usedVoice: "quote.opening"
        case .highVolume: "star.fill"
        case .solidVolume: "chart.bar.fill"
        }
    }

    var label: String {
        switch self {
        case .fullWeek: "Every day this week"
        case .strongWeek: "Strong consistency"
        case .consistentWeek: "Building consistency"
        case .showedUp: "Showed up"
        case .comeback: "Came back"
        case .voiceStrong: "Said it out loud"
        case .usedVoice: "Used your voice"
        case .highVolume: "High momentum"
        case .solidVolume: "Solid progress"
        }
    }

    var detail: String {
        switch self {
        case .fullWeek: "You showed up every single day."
        case .strongWeek: "You stayed with it most of the week."
        case .consistentWeek: "You kept coming back."
        case .showedUp: "You were here. That matters."
        case .comeback: "You came back after a break. That counts."
        case .voiceStrong: "You reinforced your progress out loud."
        case .usedVoice: "You said it. That takes something."
        case .highVolume: "You created real momentum this week."
        case .solidVolume: "Your effort showed up this week."
        }
    }
}
