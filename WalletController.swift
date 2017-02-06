//
//  WalletController.swift
//  MyCashCount
//
//  Created by Tiffany Chien on 3/14/15.
//  Copyright (c) 2015 Puppy Sized Elephants. All rights reserved.
//

import UIKit

class WalletController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var tableViewOutlet: UITableView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tempTotalLabel: UILabel!
    @IBOutlet weak var selectLabel: UILabel!
    @IBOutlet weak var navBar: UINavigationBar!
    
    var values = ["$100.00", "$50.00", "$20.00", "$10.00", "$5.00", "$2.00", "$1.00", "$1.00", "$0.50", "$0.25", "$0.10", "$0.05", "$0.01"]
    var valuesFloat = [100, 50, 20, 10, 5, 2, 1, 1, 0.5, 0.25, 0.10, 0.05, 0.01]
    var counts = [0,0,0,0,0,0,0,0,0,0,0,0,0]
    var totals: Array<Int> = [0,0,0,0,0,0,0,0,0,0,0,0,0]
    var images = ["hundred", "fifty", "twenty", "ten", "five", "two", "one", "dollarCoin", "halfDollar", "quarter", "dime", "nickel", "penny"]
    
    var selectedIndex = 0
    var selectedIndexPath: NSIndexPath? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.tableView.registerClass(WalletTableCell.self, forCellReuseIdentifier: "walletCell")
    
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            self.revealViewController().rearViewRevealWidth = 180
        }
        
        let width = CGRectGetWidth(UIScreen.mainScreen().bounds)
        tableViewOutlet.rowHeight = width/3.5
        
        textField.enabled = false
        //eh maybe not textField.clearsOnBeginEditing = true
        selectLabel.text = "Select a bill or coin."
        
        let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if (defaults.objectForKey("totals") != nil) {
            totals = defaults.objectForKey("totals") as! Array<Int>
        }
        let moneyInWallet = calcTotal()
        defaults.setObject(moneyInWallet, forKey: "moneyInWallet")
        calcTempTotal()
    }
    
    override func viewWillAppear(animated: Bool) {
        navBar.barTintColor = UIColor(red: 119/255, green: 71/255, blue: 242/255, alpha: 1.0)
        navBar.tintColor = UIColor.whiteColor()
        navBar.translucent = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return values.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: WalletTableCell = self.tableViewOutlet.dequeueReusableCellWithIdentifier("walletCell", forIndexPath: indexPath) as! WalletTableCell
        
        cell.valueLabel.text = values[indexPath.row]
        cell.countLabel.text = "\(counts[indexPath.row])"
        cell.totalLabel.text = "\(totals[indexPath.row])"
        
        cell.picture.contentMode = UIViewContentMode.ScaleAspectFit    // make the size of the uiimageview the size of the image, based on height of imageview
        cell.picture.image = UIImage(named: images[indexPath.row]+".jpg")
        //cell.picture.image = UIImage(named: "one.jpg")
        
        cell.setConstraints()
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        textField.enabled = true
        selectLabel.text = ""
        
        selectedIndex = indexPath.row
        selectedIndexPath = indexPath
        textField.text = "\(counts[selectedIndex])"
    }
    
    @IBAction func minusAction(sender: UIButton) {
        if (selectedIndexPath != nil && totals[selectedIndex]+(counts[selectedIndex]-1) >= 0) {
            counts[selectedIndex]--
            updateCountLabel()
        }
        else if (selectedIndexPath != nil) {
            let alert = UIAlertController(title: "Error", message: "Negative total.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        calcTempTotal()
    }
    
    @IBAction func plusAction(sender: UIButton) {
        if (selectedIndexPath != nil) {
            counts[selectedIndex]++
            updateCountLabel()
        }
        calcTempTotal()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {    // called when press return in the text field
        textField.resignFirstResponder()
        let enteredInt: Int? = Int(textField.text!)
        if (selectedIndexPath != nil && enteredInt != nil) {
            if (totals[selectedIndex] + enteredInt! >= 0) {
                counts[selectedIndex] = enteredInt!
                updateCountLabel()
            }
            else {
                let alert = UIAlertController(title: "Error", message: "Negative total.", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
        else if (enteredInt == nil) {
            let alert = UIAlertController(title: "Error", message: "Invalid input.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        calcTempTotal()
        return true
    }
    
    @IBAction func updateWalletAction(sender: UIButton) {
        for i in 0...values.count-1 {
            totals[i] += counts[i]
            counts[i] = 0
            
            // set currently selected cell's selectedness to false b/c it unhighlights it but doesn't unselect it
            if (selectedIndexPath != nil) {
                let cell = tableViewOutlet.cellForRowAtIndexPath(selectedIndexPath!) as! WalletTableCell
                cell.selected = false
            }
        }
        selectedIndexPath = nil
        textField.text = ""
        textField.enabled = false
        selectLabel.text = "Select a bill or coin."
        
        tableViewOutlet.reloadData()    // this is how you refresh a table view...
        
        let totalInWallet: Double = calcTotal()
        calcTempTotal()
        
        let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(totals, forKey: "totals")
        defaults.setObject(totalInWallet, forKey: "moneyInWallet")
        defaults.synchronize()
    }
    
    func updateCountLabel() {
        let cell = tableViewOutlet.cellForRowAtIndexPath(selectedIndexPath!) as! WalletTableCell
        if counts[selectedIndex] <= 0 {
            cell.countLabel.text = "\(counts[selectedIndex])"
            textField.text = "\(counts[selectedIndex])"
        }
        else {
            cell.countLabel.text = "+\(counts[selectedIndex])"
            textField.text = "+\(counts[selectedIndex])"
        }
    }
    
    func calcTotal() -> Double {
        var total: Double = 0.0
        for i in 0...values.count-1 {
            /*// why is making substrings so complicated
            let index1 = advance(values[i].startIndex, 1)
            let valueStr = values[i].substringFromIndex(index1)
            // also arithmetic can only be done with two numbers of the same type
            total += ((Double(totals[i])) * (valueStr as NSString).doubleValue)*/
            total += Double(totals[i]) * valuesFloat[i]
        }
        navBar.topItem!.title = "Wallet: $"+String(format: "%.2f", total)
        return total
    }
    
    func calcTempTotal() {
        var total = 0.0
        for i in 0...values.count-1 {
            /*// why is making substrings so complicated
            let index1 = advance(values[i].startIndex, 1)
            let valueStr = values[i].substringFromIndex(index1)
            // also arithmetic can only be done with two numbers of the same type
            total += ((Double(counts[i])) * (valueStr as NSString).doubleValue)*/
            total += Double(counts[i]) * valuesFloat[i]
        }
        if total > 0 {
            tempTotalLabel.text = "To add or subtract: $+"+String(format: "%.2f", total)
        }
        else {
            tempTotalLabel.text = "To add or subtract: $"+String(format: "%.2f", total)
        }
    }
}
