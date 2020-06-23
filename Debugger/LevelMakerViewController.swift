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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playArea.layer.borderColor = UIColor.black.cgColor
        playArea.layer.borderWidth = 1
    }
    
}
