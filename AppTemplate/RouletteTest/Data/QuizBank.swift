import Foundation

enum QuizBank {
    static let questions: [QuizQuestion] = [
        QuizQuestion(
            statement: "In European roulette the house edge is 2.7%, and in American roulette it is 5.26%.",
            isTrue: true,
            explanation: "European has one zero (2.7%); American adds double zero (5.26%)."
        ),
        QuizQuestion(
            statement: "If red hits five times in a row, black is significantly more likely on the next spin.",
            isTrue: false,
            explanation: "Each spin is independent — prior results never affect future ones."
        ),
        QuizQuestion(
            statement: "The Martingale strategy guarantees a long-term profit.",
            isTrue: false,
            explanation: "Table limits and finite bankroll break progressive doubling systems."
        ),
        QuizQuestion(
            statement: "A red/black bet pays 2 to 1.",
            isTrue: false,
            explanation: "Even-money outside bets pay 1 to 1."
        ),
        QuizQuestion(
            statement: "A straight-up bet on a single number pays 35 to 1.",
            isTrue: true,
            explanation: "Single-number bets pay 35:1 in standard roulette."
        ),
        QuizQuestion(
            statement: "Any betting system can change the base RTP of roulette.",
            isTrue: false,
            explanation: "Systems change variance, not the casino's mathematical edge."
        ),
        QuizQuestion(
            statement: "Stop-Loss should be set before the first spin.",
            isTrue: true,
            explanation: "Limits must be decided while you are calm and rational."
        ),
        QuizQuestion(
            statement: "Longer sessions move results closer to the house's expected edge.",
            isTrue: true,
            explanation: "The law of large numbers favors the casino over time."
        ),
        QuizQuestion(
            statement: "Risking 20% of bankroll per session is safe.",
            isTrue: false,
            explanation: "Responsible play typically uses 1–2% of bankroll per session."
        ),
        QuizQuestion(
            statement: "Table maximums exist mainly to protect players from huge losses.",
            isTrue: false,
            explanation: "They limit progressive systems like Martingale."
        ),
        QuizQuestion(
            statement: "Voisins and Tiers bets follow wheel layout, not the betting grid.",
            isTrue: true,
            explanation: "Sector bets map to physical number positions on the wheel."
        ),
        QuizQuestion(
            statement: "The Top Line bet (0, 00, 1, 2, 3) in American roulette is best for the player.",
            isTrue: false,
            explanation: "It has the worst house edge at about 7.89%."
        ),
        QuizQuestion(
            statement: "Chasing losses after a losing streak shows good discipline.",
            isTrue: false,
            explanation: "Chasing losses is a sign of tilt and loss of control."
        ),
        QuizQuestion(
            statement: "Breaks every 30–45 minutes help prevent impulsive bets.",
            isTrue: true,
            explanation: "Rest reduces fatigue and emotional decision-making."
        ),
        QuizQuestion(
            statement: "When you hit Take-Profit, you should lock in profit and end the session.",
            isTrue: true,
            explanation: "Walking away at your goal protects winnings."
        ),
        QuizQuestion(
            statement: "RNG online roulette and a physical wheel have the same long-term house edge.",
            isTrue: true,
            explanation: "The math is defined by wheel layout and rules, not the medium."
        ),
        QuizQuestion(
            statement: "Hot and cold numbers on the board help predict the next winner.",
            isTrue: false,
            explanation: "This is the gambler's fallacy — outcomes stay random."
        ),
        QuizQuestion(
            statement: "Column and dozen bets cover 12 numbers and pay 2 to 1.",
            isTrue: true,
            explanation: "Dozens and columns are 12-number bets at 2:1."
        ),
        QuizQuestion(
            statement: "Gambling should be a stable income source for bills or rent.",
            isTrue: false,
            explanation: "Treat gambling as entertainment, not income."
        ),
        QuizQuestion(
            statement: "A pre-game checklist and fixed limits improve bankroll preservation.",
            isTrue: true,
            explanation: "Planning and limits support disciplined play."
        )
    ]
}
