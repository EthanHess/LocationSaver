//
//  ViewController.swift
//  MemorablePlacesRedone
//
//  Created by Ethan Hess on 12/1/15.
//  Copyright © 2015 Ethan Hess. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    var manager : CLLocationManager!

    @IBOutlet var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        
        if activePlace == -1 {
            
            manager.requestWhenInUseAuthorization()
            manager.startUpdatingLocation()
            
        }
        
        else {
            
            //get lat and long strings out of dictionary
            
            let latitude = NSString(string: places[activePlace]["lat"]!).doubleValue
            let longitude = NSString(string: places[activePlace]["lon"]!).doubleValue
            
            let coordinate = CLLocationCoordinate2DMake(latitude, longitude)
            let latDelta : CLLocationDegrees = 0.01
            let lonDelta : CLLocationDegrees = 0.01
            
            //make region with above coordinates
            
            let span : MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
            let region : MKCoordinateRegion = MKCoordinateRegionMake(coordinate, span)
            
            mapView.setRegion(region, animated: true)
            
            //set annotation
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = places[activePlace]["name"]
            mapView.addAnnotation(annotation)
            
        }
        
        //set up long press
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: "action:")
        longPressRecognizer.minimumPressDuration = 2.0
        mapView.addGestureRecognizer(longPressRecognizer)
        
    }
    
    func action(gestureRecognizer: UIGestureRecognizer) {
        
        if gestureRecognizer.state == UIGestureRecognizerState.Began {
            
            let touchPoint = gestureRecognizer.locationInView(mapView)
            let newCoord = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
            let location = CLLocation(latitude: newCoord.latitude, longitude: newCoord.longitude)
            
            CLGeocoder().reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
                
                //sets title to nil then gets placemark thorough/subthoroughfare
                
                var title = ""
                
                if (error == nil) {
                    
                    if let placemark = placemarks?[0] {
                        
                        var subthoroughfare : String = ""
                        var thoroughfare : String = ""
                        
                        if placemark.subThoroughfare != nil {
                            
                            subthoroughfare = placemark.subThoroughfare!
                        }
                        
                        if placemark.thoroughfare != nil {
                            
                            thoroughfare = placemark.thoroughfare!
                        }
                        
                        title = "\(subthoroughfare) \(thoroughfare)"
                        
                    }
                }
                
                //will add date of no title
                
                if title.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) == "" {
                    
                    title = "Added \(NSDate())"
                    
                }
                
                //adds info to places (array of dictionaries)
                
                places.append(["name":title,"lat":"\(newCoord.latitude)","lon":"\(newCoord.longitude)"])
                
                NSUserDefaults.standardUserDefaults().setObject(places, forKey: "places")
                NSUserDefaults.standardUserDefaults().synchronize()
                
                print(places)
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = newCoord
                annotation.title = title
                self.mapView.addAnnotation(annotation)
                
            })
        }
    }
    
    //gets user location
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let userLocation : CLLocation = locations[0]
        let latitude = userLocation.coordinate.latitude
        let longitude = userLocation.coordinate.longitude
        
        let coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        let latDelta : CLLocationDegrees = 0.01
        let longDelta : CLLocationDegrees = 0.01
        
        let span : MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)
        let region : MKCoordinateRegion = MKCoordinateRegionMake(coordinate, span)
        
        mapView.setRegion(region, animated: true)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

