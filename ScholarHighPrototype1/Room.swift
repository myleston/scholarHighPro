//
//  Room.swift
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

class Room: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var topicType: String = ""
    var latestTime: Timestamp = Timestamp(date: Date())
    @objc dynamic var roomId: String  = ""
    
    override static func primaryKey() -> String? {
        return "roomId"
    }
}

extension Room {
    func initialize(title: String, topicType: String, latestTime: Timestamp, roomId: String) -> Bool {
        self.title = title
        self.topicType = topicType
        self.latestTime = latestTime
        self.roomId = roomId
        return true
    }
    
    func initialize(document: QueryDocumentSnapshot) -> Bool {
        let data = document.data()
        
        guard let title = data["title"] as? String else {
            return false
        }
        
        guard let topicType = data["topicType"] as? String else{
            return false
        }
        
        self.title = title
        self.topicType = topicType
        
        guard let time = data["latestTime"] as? Timestamp else {
            return false
        }
        self.latestTime = time
        
        self.roomId = document.documentID
        return true
    }
}

extension Room: Comparable {
    
    static func == (lhs: Room, rhs: Room) -> Bool {
        return lhs.roomId == rhs.roomId
    }
    static func < (lhs: Room, rhs: Room) -> Bool {
        return lhs.latestTime.dateValue() < rhs.latestTime.dateValue()
    }
}
