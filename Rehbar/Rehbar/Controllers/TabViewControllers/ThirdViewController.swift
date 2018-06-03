//
//  ThirdViewController.swift
//  Rehbar
//
//  Created by Nandu Ahmed on 5/1/18.
//  Copyright © 2018 anz. All rights reserved.
//

import UIKit

class ThirdViewController: BaseViewController , UITextViewDelegate {

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
        if let link = textField.text,
            let spreadsheetId = self.getSpreadSheetId(from: link) {
            print(spreadsheetId)
            self.getSheetData(spID: spreadsheetId)
            PersistenceStore.store(value: spreadsheetId, type: StoreValue.spreadsheetId)
        } else {
            self.showError(title: "Error", message: "Your Spreadsheet link is not valid")
        }
        textField.resignFirstResponder()
        return true
    }
    
    func getSpreadSheetId(from link:String) -> String? {
        let array = link.split(separator: "/")
        if (array.count > 5) {
            return String(array[4])
        }
        return nil
    }
    
    func getSheetData(spID:String)  {
        NetworkManager.shared.getIndexing(spreadSheetId: spID) { (success, data, any) -> (Void) in
            if (success == true && data != nil) {
                let spsheet = SpreadSheet(data: data!)
                Models.shared.currentSheet = spsheet
                NotificationCenter.default.post(name: NSNotification.Name(StoreValue.spreadsheetId.rawValue), object: StoreValue.spreadsheetId)
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
