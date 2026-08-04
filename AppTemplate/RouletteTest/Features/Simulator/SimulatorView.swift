import SwiftUI

struct SimulatorView: View {
    @Environment(AppState.self) private var appState
    @State private var variant: RouletteVariant = .eu
    @State private var selectedChip = 25
    @State private var selectedBet: OutsideBet = .black
    @State private var isSpinning = false
    @State private var wheelRotation: Double = 0
    @State private var lastResult: SpinResult?
    @State private var lastDisplayNumber = ""
    @State private var recentResults: [(display: String, isRed: Bool)] = []
    @State private var lastDelta: Int?
    @State private var isEditingBalance = false
    @State private var balanceInput = ""

    private let chips = [5, 25, 100, 500]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header
                balanceCard
                wheelSection
                if lastResult != nil {
                    resultSection
                }
                chipSection
                betSection
                probabilityCard
                PrimaryButton(title: isSpinning ? "Spinning…" : "Spin — Bet $\(selectedChip)") {
                    spin()
                }
                .disabled(isSpinning || appState.virtualBalance < selectedChip)
                .opacity(isSpinning || appState.virtualBalance < selectedChip ? 0.6 : 1)
            }
            .padding(20)
        }
        .screenBackground()
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Simulator")
                    .font(AppTypography.serifTitle(28))
                    .foregroundStyle(.white)
                Spacer()
                Picker("", selection: $variant) {
                    ForEach(RouletteVariant.allCases, id: \.self) { v in
                        Text(v.rawValue).tag(v)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 120)
            }

            Text(variant == .eu
                 ? "European: single zero (37 pockets)"
                 : "American: 0 and 00 (38 pockets)")
                .font(.caption)
                .foregroundStyle(AppColors.muted)
        }
    }

    private var balanceCard: some View {
        DarkCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Virtual Balance")
                            .font(.caption)
                            .foregroundStyle(AppColors.muted)
                        if isEditingBalance {
                            TextField("Amount", text: $balanceInput)
                                .keyboardType(.numberPad)
                                .font(AppTypography.serifHeadline(28))
                                .foregroundStyle(AppColors.gold)
                                .dismissKeyboardToolbar()
                        } else {
                            Text("$\(appState.virtualBalance)")
                                .font(AppTypography.serifHeadline(32))
                                .foregroundStyle(AppColors.gold)
                        }
                    }
                    Spacer()
                    if let delta = lastDelta, !isEditingBalance {
                        Text(delta >= 0 ? "+$\(delta)" : "-$\(abs(delta))")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(delta >= 0 ? AppColors.teal : AppColors.falseRed)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(AppColors.cardElevated)
                            .clipShape(Capsule())
                    }
                }

                if isEditingBalance {
                    HStack(spacing: 8) {
                        Button("Apply") { applyBalance() }
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(AppColors.teal)
                            .clipShape(RoundedRectangle(cornerRadius: 10))

                        Button("Reset $1000") {
                            appState.virtualBalance = 1000
                            balanceInput = "1000"
                            isEditingBalance = false
                        }
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppColors.muted)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(AppColors.cardElevated)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                } else {
                    Button {
                        balanceInput = "\(appState.virtualBalance)"
                        isEditingBalance = true
                    } label: {
                        Label("Edit Balance", systemImage: "pencil")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(AppColors.teal)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var wheelSection: some View {
        Image("wheel")
            .resizable()
            .scaledToFit()
            .rotationEffect(.degrees(wheelRotation))
            .shadow(color: AppColors.teal.opacity(isSpinning ? 0.5 : 0.2), radius: 24)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
    }

    private var resultSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let result = lastResult {
                HStack(spacing: 8) {
                    Circle()
                        .fill(result.isRed ? AppColors.falseRed : (result.number <= 0 ? Color.green : Color.gray))
                        .frame(width: 12, height: 12)
                    Text(lastDisplayNumber)
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text(result.label)
                        .foregroundStyle(AppColors.muted)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(AppColors.card)
                .clipShape(Capsule())
            }

            if !recentResults.isEmpty {
                Text("RECENT RESULTS")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(AppColors.muted)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(recentResults.prefix(10).enumerated()), id: \.offset) { _, item in
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(item.isRed ? AppColors.falseRed : Color.gray)
                                    .frame(width: 8, height: 8)
                                Text(item.display)
                                    .font(.caption.weight(.semibold))
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(AppColors.card)
                            .clipShape(Capsule())
                        }
                    }
                }
            }
        }
    }

    private var chipSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("SELECT CHIP")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(AppColors.muted)
            HStack(spacing: 8) {
                ForEach(chips, id: \.self) { chip in
                    Button {
                        selectedChip = chip
                    } label: {
                        Text("$\(chip)")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(selectedChip == chip ? .black : AppColors.muted)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(selectedChip == chip ? AppColors.teal : AppColors.card)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var betSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("PLACE BET")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(AppColors.muted)
                Text("One even-money bet per spin")
                    .font(.caption)
                    .foregroundStyle(AppColors.muted)
            }

            betGroup(title: "Color", bets: [.red, .black])
            betGroup(title: "Parity", bets: [.odd, .even])
            betGroup(title: "Range", bets: [.low, .high])
        }
    }

    private func betGroup(title: String, bets: [OutsideBet]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title.uppercased())
                .font(.caption2.weight(.semibold))
                .foregroundStyle(AppColors.muted)
            HStack(spacing: 8) {
                ForEach(bets) { bet in
                    Button {
                        selectedBet = bet
                    } label: {
                        Text(bet.title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(selectedBet == bet ? .white : AppColors.muted)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(selectedBet == bet ? AppColors.cardElevated : AppColors.card)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var probabilityCard: some View {
        let probability = RouletteEngine.winProbabilityPercent(variant: variant, bet: selectedBet)
        let formula = RouletteEngine.probabilityFormulaLabel(variant: variant, bet: selectedBet)

        return DarkCard {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "shield.fill")
                    .foregroundStyle(AppColors.teal)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Win probability: \(String(format: "%.1f", probability))%")
                        .foregroundStyle(.white)
                    Text(formula)
                        .font(.caption)
                        .foregroundStyle(AppColors.muted)
                }
            }
        }
    }

    private func applyBalance() {
        let trimmed = balanceInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let value = Int(trimmed), value >= 0 else { return }
        appState.virtualBalance = value
        isEditingBalance = false
    }

    private func spin() {
        guard !isSpinning, appState.virtualBalance >= selectedChip else { return }
        isSpinning = true
        lastDelta = nil

        let extraRotation = Double.random(in: 720...1440)
        withAnimation(.easeOut(duration: 2.2)) {
            wheelRotation += extraRotation
        }

        Task { @MainActor in
            try? await Task.sleep(for: .seconds(2.2))
            let spin = RouletteEngine.spin(variant: variant)
            lastResult = spin.result
            lastDisplayNumber = spin.display
            recentResults.insert((spin.display, spin.result.isRed), at: 0)

            let won = RouletteEngine.isWin(bet: selectedBet, result: spin.result)
            let profit = won ? selectedChip : -selectedChip
            appState.virtualBalance += profit
            lastDelta = profit
            appState.recordSimulatorSpin(won: won, wager: selectedChip, profit: profit)
            isSpinning = false
        }
    }
}
