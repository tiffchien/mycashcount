//
//  AddItemController.swift
//  MyCashCount
//
//  Created by Tiffany Chien on 3/14/15.
//  Copyright (c) 2015 Puppy Sized Elephants. All rights reserved.
//

import UIKit

class AddItemController: UIViewController, UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var enoughMoneyLabel: UILabel!
    //@IBOutlet weak var moneyInWalletLabel: UILabel!
    @IBOutlet weak var navBar: UINavigationBar!
    
    var items: Array<Item> = []
    var nameArr: Array<String> = []
    var costArr: Array<Double> = []
    var quantArr: Array<Int> = []
    var moneyInWallet: Double? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //println("view did load")    // AHHHH viewdidload isn't called when unwind segue from inputitemcontroller
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            self.revealViewController().rearViewRevealWidth = 180
        }
        
        tableView.rowHeight = 100
        
        let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if !(defaults.objectForKey("itemNames") == nil) {
            //println("what")
            nameArr = defaults.objectForKey("itemNames") as! Array<String>
            costArr = defaults.objectForKey("itemCosts") as! Array<Double>
            quantArr = defaults.objectForKey("itemQuants") as! Array<Int>
            
            //println("arrs \n\(nameArr) \n\(costArr) \n\(quantArr)")
            
            items = []
            if nameArr.count > 0 {
                for i in 0...nameArr.count-1 {
                    let newItem = Item(name: nameArr[i], cost: costArr[i], quantity: quantArr[i])
                    items.append(newItem)
                }
            }
        }
        
        calcTotal()
        
        if (defaults.objectForKey("moneyInWallet") != nil) {
            moneyInWallet = defaults.objectForKey("moneyInWallet") as? Double
        }
        /*if !(moneyInWallet == nil) {
            moneyInWalletLabel.text = "Money in wallet: $" + String(format: "%.2f", moneyInWallet!)
        }*/
        
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
        return items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) 
        
        let item = items[indexPath.row]
        let string = "$" + String(format: "%.2f", item.cost * Double(item.quantity))
        cell.textLabel!.text = ("Name: " + item.name + "\nPrice: $" + String(format: "%.2f", item.cost) + "\nQuantity: \(item.quantity)\nTotal cost: "+string)
        cell.textLabel!.numberOfLines = 0
        cell.textLabel!.font = UIFont(name: cell.textLabel!.font.fontName, size: 18)
        
        return cell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            items.removeAtIndex(indexPath.row)
            nameArr.removeAtIndex(indexPath.row)
            costArr.removeAtIndex(indexPath.row)
            quantArr.removeAtIndex(indexPath.row)
            
            let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(nameArr, forKey: "itemNames")
            defaults.setObject(costArr, forKey: "itemCosts")
            defaults.setObject(quantArr, forKey: "itemQuants")
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
        calcTotal()
    }
    
    @IBAction func resetAction(sender: AnyObject) {
        let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject([], forKey: "itemNames")
        defaults.setObject([], forKey: "itemCosts")
        defaults.setObject([], forKey: "itemQuants")
        defaults.synchronize()
        
        items = []
        tableView.reloadData()
        calcTotal()
    }
    
    @IBAction func cancel(segue:UIStoryboardSegue) {}
    
    @IBAction func done(segue:UIStoryboardSegue) {
        let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if !(defaults.objectForKey("itemNames") == nil) {
            nameArr = defaults.objectForKey("itemNames") as! Array<String>
            costArr = defaults.objectForKey("itemCosts") as! Array<Double>
            quantArr = defaults.objectForKey("itemQuants") as! Array<Int>
            
            //println("arrs \n\(nameArr) \n\(costArr) \n\(quantArr)")
            
            items = []
            for i in 0...nameArr.count-1 {
                let newItem = Item(name: nameArr[i], cost: costArr[i], quantity: quantArr[i])
                items.append(newItem)
            }
        }
        
        let _ = segue.sourceViewController as! InputItemsController
        let indexPath = NSIndexPath(forRow: items.count-1, inSection: 0)
        tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        
        calcTotal()
    }
    
    func calcTotal() {
        var total: Double = 0
        if items.count == 0 {
            total = 0.0
        } else {
            for i in 0...items.count-1 {
                total += items[i].cost * Double(items[i].quantity)
            }
        }
        total += total*0.1
        totalLabel.text = "Approximate total: $" + String(format: "%.2f", total)
        
        let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if (defaults.objectForKey("moneyInWallet") != nil) {
            moneyInWallet = defaults.objectForKey("moneyInWallet") as? Double
        }
        //println(moneyInWallet)
        if !(moneyInWallet == nil) && moneyInWallet! >= total {
            enoughMoneyLabel.text = "You have enough money!"
            enoughMoneyLabel.textColor = UIColor.greenColor()
        } else {
            enoughMoneyLabel.text = "You don't have enough money."
            enoughMoneyLabel.textColor = UIColor.redColor()
        }
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
