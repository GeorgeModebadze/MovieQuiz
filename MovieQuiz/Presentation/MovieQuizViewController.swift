import UIKit

final class MovieQuizViewController: UIViewController, AlertPresenterDelegate {
    func didTapRestartGame() {
        presenter.restartGame()
    }
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
//    private var correctAnswers = 0
    
//    private var questionFactory: QuestionFactoryProtocol?
//    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenterProtocol?
    private var statisticService: StatisticServiceProtocol = StatisticService()
//    private let presenter = MovieQuizPresenter()
    private var presenter: MovieQuizPresenter!
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        presenter.viewController = self
        presenter = MovieQuizPresenter(viewController: self)
//        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        showLoadingIndicator()
//        questionFactory?.loadData()
        alertPresenter = AlertPresenter()
        alertPresenter?.delegate = self
//        questionFactory?.requestNextQuestion()
        activityIndicator.hidesWhenStopped = true
    }
    
    
//    func didReceiveNextQuestion(question: QuizQuestion?) {
//        presenter.didReceiveNextQuestion(question: question)
//    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    func resultFrame(isCorrect: Bool) {
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        imageView.layer.borderWidth = 8
    }
    func resetBorder() {
        imageView.layer.borderWidth = 0
    }
//    func showAnswerResult(isCorrect: Bool) {
//        
//        presenter.didAnswer(isYes: isCorrect)
//        
//        imageView.layer.masksToBounds = true
//        imageView.layer.borderWidth = 8
//        if isCorrect {
//            imageView.layer.borderColor = UIColor.ypGreen.cgColor
//            presenter.correctAnswers += 1
//        } else {
//            imageView.layer.borderColor = UIColor.ypRed.cgColor
//        }
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [ weak self ] in
//            guard let self else { return }
////            self.presenter.questionFactory = self.questionFactory
//            self.showNextQuestionOrResults()
//        }
//    }
    
    private func showNextQuestionOrResults() {
        imageView.layer.borderWidth = 0
        if presenter.isLastQuestion() {
            statisticService.store(correct: presenter.correctAnswers, total: presenter.questionsAmount)
            let gamesCount = statisticService.gamesCount
            let bestGame = statisticService.bestGame
            let totalAccuracy = statisticService.totalAccuracy
            
            let text = """
            Ваш результат: \(presenter.correctAnswers)/\(presenter.questionsAmount)
            Количество сыгранных квизов: \(gamesCount)
            Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))
            Средняя точность: \(String(format: "%.2f", totalAccuracy))%
            """
            
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз"
            )
            show(quiz: viewModel)
        } else {
            presenter.switchToNextQuestion()
//            self.questionFactory?.requestNextQuestion()
        }
    }
    
    func show(quiz result: QuizResultsViewModel) {
        guard let alertPresenter else { return }
        alertPresenter.presentAlert(on: self, with: result)
        self.presenter.restartGame()
    }
    
//    func didTapRestartGame() {
//        presenter.restartGame()
//        questionFactory?.requestNextQuestion()
//    }
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let viewModel = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз"
        ) {
            [weak self] in
            guard let self else { return }
            
            self.presenter.restartGame()
            
//            self.questionFactory?.requestNextQuestion()
        }
        alertPresenter?.presentAlert(on: self, with: viewModel)
    }

//    func didLoadDataFromServer() {
//        activityIndicator.isHidden = true
//        questionFactory?.requestNextQuestion()
//    }
    
//    func didFailToLoadData(with error: Error) {
//        showNetworkError(message: error.localizedDescription)
//    }
    
}
