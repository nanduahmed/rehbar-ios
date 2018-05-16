//
//  BaseViewController.swift
//  Rehbar
//
//  Created by Nandu Ahmed on 5/6/18.
//  Copyright © 2018 anz. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    func showError(title:String , message:String)  {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: UIAlertControllerStyle.alert)
        
        let action = UIAlertAction(title: "Ok",
                                   style: UIAlertActionStyle.default,
                                   handler: { (action) in
            
        })
        
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }

}
