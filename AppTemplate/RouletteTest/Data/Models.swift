import Foundation

struct QuizQuestion: Identifiable, Codable, Hashable {
    let id: UUID
    let statement: String
    let isTrue: Bool
    let explanation: String

    init(id: UUID = UUID(), statement: String, isTrue: Bool, explanation: String) {
        self.id = id
        self.statement = statement
        self.isTrue = isTrue
        self.explanation = explanation
    }
}

struct ChecklistItem: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var isCompleted: Bool
    var completionNote: String?
    var isCustom: Bool

    init(id: UUID = UUID(), title: String, isCompleted: Bool = false, completionNote: String? = nil, isCustom: Bool = false) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.completionNote = completionNote
        self.isCustom = isCustom
    }
}

enum KnowledgeTier: String, Codable, CaseIterable {
    case novice = "Novice"
    case player = "Player"
    case mathematician = "Mathematician"

    static func from(accuracy: Double) -> KnowledgeTier {
        if accuracy >= 81 { return .mathematician }
        if accuracy >= 41 { return .player }
        return .novice
    }

    var badgeImage: String {
        switch self {
        case .novice: return "shieldBadge1"
        case .player: return "shieldBadge2"
        case .mathematician: return "shieldBadge3"
        }
    }

    var description: String {
        switch self {
        case .novice:
            return "Keep studying — roulette math takes practice."
        case .player:
            return "Solid foundation — you understand the core mathematics."
        case .mathematician:
            return "Excellent grasp of probability and discipline."
        }
    }
}

enum RouletteVariant: String, Codable, CaseIterable {
    case eu = "EU"
    case us = "US"
}

enum OutsideBet: String, CaseIterable, Identifiable {
    case red, black, odd, even, low, high

    var id: String { rawValue }

    var title: String {
        switch self {
        case .red: return "Red"
        case .black: return "Black"
        case .odd: return "Odd"
        case .even: return "Even"
        case .low: return "1–18"
        case .high: return "19–36"
        }
    }
}

struct SpinResult: Identifiable, Codable, Hashable {
    let id: UUID
    let number: Int
    let isRed: Bool
    let isBlack: Bool
    let label: String

    init(id: UUID = UUID(), number: Int, isRed: Bool, isBlack: Bool) {
        self.id = id
        self.number = number
        self.isRed = isRed
        self.isBlack = isBlack
        if number == -1 {
            self.label = "Green"
        } else if number == 0 {
            self.label = "Green"
        } else if isRed {
            self.label = "Red"
        } else {
            self.label = "Black"
        }
    }
}

enum AchievementID: String, Codable, CaseIterable, Identifiable {
    case firstQuiz
    case perfectScore
    case simExpert
    case sevenDayStreak
    case allChecklists
    case rouletteMaster

    var id: String { rawValue }

    var title: String {
        switch self {
        case .firstQuiz: return "First Quiz"
        case .perfectScore: return "Perfect Score"
        case .simExpert: return "Sim Expert"
        case .sevenDayStreak: return "7-Day Streak"
        case .allChecklists: return "All Checklists"
        case .rouletteMaster: return "Roulette Master"
        }
    }

    var icon: String {
        switch self {
        case .firstQuiz: return "graduationcap.fill"
        case .perfectScore: return "star.fill"
        case .simExpert: return "dice.fill"
        case .sevenDayStreak: return "flame.fill"
        case .allChecklists: return "checkmark.square.fill"
        case .rouletteMaster: return "crown.fill"
        }
    }
}

struct PersistedState: Codable {
    var hasCompletedOnboarding: Bool = false
    var firstName: String = "Alex"
    var lastName: String = "Morgan"
    var profileImageData: Data?
    var virtualBalance: Int = 1000
    var quizTotalAnswered: Int = 0
    var quizTotalCorrect: Int = 0
    var lastQuizCorrect: Int = 0
    var lastQuizTotal: Int = 0
    var quizStreakDays: Int = 5
    var lastQuizDate: Date?
    var checklistItems: [ChecklistItem] = ChecklistDefaults.defaultItems
    var checklistCompletionsCount: Int = 0
    var simulatorSpins: Int = 0
    var simulatorWins: Int = 0
    var simulatorTotalWagered: Int = 0
    var simulatorNetProfit: Int = 0
    var unlockedAchievements: Set<AchievementID> = []
}
