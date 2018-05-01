//
//  SecondViewController.swift
//  Rehbar
//
//  Created by Nandu Ahmed on 4/27/18.
//  Copyright © 2018 anz. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class SecondViewController: UIViewController {
    
    var coordinates:CLLocationCoordinate2D?
    var displayMultiple = true
    
    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.downloadCoordinates()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func showPins() {
        var annonations = [MKPointAnnotation]()
        if (displayMultiple) {
            let places = Models.shared.brothers
            for place in places {
                if let location = place.place.coordinates {
                    let annonation = self.addPin(coordinates: location)
                    annonations.append(annonation)
                }
            }
            
        } else {
            if let location = self.coordinates {
                let annonation = self.addPin(coordinates: location)
                annonations.append(annonation)            }
        }
        
        self.mapView.showAnnotations(annonations, animated: true)
    }

    private func addPin(coordinates:CLLocationCoordinate2D) -> MKPointAnnotation {
        let pin = MKPointAnnotation()
        pin.coordinate = coordinates
        return pin
    }
    
    func downloadCoordinates()  {
        for bro in Models.shared.brothers {
            let add = bro.address! + ",Santa Clara"
            NetworkManager.shared.getData(values: add, completion: { (success, data, places) -> (Void) in
                bro.place.coordinates = places?.first?.coordinates
            })
        }
        
        let oneMin = DispatchTime.now() + 2.0
        
        DispatchQueue.main.asyncAfter(deadline: oneMin) {
            self.showPins()
        }
    }

}

