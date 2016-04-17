//
//  ViewController.swift
//  milestone1
//
//  Created by Ryan Aubrey on 4/3/16.
//  Copyright © 2016 Ryan Aubrey. All rights reserved.
//
//
//  GPSController.swift
//  finalProject
//
//  Created by Ryan Aubrey on 4/1/16.
//  Copyright © 2016 Ryan Aubrey. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import CoreMotion
import Foundation

class ViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var addressLabel: UILabel!
   
    @IBOutlet weak var addressButton: UIButton!
    var mLatitude: CLLocationDegrees = CLLocationDegrees()
    var mLongitude: CLLocationDegrees = CLLocationDegrees()
    
    var locationManager: CLLocationManager?
    
    @IBOutlet weak var addressLabel2: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        addressLabel.text = "Wait for it..."
        addressLabel2.text = ""
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.count == 0{
            //handle error here
            return
        }
        
        let newLocation = locations[0]
        
        
        mLongitude = newLocation.coordinate.longitude
        mLatitude = newLocation.coordinate.latitude
        
    }
    
    func locationManager(manager: CLLocationManager,
        didFailWithError error: NSError){
            print("Location manager failed with error = \(error)")
    }
    
    func locationManager(manager: CLLocationManager,
        didChangeAuthorizationStatus status: CLAuthorizationStatus){
            
            print("The authorization status of location services is changed to: ", terminator: "")
            
            switch CLLocationManager.authorizationStatus(){
            case .AuthorizedAlways:
                print("Authorized")
            case .AuthorizedWhenInUse:
                print("Authorized when in use")
            case .Denied:
                print("Denied")
            case .NotDetermined:
                print("Not determined")
            case .Restricted:
                print("Restricted")
            }
            
    }
    
    func displayAlertWithTitle(title: String, message: String){
        let controller = UIAlertController(title: title,
            message: message,
            preferredStyle: .Alert)
        
        controller.addAction(UIAlertAction(title: "OK",
            style: .Default,
            handler: nil))
        
        presentViewController(controller, animated: true, completion: nil)
        
    }
    
    func createLocationManager(startImmediately startImmediately: Bool){
        locationManager = CLLocationManager()
        if let manager = locationManager{
            print("Successfully created the location manager")
            manager.delegate = self
            if startImmediately{
                manager.startUpdatingLocation()
                
                
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        /* Are location services available on this device? */
        if CLLocationManager.locationServicesEnabled(){
            
            /* Do we have authorization to access location services? */
            switch CLLocationManager.authorizationStatus(){
            case .AuthorizedAlways:
                /* Yes, always */
                createLocationManager(startImmediately: true)
            case .AuthorizedWhenInUse:
                /* Yes, only when our app is in use */
                createLocationManager(startImmediately: true)
            case .Denied:
                /* No */
                displayAlertWithTitle("Not Determined",
                    message: "Location services are not allowed for this app")
            case .NotDetermined:
                /* We don't know yet, we have to ask */
                createLocationManager(startImmediately: false)
                if let manager = self.locationManager{
                    manager.requestWhenInUseAuthorization()
                }
                displayAlertWithTitle("Not determined", message: "Location services are undetermined for this app")
            case .Restricted:
                /* Restrictions have been applied, we have no access
                to location services */
                displayAlertWithTitle("Restricted",
                    message: "Location services are not allowed for this app")
            }
            
            
        } else {
            /* Location services are not enabled.
            Take appropriate action: for instance, prompt the
            user to enable the location services */
            print("Location services are not enabled")
        }
    }
    
    
    @IBAction func returnAddress(sender: AnyObject) {
        
        // Create new post
        var googleGet = "https://maps.googleapis.com/maps/api/geocode/json?latlng="
        googleGet += "\(mLatitude)" + ","
        googleGet += "\(mLongitude)"
        googleGet += "&key=AIzaSyAUl2orBA0TOyKQ9g2e5DyeTQQ54Oxnnmc"
     
        //TRYING GET
        let postsUrlRequest = NSMutableURLRequest(URL: NSURL(string: googleGet)!)
        postsUrlRequest.HTTPMethod = "GET"
        
        guard let url = NSURL(string: googleGet) else {
            print("Error: cannot create URL")
            return
        }
        let urlRequest = NSURLRequest(URL: url)
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config)
        var tempAddress = "test1"
        var tempAddress2 = "test2"
        let task = session.dataTaskWithRequest(urlRequest, completionHandler: { (data, response, error) in
            // do stuff with response, data & error here
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            guard error == nil else {
                print("error using POST for our web service!!!\n")
                print(error)
                return
            }
            // parse the result as JSON, since that's what the API provides
            let post: NSDictionary
            do {
                post = try NSJSONSerialization.JSONObjectWithData(responseData,
                    options: []) as! NSDictionary
            } catch  {
                print("error trying to convert data to JSON")
                return
            }
            // now we have the post, let's just print it to prove we can access it
            //             print("The post is: " + post.description)
            
            // the post object is a dictionary
            // so we just access the title using the "title" key
            // so check for a title and print it if we have one
            //            print(post.description)
            print(post.allKeys)
            //            print(post["results"])
            print((post["results"]).dynamicType)
            print((post["status"]).dynamicType)
            
            let json = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
            if let result = json["results"] as? NSArray {
                if let address = result[0]["address_components"] as? NSArray {
                    let number = address[0]["short_name"] as! String
                    let street = address[1]["short_name"] as! String
                    let city = address[2]["short_name"] as! String
                    let state = address[4]["short_name"] as! String
                    let zip = address[6]["short_name"] as! String
                    print("\n\(number) \(street), \(city), \(state) \(zip)")
//                    self.addressLabel.text = "\(number) \(street), \(city), \(state) \(zip)"
                    tempAddress = "\(number) \(street)"
                    tempAddress2 = "\(city), \(state) \(zip)"
                    dispatch_async(dispatch_get_main_queue(), {
                        self.addressLabel.text = tempAddress
                        self.addressLabel2.text = tempAddress2
                        
                    })
                    
                }
            }
            
        })
        task.resume()
    }
    
    
    
    
    
}

