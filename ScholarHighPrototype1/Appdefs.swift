//
//  AppSettings.swift
//  ScholarHighPrototype1
//
//  Created by 広瀬陽一 on 2018/10/27.
//  Copyright © 2018 FRESHNESS. All rights reserved.
//

import Foundation
import Firebase
import MessageKit
import RealmSwift
import Realm

final class AppDefs {
    static var displayName: String! {
        get {
            return UserDefaults.standard.string(forKey: "displayName")
        }
        set {
            let defaults = UserDefaults.standard
            let key = "displayName"
        
            if let name = newValue {
                defaults.set(name, forKey: key)
            } else {
                defaults.removeObject(forKey: key)
            }
        }
    }
}






struct Image: MediaItem {
    
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
    
}




extension UIColor {
    
    static var primary: UIColor {
        return UIColor(red: 1 / 255, green: 93 / 255, blue: 48 / 255, alpha: 1)
    }
    
    static var incomingMessage: UIColor {
        return UIColor(red: 230 / 255, green: 230 / 255, blue: 230 / 255, alpha: 1)
    }
    
}
