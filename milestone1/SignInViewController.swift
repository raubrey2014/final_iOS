//
//  SignInViewController.swift
//  milestone1
//
//  Created by Ryan Aubrey on 4/25/16.
//  Copyright © 2016 Ryan Aubrey. All rights reserved.
//

import UIKit


class SignInViewController: UIViewController {
    // MARK: Constants
    let LoginToList = "LoginToList"
    
    //MARK: VARIABLES
    var user_id:Int = 0
    
    // MARK: Outlets
    @IBOutlet weak var textFieldLoginEmail: UITextField!
    @IBOutlet weak var textFieldLoginPassword: UITextField!
    
    @IBOutlet weak var incorrectLabel: UILabel!
    // MARK: Properties
    
    // MARK: UIViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
       
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        print("HERE IN PREPARE>>>")
        if segue.identifier == LoginToList {
//            print("INDEEED LOGTOLIST")
            if let destinationVC = (segue.destinationViewController as! UINavigationController).topViewController as? EventTableController{
                print("LOGINLISTSEQUE: \(self.user_id)")
                destinationVC.user_id = self.user_id
            }
            
            
            
        }
    }
    
    //    // MARK: Actions
    @IBAction func loginDidTouch(sender: AnyObject) {
        self.userLogin(self.textFieldLoginEmail.text!, password: self.textFieldLoginPassword.text!)
    }
    
    @IBAction func signUpDidTouch(sender: AnyObject) {
        var alert = UIAlertController(title: "Register",
                                      message: "Register",
                                      preferredStyle: .Alert)
        
        let saveAction = UIAlertAction(title: "Save",
                                       style: .Default) { (action: UIAlertAction!) -> Void in
                                        
                let emailField = alert.textFields![0] as! UITextField
                let passwordField = alert.textFields![1] as! UITextField
                
                //MARK: SIGN UP NEW USER
                self.createNewUser(emailField.text!, password: passwordField.text!)
                                        
                                        
                
                                        
                                        
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .Default) { (action: UIAlertAction!) -> Void in
        }
        
        alert.addTextFieldWithConfigurationHandler {
            (textEmail) -> Void in
            textEmail.placeholder = "Enter your email"
        }
        
        alert.addTextFieldWithConfigurationHandler {
            (textPassword) -> Void in
            textPassword.secureTextEntry = true
            textPassword.placeholder = "Enter your password"
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        presentViewController(alert,
                              animated: true,
                              completion: nil)
    }
    
    
    func createNewUser(username: String, password: String){
        //Take the passed in proposed new username and password
        //Check is user exists on server and return id of user if valid new user
        var databaseGet = "http://plato.cs.virginia.edu/~rma7qb/flightservice/new_user/"
        databaseGet += username + "/"
        databaseGet += password
  
//        print(databaseGet)
        
        //Replaces spaces and unacceptable characters for web request
        let databaseGet2:String = databaseGet.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
//        print(databaseGet2)
        
        //TRYING GET
        guard let url2 = NSURL(string: databaseGet2) else {
            print("Error: cannot create URL")
            return
        }
        let urlRequest2 = NSURLRequest(URL: url2)
        let config2 = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session2 = NSURLSession(configuration: config2)
        
        let task = session2.dataTaskWithRequest(urlRequest2, completionHandler: { (data, response, error) in
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
            
            let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding)
//            print(dataString)
            if let attempt = Int(dataString! as String) {
                print("The response is an integer, and hopefully this is the id of the newly created member: \(attempt)")
                if attempt == 0 {
                    print("NO! This username is already in use!")
                    dispatch_async(dispatch_get_main_queue()) {
                        // update some UI
                        self.incorrectLabel.text = "USERNAME ALREADY USED TRY AGAIN"
                        self.incorrectLabel.textColor = UIColor.redColor()
                    }
                }
                else {
                    dispatch_async(dispatch_get_main_queue()) {
                        // update some UI
                        self.incorrectLabel.text = "Account Created!"
                        self.incorrectLabel.textColor = UIColor.greenColor()
                    }
                    
                }
            }
            
            
            
            
        })
        task.resume()
    }
    
    func userLogin(username:String, password:String){
        //Take the passed in proposed new username and password
        //Check is user exists on server and return id of user if valid new user
        var databaseGet = "http://plato.cs.virginia.edu/~rma7qb/flightservice/login_user/"
        databaseGet += username + "/"
        databaseGet += password
        
//        print(databaseGet)
        
        //Replaces spaces and unacceptable characters for web request
        let databaseGet2:String = databaseGet.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
//        print(databaseGet2)
        
        //TRYING GET
        guard let url2 = NSURL(string: databaseGet2) else {
            print("Error: cannot create URL")
            return
        }
        let urlRequest2 = NSURLRequest(URL: url2)
        let config2 = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session2 = NSURLSession(configuration: config2)
        
        let task = session2.dataTaskWithRequest(urlRequest2, completionHandler: { (data, response, error) in
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
            
            let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print(dataString)
            if let attempt = Int(dataString! as String) {
                print("The response is an integer, and hopefully this is the id of the logged in member: \(attempt)")
                if attempt == 0 {
                    print("NO! This username is already in use!")
                    dispatch_async(dispatch_get_main_queue()) {
                        // update some UI
                        self.incorrectLabel.text = "Login Failed, try again."
                        self.incorrectLabel.textColor = UIColor.redColor()
                    }
                }
                else {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.user_id = attempt
                        print("HERE IN SIGNIN: \(self.user_id)")
                        self.performSegueWithIdentifier(self.LoginToList, sender: self)
                    }
                    
                }
            }
            
            
            
            
        })
        task.resume()
    }
}
