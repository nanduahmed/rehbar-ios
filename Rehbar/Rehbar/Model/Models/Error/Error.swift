//
//  Error.swift
//  Rehbar
//
//  Created by Nandu Ahmed on 5/9/18.
//  Copyright © 2018 anz. All rights reserved.
//

import Foundation


enum RehbarError : Error {
    case IndexNotAvailable
    case InvalidUrl
    case InvalidSpreadSheet
    case SpreadSheetIdNotConfigured
    
    
    func message(id:String?) -> String {
        switch self {
        case .SpreadSheetIdNotConfigured:
            return "Your Spreadsheet ID is not configured"
        case .InvalidSpreadSheet:
            if let message = id {
                return "Spreadsheet id error - \(message)"
            } else {
                return "Configured spreadsheet id does not gives response"
            }
        default:
            return "Unknown Error"
        }
    }
}
