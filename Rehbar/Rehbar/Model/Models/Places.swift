//
//  Places.swift
//  Rehbar
//
//  Created by Nandu Ahmed on 4/27/18.
//  Copyright © 2018 anz. All rights reserved.
//

import Foundation

import CoreLocation


enum PlacesStatus:String {
    case Ok = "OK"
    case ZeroResults = "ZERO_RESULTS"
    case Unknown
}

class Place {
    var address:String?
    var coordinates:CLLocationCoordinate2D?
}

struct Brother {
    var firstName:String?
    var lastName:String?
    var address:String?
    var zipcode:String?
    var lastVisited:String?
    var comments:String?
    
    var place:Place = Place()
    
    
    init(data:[String]?) {
        if let fn = data?[0],
            let ln = data?[1],  
            let add = data?[2],
            let zip = data?[3],
            let comments = data?[6] {
            
            self.firstName = fn
            self.lastName = ln
            self.address = add
            self.zipcode = zip
            self.comments = comments
        }
    }
    
    func addCordinates(coordinate:CLLocationCoordinate2D)  {
        self.place.coordinates = coordinate
    }
}

class SpreadSheet {
    var spreadSheetId:String?
    var brothers:[Brother] = [Brother]()
}


class Models {
    
    static var shared = Models()
    
    var all:[Place] = [Place]()
    var brothers:[Brother] = [Brother]()

    var status:PlacesStatus = .Unknown
    
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
                    let model = Brother(data: brothers)
                    self.brothers.append(model)
                }
            }
            
        }
    }

    init() {
        self.status = .Unknown
    }
    
}

