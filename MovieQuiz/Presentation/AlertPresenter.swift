//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Георгий on 10.03.2025.
//

import Foundation
import UIKit

final class AlertPresenter: AlertPresenterProtocol {
    weak var delegate: AlertPresenterDelegate?
    
    func presentAlert(on viewController: UIViewController, with model: QuizResultsViewModel) {
        let alert = UIAlertController(
            title: model.title,
            message: model.text,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: model.buttonText, style: .default) { [weak self] _ in
            self?.delegate?.didTapRestartGame()
        }
        
        alert.addAction(action)
        
        viewController.present(alert, animated: true, completion: nil)
    }
}
