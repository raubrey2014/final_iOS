//
//  EventTableController.swift
//  milestone1
//
//  Created by Ryan Aubrey on 4/17/16.
//  Copyright © 2016 Ryan Aubrey. All rights reserved.
//

import UIKit
import CoreData

class EventTableController: UITableViewController {

    
    @IBOutlet var eventTableView: UITableView!
    
    var events = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        // Do any additional setup after loading the view.
        eventTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        eventTableView.reloadData()

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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //1
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        //2
        let fetchRequest = NSFetchRequest(entityName: "Your_events")
        
        //3
        do {
            let results =
            try managedContext.executeFetchRequest(fetchRequest)
            events = results as! [NSManagedObject]
            eventTableView.reloadData()

        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    
    // MARK: UITableViewDataSource
    override func tableView(tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int {
            print("Events count: ", events.count)
            return events.count
            
    }
    
    override func tableView(tableView: UITableView,
        cellForRowAtIndexPath
        indexPath: NSIndexPath) -> UITableViewCell {
            
            let cell =
            tableView.dequeueReusableCellWithIdentifier("Cell")
            
            //Still stored NSManagedObject in local var
            let event = events[indexPath.row]
            
            //Accessing name field via valueForKey
            cell!.textLabel!.text = event.valueForKey("event_name") as? String
//            cell!.textLabel!.text = "Example"
            return cell!
    }
    
    //Events
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath){
        print("Here is didselectrowatindexpath..\(indexPath.row)")
        
        performSegueWithIdentifier("DetailViewSegue", sender: indexPath.row)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "DetailViewSegue"{
            print("preparing for detail segue")
            if let destinationVC = segue.destinationViewController as? DetailViewController{
                if let senderInt = sender as? Int{
                    destinationVC.index = senderInt
//                    reminderManager.currentlyEditing = senderInt
                    print("sender Int = \(senderInt)")
                }
                
            }
            
            
            
        }
    }
    
    @IBAction func reload(sender: AnyObject) {
        
        print("Attempting reload on eventTableView..")
        eventTableView.reloadData()
    }
    
    
    

}
