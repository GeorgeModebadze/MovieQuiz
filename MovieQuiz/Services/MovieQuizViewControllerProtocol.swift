//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Георгий on 14.03.2025.
//

import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func show(quiz result: QuizResultsViewModel)
    func didTapRestartGame()
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func resetBorder()
    func resultFrame(isCorrect: Bool)
    
    func showNetworkError(message: String)
}
