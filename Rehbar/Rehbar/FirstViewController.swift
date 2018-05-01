//
//  FirstViewController.swift
//  Rehbar
//
//  Created by Nandu Ahmed on 4/27/18.
//  Copyright © 2018 anz. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {
    
    var places = [Brother]()
    
    @IBOutlet weak var tbView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var errorLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let s = "149uZmIOtYsV5iozJB-QvbjVjRGZeP0gag_ukLyF0qT8"
        
        NetworkManager.shared.getSheetsData(spreadsheetId: s) { (success, data, brothers) -> (Void) in
            DispatchQueue.main.async {
                self.tbView.reloadData()
            }
        }
           // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension FirstViewController : UITableViewDataSource , UITableViewDelegate {
    
//    func numberOfSections(in tableView: UITableView) -> Int {// Default is 1 if not implemented
//        return 2
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
            return Models.shared.brothers.count - 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let bro = Models.shared.brothers[indexPath.row + 1]
    
        let cell = tableView.dequeueReusableCell(withIdentifier: "identifier")
        cell?.textLabel?.text = Models.shared.brothers[indexPath.row + 1].firstName
        let add = bro.address! + "- Comments" + bro.comments!
        cell?.detailTextLabel?.text = add
        return cell!
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        self.performSegue(withIdentifier: "toMapSegue", sender: indexPath)
    }
    
}

/*extension FirstViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {// called when keyboard search button pressed
        
        NetworkManager.shared.getData(values:searchBar.text!) { (success, data, models) in
            self.places.removeAll()
            if (success && (models != nil) && (models?.count)! > 0 && Models.shared.status == .Ok) {
                self.places = models!
                self.showError(value: nil)
                DispatchQueue.main.async {
                    self.tbView.reloadData()
                }
                
            }
                
            else {
                // Display Error
                if (success == false) {
                    DispatchQueue.main.async(execute: {
                        self.showError(value: "Google API Error")
                    })
                }
                
                if (Models.shared.status == .ZeroResults) {
                    DispatchQueue.main.async(execute: {
                        self.showError(value: "Zero Results")
                    })
                    
                }
                
            }
            
        }
    }
    
    private func showError(value:String?) {
        if let value = value {
            self.tbView.alpha = 0.0
            self.errorLabel.isHidden = false
            self.errorLabel.text = value
        } else {
            self.tbView.alpha = 1.0
            self.errorLabel.isHidden = true
        }
    }
}*/


