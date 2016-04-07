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
//                                                            result.valueForKey("photos")!.addObject(newPhoto)
                                                        
                                                                                            
                                                        let photo = result.mutableSetValueForKey("photos")
                                                        
                                                        photo.addObject(newPhoto)                                                    }
                                                    
                                                
                                                }
                                                
                                            } catch {
                                                
                                            }
                                            
                                            
                                            do {
                                                try context.save()
                                            } catch {
                                                print("There was a problem saving")
                                            }
                                            
                                            
                                            //                                            self.do_collection_refresh()
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