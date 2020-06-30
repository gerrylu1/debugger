//
//  AppInitializer.swift
//  Debugger
//
//  Created by Gerry Low on 2020-06-30.
//  Copyright © 2020 Gerry Low. All rights reserved.
//

import CoreData

class AppInitializer {
    
    var dataController: DataController!
    
    func initialize() {
        initializeLevels()
        UserDefaults.standard.set(true, forKey: AppDelegate.keyForHasInitDefaultLevels)
        do {
            try dataController.save()
        } catch {
            print(error)
        }
    }
    
    func initializeLevels() {
        let levels = DefaultLevels()
        for defaultLevel in levels.defaultLevels {
            let level = Level(context: dataController.viewContext)
            level.dateCreated = defaultLevel.dateCreated
            level.isCustom = false
            level.name = defaultLevel.name
            if let bgImage = defaultLevel.bgImage {
                level.bgImage = bgImage.jpegData(compressionQuality: 0.7)
            }
            for bug in defaultLevel.bugs {
                let newBug = Bug(context: dataController.viewContext)
                newBug.xLocation = bug.xLocation
                newBug.yLocation = bug.yLocation
                newBug.size = bug.size
                newBug.level = level
            }
        }
    }
    
}
