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
        var annonations = [MKAnnotation]()
        if (displayMultiple) {
            let places = Models.shared.brothers
            for place in places {
                if let location = place.place.coordinates , let add = place.address , let name = place.firstName  {
                    let annonation = self.addBortherPin(title: name, subTitle: add, coordinates: location)
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
    
    private func addBortherPin(title:String ,subTitle:String, coordinates:CLLocationCoordinate2D) -> MKAnnotation {
        let pin = BrotherAnnonation(c: coordinates)
        pin.title = title
        pin.subtitle = subTitle
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

class BrotherAnnonation : NSObject, MKAnnotation {
    var title: String?
    let coordinate: CLLocationCoordinate2D
    var subtitle: String?
    init(c:CLLocationCoordinate2D) {
        self.coordinate = c
        super.init()
    }
}

extension SecondViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation{
            return nil;
        }else{
            let pinIdent = "Pin";
            var pinView: MKPinAnnotationView;
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: pinIdent) as? MKPinAnnotationView {
                dequeuedView.annotation = annotation;
                pinView = dequeuedView;
            }else{
                pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: pinIdent)
                pinView.canShowCallout = true
                pinView.calloutOffset = CGPoint(x: -5, y: 5)
                pinView.rightCalloutAccessoryView = UIButton(type: UIButtonType.detailDisclosure)
                
            }
            return pinView;
        }
    }
}

