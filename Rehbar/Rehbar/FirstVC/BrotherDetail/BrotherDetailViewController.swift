//
//  BrotherDetailViewController.swift
//  Rehbar
//
//  Created by Nandu Ahmed on 5/6/18.
//  Copyright © 2018 anz. All rights reserved.
//

import UIKit

class BrotherDetailViewController: UIViewController {
    
    var selectedBrother: Brother?

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressTextField: UITextView!
    @IBOutlet weak var deteLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let bro = self.selectedBrother ,
            let fName = bro.firstName ,
            let lName = bro.lastName {
            self.nameLabel.text = fName + " " + lName
            self.addressTextField.text = bro.address
            self.deteLabel.text = bro.lastVisited
        }

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

}

extension BrotherDetailViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let bro = self.selectedBrother , let count = bro.comments?.count {
            return count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentsCellIdentifier") as? BrotherCommentsTableViewCell
        cell?.textView.text = selectedBrother?.comments![indexPath.row]
        return cell!
    }
    

}
