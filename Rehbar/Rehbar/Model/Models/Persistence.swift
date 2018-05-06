//
//  Persistence.swift
//  Rehbar
//
//  Created by Nandu Ahmed on 5/2/18.
//  Copyright © 2018 anz. All rights reserved.
//

import Foundation

enum StoreValue: String {
    case spreadsheetId = "spreadsheetId"
}

class PersistenceStore {
    
    static func store(value:String, type:StoreValue ) {
        UserDefaults.standard.set(value, forKey: type.rawValue)
    }
    
    static func retreiveValue(type:StoreValue) -> String? {
        return UserDefaults.standard.value(forKey: type.rawValue) as? String
    }
}
