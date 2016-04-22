//
//  DetailViewController.swift
//  Virtual Tourist
//
//  Created by Ben Wong on 2016-03-27.
//  Copyright © 2016 Ben Wong. All rights reserved.
//


import UIKit
import MapKit
import CoreLocation
import CoreData

class PhotoAlbumViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIGestureRecognizerDelegate  {
    
    
    var latitude : Double = 0
    var longitude : Double = 0
    //    var selectedCell: [Int] =  []
    
    var selectedCell: Int = 0
    var selectedItem: String = ""
    
    @IBOutlet var toolbarButton: UIBarButtonItem!
    
    @IBOutlet var mapView: MKMapView!
    
    @IBOutlet var collectionView: UICollectionView!
    
    
    let reuseIdentifier = "cell" // also enter this string as the cell identifier in the storyboard
    //        var items = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "40", "41", "42", "43", "44", "45", "46", "47", "48"]
    
    
    var items : [String] = []
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        FetchImages().fetchNewCollection(latitude, longitude: longitude)
        
        toolbarButton.title = "New Collection"
        
        let latitudeAnn:CLLocationDegrees = self.latitude
        let longitudeAnn:CLLocationDegrees = self.longitude
        
        
        // Set map Location
        let latDelta:CLLocationDegrees = 0.01
        let lonDelta:CLLocationDegrees = 0.01
        
        let span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
        
        let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitudeAnn, longitudeAnn)
        
        let region:MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = location
        
        self.mapView.addAnnotation(annotation)
        
        mapView.setRegion(region, animated: true)
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            
            self.refresh_data()
        })
        
        let roundLatitude = round(latitude * 100 )/100
        let roundLongitude = round(longitude * 100 )/100
        
        
        // handle long press, long press to delete
        let lpgr = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        lpgr.minimumPressDuration = 1
        lpgr.delaysTouchesBegan = true
        lpgr.delegate = self
        self.collectionView.addGestureRecognizer(lpgr)
    }
    
    // long press to delete
    func handleLongPress(gestureReconizer: UILongPressGestureRecognizer) {
        if gestureReconizer.state != UIGestureRecognizerState.Began {
            return
        }
        let p = gestureReconizer.locationInView(self.collectionView)
        let indexPath = self.collectionView.indexPathForItemAtPoint(p)
        
        if let index = indexPath {
            var cell = self.collectionView.cellForItemAtIndexPath(index)
            // do stuff with your cell, for example print the indexPath
//            print(index.row)
            
            items.removeAtIndex(index.row)
            
            //remove from directory
            var documentsDirectory: String?
            
            var paths:[AnyObject] = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
            
            if paths.count > 0 {
                
                documentsDirectory = paths[0] as? String
                
                let removePath = documentsDirectory! + items[index.row]
                
                do {
                    try NSFileManager.defaultManager().removeItemAtPath(removePath)
                } catch {
                    
                }
                
            }
            // Find the Pin to which the images should be downloaded and delete that image
            let request = NSFetchRequest(entityName: "Pin")
            
            let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            
            let context: NSManagedObjectContext = appDel.managedObjectContext
            
            let firstPredicate = NSPredicate(format: "latitude == \(latitude)")
            
            let secondPredicate = NSPredicate(format: "longitude == \(longitude)")
            
            request.returnsObjectsAsFaults = false
            
            request.predicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [firstPredicate, secondPredicate])
            
            do {
                
                let results = try context.executeFetchRequest(request)
                
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        let photos =  result.valueForKey("photos")?.allObjects as! NSArray
                        
                        context.deleteObject(photos[index.row] as! NSManagedObject)
                        do_collection_refresh()
                    }
                }
            } catch {
                
            }
            do {
                try context.save()
            } catch {
                print("There was a problem saving")
            }
        } else {
            print("Could not find index path")
        }
    }
    
    public func  refresh_data(){
        let qualityOfServiceClass = QOS_CLASS_BACKGROUND
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        dispatch_async(backgroundQueue, {
//            print("This is run on the background queue")
            
            let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            
            let context: NSManagedObjectContext = appDel.managedObjectContext
            
            let request = NSFetchRequest(entityName: "Pin")
            
            request.returnsObjectsAsFaults = false
            
            let firstPredicate = NSPredicate(format: "latitude == \(self.latitude)")
            
            let secondPredicate = NSPredicate(format: "longitude == \(self.longitude)")
            
            request.predicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [firstPredicate, secondPredicate])
            
            //        request.predicate = NSPredicate(format: "latitude == %f", latitude)
            
            do {
                
                let results = try context.executeFetchRequest(request)
                
                
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        //                        print(result)
                        //                        print(result.valueForKey("photos")! )
                        // check to see if there's any photos under **this** pin, if not do a fetch image
                        print("Number of pages \(result.valueForKey("pages"))" )
                        if let photos =  (result.valueForKey("photos")?.allObjects)! as? NSArray {
                            //                            // not worrking
                            //                            print(photos)
                            if photos.count > 0 {
                                for photo in photos {
                                    //
                                    var documentsDirectory: String?
                                    
                                    var paths:[AnyObject] = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
                                    
                                    documentsDirectory = paths[0] as? String
                                    
                                    dispatch_async(dispatch_get_main_queue(), {
                                        if let imagePath = photo.valueForKey("imageURL") as? String {
                                            let savePath = documentsDirectory! + imagePath
                                            
                                            if !self.items.contains(savePath){
                                                
                                                self.items.append(savePath)
                                                self.do_collection_refresh()
                                            }
                                            
                                        }
                                        return
                                    })
                                }
                            } else {
                                
                            }
                        }
                    }
                }
                
            } catch {
                print("Fetch Failed")
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                for x in self.items {
//                    print(self.items.indexOf(x))
                }
                
                
            })
        })
    }
    
    public func do_collection_refresh()
    {
        dispatch_async(dispatch_get_main_queue(), {
            self.collectionView.reloadData()
            return
        })
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }
    
    //     make a cell for each cell index path
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! MyCollectionViewCell
        
        
      
        
        cell.activityIndicator.color = UIColor.whiteColor()
        cell.activityIndicator.startAnimating()
        cell.activityIndicator.hidden = false
        
        
        if cell.myImage.image != nil {
            cell.activityIndicator.stopAnimating()
            cell.activityIndicator.hidden = true
            

        }
        
        

        
        cell.layer.shouldRasterize = true
        cell.layer.rasterizationScale = UIScreen.mainScreen().scale
        
        let imagePath  = self.items[indexPath.item]
        
        cell.myImage.image = UIImage(named: imagePath)
        cell.layer.shouldRasterize = true
        cell.layer.rasterizationScale = UIScreen.mainScreen().scale
        
        
        cell.backgroundColor = UIColor.whiteColor()
        
        cell.activityIndicator.stopAnimating()
        cell.activityIndicator.hidden = true
        
        
        
        return cell
    }
    
    
    // MARK: - UICollectionViewDelegate protocol
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // handle tap events
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! MyCollectionViewCell
        cell.layer.shouldRasterize = true
        cell.layer.rasterizationScale = UIScreen.mainScreen().scale
        
        
        self.selectedItem = items[indexPath.row]
        self.performSegueWithIdentifier("detailViewSegue", sender: self)
        
        self.collectionView.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "detailViewSegue"{
            let detailVC = segue.destinationViewController as!  DetailImageController
            
            detailVC.imageURL = self.selectedItem
        }
        
    }
    
    @IBAction func toolbarButtonAction(sender: AnyObject) {
        
        // on New Collection button pressed, delete the results in "photos" and do a new fetch
        if toolbarButton.title ==  "New Collection" {
                        dispatch_async(dispatch_get_main_queue(), {
                
                self.items.removeAll()
                self.do_collection_refresh()
                
            })
            
            let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            
            let context: NSManagedObjectContext = appDel.managedObjectContext
            
            let request = NSFetchRequest(entityName: "Pin")
            //        request.predicate = NSPredicate(format: "latitude = %@", latitude)
            
            request.returnsObjectsAsFaults = false
            
            let firstPredicate = NSPredicate(format: "latitude == \(latitude)")
            
            let secondPredicate = NSPredicate(format: "longitude == \(longitude)")
            
            //
            request.predicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [firstPredicate, secondPredicate])
            do {
                let results = try context.executeFetchRequest(request)
                //                print(results)
                if results.count > 0 {
                 
                    for result in results as! [NSManagedObject] {
                        
                        for result in results as! [NSManagedObject] {
                            //                            print(result.valueForKey("photos")! )
                            //                             check to see if there's any photos under **this** pin, if not do a fetch image
                            let photosArray = result.valueForKey("photos")?.allObjects as! NSArray
                            
                            for x in photosArray {
                                //                                print(Mirror(reflecting: x))
//                                print(x.valueForKey("imageURL"))
                                
                                // delete from Core Data
                                context.deleteObject(x as! NSManagedObject)
                                
                                //remove from directory
                                var documentsDirectory: String?
                                
                                var paths:[AnyObject] = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
                                
                                if paths.count > 0 {
                                    
                                    documentsDirectory = paths[0] as? String
                                    
                                    let removePath = documentsDirectory! + String(x.valueForKey("imageURL")!)
                                    
//                                    print(removePath)
                                    
                                    do {
                                        try NSFileManager.defaultManager().removeItemAtPath(removePath)
                                    } catch {
                                        
                                    }
                                    
                                }
                            }
                            
                            
                        }
                        
                    }
                    
                    do {
                        try context.save()
                    } catch {
                        print("There was a problem saving")
                    }
                    
                }
                
            } catch {
                
            }
            
            FetchImages().fetchNewCollection(latitude, longitude: longitude)
            {(success, error, results) in
                if success {
                    self.refresh_data()
                    self.do_collection_refresh()
              

                } else {
                    
                }
            }
            
        }
        
    }
    
    
    
    
    
}
