//
//  Places.swift
//  Rehbar
//
//  Created by Nandu Ahmed on 4/27/18.
//  Copyright © 2018 anz. All rights reserved.
//

import Foundation

import CoreLocation


typealias JsonDict = [String:Any]

enum PlacesStatus:String {
    case Ok = "OK"
    case ZeroResults = "ZERO_RESULTS"
    case Unknown
}

class Place {
    var address:String?
    var coordinates:CLLocationCoordinate2D?
}

struct BrotherItemIndexes {
    var firstNameIndex = -1
    var lastNameIndex = -1
    var addressIndex = -1
    var cityIndex = -1
    var zipcodeIndex = -1
    var lastVisitedIndex = -1
    var commentsIndex = -1
    
    private var count = 0

    init(data:[String]) {
        for (index,column) in data.enumerated() {
            switch column.lowercased() {
            case "first name","firstname":
                firstNameIndex = index
                count += 1
                break
            case "last name", "lastname":
                lastNameIndex = index
                count += 1
                break
            case "address":
                addressIndex = index
                count += 1
                break
            case "city":
                cityIndex = index
                count += 1
                break
            case "zip code" , "zipcode", "zip":
                zipcodeIndex = index
                count += 1
                break
            case "date visited","datevisited":
                lastVisitedIndex = index
                //count += 1
                break
            case "comments":
                commentsIndex = index
                //count += 1
                break
            default:
                break
            }
        }
    }
    
    func isIndexItemValid() -> Bool {
        return count >= 4
    }
    
    func indexMissingInfo() -> String {
        var value = "Missing Coumns in your excel sheet are "
        if self.addressIndex == -1 {
            value += "Address, "
        }
        if self.cityIndex == -1 {
            value += "City, "
        }
        if self.commentsIndex == -1 {
            value += "Comments, "
        }
        if self.firstNameIndex == -1 {
            value += "First Name, "
        }
        if self.lastNameIndex == -1 {
            value += "Last Name, "
        }
        if self.zipcodeIndex == -1 {
            value += "Zip Code"
        }
        return value
    }
}

struct Brother {
    var firstName:String?
    var lastName:String?
    var address:String?
    var city:String?
    var zipcode:String?
    var lastVisited:String?
    var comments:[String]?
    
    var success = false
    
    var place:Place = Place()
    
    
    init?(data:[String]?) {
        guard let brotherIndex = Models.shared.brotherIndex else {
           return nil
        }
        
        let containsFirstName = data?.indices.contains(brotherIndex.firstNameIndex)
        let containsLastName = data?.indices.contains(brotherIndex.lastNameIndex)
        let containsAddress = data?.indices.contains(brotherIndex.addressIndex)
        let containsCity = data?.indices.contains(brotherIndex.cityIndex)
        let containsZipCode = data?.indices.contains(brotherIndex.zipcodeIndex)

        
        if ( containsFirstName! &&
            containsLastName! &&
            containsAddress! &&
            containsCity! ){
            
            if let fn = data?[brotherIndex.firstNameIndex],
                let ln = data?[brotherIndex.lastNameIndex],
                let add = data?[brotherIndex.addressIndex],
                let city = data?[brotherIndex.cityIndex]{
                
                self.firstName = fn
                self.lastName = ln
                self.address = add
                self.city = city
                self.success = true
            }
        }

        if (data?.indices.contains(brotherIndex.zipcodeIndex) == true) {
            if let date = data?[brotherIndex.zipcodeIndex] {
                self.zipcode = date
            }
        }
        
        
        if (data?.indices.contains(brotherIndex.lastVisitedIndex) == true) {
            if let date = data?[brotherIndex.lastVisitedIndex] {
                self.lastVisited = date
            }
        }
        
        if (data?.indices.contains(brotherIndex.commentsIndex) == true) {
            if let comments = data?[brotherIndex.commentsIndex] {
                let commentsArray = comments.components(separatedBy: ".")
                self.comments = commentsArray
            }
        }
    }
    
    func addCordinates(coordinate:CLLocationCoordinate2D)  {
        self.place.coordinates = coordinate
    }
}

class SpreadSheet {
    var spreadSheetId:String?
    var spreadSheetName:String?
    var rows:UInt = 0
    var columns:UInt = 0
    
    var success = false
    
    init(data:[String:Any]) {
        if let properties = data["properties"] as? [String:Any] ,
            let sheets = data["sheets"] as? [Any] ,
            let name = properties["title"] as? String ,
            let firstSheet = sheets.first as? [String:Any],
            let firstSheetProps = firstSheet["properties"] as? [String:Any] ,
            let gridProps = firstSheetProps["gridProperties"] as? [String:Any],
            
            let rowCount = gridProps["rowCount"] as? UInt,
            let colCount = gridProps["columnCount"] as? UInt {
            
            self.rows = rowCount
            self.columns = colCount
            self.spreadSheetName = name
            success = true
        }
        
        if let error = data["error"] as? JsonDict,
            let message = error["message"] as? String {
                self.spreadSheetName = "Error: " + message
            }
    }
}


class Models {
    
    static var shared = Models()
    
    var all:[Place] = [Place]()
    var brothers:[Brother] = [Brother]()
    var status:PlacesStatus = .Unknown
    var brotherIndex:BrotherItemIndexes?
    
    var currentSheet:SpreadSheet?
    
    var searchText:String?
    
    public func create(data:[String:Any]) {
        self.all.removeAll()
        if let content = data["results"] as? [Any] , let status = data["status"] as? String {
            for item in content {
                if let itemDict = item as? [String:Any] ,
                    let add = itemDict["formatted_address"] as? String,
                    let geometryItem = itemDict["geometry"] as? [String:Any] ,
                    let location = geometryItem["location"] as? [String:Any] ,
                    let lat = location["lat"] as? CLLocationDegrees ,
                    let long = location["lng"] as? CLLocationDegrees {
                    
                    let model = Place()
                    model.address = add
                    model.coordinates = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    
                    
                    self.all.append(model)
                }
            }
            if (status == PlacesStatus.Ok.rawValue) {
                self.status = .Ok
            } else if (status == PlacesStatus.ZeroResults.rawValue ) {
                self.status = .ZeroResults
            }
        }
    }

    public func createBrothers(data:[String:Any]) {
        self.brothers.removeAll()
        if let content = data["valueRanges"] as? [Any] ,
            //let id = data["spreadsheetId"] as? String ,
            let firstRange = content.first as? [String:Any],
            let values = firstRange["values"] as? [Any] {
            for item in values {
                if let brothers = item as? [String] {
                    if let model = Brother(data: brothers),
                        (model.success == true) {
                        self.brothers.append(model)
                    }
                }
            }
        }
    }
    
    public func checkForIndex(data:JsonDict) -> Bool {
        if let content = data["valueRanges"] as? [Any] ,
            let firstRange = content.first as? [String:Any],
            let values = firstRange["values"] as? [Any] {
            
            if let header = values.first as? [String] {
                let itemIndexes = BrotherItemIndexes(data: header)
                self.brotherIndex = itemIndexes
                return itemIndexes.isIndexItemValid()
            }
        }
        return false
    }

    init() {
        self.status = .Unknown
    }
    
}

