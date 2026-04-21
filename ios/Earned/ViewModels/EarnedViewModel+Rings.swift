import Foundation

extension EarnedViewModel {
    func rings(for date: Date) -> ReflectionRings {
        let key = DailyEntry.dateKey(for: date)
        let isToday = Calendar.current.isDateInToday(date)
        let entry = entries[key]

        let checkInProgress: Double = {
            guard let entry else { return isToday ? min(progress, 1.0) : 0 }
            let responded = entry.earnedWinIDs.count + entry.skippedWinIDs.count
            let comebackCounted = entry.earnedWinIDs.contains(Win.comebackID) ? 1 : 0
            let adjusted = max(0, responded - comebackCounted)
            if adjusted >= 5 { return 1.0 }
            if isToday && !checkInComplete {
                let fromProgress = min(progress, 1.0)
                return max(Double(adjusted) / 5.0, fromProgress)
            }
            return min(Double(adjusted) / 5.0, 1.0)
        }()

        let reflectProgress: Double = {
            guard let entry else { return 0 }
            let responded = entry.earnedWinIDs.count + entry.skippedWinIDs.count
            let comebackCounted = entry.earnedWinIDs.contains(Win.comebackID) ? 1 : 0
            let adjusted = max(0, responded - comebackCounted)
            if adjusted >= 5 { return 1.0 }
            if (entry.journalNote?.isEmpty == false) || (entry.aiJournalEntry?.isEmpty == false) { return 1.0 }
            if entry.sayItOutLoudCompleted { return 1.0 }
            if entry.weeklyReflection?.isEmpty == false { return 1.0 }
            if isToday && adjusted > 0 {
                return Double(adjusted) / 5.0
            }
            return 0
        }()

        let moodProgress: Double = {
            guard let entry else { return 0 }
            return entry.mood != nil ? 1.0 : 0.0
        }()

        return ReflectionRings(
            checkIn: checkInProgress,
            reflect: reflectProgress,
            mood: moodProgress
        )
    }

    var todayRings: ReflectionRings {
        rings(for: .now)
    }
}
