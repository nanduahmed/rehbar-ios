//
//  ThirdViewController.swift
//  Rehbar
//
//  Created by Nandu Ahmed on 5/1/18.
//  Copyright © 2018 anz. All rights reserved.
//

import UIKit

class ThirdViewController: UIViewController , UITextViewDelegate {

    @IBOutlet weak var sheetLinkTextFiled: UITextField!
    @IBOutlet weak var statusTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @objc func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //https://docs.google.com/spreadsheets/d/149uZmIOtYsV5iozJB-QvbjVjRGZeP0gag_ukLyF0qT8/edit?usp=sharing
//        let regex = "https://docs.google.com/spreadsheets/d/149uZmIOtYsV5iozJB-QvbjVjRGZeP0gag_ukLyF0qT8/edit?usp=sharing"
        if let spreadsheetId = textField.text {
            print(spreadsheetId)
            self.getSheetData(spID: spreadsheetId)
            PersistenceStore.store(value: spreadsheetId, type: StoreValue.spreadsheetId)
        }
        textField.resignFirstResponder()
        return true
    }
    
    func getSheetData(spID:String)  {
        NetworkManager.shared.getIndexing(spreadSheetId: spID) { (success, data, any) -> (Void) in
            if (success == true && data != nil) {
                let spsheet = SpreadSheet(data: data!)
                Models.shared.currentSheet = spsheet
                DispatchQueue.main.async {
                    var sheetInfo = "Spreadsheet Name\n"

                    if let name =  spsheet.spreadSheetName {
                        sheetInfo.append("\(name) \n")
                    }
                    sheetInfo.append("Num Rows - \(spsheet.rows)\n")
                    sheetInfo.append("Num Columns - \(spsheet.columns)")
                    
                    self.statusTextView.text = sheetInfo
                    
                }
            }
        }
    }
    
}
