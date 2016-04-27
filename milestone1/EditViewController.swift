//
//  EditViewController.swift
//  milestone1
//
//  Created by Logan on 4/17/16.
//  Copyright © 2016 Ryan Aubrey. All rights reserved.
//

import UIKit
import CoreData

class EditViewController: UIViewController, UITextFieldDelegate {
    
    var user_id:Int = 0
    var index:Int = 0
    var foreignIndex:Int = 0
    var eventName:String = ""
    var address:String = ""
    var city:String = ""
    var state:String = ""
    var dateTime = NSDate()
    
    var mLatitude:Double = 0.0
    var mLongitude:Double = 0.0
    
    
    var events = [NSManagedObject]()

    @IBOutlet weak var editNameField: UITextField!
    
    @IBOutlet weak var editAddressField: UITextField!
    
    @IBOutlet weak var editCityField: UITextField!
    
    @IBOutlet weak var editStateField: UITextField!
    
    @IBOutlet weak var editDateTime: UIDatePicker!
    
    @IBOutlet weak var saveEditEvent: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        editNameField.delegate = self
        editAddressField.delegate = self
        editCityField.delegate = self
        editStateField.delegate = self
        
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMM dd, YYYY hh:mm a"
        let dateString = dateFormatter.stringFromDate(dateTime)
        print(eventName + "," + address + "," + city + "," + state + "," + dateString)
        
        editNameField.text = eventName
        editAddressField.text = address
        editCityField.text = city
        editStateField.text = state
        editDateTime.minimumDate = NSDate()
        editDateTime.date = dateTime
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        //hide keyboard
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func saveEditedEvent(sender: AnyObject) {
        print("in saveEditedEvent....")
            
        //################################################################################################
        // Create new post
        var googleGet = "https://maps.googleapis.com/maps/api/geocode/json?address="
        googleGet += (editAddressField.text!).stringByReplacingOccurrencesOfString(" ", withString: "+") + ","
        googleGet += (editCityField.text!).stringByReplacingOccurrencesOfString(" ", withString: "+") + ","
        googleGet += (editStateField.text!).stringByReplacingOccurrencesOfString(" ", withString: "+")
        
        googleGet += "&key=AIzaSyAUl2orBA0TOyKQ9g2e5DyeTQQ54Oxnnmc"
        print(googleGet)
        
        
        //TRYING GET
        
        guard let url = NSURL(string: googleGet) else {
            print("Error: cannot create URL")
            return
        }
        let urlRequest = NSURLRequest(URL: url)
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config)
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
            
            
            let json = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
            if let result = json["results"] as? NSArray {
                if let geometry = result[0]["geometry"] as? NSDictionary {
                    //let number = address[0]["short_name"] as! String
                    let latitude = geometry["location"]!["lat"] as! Double
                    let longitude = geometry["location"]!["lng"] as! Double
                    
                    self.mLatitude = geometry["location"]!["lat"] as! Double
                    self.mLongitude = geometry["location"]!["lng"] as! Double
                    
                    print("\n latitude: \(latitude)")
                    print("longitude: \(longitude)")
                    
//                    //**********************************************************************************************
//                    //CREATE EVENT ENTRY WITH GPS INFORMATION
//                    //Send Event name, longitude, latitude, date time
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "dd-MM-YYYY:hh:mm"
                    let dateValue = self.editDateTime.date
                    let dateString = dateFormatter.stringFromDate(dateValue)
//
                    var databaseGet = "http://plato.cs.virginia.edu/~rma7qb/flightservice/gps/update/"
                    databaseGet += "\(self.foreignIndex)/"
                    databaseGet += "\(self.editNameField.text!)/"
                    databaseGet += "\(dateString)/"
                    databaseGet += "\(self.mLatitude)/"
                    databaseGet += "\(self.mLongitude)"
                    print(databaseGet)
//
//                    //Replaces spaces and unacceptable characters for web request
                    let databaseGet2:String = databaseGet.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
                    print(databaseGet2)
//
//                    //TRYING GET
                    guard let url2 = NSURL(string: databaseGet2) else {
                        print("Error: cannot create URL")
                        return
                    }
                    let urlRequest2 = NSURLRequest(URL: url2)
                    let config2 = NSURLSessionConfiguration.defaultSessionConfiguration()
                    let session2 = NSURLSession(configuration: config2)
//
                    let task2 = session2.dataTaskWithRequest(urlRequest2, completionHandler: { (data, response, error) in
                        // do stuff with response, data & error here
                        guard let _ = data else {
                            print("Error: did not receive data")
                            return
                        }
                        guard error == nil else {
                            print("error using POST for our web service!!!\n")
                            print(error)
                            return
                        }
                        let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding)
//                        print(dataString)
                        let attempt = Int(dataString! as String)
                        print("Event_id: ", attempt)
                        print("Event_name: ", self.editNameField.text!)
                        print("Lat: ", self.mLatitude)
                        print("Long: ", self.mLongitude)
                        
                        //NOT UPDATING USER ID BECUASE IT MUST BE CREATOR, CHECK SPECIAL DEATAIL VIEW
                        self.updateEvent(self.events.count, event_id: attempt!, event_name: self.editNameField.text!, event_date: self.editDateTime.date,event_lat: self.mLatitude, event_long: self.mLongitude)
                        dispatch_async(dispatch_get_main_queue()) {
                            self.navigationController?.popViewControllerAnimated(true)
                        }
                            
                    })
                    task2.resume()
                    //##############################################################################################
                }
            }
            
        })
        
        task.resume()
 
        
        //Update Server Information
        
//        navigationController?.popViewControllerAnimated(true)
        
    }
    
    
    func updateEvent(local_id:Int, event_id: Int, event_name: String, event_date: NSDate, event_lat: Double, event_long: Double) {
        //Edit values in Core Data
        print("in updateEvent")
        //1
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        //2
        let fetchRequest = NSFetchRequest(entityName: "Your_events")
        
        //3

        do {
        let results = try managedContext.executeFetchRequest(fetchRequest)
        events = results as! [NSManagedObject]
        let eventUpdate = events[self.index]
        
        eventUpdate.setValue(local_id, forKey:"local_id")
        eventUpdate.setValue(event_id, forKey: "event_id")
        eventUpdate.setValue(event_name, forKey: "event_name")
        eventUpdate.setValue(event_date, forKey: "date_time")
        eventUpdate.setValue(event_lat, forKey: "lat")
        eventUpdate.setValue(event_long, forKey: "long")
            
            do {
                try eventUpdate.managedObjectContext?.save()
                //5
                
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")

        }
    }

}
