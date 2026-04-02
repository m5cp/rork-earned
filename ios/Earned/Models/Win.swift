import Foundation

nonisolated struct Win: Codable, Sendable, Identifiable, Hashable {
    let id: String
    let text: String
    let category: WinCategory

    init(text: String, category: WinCategory) {
        self.id = "\(category.rawValue)_\(text.hashValue)"
        self.text = text
        self.category = category
    }

    static let sayItOutLoudID = "declaration_said_it_out_loud"
    static let comebackID = "comeback_showed_up"

    static func sayItOutLoud(statement: String) -> Win {
        Win(id: sayItOutLoudID, text: statement, category: .declaration)
    }

    static func comeback() -> Win {
        Win(id: comebackID, text: "You showed up", category: .resilience)
    }

    private init(id: String, text: String, category: WinCategory) {
        self.id = id
        self.text = text
        self.category = category
    }
}
