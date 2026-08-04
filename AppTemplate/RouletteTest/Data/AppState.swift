import Foundation

@Observable
final class AppState {
    var hasCompletedOnboarding: Bool {
        didSet { save() }
    }

    var firstName: String {
        didSet { save() }
    }

    var lastName: String {
        didSet { save() }
    }

    var profileImageData: Data? {
        didSet { save() }
    }

    var selectedTab: AppTab = .home

    var virtualBalance: Int {
        didSet { save() }
    }

    var quizTotalAnswered: Int {
        didSet { save() }
    }

    var quizTotalCorrect: Int {
        didSet { save() }
    }

    var lastQuizCorrect: Int {
        didSet { save() }
    }

    var lastQuizTotal: Int {
        didSet { save() }
    }

    var quizStreakDays: Int {
        didSet { save() }
    }

    var lastQuizDate: Date? {
        didSet { save() }
    }

    var checklistItems: [ChecklistItem] {
        didSet { save() }
    }

    var checklistCompletionsCount: Int {
        didSet { save() }
    }

    var simulatorSpins: Int {
        didSet { save() }
    }

    var simulatorWins: Int {
        didSet { save() }
    }

    var simulatorTotalWagered: Int {
        didSet { save() }
    }

    var simulatorNetProfit: Int {
        didSet { save() }
    }

    var unlockedAchievements: Set<AchievementID> {
        didSet { save() }
    }

    init() {
        let loaded = Persistence.load()
        hasCompletedOnboarding = loaded.hasCompletedOnboarding
        firstName = loaded.firstName
        lastName = loaded.lastName
        profileImageData = loaded.profileImageData
        virtualBalance = loaded.virtualBalance
        quizTotalAnswered = loaded.quizTotalAnswered
        quizTotalCorrect = loaded.quizTotalCorrect
        lastQuizCorrect = loaded.lastQuizCorrect
        lastQuizTotal = loaded.lastQuizTotal
        quizStreakDays = loaded.quizStreakDays
        lastQuizDate = loaded.lastQuizDate
        checklistItems = loaded.checklistItems
        checklistCompletionsCount = loaded.checklistCompletionsCount
        simulatorSpins = loaded.simulatorSpins
        simulatorWins = loaded.simulatorWins
        simulatorTotalWagered = loaded.simulatorTotalWagered
        simulatorNetProfit = loaded.simulatorNetProfit
        unlockedAchievements = loaded.unlockedAchievements
    }

    var displayName: String { "\(firstName) \(lastName)" }
    var shortName: String { firstName }

    var quizAccuracyPercent: Int {
        guard quizTotalAnswered > 0 else { return 0 }
        return Int((Double(quizTotalCorrect) / Double(quizTotalAnswered)) * 100)
    }

    var checklistProgress: Double {
        guard !checklistItems.isEmpty else { return 0 }
        let done = checklistItems.filter(\.isCompleted).count
        return Double(done) / Double(checklistItems.count)
    }

    var readinessPercent: Int {
        let quizPart = Double(quizAccuracyPercent) * 0.6
        let prepPart = checklistProgress * 100 * 0.4
        return min(100, Int(quizPart + prepPart))
    }

    var knowledgeTier: KnowledgeTier {
        KnowledgeTier.from(accuracy: Double(quizAccuracyPercent))
    }

    var winRatePercent: Int {
        guard simulatorSpins > 0 else { return 0 }
        return Int((Double(simulatorWins) / Double(simulatorSpins)) * 100)
    }

    var roiPercent: Int {
        guard simulatorTotalWagered > 0 else { return 0 }
        return Int((Double(simulatorNetProfit) / Double(simulatorTotalWagered)) * 100)
    }

    var playerLevel: Int {
        min(10, 1 + quizTotalCorrect / 5 + checklistCompletionsCount)
    }

    func completeOnboarding() {
        hasCompletedOnboarding = true
    }

    func updateProfile(firstName: String, lastName: String, imageData: Data?) {
        self.firstName = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        self.lastName = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        profileImageData = imageData
    }

    func recordQuizSession(correct: Int, total: Int) {
        lastQuizCorrect = correct
        lastQuizTotal = total
        quizTotalAnswered += total
        quizTotalCorrect += correct
        updateQuizStreak()
        if total > 0 { unlockedAchievements.insert(.firstQuiz) }
        if correct == total && total == QuizBank.questions.count {
            unlockedAchievements.insert(.perfectScore)
        }
        if correct >= 16 {
            unlockedAchievements.insert(.rouletteMaster)
        }
        save()
    }

    func recordSimulatorSpin(won: Bool, wager: Int, profit: Int) {
        simulatorSpins += 1
        simulatorTotalWagered += wager
        simulatorNetProfit += profit
        if won { simulatorWins += 1 }
        if simulatorSpins >= 50 {
            unlockedAchievements.insert(.simExpert)
        }
        save()
    }

    func recordChecklistFullyCompleted() {
        checklistCompletionsCount += 1
        unlockedAchievements.insert(.allChecklists)
        save()
    }

    func resetChecklist() {
        checklistItems = ChecklistDefaults.defaultItems
    }

    func addChecklistItem(_ title: String) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        checklistItems.append(ChecklistItem(title: trimmed, isCustom: true))
    }

    func removeChecklistItem(id: UUID) {
        checklistItems.removeAll { $0.id == id && $0.isCustom }
    }

    func completeChecklistItem(id: UUID, note: String?) {
        guard let index = checklistItems.firstIndex(where: { $0.id == id }) else { return }
        var items = checklistItems
        items[index].isCompleted = true
        items[index].completionNote = note
        checklistItems = items
    }

    func uncompleteChecklistItem(id: UUID) {
        guard let index = checklistItems.firstIndex(where: { $0.id == id }) else { return }
        var items = checklistItems
        items[index].isCompleted = false
        items[index].completionNote = nil
        checklistItems = items
    }

    func isAchievementUnlocked(_ id: AchievementID) -> Bool {
        if unlockedAchievements.contains(id) { return true }
        switch id {
        case .sevenDayStreak:
            return quizStreakDays >= 7
        default:
            return false
        }
    }

    private func updateQuizStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        if let last = lastQuizDate {
            let lastDay = calendar.startOfDay(for: last)
            if lastDay == today { return }
            if let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
               calendar.isDate(lastDay, inSameDayAs: yesterday) {
                quizStreakDays += 1
            } else if lastDay != today {
                quizStreakDays = 1
            }
        } else {
            quizStreakDays = 1
        }
        lastQuizDate = Date()
        if quizStreakDays >= 7 {
            unlockedAchievements.insert(.sevenDayStreak)
        }
    }

    private func save() {
        let snapshot = PersistedState(
            hasCompletedOnboarding: hasCompletedOnboarding,
            firstName: firstName,
            lastName: lastName,
            profileImageData: profileImageData,
            virtualBalance: virtualBalance,
            quizTotalAnswered: quizTotalAnswered,
            quizTotalCorrect: quizTotalCorrect,
            lastQuizCorrect: lastQuizCorrect,
            lastQuizTotal: lastQuizTotal,
            quizStreakDays: quizStreakDays,
            lastQuizDate: lastQuizDate,
            checklistItems: checklistItems,
            checklistCompletionsCount: checklistCompletionsCount,
            simulatorSpins: simulatorSpins,
            simulatorWins: simulatorWins,
            simulatorTotalWagered: simulatorTotalWagered,
            simulatorNetProfit: simulatorNetProfit,
            unlockedAchievements: unlockedAchievements
        )
        Persistence.save(snapshot)
    }
}
