import Foundation

final class StatisticService: StatisticServiceProtocol {
    
    private let storage: UserDefaults = .standard
    
    private enum Keys: String {
        case correctAnswers
        case totalCorrectAnswers
        case totalQuestions
        case bestGameCorrect
        case bestGameTotal
        case bestGameDate
        case gamesCount
    }
    
    var gamesCount: Int {
        get {
            storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameResult {
        get {
            let correctAnswers = storage.integer(forKey: Keys.bestGameCorrect.rawValue)
            let total = storage.integer(forKey: Keys.bestGameTotal.rawValue)
            let date = storage.object(forKey: Keys.bestGameDate.rawValue) as? Date ?? Date()
            return GameResult(correct: correctAnswers, total: total, date: date)
        }
        set {
            storage.set(newValue.correct, forKey: Keys.bestGameCorrect.rawValue)
            storage.set(newValue.total, forKey: Keys.bestGameTotal.rawValue)
            storage.set(newValue.date, forKey: Keys.bestGameDate.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        let totalCorrectAnswers = storage.integer(forKey: Keys.totalCorrectAnswers.rawValue)
        let totalQuestions = storage.integer(forKey: Keys.totalQuestions.rawValue)
        guard totalQuestions > 0 else { return 0 }
        return (Double(totalCorrectAnswers) / Double(totalQuestions)) * 100
    }
    
    func store(correct count: Int, total amount: Int) {
        let totalCorrectAnswers = storage.integer(forKey: Keys.totalCorrectAnswers.rawValue) + count
        storage.set(totalCorrectAnswers, forKey: Keys.totalCorrectAnswers.rawValue)
        
        let totalQuestions = storage.integer(forKey: Keys.totalQuestions.rawValue) + amount
        storage.set(totalQuestions, forKey: Keys.totalQuestions.rawValue)
        gamesCount += 1
        
        let currentGame = GameResult(correct: count, total: amount, date: Date())
        if currentGame.isBetterThan(bestGame) {
            bestGame = currentGame
        }
    }
}
