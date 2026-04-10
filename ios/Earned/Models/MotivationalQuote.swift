import Foundation

nonisolated enum MotivationalQuoteLibrary: Sendable {
    static let quotes: [(text: String, author: String)] = [
        ("The secret of getting ahead is getting started.", "Mark Twain"),
        ("Small daily improvements are the key to staggering long-term results.", "Robin Sharma"),
        ("You don't have to be great to start, but you have to start to be great.", "Zig Ziglar"),
        ("What you do every day matters more than what you do once in a while.", "Gretchen Rubin"),
        ("Success is the sum of small efforts repeated day in and day out.", "Robert Collier"),
        ("The only way to do great work is to love what you do.", "Steve Jobs"),
        ("It does not matter how slowly you go as long as you do not stop.", "Confucius"),
        ("Every strike brings me closer to the next home run.", "Babe Ruth"),
        ("You are never too old to set another goal or to dream a new dream.", "C.S. Lewis"),
        ("Believe you can and you're halfway there.", "Theodore Roosevelt"),
        ("The best time to plant a tree was 20 years ago. The second best time is now.", "Chinese Proverb"),
        ("Don't count the days. Make the days count.", "Muhammad Ali"),
        ("A year from now you will wish you had started today.", "Karen Lamb"),
        ("Progress, not perfection.", "Unknown"),
        ("We are what we repeatedly do. Excellence is not an act, but a habit.", "Aristotle"),
        ("The journey of a thousand miles begins with a single step.", "Lao Tzu"),
        ("Your future is created by what you do today, not tomorrow.", "Robert Kiyosaki"),
        ("Stars can't shine without darkness.", "D.H. Sidebottom"),
        ("Fall seven times, stand up eight.", "Japanese Proverb"),
        ("The hard days are what make you stronger.", "Aly Raisman"),
        ("One day or day one. You decide.", "Paulo Coelho"),
        ("Be proud of how far you've come and have faith in how far you can go.", "Unknown"),
        ("Discipline is choosing between what you want now and what you want most.", "Abraham Lincoln"),
        ("You didn't come this far to only come this far.", "Unknown"),
        ("Consistency is what transforms average into excellence.", "Unknown"),
    ]

    static func randomQuote(for date: Date = .now) -> (text: String, author: String) {
        let calendar = Calendar.current
        let day = calendar.ordinality(of: .day, in: .year, for: date) ?? 0
        let index = day % quotes.count
        return quotes[index]
    }
}
