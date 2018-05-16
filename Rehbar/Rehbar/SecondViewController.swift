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

class SecondViewController: BaseViewController {
    
    var coordinates:CLLocationCoordinate2D?
    var displayMultiple = true
    var annotations = [MKAnnotation]()
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let bro = sender as? Brother ,
            let broDetailVC = segue.destination as? BrotherDetailViewController {
            broDetailVC.selectedBrother = bro
        }
    }
    
    @IBAction func onRefresh(_ sender: UIBarButtonItem) {
        self.downloadCoordinates()
    }
    
    @IBAction func onClearPins(_ sender: UIBarButtonItem) {
        self.removeAnnotationsFromMap()
    }
    
    func removeAnnotationsFromMap() {
        self.mapView.removeAnnotations(self.annotations)
        self.annotations.removeAll()
    }
    
    private func showPins() {
        self.removeAnnotationsFromMap()
        if (displayMultiple) {
            var places = Models.shared.brothers
            if let searchText = Models.shared.searchText, (searchText.count > 0) {
                places = places.filter({ (brother) -> Bool in
                    if let firstN = brother.firstName,
                        let lName = brother.lastName ,
                        let add = brother.address {
                        return firstN.contains(searchText) || lName.contains(searchText) || add.contains(searchText)
                    }
                    return false
                })
            }
            
            for place in places {
                if let location = place.place.coordinates , let add = place.address , let name = place.firstName  {
                    let annonation = self.addBortherPin(title: name, subTitle: add, coordinates: location)
                    self.annotations.append(annonation)
                }
            }
            
        } else {
            if let location = self.coordinates {
                let annonation = self.addPin(coordinates: location)
                self.annotations.append(annonation)            }
        }
        
        self.mapView.showAnnotations(self.annotations, animated: true)
        self.activityIndicator.stopAnimating()
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
        self.activityIndicator.startAnimating()
        var brothers = Models.shared.brothers
        if brothers.count > 0 {
            brothers.removeFirst()
        }
        if let searchText = Models.shared.searchText, (searchText.count > 0) {
            brothers = brothers.filter({ (brother) -> Bool in
                if let firstN = brother.firstName,
                    let lName = brother.lastName ,
                    let add = brother.address {
                    return firstN.contains(searchText) || lName.contains(searchText) || add.contains(searchText)
                }
                
                return false
            })
        }
        for bro in brothers {
            let add = bro.address! + "," + bro.city!
            if (bro.place.coordinates == nil) {
                NetworkManager.shared.getData(values: add, completion: { (success, data, places) -> (Void) in
                    bro.place.coordinates = places?.first?.coordinates
                })
            }
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
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if (control as? UIButton)?.buttonType == UIButtonType.detailDisclosure {
            mapView.deselectAnnotation(view.annotation, animated: false)
            if let broAnnotation = view.annotation as? BrotherAnnonation {
                let selectedBro = Models.shared.brothers.filter { (brother) -> Bool in
                    return ((brother.firstName == broAnnotation.title) && (brother.address == broAnnotation.subtitle))
                }
                if selectedBro.count > 0 {
                    performSegue(withIdentifier: "broDetailSegue", sender: selectedBro.first)
                } else {
                    self.showError(title: "Error", message: "Cannot Open Details Right now")
                }
            }
        }
    }
}

