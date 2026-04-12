import Foundation

struct WinLibrary {
    static let all: [Win] = [

        // MARK: - Discipline

        Win(text: "You followed through on something important", category: .discipline),
        Win(text: "You chose discipline over comfort", category: .discipline),
        Win(text: "You kept a promise to yourself", category: .discipline),
        Win(text: "You stayed consistent", category: .discipline),
        Win(text: "You stayed focused", category: .discipline),
        Win(text: "You acted with intention", category: .discipline),
        Win(text: "You held yourself accountable", category: .discipline),
        Win(text: "You kept your standards", category: .discipline),
        Win(text: "You stayed committed", category: .discipline),
        Win(text: "You followed through under pressure", category: .discipline),
        Win(text: "You kept your word to yourself", category: .discipline),
        Win(text: "You stayed on track", category: .discipline),
        Win(text: "You stayed aligned with your goals", category: .discipline),
        Win(text: "You stayed focused under pressure", category: .discipline),
        Win(text: "You stayed focused on what matters", category: .discipline),
        Win(text: "You showed discipline today", category: .discipline),
        Win(text: "You stayed disciplined when it would have been easy not to", category: .discipline),
        Win(text: "You kept your direction clear", category: .discipline),

        // MARK: - Resilience

        Win(text: "You showed up when it was hard", category: .resilience),
        Win(text: "You kept going even without motivation", category: .resilience),
        Win(text: "You handled pressure better than before", category: .resilience),
        Win(text: "You pushed through resistance", category: .resilience),
        Win(text: "You controlled your reaction", category: .resilience),
        Win(text: "You stayed composed under stress", category: .resilience),
        Win(text: "You didn't let one mistake define your day", category: .resilience),
        Win(text: "You reset instead of spiraling", category: .resilience),
        Win(text: "You showed resilience", category: .resilience),
        Win(text: "You didn't let emotions take over", category: .resilience),
        Win(text: "You stayed steady", category: .resilience),
        Win(text: "You didn't fold under pressure", category: .resilience),
        Win(text: "You didn't let doubt win", category: .resilience),
        Win(text: "You handled a tough moment well", category: .resilience),
        Win(text: "You handled stress better", category: .resilience),
        Win(text: "You stayed calm when it mattered", category: .resilience),
        Win(text: "You stayed grounded under pressure", category: .resilience),
        Win(text: "You handled adversity better than you used to", category: .resilience),
        Win(text: "You stayed grounded through a difficult moment", category: .resilience),

        // MARK: - Self-Kindness

        Win(text: "You gave yourself grace", category: .selfKindness),
        Win(text: "You didn't beat yourself up", category: .selfKindness),
        Win(text: "You chose rest without guilt", category: .selfKindness),
        Win(text: "You let yourself be human", category: .selfKindness),
        Win(text: "You accepted where you are right now", category: .selfKindness),
        Win(text: "You stopped overthinking", category: .selfKindness),
        Win(text: "You gave yourself credit", category: .selfKindness),
        Win(text: "You recognized your own effort", category: .selfKindness),
        Win(text: "You made yourself proud", category: .selfKindness),
        Win(text: "You proved something to yourself", category: .selfKindness),
        Win(text: "You gave yourself a chance", category: .selfKindness),
        Win(text: "You didn't quit on yourself", category: .selfKindness),
        Win(text: "You stayed patient with yourself", category: .selfKindness),
        Win(text: "You stayed true to yourself", category: .selfKindness),

        // MARK: - Courage

        Win(text: "You did something you were avoiding", category: .courage),
        Win(text: "You didn't quit when it got uncomfortable", category: .courage),
        Win(text: "You chose growth over comfort", category: .courage),
        Win(text: "You faced something difficult", category: .courage),
        Win(text: "You didn't run from discomfort", category: .courage),
        Win(text: "You showed mental toughness", category: .courage),
        Win(text: "You showed strength when it counted", category: .courage),
        Win(text: "You didn't avoid responsibility", category: .courage),
        Win(text: "You handled discomfort", category: .courage),
        Win(text: "You showed up despite resistance", category: .courage),
        Win(text: "You did something that mattered", category: .courage),
        Win(text: "You kept moving despite resistance", category: .courage),
        Win(text: "You did the hard thing", category: .courage),

        // MARK: - Progress

        Win(text: "You made progress, even if small", category: .progress),
        Win(text: "You moved forward", category: .progress),
        Win(text: "You improved from yesterday", category: .progress),
        Win(text: "You made a better decision", category: .progress),
        Win(text: "You kept moving forward", category: .progress),
        Win(text: "You stayed in control", category: .progress),
        Win(text: "You made something happen", category: .progress),
        Win(text: "You made progress that matters", category: .progress),
        Win(text: "You showed growth", category: .progress),
        Win(text: "You improved from before", category: .progress),
        Win(text: "You made effort count", category: .progress),
        Win(text: "You made a step forward", category: .progress),
        Win(text: "You stayed aligned with your direction", category: .progress),

        // MARK: - Habits

        Win(text: "You showed up even when you didn't feel like it", category: .habits),
        Win(text: "You gave effort when it mattered", category: .habits),
        Win(text: "You stayed present", category: .habits),
        Win(text: "You showed up again", category: .habits),
        Win(text: "You showed up today", category: .habits),
        Win(text: "You followed through", category: .habits),
        Win(text: "You showed effort", category: .habits),
        Win(text: "You kept trying", category: .habits),
        Win(text: "You showed up when it mattered", category: .habits),
        Win(text: "You kept showing up", category: .habits),
        Win(text: "You showed up with intention", category: .habits),
        Win(text: "You showed up for yourself", category: .habits),
        Win(text: "You stayed committed to showing up", category: .habits),
        Win(text: "You stayed engaged with your goals", category: .habits),
        Win(text: "You gave a real effort", category: .habits),
        Win(text: "You followed through again", category: .habits),

        // MARK: - Recovery

        Win(text: "You didn't give up", category: .recovery),
        Win(text: "You kept going", category: .recovery),
        Win(text: "You made a better choice", category: .recovery),
        Win(text: "You handled things better than before", category: .recovery),
        Win(text: "You stayed strong", category: .recovery),
        Win(text: "You handled the moment well", category: .recovery),
        Win(text: "You stayed in control of yourself", category: .recovery),
        Win(text: "You handled the day with strength", category: .recovery),
        Win(text: "You handled things step by step", category: .recovery),
        Win(text: "You handled what was in front of you", category: .recovery),
        Win(text: "You got through it", category: .recovery),
        Win(text: "You didn't let a setback stop you", category: .recovery),

        // MARK: - Relationships

        Win(text: "You showed patience", category: .relationships),
        Win(text: "You stayed patient", category: .relationships),
        Win(text: "You showed control", category: .relationships),
        Win(text: "You stayed present through a difficult conversation", category: .relationships),
        Win(text: "You listened more than you spoke", category: .relationships),
        Win(text: "You chose understanding over reacting", category: .relationships),
        Win(text: "You showed empathy when it would have been easier not to", category: .relationships),
        Win(text: "You set a healthy boundary", category: .relationships),
        Win(text: "You supported someone without expecting anything back", category: .relationships),
        Win(text: "You let go of needing to be right", category: .relationships),

        // MARK: - Creativity

        Win(text: "You tried something new", category: .courage),
        Win(text: "You created something today", category: .progress),
        Win(text: "You solved a problem in a new way", category: .progress),
        Win(text: "You took a creative risk", category: .courage),

        // MARK: - Health & Body

        Win(text: "You moved your body today", category: .habits),
        Win(text: "You chose nourishment over convenience", category: .discipline),
        Win(text: "You got enough sleep", category: .selfKindness),
        Win(text: "You took a break when your body needed it", category: .selfKindness),
        Win(text: "You drank enough water", category: .habits),

        // MARK: - Learning & Growth

        Win(text: "You learned something new", category: .progress),
        Win(text: "You asked for help when you needed it", category: .courage),
        Win(text: "You admitted you were wrong", category: .courage),
        Win(text: "You reflected instead of reacting", category: .resilience),
        Win(text: "You recognized a pattern and chose differently", category: .progress),

        // MARK: - Financial

        Win(text: "You made a smart financial decision", category: .discipline),
        Win(text: "You resisted an impulse purchase", category: .discipline),
        Win(text: "You planned ahead with your money", category: .discipline),
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
