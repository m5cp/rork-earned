import Foundation

@MainActor
class StreakShieldService {
    static let shared = StreakShieldService()
    private let storageKey = "streak_shield_data"

    var shieldData: StreakShield {
        get {
            guard let data = UserDefaults.standard.data(forKey: storageKey),
                  let decoded = try? JSONDecoder().decode(StreakShield.self, from: data) else {
                return StreakShield()
            }
            var shield = decoded
            if shield.weekResetNeeded {
                shield.freeShieldsUsedThisWeek = 0
                shield.lastWeekReset = DailyEntry.dateKey()
                save(shield)
            }
            return shield
        }
        set {
            save(newValue)
        }
    }

    func canUseShield(isPremium: Bool) -> Bool {
        let data = shieldData
        let maxShields = isPremium ? StreakShield.proShieldsPerWeek : StreakShield.freeShieldsPerWeek
        return data.freeShieldsUsedThisWeek < maxShields
    }

    func shieldsRemaining(isPremium: Bool) -> Int {
        let data = shieldData
        let maxShields = isPremium ? StreakShield.proShieldsPerWeek : StreakShield.freeShieldsPerWeek
        return max(0, maxShields - data.freeShieldsUsedThisWeek)
    }

    func useShield(for dateKey: String) {
        var data = shieldData
        data.freeShieldsUsedThisWeek += 1
        data.shieldActiveDates.append(dateKey)
        shieldData = data
    }

    func isShielded(_ dateKey: String) -> Bool {
        shieldData.shieldActiveDates.contains(dateKey)
    }

    private func save(_ shield: StreakShield) {
        guard let data = try? JSONEncoder().encode(shield) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}
