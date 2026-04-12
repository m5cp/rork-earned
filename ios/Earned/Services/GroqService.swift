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
        let winTexts = wins.map { "- \($0.text) (\($0.category.displayName))" }.joined(separator: "\n")
        let skippedTexts = skippedWins.isEmpty ? "None" : skippedWins.map { "- \($0.text)" }.joined(separator: "\n")
        let moodText = mood.map { "\($0.label) (\($0.emoji))" } ?? "Not specified"
        let noteText = userNote.map { "User's personal note: \"\($0)\"" } ?? ""
        let comebackText = isComeback ? "This person came back after missing a day — that takes courage." : ""

        let systemPrompt = """
        You are a warm, insightful personal journal writer. Your job is to take someone's daily wins \
        and create a beautiful, reflective first-person journal entry as if they wrote it themselves. \
        Write in first person. Be authentic, not cheesy. Keep it conversational but meaningful. \
        2-3 short paragraphs max. Don't use bullet points. Don't repeat the wins verbatim — \
        weave them naturally into a narrative about the day. Reference their mood naturally if provided. \
        End on a forward-looking or grateful note. Never use hashtags or emojis in the entry.
        """

        let userPrompt = """
        Today's wins earned:
        \(winTexts)

        Wins skipped today:
        \(skippedTexts)

        Mood: \(moodText)
        Current streak: \(streak) days
        \(comebackText)
        \(noteText)

        Write a personal, reflective journal entry for today.
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
