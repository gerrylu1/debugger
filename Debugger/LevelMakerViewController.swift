//
//  LevelMakerViewController.swift
//  Debugger
//
//  Created by Gerry Low on 2020-06-23.
//  Copyright © 2020 Gerry Low. All rights reserved.
//

import UIKit
import CoreData

class LevelMakerViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var playArea: UIView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var outOfAreaLabel: UILabel!
    @IBOutlet weak var controls: UIStackView!
    @IBOutlet weak var bgImageView: UIImageView!
    
    var dataController: DataController!
    
    // config UI elements
    let bugWidth: CGFloat = 50.0
    let bugHeight: CGFloat = 50.0
    let playAreaWidth: CGFloat = 300
    let playAreaHeight: CGFloat = 300
    
    // set the compression quality for converting downloaded images to data for storing
    let compressionQuality: CGFloat = 0.7
    
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
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        if nameTextField.text == "" {
            showAlert(title: "Name Required", message: "Please enter a name for this level. You can enter a space if you don't want to name it.", on: self)
        } else if bugs.isEmpty {
            showAlert(title: "No Bugs Added", message: "Please add a bug at least in the play area.", on: self)
        } else {
            saveLevel()
        }
        
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
    
    private func saveLevel() {
        var levelsCount = 0
        let fetchRequest: NSFetchRequest<Level> = Level.fetchRequest()
        do {
            let result = try dataController.viewContext.fetch(fetchRequest)
            let levels = result
            levelsCount = levels.count
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
        let newLevel = Level(context: dataController.viewContext)
        newLevel.id = Int64(levelsCount + 1)
        newLevel.isCustom = true
        newLevel.name = nameTextField.text
        if let bgImage = bgImage {
            newLevel.bgImage = bgImage.jpegData(compressionQuality: compressionQuality)
        }
        for bug in bugs {
            let newBug = Bug(context: dataController.viewContext)
            newBug.xLocation = Double(bug.frame.origin.x)
            newBug.yLocation = Double(bug.frame.origin.y)
            newBug.level = newLevel
        }
        do {
            try dataController.save()
            navigationController?.popViewController(animated: true)
        } catch {
            showAlert(title: "Failed to Save Level", message: error.localizedDescription, on: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ImagePickerViewController {
            vc.dataController = dataController
        }
    }
    
}
