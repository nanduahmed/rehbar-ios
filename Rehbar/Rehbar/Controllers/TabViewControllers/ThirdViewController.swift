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
    
    @IBAction func onDone(_ sender: Any) {
        
        
    }
    
    
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //https://docs.google.com/spreadsheets/d/149uZmIOtYsV5iozJB-QvbjVjRGZeP0gag_ukLyF0qT8/edit?usp=sharing
//        let regex = "https://docs.google.com/spreadsheets/d/149uZmIOtYsV5iozJB-QvbjVjRGZeP0gag_ukLyF0qT8/edit?usp=sharing"
        if let spreadsheetId = textField.text {
        print(spreadsheetId)
        PersistenceStore.store(value: spreadsheetId, type: StoreValue.spreadsheetId)
        }
        textField.resignFirstResponder()
        return true
    }
    
}
