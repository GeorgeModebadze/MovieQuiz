//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Георгий on 09.03.2025.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer()
    func didFailToLoadData(with error: Error)
}
