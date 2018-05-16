//
//  NetworkManager.swift
//  Rehbar
//
//  Created by Nandu Ahmed on 4/27/18.
//  Copyright © 2018 anz. All rights reserved.
//

import Foundation

typealias NetworkCompletionType = (_ success:Bool, _ data:[String:Any]?,  Any?) -> (Void)
typealias PlaceCompletionType = (_ success:Bool, _ data:[String:Any]?,  [Place]?) -> (Void)
typealias SheetCompletionType = (_ success:Bool, _ data:[String:Any]?,  [Brother]? , _ error:Error?) -> (Void)


class NetworkManager {
    
    static var shared = NetworkManager()
    
    func getData(values:String, completion:@escaping PlaceCompletionType)  {
        
        //Convert Space in address to +
        let address = values.replacingOccurrences(of: " ", with: "+")
        
        let apiKey = "AIzaSyBB4wCIVJbzyg_Fg_uTie8AtLp6Mg8_SYU"
        let url = "https://maps.googleapis.com/maps/api/geocode/json?address=\(address)&sensor=false&key=\(apiKey)"
        let aUrl = URL.init(string: url)
        
        let task = URLSession.shared.dataTask(with: aUrl!) { (data, resp, error) in
            if error != nil {
                print(error ?? "error")
                completion(false, nil, nil)
            } else {
                if let usableData = data {
                    print(usableData) //JSONSerialization
                    if let json = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String:Any] {
                        Models.shared.create(data: json!)
                        completion(true, json, Models.shared.all)
                    }
                }
            }
            
        }
        task.resume()
        
    }
    
    func getIndexing(spreadSheetId:String , completion:@escaping NetworkCompletionType)  {
        let apiKey = "AIzaSyAKyRLKcXYyX4pvSiqev_LbVu1_asz-oQk"
        let url = "https://sheets.googleapis.com/v4/spreadsheets/\(spreadSheetId)?key=\(apiKey)"
        if let aUrl = URL.init(string: url) {
            let task = URLSession.shared.dataTask(with: aUrl) { (data, resp, error) in
                if error != nil {
                    print(error ?? "error")
                    completion(false, nil, nil)
                } else {
                    if let usableData = data {
                        print(usableData) //JSONSerialization
                        if let json = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String:Any] {
                            completion(true, json, nil)
                        }
                    }
                }
                
            }
            task.resume()
        }else {
            completion(false, nil , nil)
        }
        
    }
    
    func getSheetsData(spreadsheetId:String , completion:@escaping SheetCompletionType) {
        let apiKey = "AIzaSyAKyRLKcXYyX4pvSiqev_LbVu1_asz-oQk"
        let majorDim = "ROWS"
        var ranges = "A1:K1000"
        let renderOption = "FORMATTED_VALUE"
        
        if let numRows = Models.shared.currentSheet?.rows {
            ranges = "A1:Z\(numRows)"
        }
        
        let url = "https://sheets.googleapis.com/v4/spreadsheets/\(spreadsheetId)/values:batchGet?majorDimension=\(majorDim)&ranges=\(ranges)&valueRenderOption=\(renderOption)&key=\(apiKey)"
        
        if let aUrl = URL.init(string: url) {
            let task = URLSession.shared.dataTask(with: aUrl) { (data, resp, error) in
                if error != nil {
                    print(error ?? "error")
                    completion(false, nil, nil, nil)
                } else {
                    if let usableData = data {
                        print(usableData) //JSONSerialization
                        if let json = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String:Any] {
                            if (Models.shared.checkForIndex(data: json!)) {
                                Models.shared.createBrothers(data: json!)
                                completion(true, json, Models.shared.brothers, nil)
                            } else {
                                completion(false, json ,nil , RehbarError.IndexNotAvailable )
                            }
                        }
                    }
                }
            }
            task.resume()
        } else {
            completion(false, nil , nil, RehbarError.InvalidUrl)
        }
    }
    
}
