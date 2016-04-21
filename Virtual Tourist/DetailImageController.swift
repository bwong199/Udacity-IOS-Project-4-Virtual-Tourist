//
//  DetailImageController.swift
//  Virtual Tourist
//
//  Created by Ben Wong on 2016-04-15.
//  Copyright © 2016 Ben Wong. All rights reserved.
//

import UIKit

class DetailImageController: UIViewController {
    
    @IBOutlet var image: UIImageView!
    
    var imageURL : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var documentsDirectory: String?
        
        var paths:[AnyObject] = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        
        if paths.count > 0 {
            documentsDirectory = paths[0] as? String
            
            let savePath = documentsDirectory! + imageURL

            dispatch_async(dispatch_get_main_queue(), { () -> Void in

                self.image.image = UIImage(named: savePath)
                
            })
        }
    }
}