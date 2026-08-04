import Foundation

enum Persistence {
    private static let key = "roulette_test_state"

    static func load() -> PersistedState {
        guard let data = UserDefaults.standard.data(forKey: key),
              let state = try? JSONDecoder().decode(PersistedState.self, from: data) else {
            return PersistedState()
        }
        return state
    }

    static func save(_ state: PersistedState) {
        guard let data = try? JSONEncoder().encode(state) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}
