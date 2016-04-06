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

class PhotoAlbumViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate  {
    
    
    var latitude : Double = 0
    var longitude : Double = 0
    
    @IBOutlet var mapView: MKMapView!
    
    @IBOutlet var collectionView: UICollectionView!
    
    
    let reuseIdentifier = "cell" // also enter this string as the cell identifier in the storyboard
    //        var items = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "40", "41", "42", "43", "44", "45", "46", "47", "48"]
    
    
    var items : [String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            //            print(results)
            
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    //                    print(result.valueForKey("photos") )
                    //
                    
                    
                    let photos =  result.valueForKey("photos")?.allObjects as! NSArray
                    
                    for photo in photos {
                        print(photo.valueForKey("imageURL")!)
                        
                        
                        
                        
                        NSOperationQueue.mainQueue().addOperationWithBlock({
                            self.items.append(photo.valueForKey("imageURL")! as! String)
                            self.do_collection_refresh()
                        })
                        
                    }
                    
                    
                    
                    
                }
            }
            
            
        } catch {
            print("Fetch Failed")
        }
        
        
        // Find the Pin to which the images should be downloaded and associated with
        
        
        //        print(roundLatitude)
        //        print(roundLongitude)
        
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
        
        let roundLatitude = round(latitude * 100 )/100
        let roundLongitude = round(longitude * 100 )/100
        
        
        
        //        // Fetch Flickr pictures baesd on geolocation
        //        let url = NSURL(string: "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=6cd8800d04b7e3edca0524f5b429042e&lat=\(roundLatitude)&lon=\(roundLongitude)&extras=url_s&format=json&nojsoncallback=1&per_page=20")! ;
        //
        //
        //        let task = NSURLSession.sharedSession().dataTaskWithURL(url){(data, response, error) -> Void in
        //            if let data = data {
        //                //                print(urlContent)
        //
        //                do {
        //                    let jsonResult =  try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
        //
        //                    if jsonResult.count > 0 {
        //                        if let items = jsonResult["photos"] as? NSDictionary {
        //
        //                            if let photoItems = items["photo"] as? NSArray {
        //
        //                                for item in photoItems {
        //
        //                                    if let imageURL = item["url_s"] as? String {
        //
        //
        //
        //                                        NSOperationQueue.mainQueue().addOperationWithBlock({
        //                                            self.items.append(imageURL)
        //
        //                                            self.do_collection_refresh()
        //                                        })
        //
        //
        //
        //
        //                                    }
        //                                }
        //                            }
        //                        }
        //                    }
        //
        //
        //
        //                } catch {
        //                    print("JSON Serialization failed")
        //                }
        //            }
        //        }
        //        task.resume()
    }
    
    func do_collection_refresh()
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
        
        // Use the outlet in our custom class to get a reference to the UILabel in the cell
        //                cell.myLabel.text = self.items[indexPath.item]
        
        
        if let url  = NSURL(string: self.items[indexPath.item] ),
            data = NSData(contentsOfURL: url)
        {
            cell.myImage.image = UIImage(data: data)
        }
        
        cell.backgroundColor = UIColor.yellowColor() // make cell more visible in our example project
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! MyCollectionViewCell
        
        // Use the outlet in our custom class to get a reference to the UILabel in the cell
        //                cell.myLabel.text = self.items[indexPath.item]
        
        
        if let url  = NSURL(string: self.items[indexPath.item] ),
            data = NSData(contentsOfURL: url)
        {
            cell.myImage.image = UIImage(data: data)
        }
        
        cell.backgroundColor = UIColor.yellowColor() // make cell more visible in our example project
        
        //        return cell
    }
    
    // MARK: - UICollectionViewDelegate protocol
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // handle tap events
        print("You selected cell #\(indexPath.item)!")
    }
    
    
}
