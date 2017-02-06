//
//  ItemHistoryController.swift
//  MyCashCount
//
//  Created by Tiffany Chien on 3/14/15.
//  Copyright (c) 2015 Puppy Sized Elephants. All rights reserved.
//

import UIKit

class ItemHistoryController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navBar: UINavigationBar!
    
    var trips: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            self.revealViewController().rearViewRevealWidth = 180
        }
        
        let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if !(defaults.objectForKey("trips") == nil) {
            trips = defaults.objectForKey("trips") as! Array<String>
        }
        
        //tableView.rowHeight = 50
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        navBar.barTintColor = UIColor(red: 119/255, green: 71/255, blue: 242/255, alpha: 1.0)
        navBar.tintColor = UIColor.whiteColor()
        navBar.translucent = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //println("initializing tableview \(trips.count)")
        return trips.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) 
        
        cell.textLabel!.text = trips[indexPath.row]
        
        return cell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            trips.removeAtIndex(indexPath.row)
            
            let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
            var arr: Array<String> = defaults.objectForKey("trips") as! Array<String>
            arr.removeAtIndex(indexPath.row)
            defaults.setObject(arr, forKey: "trips")
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    @IBAction func resetButton(sender: UIButton) {
        let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(nil, forKey: "trips")
        trips = []
        tableView.reloadData()
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
