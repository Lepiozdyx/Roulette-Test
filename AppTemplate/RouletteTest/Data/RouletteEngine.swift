import Foundation

enum RouletteEngine {
    static let redNumbers: Set<Int> = [1, 3, 5, 7, 9, 12, 14, 16, 18, 19, 21, 23, 25, 27, 30, 32, 34, 36]

    static func pocketCount(variant: RouletteVariant) -> Int {
        variant == .eu ? 37 : 38
    }

    static func spin(variant: RouletteVariant) -> (result: SpinResult, display: String) {
        let count = pocketCount(variant: variant)
        let index = Int.random(in: 0..<count)
        if variant == .us && index == 37 {
            let result = SpinResult(number: -1, isRed: false, isBlack: false)
            return (result, "00")
        }
        let number = index
        let isGreen = number == 0
        let isRed = !isGreen && redNumbers.contains(number)
        let isBlack = !isGreen && !isRed
        let result = SpinResult(number: number, isRed: isRed, isBlack: isBlack)
        return (result, "\(number)")
    }

    static func winningPocketCount(for bet: OutsideBet) -> Int {
        switch bet {
        case .red, .black, .odd, .even, .low, .high:
            return 18
        }
    }

    static func winProbabilityPercent(variant: RouletteVariant, bet: OutsideBet) -> Double {
        Double(winningPocketCount(for: bet)) / Double(pocketCount(variant: variant)) * 100
    }

    static func probabilityFormulaLabel(variant: RouletteVariant, bet: OutsideBet) -> String {
        let wins = winningPocketCount(for: bet)
        let total = pocketCount(variant: variant)
        return "\(bet.title) · \(wins)/\(total) · Pays 1:1"
    }

    static func winProbabilityPercent(variant: RouletteVariant) -> Double {
        winProbabilityPercent(variant: variant, bet: .red)
    }

    static func isWin(bet: OutsideBet, result: SpinResult) -> Bool {
        let n = result.number
        if n <= 0 { return false }
        switch bet {
        case .red: return result.isRed
        case .black: return result.isBlack
        case .odd: return n % 2 == 1
        case .even: return n % 2 == 0
        case .low: return (1...18).contains(n)
        case .high: return (19...36).contains(n)
        }
    }

}
