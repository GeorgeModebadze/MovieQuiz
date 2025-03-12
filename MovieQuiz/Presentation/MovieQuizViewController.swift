import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate {
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenterProtocol?
    private var statisticService: StatisticServiceProtocol = StatisticService()
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        showLoadingIndicator()
        questionFactory?.loadData()
        alertPresenter = AlertPresenter()
        alertPresenter?.delegate = self
        questionFactory?.requestNextQuestion()
        activityIndicator.hidesWhenStopped = true
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let givenAnswer = false
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let givenAnswer = true
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        if isCorrect {
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
            correctAnswers += 1
        } else {
            imageView.layer.borderColor = UIColor.ypRed.cgColor
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [ weak self ] in
            guard let self else { return }
            self.showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults() {
        imageView.layer.borderWidth = 0
        if currentQuestionIndex == questionsAmount - 1 {
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            let gamesCount = statisticService.gamesCount
            let bestGame = statisticService.bestGame
            let totalAccuracy = statisticService.totalAccuracy
            
            let text = """
            Ваш результат: \(correctAnswers)/\(questionsAmount)
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
            currentQuestionIndex += 1
            self.questionFactory?.requestNextQuestion()
        }
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        guard let alertPresenter = alertPresenter else { return }
        alertPresenter.presentAlert(on: self, with: result)
    }
    
    func didTapRestartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    private func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let viewModel = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз"
        ) {
            [weak self] in
            guard let self else { return }
            
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            
            self.questionFactory?.requestNextQuestion()
        }
        alertPresenter?.presentAlert(on: self, with: viewModel)
    }
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
}
