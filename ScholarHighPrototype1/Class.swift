//
//  Class.swift
//  ScholarHighPrototype1
//
//  Created by Myleston Law on 2018/11/13.
//  Copyright © 2018 FRESHNESS. All rights reserved.
//

import Foundation
import Firebase
import MessageKit
import RealmSwift
import Realm

class Class: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var day: String = ""
    @objc dynamic var period: Int = 0
    @objc dynamic var teacherName: String = ""
    @objc dynamic var classID: String = ""
}

extension Class {
    func initialize(title: String, day: String, period: Int, teacherName: String, classID: String) -> Bool {
        self.title = title
        self.day = day
        self.period = period
        self.teacherName = teacherName
        self.classID = classID
        return true
    }
}
