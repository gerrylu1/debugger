//
//  DefaultLevels.swift
//  Debugger
//
//  Created by Gerry Low on 2020-06-30.
//  Copyright © 2020 Gerry Low. All rights reserved.
//

import UIKit

struct DefaultLevel {
    let name: String
    let dateCreated: Date
    let bgImage: UIImage?
    let bugs: [BugForDefaultLevel]
}

struct BugForDefaultLevel {
    let size: Double
    let xLocation: Double
    let yLocation: Double
}

class DefaultLevels {
    
    let dateFormatter: DateFormatter
    var defaultLevels: [DefaultLevel] = []
    
    init() {
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        createLevels()
    }
    
    func createLevels() {
        createLevel1()
        createLevel2()
        createLevel3()
        createLevel4()
        createLevel5()
    }
    
    func createLevel1() {
        let bug1 = BugForDefaultLevel(size: 100.0, xLocation: 20.0, yLocation: 20.0)
        let bug2 = BugForDefaultLevel(size: 100.0, xLocation: 180.0, yLocation: 20.0)
        let bug3 = BugForDefaultLevel(size: 100.0, xLocation: 100.0, yLocation: 180.0)
        let level1 = DefaultLevel(name: "Level 1", dateCreated: dateFormatter.date(from: "2020-06-29 17:01:00")!, bgImage: UIImage(named: "DefaultLevelBackground"), bugs: [bug1, bug2, bug3])
        defaultLevels.append(level1)
    }
    
    func createLevel2() {
        let bug1 = BugForDefaultLevel(size: 50.0, xLocation: 20.0, yLocation: 20.0)
        let bug2 = BugForDefaultLevel(size: 50.0, xLocation: 230.0, yLocation: 20.0)
        let bug3 = BugForDefaultLevel(size: 50.0, xLocation: 20.0, yLocation: 230.0)
        let bug4 = BugForDefaultLevel(size: 50.0, xLocation: 230.0, yLocation: 230.0)
        let bug5 = BugForDefaultLevel(size: 70.0, xLocation: 115.0, yLocation: 115.0)
        let level2 = DefaultLevel(name: "Level 2", dateCreated: dateFormatter.date(from: "2020-06-29 17:02:00")!, bgImage: UIImage(named: "DefaultLevelBackground"), bugs: [bug1, bug2, bug3, bug4, bug5])
        defaultLevels.append(level2)
    }
    
    func createLevel3() {
        let bug1 = BugForDefaultLevel(size: 40.0, xLocation: 20.0, yLocation: 20.0)
        let bug2 = BugForDefaultLevel(size: 40.0, xLocation: 130.0, yLocation: 20.0)
        let bug3 = BugForDefaultLevel(size: 40.0, xLocation: 240.0, yLocation: 20.0)
        let bug4 = BugForDefaultLevel(size: 40.0, xLocation: 20.0, yLocation: 130.0)
        let bug5 = BugForDefaultLevel(size: 40.0, xLocation: 130.0, yLocation: 130.0)
        let bug6 = BugForDefaultLevel(size: 40.0, xLocation: 240.0, yLocation: 130.0)
        let bug7 = BugForDefaultLevel(size: 40.0, xLocation: 20.0, yLocation: 240.0)
        let bug8 = BugForDefaultLevel(size: 40.0, xLocation: 130.0, yLocation: 240.0)
        let bug9 = BugForDefaultLevel(size: 40.0, xLocation: 240.0, yLocation: 240.0)
        let level3 = DefaultLevel(name: "Level 3", dateCreated: dateFormatter.date(from: "2020-06-29 17:03:00")!, bgImage: UIImage(named: "DefaultLevelBackground"), bugs: [bug1, bug2, bug3, bug4, bug5, bug6, bug7, bug8, bug9])
        defaultLevels.append(level3)
    }
    
    func createLevel4() {
        let bug1 = BugForDefaultLevel(size: 40.0, xLocation: 176.4, yLocation: 229.1)
        let bug2 = BugForDefaultLevel(size: 40.0, xLocation: 197.8, yLocation: 27.0)
        let bug3 = BugForDefaultLevel(size: 40.0, xLocation: 91.2, yLocation: 193.7)
        let bug4 = BugForDefaultLevel(size: 40.0, xLocation: 128.4, yLocation: 236.9)
        let bug5 = BugForDefaultLevel(size: 40.0, xLocation: 125.0, yLocation: 142.3)
        let bug6 = BugForDefaultLevel(size: 40.0, xLocation: 37.5, yLocation: 56.9)
        let bug7 = BugForDefaultLevel(size: 40.0, xLocation: 140.1, yLocation: 96.6)
        let bug8 = BugForDefaultLevel(size: 40.0, xLocation: 26.0, yLocation: 51.6)
        let bug9 = BugForDefaultLevel(size: 40.0, xLocation: 258.4, yLocation: 131.4)
        let bug10 = BugForDefaultLevel(size: 40.0, xLocation: 224.3, yLocation: 151.0)
        let bug11 = BugForDefaultLevel(size: 40.0, xLocation: 65.2, yLocation: 172.1)
        let bug12 = BugForDefaultLevel(size: 40.0, xLocation: 221.1, yLocation: 217.7)
        let bug13 = BugForDefaultLevel(size: 40.0, xLocation: 6.7, yLocation: 164.1)
        let bug14 = BugForDefaultLevel(size: 40.0, xLocation: 134.2, yLocation: 14.8)
        let bug15 = BugForDefaultLevel(size: 40.0, xLocation: 63.0, yLocation: 158.2)
        let bug16 = BugForDefaultLevel(size: 40.0, xLocation: 60.4, yLocation: 249.5)
        let bug17 = BugForDefaultLevel(size: 40.0, xLocation: 132.4, yLocation: 96.4)
        let bug18 = BugForDefaultLevel(size: 40.0, xLocation: 184.4, yLocation: 147.5)
        let level4 = DefaultLevel(name: "Level 4", dateCreated: dateFormatter.date(from: "2020-06-29 17:04:00")!, bgImage: UIImage(named: "DefaultLevelBackground"), bugs: [bug1, bug2, bug3, bug4, bug5, bug6, bug7, bug8, bug9, bug10, bug11, bug12, bug13, bug14, bug15, bug16, bug17, bug18])
        defaultLevels.append(level4)
    }
    
    func createLevel5() {
        let bug1 = BugForDefaultLevel(size: 30.0, xLocation: 175.1, yLocation: 17.9)
        let bug2 = BugForDefaultLevel(size: 30.0, xLocation: 48.8, yLocation: 263.0)
        let bug3 = BugForDefaultLevel(size: 30.0, xLocation: 10.1, yLocation: 188.1)
        let bug4 = BugForDefaultLevel(size: 30.0, xLocation: 212.7, yLocation: 146.3)
        let bug5 = BugForDefaultLevel(size: 30.0, xLocation: 167.4, yLocation: 44.5)
        let bug6 = BugForDefaultLevel(size: 30.0, xLocation: 161.3, yLocation: 40.7)
        let bug7 = BugForDefaultLevel(size: 30.0, xLocation: 148.5, yLocation: 65.9)
        let bug8 = BugForDefaultLevel(size: 30.0, xLocation: 137.2, yLocation: 148.8)
        let bug9 = BugForDefaultLevel(size: 30.0, xLocation: 260.9, yLocation: 233.8)
        let bug10 = BugForDefaultLevel(size: 30.0, xLocation: 86.7, yLocation: 10.2)
        let bug11 = BugForDefaultLevel(size: 30.0, xLocation: 196.4, yLocation: 69.9)
        let bug12 = BugForDefaultLevel(size: 30.0, xLocation: 201.1, yLocation: 109.4)
        let bug13 = BugForDefaultLevel(size: 30.0, xLocation: 226.2, yLocation: 203.1)
        let bug14 = BugForDefaultLevel(size: 30.0, xLocation: 0.0, yLocation: 244.4)
        let bug15 = BugForDefaultLevel(size: 30.0, xLocation: 66.5, yLocation: 157.2)
        let bug16 = BugForDefaultLevel(size: 30.0, xLocation: 186.4, yLocation: 102.1)
        let bug17 = BugForDefaultLevel(size: 30.0, xLocation: 185.5, yLocation: 56.4)
        let bug18 = BugForDefaultLevel(size: 30.0, xLocation: 161.3, yLocation: 156.2)
        let bug19 = BugForDefaultLevel(size: 30.0, xLocation: 267.3, yLocation: 94.9)
        let bug20 = BugForDefaultLevel(size: 30.0, xLocation: 14.8, yLocation: 238.8)
        let bug21 = BugForDefaultLevel(size: 30.0, xLocation: 239.2, yLocation: 112.5)
        let bug22 = BugForDefaultLevel(size: 30.0, xLocation: 58.9, yLocation: 164.3)
        let bug23 = BugForDefaultLevel(size: 30.0, xLocation: 171.2, yLocation: 27.8)
        let bug24 = BugForDefaultLevel(size: 30.0, xLocation: 126.8, yLocation: 20.0)
        let bug25 = BugForDefaultLevel(size: 30.0, xLocation: 197.4, yLocation: 178.6)
        let bug26 = BugForDefaultLevel(size: 30.0, xLocation: 115.3, yLocation: 249.3)
        let bug27 = BugForDefaultLevel(size: 30.0, xLocation: 240.5, yLocation: 34.0)
        let bug28 = BugForDefaultLevel(size: 30.0, xLocation: 190.3, yLocation: 44.7)
        let bug29 = BugForDefaultLevel(size: 30.0, xLocation: 217.3, yLocation: 31.4)
        let bug30 = BugForDefaultLevel(size: 30.0, xLocation: 223.4, yLocation: 260.0)
        let bug31 = BugForDefaultLevel(size: 30.0, xLocation: 117.9, yLocation: 205.3)
        let bug32 = BugForDefaultLevel(size: 30.0, xLocation: 243.9, yLocation: 209.6)
        let level5 = DefaultLevel(name: "Level 5", dateCreated: dateFormatter.date(from: "2020-06-29 17:05:00")!, bgImage: UIImage(named: "DefaultLevelBackground"), bugs: [bug1, bug2, bug3, bug4, bug5, bug6, bug7, bug8, bug9, bug10, bug11, bug12, bug13, bug14, bug15, bug16, bug17, bug18, bug19, bug20, bug21, bug22, bug23, bug24, bug25, bug26, bug27, bug28, bug29, bug30, bug31, bug32])
        defaultLevels.append(level5)
    }
    
}
