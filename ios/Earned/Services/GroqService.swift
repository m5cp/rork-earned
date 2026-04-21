import Foundation

nonisolated struct GroqChatMessage: Codable, Sendable {
    let role: String
    let content: String
}

nonisolated struct GroqChatRequest: Codable, Sendable {
    let model: String
    let messages: [GroqChatMessage]
    let temperature: Double
    let max_tokens: Int
}

nonisolated struct GroqChatResponse: Codable, Sendable {
    let choices: [GroqChoice]
}

nonisolated struct GroqChoice: Codable, Sendable {
    let message: GroqChatMessage
}

@MainActor
class GroqService {
    static let shared = GroqService()
    private let baseURL = "https://api.groq.com/openai/v1/chat/completions"
    private let model = "llama-3.3-70b-versatile"

    private var apiKey: String {
        Config.EXPO_PUBLIC_GROQ_API_KEY
    }

    func generateJournalEntry(
        wins: [Win],
        skippedWins: [Win],
        mood: Mood?,
        streak: Int,
        isComeback: Bool,
        userNote: String?
    ) async throws -> String {
        let yesTexts = wins.isEmpty ? "None" : wins.map { "- \($0.text)" }.joined(separator: "\n")
        let noTexts = skippedWins.isEmpty ? "None" : skippedWins.map { "- \($0.text)" }.joined(separator: "\n")
        let moodText = mood.map { "\($0.label) (\($0.emoji))" } ?? "Not specified"
        let noteText = userNote.map { "User's personal note: \"\($0)\"" } ?? ""
        let comebackText = isComeback ? "They came back after missing a day — honor that gently." : ""

        let systemPrompt = """
        You are a warm, encouraging, judgment-free personal journal writer. \
        The user just answered yes/no reflection prompts about their day. \
        Write a short first-person journal entry (2–3 short paragraphs) as if they wrote it themselves. \
        Tone: happy, kind, encouraging, gentle. NEVER judge, shame, guilt, or criticize. \
        Celebrate the YES answers warmly. Frame the NO answers as gentle self-awareness or soft \
        observations about what tomorrow could hold — never as failures or shortcomings. \
        Do not list the prompts verbatim — weave them naturally into a soft, reflective narrative. \
        If everything is NO, be extra kind and remind them that simply showing up to reflect is \
        meaningful and enough. Never use hashtags, emojis, or bullet points.
        """

        let userPrompt = """
        Today's reflection answers:

        Said YES to:
        \(yesTexts)

        Said NO (or not today) to:
        \(noTexts)

        Mood: \(moodText)
        Current streak: \(streak) days
        \(comebackText)
        \(noteText)

        Write a warm, encouraging first-person journal entry for today. Happy tone, no judgment.
        """

        return try await chatCompletion(system: systemPrompt, user: userPrompt)
    }

    func generateWeeklyInsight(
        weekEntries: [(date: String, earnedCount: Int, mood: Mood?, categories: [String])],
        totalWins: Int,
        streak: Int
    ) async throws -> String {
        var summary = ""
        for entry in weekEntries {
            let moodStr = entry.mood?.label ?? "—"
            let cats = entry.categories.isEmpty ? "none" : entry.categories.joined(separator: ", ")
            summary += "- \(entry.date): \(entry.earnedCount) wins, mood: \(moodStr), categories: \(cats)\n"
        }

        let systemPrompt = """
        You are a supportive personal growth coach. Analyze the user's week and write a brief, \
        insightful weekly summary. Highlight patterns, strengths, and gentle suggestions. \
        Keep it to 2-3 paragraphs. Be encouraging but honest. Write in second person ("you"). \
        Don't use bullet points or headers. Don't be generic — reference specific patterns from the data.
        """

        let userPrompt = """
        Weekly check-in data:
        \(summary)
        Total wins this week: \(totalWins)
        Current streak: \(streak) days

        Write a personalized weekly insight summary.
        """

        return try await chatCompletion(system: systemPrompt, user: userPrompt)
    }

    func generatePersonalizedAffirmation(
        recentWins: [Win],
        mood: Mood?,
        streak: Int
    ) async throws -> String {
        let winTexts = recentWins.prefix(5).map { $0.text }.joined(separator: ", ")
        let moodText = mood?.label ?? "neutral"

        let systemPrompt = """
        You are generating a single, powerful personal affirmation statement. \
        It should be in first person, present tense. Based on what the person has been earning, \
        create something that feels earned and real — not generic. One sentence only. \
        No quotes around it. No period at the end.
        """

        let userPrompt = """
        Recent wins: \(winTexts)
        Current mood: \(moodText)
        Streak: \(streak) days

        Generate one personalized affirmation.
        """

        return try await chatCompletion(system: systemPrompt, user: userPrompt, maxTokens: 100)
    }

    func chat(messages: [(role: String, content: String)]) async throws -> String {
        let groqMessages = messages.map { GroqChatMessage(role: $0.role, content: $0.content) }
        let request = GroqChatRequest(
            model: model,
            messages: groqMessages,
            temperature: 0.8,
            max_tokens: 500
        )
        return try await executeRequest(request)
    }

    private func chatCompletion(system: String, user: String, maxTokens: Int = 500) async throws -> String {
        let messages = [
            GroqChatMessage(role: "system", content: system),
            GroqChatMessage(role: "user", content: user)
        ]
        let request = GroqChatRequest(
            model: model,
            messages: messages,
            temperature: 0.7,
            max_tokens: maxTokens
        )
        return try await executeRequest(request)
    }

    private func executeRequest(_ chatRequest: GroqChatRequest) async throws -> String {
        guard !apiKey.isEmpty else {
            throw GroqError.missingAPIKey
        }

        var request = URLRequest(url: URL(string: baseURL)!)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(chatRequest)
        request.timeoutInterval = 30

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw GroqError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw GroqError.apiError(statusCode: httpResponse.statusCode)
        }

        let decoded = try JSONDecoder().decode(GroqChatResponse.self, from: data)
        guard let content = decoded.choices.first?.message.content else {
            throw GroqError.emptyResponse
        }

        return content.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

nonisolated enum GroqError: Error, LocalizedError, Sendable {
    case missingAPIKey
    case invalidResponse
    case apiError(statusCode: Int)
    case emptyResponse

    var errorDescription: String? {
        switch self {
        case .missingAPIKey: "AI features require an API key."
        case .invalidResponse: "Unexpected response from AI."
        case .apiError(let code): "AI service error (\(code))."
        case .emptyResponse: "AI returned an empty response."
        }
    }
}
