//
//  Message.swift
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

class Message: Object, MessageType {
    
    @objc dynamic var messageId: String = ""
    @objc dynamic var sentDate: Date = Date()
    @objc dynamic var content: String = ""
    var image: Image? = nil
    var sender: Sender = Sender(id: "", displayName: "")
    var kind: MessageKind {
        if let image = image {
            return .photo(image)
        } else {
            return .text(content)
        }
    }
    
    override static func primaryKey() -> String? {
        return "messageId"
    }
    
}


extension Message {
    func initialize(messageId: String, sender: Sender, sentDate: Date, content: String) {
        self.messageId = messageId
        self.sender = sender
        self.sentDate = sentDate
        self.content = content
        self.image?.image = nil
        self.image?.url = nil
    }
    
    func initialize(document: QueryDocumentSnapshot) -> Bool {
        let data = document.data()
        
        guard let senderId = data["senderID"] as? String,
            let displayName =  data["senderName"] as? String else {
                print("displayName fail")
                return false
        }
        guard let time = data["created"] as? Timestamp else {
            print("time fail")
            return false
        }
        guard let content = data["content"] as? String else {
            print("content fail")
            return false
        }
        self.sender = Sender(id: senderId, displayName: displayName)
        self.sentDate = time.dateValue()
        self.content = content
        self.messageId = document.documentID
        self.image = nil
        self.image?.url = nil
        
        return true
    }
    
    func initialize(user: User, content: String) -> Bool {
        sender = Sender(id: user.uid, displayName: AppDefs.displayName)
        self.content = content
        sentDate = Date()
        // ignoring messageId
        self.messageId = "0"
        // self.messageId = String(arc4random_uniform(100000))
        return true
    }
}
extension Message: Comparable {
    
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.messageId == rhs.messageId
    }
    
    static func < (lhs: Message, rhs: Message) -> Bool {
        return lhs.sentDate < rhs.sentDate
    }
    
}
protocol DatabaseRepresentation {
    var representation: [String: Any] { get }
}

extension Message: DatabaseRepresentation {
    
    var representation: [String : Any] {
        var rep: [String : Any] = [
            "created": sentDate,
            "senderID": sender.id,
            "senderName": sender.displayName
        ]
        
        if let url = image?.url {
            rep["url"] = url.absoluteString
        } else {
            rep["content"] = content
        }
        
        return rep
    }
    
}
