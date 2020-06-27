//
//  LevelBrowserViewController.swift
//  Debugger
//
//  Created by Gerry Low on 2020-06-23.
//  Copyright © 2020 Gerry Low. All rights reserved.
//

import UIKit

class LevelBrowserViewController: UIViewController {
    
    var dataController: DataController!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? LevelMakerViewController {
            vc.dataController = dataController
        }
    }
    
}
