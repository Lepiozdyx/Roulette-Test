import SwiftUI

@Observable
final class QuizSession {
    let questions: [QuizQuestion]
    var currentIndex = 0
    var correctCount = 0
    var answeredCount = 0
    var selectedAnswer: Bool?
    var secondsLeft = 30
    var isFinished = false
    private var timerTask: Task<Void, Never>?

    init(questions: [QuizQuestion] = QuizBank.questions.shuffled()) {
        self.questions = questions
    }

    var currentQuestion: QuizQuestion? {
        guard currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }

    var total: Int { questions.count }

    var hasAnsweredCurrent: Bool { selectedAnswer != nil }

    func startTimer(onTick: @escaping () -> Void) {
        stopTimer()
        secondsLeft = 30
        timerTask = Task { @MainActor in
            while !Task.isCancelled, secondsLeft > 0, selectedAnswer == nil {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { return }
                if selectedAnswer == nil {
                    secondsLeft -= 1
                    onTick()
                }
            }
            if selectedAnswer == nil, !isFinished {
                submitTimeout()
                onTick()
            }
        }
    }

    func stopTimer() {
        timerTask?.cancel()
        timerTask = nil
    }

    func submit(answer: Bool) {
        guard selectedAnswer == nil, let question = currentQuestion else { return }
        selectedAnswer = answer
        answeredCount += 1
        if answer == question.isTrue {
            correctCount += 1
        }
        stopTimer()
    }

    private func submitTimeout() {
        guard selectedAnswer == nil, let question = currentQuestion else { return }
        selectedAnswer = !question.isTrue
        answeredCount += 1
        stopTimer()
    }

    func nextQuestion() {
        guard currentIndex + 1 < questions.count else {
            isFinished = true
            stopTimer()
            return
        }
        currentIndex += 1
        selectedAnswer = nil
        secondsLeft = 30
    }

    func restart() {
        stopTimer()
        currentIndex = 0
        correctCount = 0
        answeredCount = 0
        selectedAnswer = nil
        secondsLeft = 30
        isFinished = false
    }

    var scorePercent: Int {
        guard total > 0 else { return 0 }
        return Int((Double(correctCount) / Double(total)) * 100)
    }

    var resultTitle: String {
        if scorePercent >= 80 { return "Excellent Work" }
        if scorePercent >= 50 { return "Keep Learning" }
        return "Study More"
    }
}

struct QuizView: View {
    @Environment(AppState.self) private var appState
    @State private var session = QuizSession()
    @State private var didRecordSession = false

    var body: some View {
        Group {
            if session.isFinished {
                resultsView
            } else {
                questionView
            }
        }
        .screenBackground()
        .onAppear { session.startTimer { } }
        .onDisappear { session.stopTimer() }
        .onChange(of: session.isFinished) { _, finished in
            if finished, !didRecordSession {
                appState.recordQuizSession(correct: session.correctCount, total: session.total)
                didRecordSession = true
            }
        }
    }

    private var questionView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Question \(session.currentIndex + 1) of \(session.total)")
                        .font(.caption)
                        .foregroundStyle(AppColors.muted)
                    Text("Myth or Fact?")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                }
                Spacer()
                HStack(spacing: 6) {
                    Image(systemName: "stopwatch")
                        .foregroundStyle(AppColors.teal)
                    Text("\(session.secondsLeft)s")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(AppColors.card)
                .clipShape(Capsule())
            }

            Divider().overlay(AppColors.cardElevated)

            if let question = session.currentQuestion {
                DarkCard {
                    Text("\"\(question.statement)\"")
                        .font(AppTypography.serifHeadline(20))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }
                .frame(minHeight: 160)

                if let answer = session.selectedAnswer {
                    feedbackView(question: question, userAnswer: answer)
                    PrimaryButton(title: session.currentIndex + 1 == session.total ? "See Results" : "Next Question →") {
                        if session.currentIndex + 1 == session.total {
                            session.isFinished = true
                            session.stopTimer()
                        } else {
                            session.nextQuestion()
                            session.startTimer { }
                        }
                    }
                } else {
                    HStack(spacing: 12) {
                        answerButton(title: "TRUE", color: AppColors.trueGreen) {
                            session.submit(answer: true)
                        }
                        answerButton(title: "FALSE", color: AppColors.falseRed) {
                            session.submit(answer: false)
                        }
                    }
                }

                Text("Score: \(session.correctCount) / \(session.answeredCount)")
                    .font(.caption)
                    .foregroundStyle(AppColors.muted)
                    .frame(maxWidth: .infinity)
            }

            Spacer()
        }
        .padding(20)
    }

    private func feedbackView(question: QuizQuestion, userAnswer: Bool) -> some View {
        let isCorrect = userAnswer == question.isTrue
        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: isCorrect ? "checkmark" : "xmark")
                Text(isCorrect ? "Correct!" : "Incorrect")
                    .font(.headline)
            }
            .foregroundStyle(isCorrect ? AppColors.teal : AppColors.falseRed)

            Text(question.explanation)
                .font(.subheadline)
                .foregroundStyle(AppColors.muted)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.card)
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(isCorrect ? AppColors.teal.opacity(0.4) : AppColors.falseRed.opacity(0.4), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func answerButton(title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.headline.bold())
                .foregroundStyle(color)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(color.opacity(0.12))
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color, lineWidth: 2)
                }
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }

    private var resultsView: some View {
        VStack(spacing: 24) {
            Spacer()
            ZStack {
                Circle()
                    .stroke(AppColors.teal, lineWidth: 2)
                    .frame(width: 120, height: 120)
                Image(systemName: "trophy.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(AppColors.gold)
            }

            Text(session.resultTitle)
                .font(AppTypography.serifTitle(28))
                .foregroundStyle(.white)

            VStack(spacing: 4) {
                Text("\(session.scorePercent)%")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundStyle(AppColors.teal)
                Text("\(session.correctCount) of \(session.total) correct")
                    .foregroundStyle(AppColors.muted)
            }

            PrimaryButton(title: "Try Again") {
                didRecordSession = false
                session = QuizSession()
                session.startTimer { }
            }
            .padding(.horizontal, 20)

            Spacer()
        }
        .padding(20)
    }
}
