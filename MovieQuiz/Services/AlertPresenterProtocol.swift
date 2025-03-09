//
//  AlertPresenterProtocol.swift
//  MovieQuiz
//
//  Created by Георгий on 10.03.2025.
//

import Foundation
import UIKit

protocol AlertPresenterProtocol {
    var delegate: AlertPresenterDelegate? { get set }
    
    func presentAlert(on viewController: UIViewController, with model: QuizResultsViewModel)
}
