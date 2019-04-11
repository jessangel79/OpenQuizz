//
//  ViewController.swift
//  OpenQuizz
//
//  Created by Angelique Babin on 02/04/2019.
//  Copyright © 2019 Angelique Babin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var newGameButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var questionView: QuestionView!
    
    var game = Game()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let name = Notification.Name(rawValue: "QuestionsLoaded")
        NotificationCenter.default.addObserver(self, selector: #selector(questionsLoaded), name: name, object: nil)
        
        startNewGame()
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(dragQuestionView(_:)))
        questionView.addGestureRecognizer(panGestureRecognizer)
    }
    
    @IBAction func didTapNewGameButton() {
        startNewGame()
    }
    
    private func startNewGame() {
        activityIndicator.isHidden = false
        newGameButton.isHidden = true
        
        
        questionView.title = "Loading..."
        questionView.style = .standard
        
        scoreLabel.text = "0 / 10"
        
        // refresh the scoreLabel
        scoreLabel.transform = .identity
        scoreLabel.backgroundColor = .clear
        
        game.refresh()
    }
    
    @objc func questionsLoaded() {
        activityIndicator.isHidden = true
        newGameButton.isHidden = false
        questionView.title = game.currentQuestion.title
    }
    
    @objc func dragQuestionView(_ sender: UIPanGestureRecognizer) {
        if game.state == .ongoing {
            switch sender .state {
            case .began, .changed:
                transformQestionViewWith(gesture: sender)
            case .ended, .cancelled:
                answerQuestion()
            default:
                break
            }
        }
    }
    
    private func transformQestionViewWith(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: questionView)
        
        let translationTransform = CGAffineTransform(translationX: translation.x, y: translation.y)
        
        let screenWidth = UIScreen.main.bounds.width
        let translationPercent = translation.x/(screenWidth / 2)
        let rotationAngle = (CGFloat.pi / 6) * translationPercent
        let rotationTransform = CGAffineTransform(rotationAngle: rotationAngle)
        
        let transform = translationTransform.concatenating(rotationTransform)
        questionView.transform = transform
        
        if translation.x > 0 {
            questionView.style = .correct
        } else {
            questionView.style = .incorrect
        }
    }
    
    private func answerQuestion() {
        switch questionView.style {
        case .correct:
            game.answerCurrentQuestion(with: true)
        case .incorrect:
            game.answerCurrentQuestion(with: false)
        case .standard:
            break
        }
        
        scoreLabel.text = "\(game.score) / 10"
        
        showScoreView()
        
        let screenWidth = UIScreen.main.bounds.width
        var translationTransform: CGAffineTransform
        if questionView.style == .correct {
            translationTransform = CGAffineTransform(translationX: screenWidth, y: 0)
        } else {
            translationTransform = CGAffineTransform(translationX: -screenWidth, y: 0)
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.questionView.transform = translationTransform
        }) { (success) in
            if success {
                self.showQuestionView()
            }
        }
    }
    
    private func showQuestionView() {
        questionView.transform = .identity
        questionView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        
        questionView.style = .standard
        
        switch game.state {
        case .ongoing:
            questionView.title = game.currentQuestion.title
        case .over:
            questionView.title = "Game Over"
            showGameOverQuestionView()
        }
        
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [], animations: {
            self.questionView.transform = .identity
        }, completion: nil)
    }
    
    
    // #### BONUS ####
    
    // change the size of the score if the player wins or loses
    private func changeSizeScoreView() {
        var scoreTransform: CGAffineTransform
        if questionView.style == .correct {
            scoreTransform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        } else {
            scoreTransform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }
        
        UIView.animate(withDuration: 0.5, delay: 0.2, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: [], animations: {
            self.scoreLabel.transform = scoreTransform
        }, completion: nil)
    }
    
    // change of background color of the score view if the player wins or loses
    private func changeBackgroundColorScoreView() {
        var scoreBackgroundColor: UIColor
        if questionView.style == .correct {
            scoreBackgroundColor = #colorLiteral(red: 0, green: 0.5628422499, blue: 0.3188166618, alpha: 0.5)
        } else {
            scoreBackgroundColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 0.5048694349)
        }
        
        UIView.animate(withDuration: 0.7, delay: 0.0, usingSpringWithDamping: 0.2, initialSpringVelocity: 0.2, options: [], animations: {
            self.scoreLabel.backgroundColor = scoreBackgroundColor
        }, completion: nil)
    }
    
    // change of opacity of the score
    private func changeOpacityScoreView() {
        UIView.animate(withDuration: 0.5, delay: 0.1, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.4, options: [], animations: {
            self.scoreLabel.alpha = CGFloat(0.1)
        }) { (success) in
            if success {
                self.scoreLabel.alpha = CGFloat(1.0)
            }
        }
    }
    
    // animates the score by changing the background color, the size and the opacity of score text
    private func showScoreView() {
        changeSizeScoreView()
        changeBackgroundColorScoreView()
        changeOpacityScoreView()
    }
    
    // change background color of the "Game Over" view based of the score
    private func showGameOverQuestionView() {
        var gameOverBackgroundColorView: UIColor
        if game.score > 5 {
            gameOverBackgroundColorView = #colorLiteral(red: 0.5818830132, green: 0.2156915367, blue: 1, alpha: 0.7974101027)
        } else if game.score == 5 {
            gameOverBackgroundColorView = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 0.7975438784)
        } else {
            gameOverBackgroundColorView = #colorLiteral(red: 1, green: 0.4932718873, blue: 0.4739984274, alpha: 0.9012735445)
        }
        
        UIView.animate(withDuration: 0.7, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8, options: [], animations: {
            self.questionView.backgroundColor = gameOverBackgroundColorView
        }, completion: nil)
    }


}

