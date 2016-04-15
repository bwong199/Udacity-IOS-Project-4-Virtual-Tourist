//
//  FetchImages.swift
//  Virtual Tourist
//
//  Created by Ben Wong on 2016-04-05.
//  Copyright © 2016 Ben Wong. All rights reserved.
//

import UIKit
import CoreData
import MapKit
import CoreLocation

class FetchImages: UIViewController, MKMapViewDelegate {
    
    
    func fetchImages (latitude: Double, longitude: Double){
        print("Fetching Images")
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let context: NSManagedObjectContext = appDel.managedObjectContext
        
        let roundLatitude = round(latitude * 100 )/100
        let roundLongitude = round(longitude * 100 )/100
        
        
        // Ideally, I would save the number of pages for the search results  for the given latitude/longitude in core data so I can do a random on page 1 to the max number of pages instead of a fixed number of 10
        // generate a random number per page
        let myRandom = arc4random_uniform(10) + 1
        
        // Fetch Flickr pictures baesd on geolocation
        let url = NSURL(string: "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=6cd8800d04b7e3edca0524f5b429042e&lat=\(roundLatitude)&lon=\(roundLongitude)&extras=url_s&format=json&nojsoncallback=1&per_page=10")! ;
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(url){(data, response, error) -> Void in
            if let data = data {
                //                print(urlContent)
                
                do {
                    let jsonResult =  try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                    
                    if jsonResult.count > 0 {
                        
                        if let items = jsonResult["photos"] as? NSDictionary {
                            
                            print(items["pages"])
                            
                            if let photoItems = items["photo"] as? NSArray {
                                
                                for item in photoItems {
                                    
                                    if let imageURL = item["url_s"] as? String, let imageID = item["id"] as? String {
                                        
                                        let url = NSURL(string: imageURL)
                                        
                                        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) { (imageData, response, error) -> Void in
                                            if error != nil {
                                                print(error)
                                            } else {
                                                
                                                var documentsDirectory: String?
                                                
                                                var paths:[AnyObject] = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
                                                
                                                if paths.count > 0 {
                                                    
                                                    documentsDirectory = paths[0] as? String
                                                    
                                                    //                                                    print(documentsDirectory)
                                                    
                                                    let savePath = documentsDirectory! + "/\(imageID).jpg"
                                                    //                                                    print(savePath)
                                                    //save the images to the savePath/Document Directory
                                                    NSFileManager.defaultManager().createFileAtPath(savePath, contents: imageData, attributes: nil)
                                                    
                                                    
                                                    // Find the Pin to which the images should be downloaded and associated with
                                                    let request = NSFetchRequest(entityName: "Pin")
                                                    //        request.predicate = NSPredicate(format: "latitude = %@", latitude)
                                                    
                                                    
                                                    let firstPredicate = NSPredicate(format: "latitude == \(latitude)")
                                                    
                                                    let secondPredicate = NSPredicate(format: "longitude == \(longitude)")
                                                    
                                                    request.returnsObjectsAsFaults = false
                                                    
                                                    request.predicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [firstPredicate, secondPredicate])
                                                    
                                                    do {
                                                        
                                                        let results = try context.executeFetchRequest(request)
                                                        
                                                        if results.count > 0 {
                                                            for result in results as! [NSManagedObject] {
//                                                                print(result)
                                                                let newPhoto = NSEntityDescription.insertNewObjectForEntityForName("Photo", inManagedObjectContext: context)
                                                                // save image id to imageURL Photo Entity
                                                                print("/\(imageID).jpg")
                                                                newPhoto.setValue("/\(imageID).jpg", forKey: "imageURL")
                                                                
                                                                let photos = result.mutableSetValueForKey("photos")
                                                                photos.addObject(newPhoto)
                                                             }
                                                        }
                                                    } catch {
                                                    }
                                                    do {
                                                       
                                                        try context.save()
                                                        print("Saved Successfully")
                                                    } catch {
                                                        print("There was a problem saving")
                                                    }
                                                    
                                                }
                                            }
                                        }
                                        task.resume()
                                    }
                                }
                            }
                        }
                    }
  
                    print("Done fetching data")
    
                } catch {
                    print("JSON Serialization failed")
                }
            }
        }
        task.resume()
        
        //        let viewController = UIApplication.sharedApplication().windows[0].rootViewController?.childViewControllers[1] as? PhotoAlbumViewController
        //
        //        viewController?.refresh_data()
        //        viewController?.do_collection_refresh()
        
    }
    
    
    func fetchNewCollection (latitude: Double, longitude: Double){
        
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let context: NSManagedObjectContext = appDel.managedObjectContext
        
        let roundLatitude = round(latitude * 100 )/100
        let roundLongitude = round(longitude * 100 )/100
        
        // generate a random number per page
        let myRandom = arc4random_uniform(10) + 1
        
        // Fetch Flickr pictures baesd on geolocation
        let url = NSURL(string: "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=6cd8800d04b7e3edca0524f5b429042e&lat=\(roundLatitude)&lon=\(roundLongitude)&extras=url_s&format=json&nojsoncallback=1&per_page=10&page=\(myRandom)")! ;
        
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(url){(data, response, error) -> Void in
            if let data = data {
                //                print(urlContent)
                
                do {
                    let jsonResult =  try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                    
                    if jsonResult.count > 0 {
                        
                        if let items = jsonResult["photos"] as? NSDictionary {
                            
                            print(items["pages"])
                            
                            if let photoItems = items["photo"] as? NSArray {
                                
                                for item in photoItems {
                                    
                                    if let imageURL = item["url_s"] as? String {
                                        //
                                        //                                        print(imageURL)
                                        
                                        let viewController = UIApplication.sharedApplication().windows[0].rootViewController?.childViewControllers[1] as? PhotoAlbumViewController
                                        
                                        // add individual picture to the items array in CollectionView and do a refresh
                                        viewController?.items.append(imageURL)
                                        viewController?.do_collection_refresh()
                                        
                                        NSOperationQueue.mainQueue().addOperationWithBlock({
                                            //                                            self.items.append(imageURL)
                                            
                                            // Find the Pin to which the images should be downloaded and associated with
                                            let request = NSFetchRequest(entityName: "Pin")
                                            //        request.predicate = NSPredicate(format: "latitude = %@", latitude)
                                            
                                            
                                            let firstPredicate = NSPredicate(format: "latitude == \(latitude)")
                                            
                                            let secondPredicate = NSPredicate(format: "longitude == \(longitude)")
                                            
                                            
                                            //
                                            request.predicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [firstPredicate, secondPredicate])
                                            
                                            do {
                                                
                                                let results = try context.executeFetchRequest(request)
                                                
                                                if results.count > 0 {
                                                    for result in results as! [NSManagedObject] {
                                                        
                                                        let newPhoto = NSEntityDescription.insertNewObjectForEntityForName("Photo", inManagedObjectContext: context)
                                                        
                                                        newPhoto.setValue(imageURL, forKey: "imageURL")
                                                        
                                                        //                                                        result.valueForKey("photos")!.addObject(newPhoto)
                                                        
                                                        //
                                                        //                                                        let photo = result.mutableSetValueForKey("photos")
                                                        //
                                                        //                                                        photo.addObject(newPhoto)
                                                    }
                                                }
                                                
                                            } catch {
                                                
                                            }
                                            do {
                                                try context.save()
                                            } catch {
                                                print("There was a problem saving")
                                            }
                                            
                                        })
                                    }
                                }
                            }
                        }
                    }
                    
                } catch {
                    print("JSON Serialization failed")
                }
            }
        }
        task.resume()
        
    }
}