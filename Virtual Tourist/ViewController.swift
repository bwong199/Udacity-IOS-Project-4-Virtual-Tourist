//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Ben Wong on 2016-03-27.
//  Copyright © 2016 Ben Wong. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    var latitude : Double = 0
    var longitude : Double = 0
    
    @IBOutlet var map: MKMapView!
    
    var locationManager = CLLocationManager()
    
    var selectedPin: CLLocationCoordinate2D? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.map.delegate = self
        
//        locationManager.delegate = self
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        
//        locationManager.requestWhenInUseAuthorization()
//        
//        locationManager.startUpdatingLocation()
//        
//        let latitude:CLLocationDegrees = 51.03
//        
//        let longitude:CLLocationDegrees = -114.14
//        
//        let latDelta:CLLocationDegrees = 0.01
//        
//        let lonDelta:CLLocationDegrees = 0.01
//        
//        let span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
//        
//        let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
//        
//        let region:MKCoordinateRegion = MKCoordinateRegionMake(location, span)
//        
//        map.setRegion(region, animated: false)
        
        
        
        let uilpgr = UILongPressGestureRecognizer(target: self, action: "action:")
        
        // 2 seconds
        
        uilpgr.minimumPressDuration = 0.8
        
        map.addGestureRecognizer(uilpgr)
    }
    
    
    func action(gestureRecognizer: UIGestureRecognizer){
        
        
        let touchPoint = gestureRecognizer.locationInView(self.map)
        
        let newCoordinate: CLLocationCoordinate2D = map.convertPoint(touchPoint, toCoordinateFromView: self.map)
        
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = newCoordinate
        
        annotation.title = "\(newCoordinate.latitude)  \(newCoordinate.longitude)"
        
        annotation.subtitle = "\(newCoordinate.latitude)  \(newCoordinate.longitude)"
        
        annotation.coordinate = newCoordinate
        
        map.addAnnotation(annotation)
        
        //        self.performSegueWithIdentifier("toLocationDetail", sender: annotation)
        
        //
        //        print(touchPoint)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //        print(locations)
        
        let userLocation: CLLocation = locations[0]
        
        let latitude = userLocation.coordinate.latitude
        
        let longitude = userLocation.coordinate.longitude
        
        let latDelta:CLLocationDegrees = 0.01
        
        let lonDelta:CLLocationDegrees = 0.01
        
        let span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
        
        let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        
        let region:MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        
        self.map.setRegion(region, animated: false)
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        
        let pin = view.annotation
        performSegueWithIdentifier("toLocationDetail", sender: pin)
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        let coordinates = String((view.annotation!.coordinate))
        
//        print(coordinates)
        
        self.latitude = view.annotation!.coordinate.latitude
        self.longitude = view.annotation!.coordinate.longitude
        
        //                if let requestUrl = NSURL(string: link) {
        //                    UIApplication.sharedApplication().openURL(requestUrl)
        //                }
        
        NSOperationQueue.mainQueue().addOperationWithBlock {
            self.performSegueWithIdentifier("toLocationDetail", sender: self)
        }
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "toLocationDetail" )
        {
            let detailController = segue.destinationViewController as! DetailViewController
            
            detailController.latitude = self.latitude
            detailController.longitude = self.longitude
            
        }
        
    }
    
    
}

