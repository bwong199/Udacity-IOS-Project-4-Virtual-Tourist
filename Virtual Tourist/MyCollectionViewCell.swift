//
//  MyCollectionViewCell.swift
//  Virtual Tourist
//
//  Created by Ben Wong on 2016-04-05.
//  Copyright © 2016 Ben Wong. All rights reserved.
//

import UIKit

class MyCollectionViewCell: UICollectionViewCell {
    
//
//    @IBOutlet var spinner: UIActivityIndicatorView!

    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet var myImage: UIImageView!
//    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.activityIndicator.startAnimating()
        updateWithImage(nil)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        updateWithImage(nil)
    }
    
    func updateWithImage(image: UIImage?) {
        if let imageToDisplay = image {
            activityIndicator.stopAnimating()
            myImage.image = imageToDisplay
        }
        else {
            activityIndicator.startAnimating()
            myImage.image = nil
        }
    }
   }
