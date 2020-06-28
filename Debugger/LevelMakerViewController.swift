//
//  LevelMakerViewController.swift
//  Debugger
//
//  Created by Gerry Low on 2020-06-23.
//  Copyright © 2020 Gerry Low. All rights reserved.
//

import UIKit

class LevelMakerViewController: UIViewController {
    
    @IBOutlet weak var playArea: UIView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var outOfAreaLabel: UILabel!
    @IBOutlet weak var controls: UIStackView!
    @IBOutlet weak var bgImageView: UIImageView!
    
    var dataController: DataController!
    
    let bugWidth: CGFloat = 50.0
    let bugHeight: CGFloat = 50.0
    let playAreaWidth: CGFloat = 300
    let playAreaHeight: CGFloat = 300
    
    var bgImage: UIImage? = nil
    var isAddingBugs = true
    var bugs = [UIImageView]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackgroundForControls()
        setupPlayArea()
        switchToAddingBugs()
    }
    
    func updateBGImage() {
        bgImageView.image = bgImage
    }
    
    private func setupPlayArea() {
        playArea.layer.borderColor = UIColor.black.cgColor
        playArea.layer.borderWidth = 1
        playArea.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.addBug(_:))))
    }
    
    private func setupBackgroundForControls() {
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.white
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        let blurEffect = UIBlurEffect(style: .extraLight)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.bounds = controls.bounds
        blurEffectView.frame.origin = CGPoint(x: 0, y: 0)
        
        controls.insertSubview(blurEffectView, at: 0)
    }
    
    @objc private func addBug(_ gestureRecognizer: UIGestureRecognizer) {
        if isAddingBugs {
            let location = gestureRecognizer.location(in: playArea)
            let x = location.x - bugWidth / 2
            let y = location.y - bugHeight / 2
            if x > 0 && x < playAreaWidth - bugWidth && y > 0 && y < playAreaHeight - bugHeight {
                let bug = createBug(x: x, y: y)
                bug.isUserInteractionEnabled = false
                bug.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.removeBug(_:))))
                bugs.append(bug)
                playArea.addSubview(bug)
            } else {
                if outOfAreaLabel.alpha == 0 {
                    showOutOfPlayArea()
                }
            }
        }
    }
    
    private func createBug(x: CGFloat, y: CGFloat) -> UIImageView {
        let bug = UIImageView(frame: CGRect(x: x, y: y, width: bugWidth, height: bugHeight))
        bug.image = UIImage(named: "Bug")
        return bug
    }
    
    @objc private func removeBug(_ gestureRecognizer: UIGestureRecognizer) {
        if !isAddingBugs {
            let bug = gestureRecognizer.view as! UIImageView
            bug.removeFromSuperview()
            bugs.removeAll { (imageView) -> Bool in
                return imageView == bug
            }
        }
    }
    
    private func showOutOfPlayArea() {
        UIView.animate(withDuration: 0.5) {
            self.outOfAreaLabel.alpha = 1.0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            UIView.animate(withDuration: 0.5) {
                self.outOfAreaLabel.alpha = 0
            }
        }
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        switchToAddingBugs()
    }
    
    @IBAction func removeButtonTapped(_ sender: Any) {
        switchToRemovingBugs()
    }
    
    private func switchToAddingBugs() {
        isAddingBugs = true
        addButton.backgroundColor = .systemGray5
        removeButton.backgroundColor = .clear
        for bug in bugs {
            bug.isUserInteractionEnabled = false
        }
    }
    
    private func switchToRemovingBugs() {
        isAddingBugs = false
        addButton.backgroundColor = .clear
        removeButton.backgroundColor = .systemGray5
        for bug in bugs {
            bug.isUserInteractionEnabled = true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ImagePickerViewController {
            vc.dataController = dataController
        }
    }
    
}
