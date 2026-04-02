import Foundation

struct SayItOutLoudLibrary {

    private static let categoryStatements: [WinCategory: [String]] = [
        .discipline: [
            "I follow through",
            "I do what I say I will do",
            "I am building discipline",
            "I stayed disciplined",
            "I am becoming more consistent",
            "I kept my standards",
            "I am building discipline daily",
            "I stayed focused",
            "I held myself accountable",
        ],
        .resilience: [
            "I don't break under pressure",
            "I stayed steady",
            "I handled pressure",
            "I am getting stronger mentally",
            "I didn't fold under pressure",
            "I showed resilience",
            "I stayed grounded",
            "I didn't let doubt win",
            "I stayed composed",
        ],
        .selfKindness: [
            "I gave myself grace",
            "I am enough right now",
            "I recognized my own effort",
            "I stayed patient with myself",
            "I didn't beat myself up",
            "I gave myself credit",
            "I stayed true to myself",
        ],
        .courage: [
            "I did the hard thing",
            "I don't quit when it gets hard",
            "I faced it",
            "I showed mental toughness",
            "I handled discomfort",
            "I chose growth over comfort",
            "I showed strength when it counted",
        ],
        .progress: [
            "I am making progress",
            "I moved forward",
            "I am getting better",
            "I improved today",
            "I made something happen",
            "I am building something real",
            "I showed growth",
        ],
        .habits: [
            "I showed up today",
            "I followed through",
            "I kept showing up",
            "I showed effort",
            "I am proving it daily",
            "I showed up for myself",
            "I gave a real effort",
        ],
        .recovery: [
            "I kept going",
            "I did not give up",
            "I got through it",
            "I handled it",
            "I stayed strong",
            "I am not quitting",
            "I made a better choice",
        ],
        .relationships: [
            "I showed patience",
            "I stayed present",
            "I showed control",
        ],
    ]

    private static let powerStatements: [String] = [
        "I am earning my confidence",
        "I am becoming who I said I would be",
        "I am proving myself right",
        "I am not the same as before",
        "I earned this day",
        "I execute",
        "I earn it",
        "I am building momentum",
        "I trust my ability to follow through",
        "I am building confidence through action",
    ]

    private static let baseStatements: [String] = [
        "I showed up today",
        "I followed through",
        "I made progress today",
        "I kept going",
        "I did what I could",
        "I stayed steady today",
    ]

    static func statement(for earnedWins: [Win], date: Date = .now) -> String {
        let dayHash = DailyEntry.dateKey(for: date).hashValue
        var rng = SeededRNG(seed: UInt64(bitPattern: Int64(dayHash)))

        guard !earnedWins.isEmpty else {
            return baseStatements.randomElement(using: &rng) ?? "I showed up today"
        }

        let earnedCategories = Set(earnedWins.map(\.category))

        if earnedWins.count >= 4 {
            return powerStatements.randomElement(using: &rng) ?? "I earned this day"
        }

        var pool: [String] = []
        for category in earnedCategories {
            if let statements = categoryStatements[category] {
                pool.append(contentsOf: statements)
            }
        }

        if pool.isEmpty {
            pool = baseStatements
        }

        return pool.randomElement(using: &rng) ?? "I showed up today"
    }

    static func statement(for date: Date = .now) -> String {
        let dayHash = DailyEntry.dateKey(for: date).hashValue
        var rng = SeededRNG(seed: UInt64(bitPattern: Int64(dayHash)))
        return baseStatements.randomElement(using: &rng) ?? "I showed up today"
    }
}
