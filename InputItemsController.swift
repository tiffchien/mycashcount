//
//  InputItemsController.swift
//  MyCashCount
//
//  Created by Tiffany Chien on 3/29/15.
//  Copyright (c) 2015 Puppy Sized Elephants. All rights reserved.
//

import UIKit

class InputItemsController: UITableViewController, UITextFieldDelegate {
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var costField: UITextField!
    @IBOutlet weak var quantityField: UITextField!
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    var allValidArr = [false, false, false]
    
    /*required init(coder aDecoder: NSCoder) {
        println("init PlayerDetailsViewController")
        super.init(coder: aDecoder)
    }*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        doneButton.enabled = false
        
        let navBar = self.navigationController?.navigationBar
        navBar!.barTintColor = UIColor(red: 119/255, green: 71/255, blue: 242/255, alpha: 1.0)
        navBar!.tintColor = UIColor.whiteColor()
        navBar!.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        navBar!.translucent = false
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func nameEndEdit(sender: UITextField) {
        //println("nameEndEdit")
        //print("blah " + sender.text!)
        if sender.text!.characters.count == 0 {
            allValidArr[0] = false
            let alert = UIAlertController(title: "Error", message: "Invalid input. Enter item name.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            allValidArr[0] = true
        }
        
        checkIfAllValid()
    }
    
    @IBAction func costEndEdit(sender: UITextField) {
        //println("costEndEdit")
        let number: Double = (sender.text! as NSString).doubleValue
        if number <= 0 {
            allValidArr[1] = false
            let alert = UIAlertController(title: "Error", message: "Invalid input. Enter positive item cost, without dollar sign.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            allValidArr[1] = true
        }
        
        checkIfAllValid()
    }
    
    @IBAction func quantityEndEdit(sender: UITextField) {
        //println("quantityEndEdit")
        let value: Int? = Int(sender.text!)
        let double: Double = (sender.text! as NSString).doubleValue
        let wholeNum = double%1 == 0
        if value == nil || value! <= 0 || !wholeNum {
            allValidArr[2] = false
            let alert = UIAlertController(title: "Error", message: "Invalid input. Enter positive integer item quantity.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            allValidArr[2] = true
        }
        
        checkIfAllValid()
    }
    
    func checkIfAllValid() {
        var allValid = true
        for var i = 0; i < 3; i++ {
            if allValidArr[i] == false {
                allValid = false
                i = 10  // stop loop
            }
        }
        doneButton.enabled = allValid
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        nameField.resignFirstResponder()
        costField.resignFirstResponder()
        quantityField.resignFirstResponder()
        return true
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            nameField.becomeFirstResponder()
        }
        if indexPath.section == 1 {
            costField.becomeFirstResponder()
        }
        if indexPath.section == 2 {
            quantityField.becomeFirstResponder()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "doneSegue" {
            // save the item into phone storage so that it can be seen in shopping list
            
            let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
            var arr: NSMutableArray? = defaults.objectForKey("itemNames") as? NSMutableArray
            if arr == nil {
                arr = NSMutableArray()
            }
            arr = arr!.mutableCopy() as? NSMutableArray
            arr!.addObject(nameField.text!)
            defaults.setObject(arr!, forKey: "itemNames")
            
            arr = defaults.objectForKey("itemCosts") as? NSMutableArray
            if arr == nil {
                arr = NSMutableArray()
            }
            arr = arr!.mutableCopy() as? NSMutableArray
            //println(arr!)
            arr!.addObject((costField.text! as NSString).doubleValue)
            defaults.setObject(arr!, forKey: "itemCosts")
            
            arr = defaults.objectForKey("itemQuants") as? NSMutableArray
            if arr == nil {
                arr = NSMutableArray()
            }
            arr = arr!.mutableCopy() as? NSMutableArray
            arr!.addObject(Int(quantityField.text!)!)
            defaults.setObject(arr!, forKey: "itemQuants")
            
            defaults.synchronize()
        }
    }
}