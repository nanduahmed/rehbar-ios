//
//  FirstViewController.swift
//  Rehbar
//
//  Created by Nandu Ahmed on 4/27/18.
//  Copyright © 2018 anz. All rights reserved.
//

import UIKit

class FirstViewController: BaseViewController {
    
    var filteredBrothers = [Brother]()
    
    @IBOutlet weak var tbView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var gettingSheetsData = false
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(FirstViewController.handleRefresh(_:)),
                                 for: UIControlEvents.valueChanged)
        refreshControl.tintColor = UIColor.green
        return refreshControl
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tbView.addSubview(self.refreshControl)
        self.checkRows()
          // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        /*if let searchText = Models.shared.searchText,
            (searchText.count > 0) {
        } else {
            self.checkRows()
        }*/
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let bro = sender as? Brother ,
            let broDetailVC = segue.destination as? BrotherDetailViewController {
            broDetailVC.selectedBrother = bro
        }
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.checkRows()
    }
    
    private func checkRows() {
        if let sheet = Models.shared.currentSheet,
            (Models.shared.currentSheet?.success == true),
            (sheet.rows > 0) {
            self.activityIndicator.startAnimating()
            getData()
        } else {
            if let spreadheetId = PersistenceStore.retreiveValue(type: StoreValue.spreadsheetId) {
                self.activityIndicator.startAnimating()
                NetworkManager.shared.getIndexing(spreadSheetId: spreadheetId) {[weak self] (success, data, _) -> (Void) in
                    if (success == true && data != nil) {
                        let spsheet = SpreadSheet(data: data!)
                        Models.shared.currentSheet = spsheet
                        if (spsheet.success == true) {
                            self?.getData()
                        } else {
                            DispatchQueue.main.async {
                                self?.activityIndicator.stopAnimating()
                                self?.showError(title: "Spreadsheet Error", message: RehbarError.InvalidSpreadSheet.message(id: spsheet.spreadSheetName))
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            self?.activityIndicator.stopAnimating()
                            self?.showError(title: "Error", message: RehbarError.InvalidSpreadSheet.message(id: "\(spreadheetId)"))
                        }
                    }
                }
            } else {
                self.showError(title: "Error", message: RehbarError.SpreadSheetIdNotConfigured.message(id: nil))
            }
        }
    }
    
    private func getData() {
        if self.gettingSheetsData == true {
            return
        }
        self.gettingSheetsData = true
        if let spreadheetId = PersistenceStore.retreiveValue(type: StoreValue.spreadsheetId),
            spreadheetId.count > 5 {
            filteredBrothers.removeAll()
            NetworkManager.shared.getSheetsData(spreadsheetId: spreadheetId) { [weak self] (success, data, brothers, error) -> (Void) in
                self?.gettingSheetsData = false
                if (success == true && brothers != nil) {
                    DispatchQueue.main.async {
                        self?.activityIndicator.stopAnimating()
                        self?.refreshControl.endRefreshing()
                        if let downloadedBrothers = brothers ,
                            let weakSelf = self {
                            weakSelf.filteredBrothers.append(contentsOf: downloadedBrothers)
                            if weakSelf.filteredBrothers.count > 0 {
                                weakSelf.filteredBrothers.removeFirst(1)
                            }
                            weakSelf.tbView.reloadData()
                        }
                    }
                } else {
                    DispatchQueue.main.async(execute: {
                        self?.activityIndicator.stopAnimating()
                        self?.refreshControl.endRefreshing()
                        if let rehbarError = error as? RehbarError,
                            (rehbarError == RehbarError.IndexNotAvailable),
                            let missingIdxMsg = Models.shared.brotherIndex?.indexMissingInfo() {
                            self?.showError(title: "Your Excel sheet not valid", message: missingIdxMsg)
                        } else {
                            self?.showError(title: "Error", message: "Error Downloading Data. Please verify your link or excel sheet data")
                        }
                    })
                }
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0, execute: { 
                self.showError(title:"Configure Error", message:"Please go to settings panel and set your spreadheet link")
            })
        }
    }

}

extension FirstViewController : UITableViewDataSource , UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredBrothers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "brotherCellId") as? BrotherListTableViewCell
        if (filteredBrothers.count > 0) {
            let bro = filteredBrothers[indexPath.row]
            if let fName = bro.firstName ,
                let lName = bro.lastName ,
                let address = bro.address ,
                let city = bro.city {
                cell?.nameLabel.text = fName + " " +  lName
                cell?.dateLabel.text = bro.lastVisited
                cell?.addressLabel.text = address + ", " + city
                cell?.commentLabel.text = bro.comments?.last
            }
        }
        
        return cell!
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (filteredBrothers.count > 0) {
            self.performSegue(withIdentifier: "broDetailSegue", sender: filteredBrothers[indexPath.row])
        } 
    }
    
}

extension FirstViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {// called when keyboard search button pressed
        filteredBrothers =  Models.shared.brothers.filter { (brother) -> Bool in
            if let firstN = brother.firstName,
                let lName = brother.lastName ,
                let add = brother.address ,
                let text = searchBar.text {
                return firstN.contains(text) || lName.contains(text) || add.contains(text)
            }
            
            return false
        }
        
        Models.shared.searchText = searchBar.text
        self.tbView.reloadData()
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) { // called when text changes (including clear)
        if (searchText == "") {
            filteredBrothers = Models.shared.brothers
        } else {
            filteredBrothers =  Models.shared.brothers.filter { (brother) -> Bool in
                if let firstN = brother.firstName,
                    let lName = brother.lastName ,
                    let add = brother.address {
                    return firstN.contains(searchText) || lName.contains(searchText) || add.contains(searchText)
                }
                
                return false
            }
        }
        Models.shared.searchText = searchText
        self.tbView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        Models.shared.searchText = nil
        filteredBrothers = Models.shared.brothers
        self.tbView.reloadData()
        searchBar.resignFirstResponder()
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
}


