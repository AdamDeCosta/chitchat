//
//  MessageViewController.swift
//  chitchat
//
//  Created by Andrew Rimpici on 4/26/18.
//  Copyright © 2018 Adam DeCosta. All rights reserved.
//

import UIKit
import Kingfisher
import MapKit

class MessageViewController: UIViewController
{
    var currentMessage: Message!
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var message: UILabel!

    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        if let imageURL = currentMessage.getImageURLInMessage()
        {
            imageView.kf.setImage(with: imageURL)
        }
        
        message.text = currentMessage.message

        if let lat = currentMessage.location[0], let long = currentMessage.location[1] {
            let initialLoc = CLLocation(latitude: lat, longitude: long)
            
            let region = MKCoordinateRegionMakeWithDistance(initialLoc.coordinate, 750, 750)
            
            mapView.setRegion(region, animated: true)
            
            let locAnnotion = MKPointAnnotation()
            locAnnotion.coordinate = initialLoc.coordinate
            
            mapView.addAnnotation(locAnnotion)
        }
    }
    
    
}
