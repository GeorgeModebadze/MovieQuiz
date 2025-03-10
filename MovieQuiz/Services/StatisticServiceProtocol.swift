//
//  StatisticServiceProtocol.swift
//  MovieQuiz
//
//  Created by Георгий on 10.03.2025.
//

import Foundation

protocol StatisticServiceProtocol {
    var gamesCount: Int { get }
    var bestGame: GameResult { get }
    var totalAccuracy: Double { get }
    
    func store(correct count: Int, total amount: Int)
}
