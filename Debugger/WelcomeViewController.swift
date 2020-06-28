//
//  ViewController.swift
//  Debugger
//
//  Created by Gerry Low on 2020-06-23.
//  Copyright © 2020 Gerry Low. All rights reserved.
//

import UIKit
import CoreData

class WelcomeViewController: UIViewController {
    
    var dataController: DataController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? LevelSelectionViewController {
            vc.dataController = dataController
        }
        if let vc = segue.destination as? LevelBrowserViewController {
            vc.dataController = dataController
        }
    }
    
}
