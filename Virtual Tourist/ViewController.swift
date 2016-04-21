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
import CoreData

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    var latitude : Double = 0
    var longitude : Double = 0
    
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet var map: MKMapView!
    
    var locationManager = CLLocationManager()
    
    var selectedPin: CLLocationCoordinate2D? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.map.delegate = self
        
        
        let uilpgr = UILongPressGestureRecognizer(target: self, action: "action:")
        
        // 2 seconds
        
        uilpgr.minimumPressDuration = 0.8
        
        map.addGestureRecognizer(uilpgr)
        
        
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        self.activityIndicator.hidden = true
        
        let allAnnotations = self.map.annotations
        self.map.removeAnnotations(allAnnotations)
        
        let request = NSFetchRequest(entityName: "Pin")
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let context: NSManagedObjectContext = appDel.managedObjectContext
        do {
            let results = try context.executeFetchRequest(request)
            
            if results.count > 0 {
                for result in results as! [NSManagedObject]{
                    //                    print(result.valueForKey("latitude")!)
                    //                    print(result.valueForKey("longitude")!)
                    
                    let latitudeAnn:CLLocationDegrees = Double(result.valueForKey("latitude")! as! NSNumber)
                    let longitudeAnn:CLLocationDegrees = Double(result.valueForKey("longitude")! as! NSNumber)
                    
                    let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitudeAnn, longitudeAnn)
                    
                    let annotation = MKPointAnnotation()
                    
                    annotation.coordinate = location
                    
                    self.map.addAnnotation(annotation)
                }
            }
            //
            //            print(results)
            
        } catch {
            print("There was a problem!")
        }
        
        // We need just to get the documents folder url
        let documentsUrl =  NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        
//                 now lets get the directory contents (including folders)
                do {
                    let directoryContents = try NSFileManager.defaultManager().contentsOfDirectoryAtURL(documentsUrl, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions())
                    print(directoryContents)
        
                    for x in directoryContents {
                        print(x)
                    }
        
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
    }
    
    
    func action(gestureRecognizer: UIGestureRecognizer){
        activityIndicator.hidden = false
        activityIndicator.color = UIColor.blackColor()
        activityIndicator.startAnimating()
        
        if (gestureRecognizer.state == UIGestureRecognizerState.Began){
            let touchPoint = gestureRecognizer.locationInView(self.map)
            
            let newCoordinate: CLLocationCoordinate2D = map.convertPoint(touchPoint, toCoordinateFromView: self.map)
            
            let annotation = MKPointAnnotation()
            
            annotation.coordinate = newCoordinate
            
            annotation.title = "\(newCoordinate.latitude)  \(newCoordinate.longitude)"
            
            annotation.subtitle = "\(newCoordinate.latitude)  \(newCoordinate.longitude)"
            
            annotation.coordinate = newCoordinate
            
            let roundLatitude = round(newCoordinate.latitude * 100 )/100
            let roundLongitude = round(newCoordinate.longitude * 100 )/100
            
            let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            
            let context: NSManagedObjectContext = appDel.managedObjectContext
            
            let newLocation = NSEntityDescription.insertNewObjectForEntityForName("Pin", inManagedObjectContext: context)
            
            newLocation.setValue(roundLatitude, forKey: "latitude")
            
            newLocation.setValue(roundLongitude, forKey: "longitude")
            
            do {
                try context.save()
            } catch {
                print("There was a problem")
            }
            
            // start downloading images when pin is annotated
            
            
            
            
            dispatch_async(dispatch_get_main_queue(), {
                self.activityIndicator.startAnimating()
            })
            
            FetchImages().fetchImages(roundLatitude, longitude: roundLongitude)
            {(success, error, results) in
                if success {
                    
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.activityIndicator.stopAnimating()
                        self.activityIndicator.hidden = true
                    })
                    
                } else {
                    
                }
            }
            
            
            map.addAnnotation(annotation)
        }
        
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
    
    //    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
    //
    //        let pin = view.annotation
    //        performSegueWithIdentifier("toLocationDetail", sender: pin)
    //    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        //        let coordinates = String((view.annotation!.coordinate))
        //
        //        print(coordinates)
        let roundLatitude = round(view.annotation!.coordinate.latitude * 100 )/100
        let roundLongitude = round(view.annotation!.coordinate.longitude * 100 )/100
        
        self.latitude = roundLatitude
        self.longitude = roundLongitude
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
            let detailController = segue.destinationViewController as! PhotoAlbumViewController
            
            detailController.latitude = self.latitude
            //            print(String(detailController.latitude) + "from main view" + String(Mirror(reflecting: detailController.latitude)) )
            detailController.longitude = self.longitude
            //            print(String(detailController.longitude) + "from main view" + String(Mirror(reflecting: detailController.longitude)) )
        }
        
    }
    
    
}

