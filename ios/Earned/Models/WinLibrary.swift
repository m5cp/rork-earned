import Foundation

struct WinLibrary {
    static let all: [Win] = [

        // MARK: - Habits (showing up)

        Win(text: "Did you show up for yourself today?", category: .habits),
        Win(text: "Did you move your body, even a little?", category: .habits),
        Win(text: "Did you drink some water today?", category: .habits),
        Win(text: "Did you stay present for a moment today?", category: .habits),
        Win(text: "Did you make time for something that matters?", category: .habits),
        Win(text: "Did you get some fresh air today?", category: .habits),

        // MARK: - Self-Kindness

        Win(text: "Were you kind to yourself today?", category: .selfKindness),
        Win(text: "Did you give yourself grace?", category: .selfKindness),
        Win(text: "Did you let yourself rest when you needed it?", category: .selfKindness),
        Win(text: "Did you give yourself credit for something?", category: .selfKindness),
        Win(text: "Did you speak to yourself gently today?", category: .selfKindness),
        Win(text: "Did you let yourself be human today?", category: .selfKindness),

        // MARK: - Progress

        Win(text: "Did you make a little progress today?", category: .progress),
        Win(text: "Did you learn something new?", category: .progress),
        Win(text: "Did you take one small step forward?", category: .progress),
        Win(text: "Did you create or build something today?", category: .progress),

        // MARK: - Courage

        Win(text: "Did you try something outside your comfort zone?", category: .courage),
        Win(text: "Did you do something you were putting off?", category: .courage),
        Win(text: "Did you ask for help when you needed it?", category: .courage),

        // MARK: - Resilience

        Win(text: "Did you stay steady through a hard moment?", category: .resilience),
        Win(text: "Did you pause before reacting today?", category: .resilience),
        Win(text: "Did you handle stress with care today?", category: .resilience),

        // MARK: - Relationships

        Win(text: "Did you connect with someone today?", category: .relationships),
        Win(text: "Did you listen well to someone?", category: .relationships),
        Win(text: "Did you show someone you care?", category: .relationships),

        // MARK: - Discipline (gentle framing)

        Win(text: "Did you keep a promise to yourself?", category: .discipline),
        Win(text: "Did you stay focused on what matters?", category: .discipline),

        // MARK: - Recovery

        Win(text: "Did you keep going, even slowly?", category: .recovery),
        Win(text: "Did you give yourself a fresh start today?", category: .recovery),
    ]

    static func dailySet(for date: Date = .now, count: Int = 5) -> [Win] {
        let dayHash = DailyEntry.dateKey(for: date).hashValue
        var rng = SeededRNG(seed: UInt64(bitPattern: Int64(dayHash)))

        var pool = all
        pool.shuffle(using: &rng)

        var result: [Win] = []
        var usedCategories = Set<WinCategory>()

        for win in pool where result.count < count {
            if !usedCategories.contains(win.category) {
                result.append(win)
                usedCategories.insert(win.category)
            }
        }

        if result.count < count {
            for win in pool where result.count < count {
                if !result.contains(where: { $0.id == win.id }) {
                    result.append(win)
                }
            }
        }

        result.shuffle(using: &rng)
        return result
    }
}

nonisolated struct SeededRNG: RandomNumberGenerator, Sendable {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed == 0 ? 1 : seed
    }

    mutating func next() -> UInt64 {
        state &+= 0x9e3779b97f4a7c15
        var z = state
        z = (z ^ (z >> 30)) &* 0xbf58476d1ce4e5b9
        z = (z ^ (z >> 27)) &* 0x94d049bb133111eb
        return z ^ (z >> 31)
    }
}
