import Foundation

struct SayItOutLoudLibrary {

    private static let categoryStatements: [WinCategory: [String]] = [
        .discipline: [
            "I follow through on what matters",
            "I do what I say I will do",
            "I am building real discipline",
            "I stayed disciplined today",
            "I am becoming more consistent every day",
            "I held the standard I set for myself",
            "I am building discipline one day at a time",
            "I stayed focused on what mattered",
            "I held myself accountable today",
        ],
        .resilience: [
            "I do not break under pressure",
            "I stayed steady when it counted",
            "I handled the pressure today",
            "I am getting stronger mentally",
            "I did not fold when it got hard",
            "I showed real resilience today",
            "I stayed grounded through it",
            "I did not let doubt win today",
            "I stayed composed under pressure",
        ],
        .selfKindness: [
            "I gave myself grace today",
            "I am enough, right here, right now",
            "I recognized my own effort today",
            "I stayed patient with myself",
            "I spoke to myself with respect",
            "I gave myself the credit I earned",
            "I stayed true to who I am",
        ],
        .courage: [
            "I did the hard thing today",
            "I do not quit when it gets hard",
            "I faced it head on",
            "I showed real mental toughness",
            "I moved through the discomfort",
            "I chose growth over comfort",
            "I showed strength when it counted",
        ],
        .progress: [
            "I am making real progress",
            "I moved myself forward today",
            "I am getting better every day",
            "I improved on yesterday",
            "I made something happen today",
            "I am building something real",
            "I am growing into who I want to be",
        ],
        .habits: [
            "I showed up for myself today",
            "I followed through on my word",
            "I kept showing up, even today",
            "I put in real effort today",
            "I am proving it to myself daily",
            "I showed up for the person I am becoming",
            "I gave an honest effort today",
        ],
        .recovery: [
            "I kept going when it was hard",
            "I did not give up on myself",
            "I got through it today",
            "I handled what came at me",
            "I stayed strong through it",
            "I am not quitting on myself",
            "I made the better choice today",
        ],
        .relationships: [
            "I showed real patience today",
            "I stayed present with the people who matter",
            "I stayed in control of how I showed up",
        ],
    ]

    private static let powerStatements: [String] = [
        "I am earning my confidence, one day at a time",
        "I am becoming who I said I would be",
        "I am proving myself right",
        "I am not the same person I was before",
        "I earned this day",
        "I execute on what I set out to do",
        "I earn my progress through action",
        "I am building real momentum",
        "I trust my ability to follow through",
        "I am building confidence through action",
    ]

    private static let baseStatements: [String] = [
        "I showed up for myself today",
        "I followed through on my word",
        "I made progress today",
        "I kept going when it mattered",
        "I did what I could with today",
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
