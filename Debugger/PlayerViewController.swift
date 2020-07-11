//
//  PlayerViewController.swift
//  Debugger
//
//  Created by Gerry Low on 2020-06-23.
//  Copyright © 2020 Gerry Low. All rights reserved.
//

import UIKit
import CoreData

class PlayerViewController: UIViewController {
    
    @IBOutlet weak var playArea: UIView!
    @IBOutlet weak var gamePanel: UIStackView!
    @IBOutlet weak var killedLabel: UILabel!
    @IBOutlet weak var missedLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var topButtonView: UIStackView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var bgImageView: UIImageView!
    
    var dataController: DataController!
    var level: Level!
    var bugs: [Bug] = []
    var bugViews: [UIImageView] = []
    
    var kills: Int = 0
    var misses: Int = 0
    var timeAtFirstTap = Date()
    var timeAtFinish = Date()
    var timerStarted = false
    var isFinished = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        setupBlurEffectForView(gamePanel)
        setupBlurEffectForView(topButtonView)
        setupPlayArea()
        loadBGImage()
        fetchBugs()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !UserDefaults.standard.bool(forKey: AppDelegate.keyForHasDisplayedTipForPlayer) {
            UserDefaults.standard.set(true, forKey: AppDelegate.keyForHasDisplayedTipForPlayer)
            displayTip()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    private func displayTip() {
        showAlert(title: "Tip", message: "Tap on a bug to kill it. If you tap on an empty space, it will count as missed. The objective is to eliminate all bugs as quickly as possible. The timer will start once you tap on a bug or an empty space. Multiple touch is not allowed.", on: self)
    }
    
    private func setupPlayArea() {
        playArea.layer.borderColor = UIColor.black.cgColor
        playArea.layer.borderWidth = 1
        let touchDownOnPlayArea = UILongPressGestureRecognizer(target: self, action: #selector(self.tapOnPlayArea(_:)))
        touchDownOnPlayArea.minimumPressDuration = 0
        playArea.addGestureRecognizer(touchDownOnPlayArea)
    }
    
    private func setupBlurEffectForView(_ view: UIView) {
        let blurEffect = UIBlurEffect(style: .extraLight)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.bounds = view.bounds
        blurEffectView.frame.origin = CGPoint(x: 0, y: 0)
        blurEffectView.clipsToBounds = true
        blurEffectView.layer.cornerRadius = 15
        view.insertSubview(blurEffectView, at: 0)
    }
    
    private func fetchBugs() {
        let fetchRequest: NSFetchRequest<Bug> = Bug.fetchRequest()
        let predicate = NSPredicate(format: "level == %@", level)
        fetchRequest.predicate = predicate
        do {
            let result = try dataController.viewContext.fetch(fetchRequest)
            bugs = result
            loadBugs()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    private func loadBGImage() {
        if let imageData = level.bgImage, let image = UIImage(data: imageData) {
            bgImageView.image = image
        }
    }
    
    private func loadBugs() {
        for bug in bugs {
            let bugView = UIImageView(frame: CGRect(x: bug.xLocation, y: bug.yLocation, width: bug.size, height: bug.size))
            bugView.image = UIImage(named: "Bug")
            bugView.isUserInteractionEnabled = false
            bugViews.append(bugView)
            playArea.addSubview(bugView)
        }
    }
    
    private func timeElapsed() -> Double {
        return Date().timeIntervalSince(timeAtFirstTap)
    }
    
    private func totalTimeElapsed() -> Double {
        return timeAtFinish.timeIntervalSince(timeAtFirstTap)
    }
    
    private func startTimer() {
        timerStarted = true
        timeAtFirstTap = Date()
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { (timer) in
            if !self.isFinished && self.view.window != nil {
                self.timeLabel.text = String(format: "Time: %.1f sec", self.timeElapsed())
            } else {
                timer.invalidate()
            }
        }
    }
    
    private func stopTimer() {
        timerStarted = false
        timeAtFinish = Date()
        timeLabel.text = String(format: "Time: %.2f sec", totalTimeElapsed())
    }
    
    private func saveResult() {
        let newStat = Stat(context: dataController.viewContext)
        newStat.date = timeAtFirstTap
        newStat.level = level
        newStat.kills = Int32(kills)
        newStat.misses = Int32(misses)
        newStat.totalTime = totalTimeElapsed()
        do {
            try dataController.save()
        } catch {
            showAlert(title: "Failed to Save Result", message: error.localizedDescription, on: self)
        }
    }
    
    private func startTimerOnce() {
        if !timerStarted {
            startTimer()
        }
    }
    
    private func levelCleared() {
        isFinished = true
        closeButton.setTitle("Finish", for: .normal)
        stopTimer()
        saveResult()
        Sound.play(file: "finish.mp3")
    }
    
    @objc private func removeBug(_ gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state == .began {
            startTimerOnce()
            kills += 1
            killedLabel.text = String("Killed: \(kills)")
            if kills == bugs.count {
                levelCleared()
            }
            let bugView = gestureRecognizer.view as! UIImageView
            bugView.image = UIImage(named: "BugSquashed")
            UIView.animate(withDuration: 0.5) {
                bugView.alpha = 0
            }
            Sound.play(file: "squashed.mp3")
        }
    }
    
    private func removeBug(_ bugView: UIImageView) {
        kills += 1
        killedLabel.text = String("Killed: \(kills)")
        if kills == bugs.count {
            levelCleared()
        }
        bugView.image = UIImage(named: "BugSquashed")
        UIView.animate(withDuration: 0.5) {
            bugView.alpha = 0
        }
        Sound.play(file: "squashed.mp3")
    }
    
    @objc private func tapOnPlayArea(_ gestureRecognizer: UIGestureRecognizer) {
        if !isFinished && gestureRecognizer.state == .began {
            startTimerOnce()
            let location = gestureRecognizer.location(in: playArea)
            let x = location.x
            let y = location.y
            var bugFound = false
            for i in (0...(bugViews.count - 1)).reversed() {
                let bugView = bugViews[i]
                let bugX = bugView.frame.origin.x
                let bugY = bugView.frame.origin.y
                let bugSize = bugView.frame.width
                if x > bugX && x < bugX + bugSize && y > bugY && y < bugY + bugSize {
                    bugViews.remove(at: i)
                    removeBug(bugView)
                    bugFound = true
                    break
                }
            }
            if !bugFound {
                misses += 1
                missedLabel.text = String("Missed: \(misses)")
                Sound.play(file: "missed.mp3")
            }
        }
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}
