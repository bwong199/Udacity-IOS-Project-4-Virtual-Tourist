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
    
    
    func fetchImages (latitude: Double, longitude: Double, completionHandler:(success: Bool, error: Bool, results: String?) -> Void){
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), {
 
            let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            
            var context: NSManagedObjectContext = appDel.managedObjectContext
            
            // Wrapping everything in these codes to make it thread safe
            let privateContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
            privateContext.persistentStoreCoordinator = context.persistentStoreCoordinator
            privateContext.performBlockAndWait {
                // Code in here is now running "in the background" and can safely
                // do anything in privateContext.
                // This is where you will create your entities and save them.
                
                let roundLatitude = round(latitude * 100 )/100
                let roundLongitude = round(longitude * 100 )/100
                
                
               
                // Fetch Flickr pictures baesd on geolocation
                let url = NSURL(string: "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=6cd8800d04b7e3edca0524f5b429042e&lat=\(roundLatitude)&lon=\(roundLongitude)&extras=url_s&format=json&nojsoncallback=1&per_page=24")! ;
                
                let task = NSURLSession.sharedSession().dataTaskWithURL(url){(data, response, error) -> Void in
                    if let data = data {
                        //                print(urlContent)
                        
                        do {
                            let jsonResult =  try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                            
                            if jsonResult.count > 0 {
                                //                        print(jsonResult)
                                if let items = jsonResult["photos"] as? NSDictionary {
                                    
                                    print("Number of pages \(items["pages"])" )
                                    if let pages = items["pages"] as? NSObject {
                                        if pages  == 0 {
                                            
                                            
                                            completionHandler(success: false, error: true, results: "Failed")
                                            
                                        }
                                    }
                                    
                                    
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
                                                            
                                                            let savePath = documentsDirectory! + "/\(imageID).jpg"
//                                                            print("savePath \(savePath)" )
                                                            //                                                    print(savePath)
                                                            //save the images to the savePath/Document Directory
                                                            NSFileManager.defaultManager().createFileAtPath(savePath, contents: imageData, attributes: nil)
                                                            
     
                                                            dispatch_async(dispatch_get_main_queue(),{
                                                                
                                                                let privateContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
                                                                privateContext.persistentStoreCoordinator = context.persistentStoreCoordinator
                                                                privateContext.performBlockAndWait {
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
                                                                            
                                                                            //                                                            print(results)
                                                                            
                                                                            let pages = results[0] as! NSManagedObject
                                                                            
                                                                            pages.setValue(items["pages"]!, forKey: "pages")
                                                                            
                                                                            
                                                                            for result in results as! [NSManagedObject] {
                                                                                //                                                                print(result)
                                                                                let newPhoto = NSEntityDescription.insertNewObjectForEntityForName("Photo", inManagedObjectContext: context)
                                                                                // save image id to imageURL Photo Entity
                                                                                //                                                                print("/\(imageID).jpg")
                                                                                newPhoto.setValue("/\(imageID).jpg", forKey: "imageURL")
                                                                                
                                                                                let photos = result.mutableSetValueForKey("photos")
                                                                                
                                                                                if let photosObject = photos as? NSMutableSet {
                                                                                    
                                                                                    do {
                                                                                        try photosObject.addObject(newPhoto)
                                                                                        
                                                                                    } catch {
                                                                                        print("There was a problem saving")
                                                                                    }
                                                                                }
                                                                                
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
                                                                
                                                            })
                                                            

             
                                                            //
                                                            
                                                            //                                                        do {
                                                            //                                                            let viewController = try UIApplication.sharedApplication().windows[0].rootViewController?.childViewControllers[1] as? PhotoAlbumViewController
                                                            //                                                            try viewController?.refresh_data()
                                                            //                                                        } catch {
                                                            //
                                                            //                                                        }
                                                            
                                                        }
                                                        
                                                    }
                                                }
                                                task.resume()
                                                
                                                
                                            }
                                        }
                                        
                                    }
                                    
                                    
                                    
                                    
                                }
                            }
                            
                            completionHandler(success: true, error: false, results: "Success")
                            
                            
                        } catch {
                            print("JSON Serialization failed")
                        }
                    }
                }
                task.resume()
                
            }
            
            
        })
        
        
        
    }
    
    
    func fetchNewCollection (latitude: Double, longitude: Double, completionHandler:(success: Bool, error: String?, results: String?) -> Void){
        
        var pages = 0
        var roundLatitude = 0.0
        var roundLongitude = 0.0
        
        // Pulls up the number of pages associated with each pin and do a random from page 1 to the max number of pages
        var convertedPages :  UInt32 = 0
        var myRandom : UInt32 = 0
        
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let context: NSManagedObjectContext = appDel.managedObjectContext
        
        let privateContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        privateContext.persistentStoreCoordinator = context.persistentStoreCoordinator
        privateContext.performBlockAndWait {
            // Code in here is now running "in the background" and can safely
            // do anything in privateContext.
            // This is where you will create your entities and save them.
            let request = NSFetchRequest(entityName: "Pin")
            
            
            request.returnsObjectsAsFaults = false
            
            let firstPredicate = NSPredicate(format: "latitude == \(latitude)")
            
            let secondPredicate = NSPredicate(format: "longitude == \(longitude)")
            
            request.predicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [firstPredicate, secondPredicate])
            
            //        request.predicate = NSPredicate(format: "latitude == %f", latitude)
            
            
            do {
                
                let results = try context.executeFetchRequest(request)
                
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        //                        print(result)
                        //                        print(result.valueForKey("photos")! )
                        // check to see if there's any photos under **this** pin, if not do a fetch image
//                        print("Number of pages \(result.valueForKey("pages"))" )
                        
                        if let pageNum = result.valueForKey("pages") as? Int {
                            pages = pageNum
                        }
                        
                        
                    }
                }
            } catch {
                print("Cannot read number of pages")
            }
            
            
             roundLatitude = round(latitude * 100 )/100
             roundLongitude = round(longitude * 100 )/100
            
            
            // Pulls up the number of pages associated with each pin and do a random from page 1 to the max number of pages
             convertedPages = UInt32(pages)
            
            //Flickr limits photos per query of 4000. Take 4000 divided number of pictures per page(12)
             myRandom = arc4random_uniform(min(convertedPages/24, 50))
            
            
            
            print("This is random page \(myRandom)")
            
        }
            // Fetch Flickr pictures baesd on geolocation
            let url = NSURL(string: "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=6cd8800d04b7e3edca0524f5b429042e&lat=\(roundLatitude)&lon=\(roundLongitude)&extras=url_s&format=json&nojsoncallback=1&per_page=24&page=\(myRandom)")! ;
        
            print(url)
            
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
                                                        
                                                        let savePath = documentsDirectory! + "/\(imageID).jpg"
                                                        //                                                    print(savePath)
                                                        //save the images to the savePath/Document Directory
                                                        NSFileManager.defaultManager().createFileAtPath(savePath, contents: imageData, attributes: nil)
                                                        
                                                        
                                                        dispatch_async(dispatch_get_main_queue(),{
                                                            
                                                            let privateContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
                                                            privateContext.persistentStoreCoordinator = context.persistentStoreCoordinator
                                                            privateContext.performBlockAndWait {
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
                                                                            //                                                                print("/\(imageID).jpg")
                                                                            newPhoto.setValue("/\(imageID).jpg", forKey: "imageURL")
                                                                            
                                                                            if let photos = result.mutableSetValueForKey("photos") as? NSMutableSet{
                                                                                if let photosObject = photos as? NSMutableSet {
                                                                                    
                                                                                    // Code in here is now running "in the background" and can safely
                                                                                    // do anything in privateContext.
                                                                                    // This is where you will create your entities and save them.
                                                                                    do {
                                                                                        try photosObject.addObject(newPhoto)
                                                                                        
                                                                                        try context.save()
                                                                                        
                                                                                        
                                                                                        //                                                                                           print("Saved Successfully")
                                                                                    } catch {
                                                                                        print("There was a problem saving")
                                                                                    }
                                                                                    
                                                                                    
                                                                                    
                                                                                    
                                                                                }
                                                                            }
                                                                            
                                                                        }
                                                                    }
                                                                } catch {
                                                                }
                                                                
                                                                
                                                                
                                                            }

                                                            
                                                        })
                                                        
                                                        
                                                        
                                                        

                                                        do {
                                                            let viewController = try UIApplication.sharedApplication().windows[0].rootViewController?.childViewControllers[1] as? PhotoAlbumViewController
                                                            try viewController?.refresh_data()
                                                        } catch {
                                                            
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
                        
                        completionHandler(success: true, error: nil, results: "Success")
                        
                        
                    } catch {
                        print("JSON Serialization failed")
                    }
                }
            }
            task.resume()
            
        }
        
        
    
    
}
