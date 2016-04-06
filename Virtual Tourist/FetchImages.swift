//
//  FetchImages.swift
//  Virtual Tourist
//
//  Created by Ben Wong on 2016-04-05.
//  Copyright © 2016 Ben Wong. All rights reserved.
//

import UIKit
import CoreData

class FetchImages: UIViewController {
    
    func fetchImages (latitude: Double, longitude: Double){
        let roundLatitude = round(latitude * 100 )/100
        let roundLongitude = round(longitude * 100 )/100
        // Fetch Flickr pictures baesd on geolocation
        let url = NSURL(string: "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=6cd8800d04b7e3edca0524f5b429042e&lat=\(roundLatitude)&lon=\(roundLongitude)&extras=url_s&format=json&nojsoncallback=1&per_page=20")! ;
        
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(url){(data, response, error) -> Void in
            if let data = data {
                //                print(urlContent)
                
                do {
                    let jsonResult =  try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                    
                    if jsonResult.count > 0 {
                        if let items = jsonResult["photos"] as? NSDictionary {
                            
                            if let photoItems = items["photo"] as? NSArray {
                                
                                for item in photoItems {
                                    
                                    if let imageURL = item["url_s"] as? String {
                                        //
                                        print(imageURL)
                                        
                                        NSOperationQueue.mainQueue().addOperationWithBlock({
//                                            self.items.append(imageURL)
                                            
                                            let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                                            
                                            let context: NSManagedObjectContext = appDel.managedObjectContext
                                            
                                            
                                            var newLocation = NSEntityDescription.insertNewObjectForEntityForName("Photo", inManagedObjectContext: context)
                                            
                                            newLocation.setValue(imageURL, forKey: "imageURL")
                                            
    
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
                    //                    print(jsonResult)
                    
                    
//                    print("Looping through array")
//                    for x in self.items {
//                        print(x)
//                    }
                    
                    
                    
                } catch {
                    print("JSON Serialization failed")
                }
            }
        }
        task.resume()

    }
}