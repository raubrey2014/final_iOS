//
//  EditViewController.swift
//  milestone1
//
//  Created by Logan on 4/17/16.
//  Copyright © 2016 Ryan Aubrey. All rights reserved.
//

import UIKit

class EditViewController: UIViewController {
    var eventName:String = ""
    var address:String = ""
    var city:String = ""
    var state:String = ""
    var dateTime = NSDate()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMM dd, YYYY hh:mm a"
        let dateString = dateFormatter.stringFromDate(dateTime)
        print(eventName + "," + address + "," + city + "," + state + "," + dateString)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
