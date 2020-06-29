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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    private func setupPlayArea() {
        playArea.layer.borderColor = UIColor.black.cgColor
        playArea.layer.borderWidth = 1
        let touchDownOnPlayArea = UILongPressGestureRecognizer(target: self, action: #selector(self.missedTap(_:)))
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
            bugView.isUserInteractionEnabled = true
            let touchDownOnBug = UILongPressGestureRecognizer(target: self, action: #selector(self.removeBug(_:)))
            touchDownOnBug.minimumPressDuration = 0
            bugView.addGestureRecognizer(touchDownOnBug)
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
    }
    
    @objc private func removeBug(_ gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state == .began {
            startTimerOnce()
            let bug = gestureRecognizer.view as! UIImageView
            bug.removeFromSuperview()
            kills += 1
            killedLabel.text = String("Killed: \(kills)")
            if kills == bugs.count {
                levelCleared()
            }
        }
    }
    
    @objc private func missedTap(_ gestureRecognizer: UIGestureRecognizer) {
        if !isFinished && gestureRecognizer.state == .began {
            startTimerOnce()
            misses += 1
            missedLabel.text = String("Missed: \(misses)")
        }
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}
