//
//  PayNowController.swift
//  MyCashCount
//
//  Created by Tiffany Chien on 3/14/15.
//  Copyright (c) 2015 Puppy Sized Elephants. All rights reserved.
//

import UIKit

class PayNowController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    @IBOutlet weak var menuButton: UIBarButtonItem!
    //@IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var tableViewOutlet: UITableView!
    @IBOutlet weak var changeLabel: UILabel!
        // text field for entering amount to pay (also need to implement uitextfielddelegate!!!)
    @IBOutlet weak var toPayField: UITextField!
    @IBOutlet weak var payButton: UIButton!
    @IBOutlet weak var navBar: UINavigationBar!
    
    var values = ["$100.00", "$50.00", "$20.00", "$10.00", "$5.00", "$2.00", "$1.00", "$1.00", "$0.50", "$0.25", "$0.10", "$0.05", "$0.01"]
    var valuesFloat = [100, 50, 20, 10, 5, 2, 1, 1, 0.5, 0.25, 0.10, 0.05, 0.01]
    var totals: Array<Int> = [0,0,0,0,0,0,0,0,0,0,0,0,0]    // money in wallet
    var toPayCounts = [0,0,0,0,0,0,0,0,0,0,0,0,0]           // money to pay
    var images = ["hundred.jpg", "fifty", "twenty", "ten", "five", "two", "one", "dollarCoin", "halfDollar", "quarter", "dime", "nickel", "penny"]
    var indices: Array<Int>? = nil
    var needToPay = 0.0     // approximate calculated total
    var toPay = 0.0         // what to pay (total of toPayCounts)
    var moneyInWallet = 0.0
    var somethingEntered = false
    
    @IBOutlet weak var changeLabelCenterX: NSLayoutConstraint!
    @IBOutlet weak var endTripButtonCenterX: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            self.revealViewController().rearViewRevealWidth = 180
        }
        
        let width = CGRectGetWidth(UIScreen.mainScreen().bounds)
        tableViewOutlet.rowHeight = width/3.5
        
        changeLabelCenterX.constant = width/4.3
        endTripButtonCenterX.constant = -1*changeLabelCenterX.constant+10
        
        let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if (defaults.objectForKey("totals") != nil) {
            totals = defaults.objectForKey("totals") as! Array<Int>
        }
        calcTotal()
        
        /*toPayCounts = [0,0,0,0,0,0,0,0,0,0,0,0,0]
        calcBillsToPay()*/
        updateChange()
        
        //payButton.titleLabel!.text = "Deduct from wallet and\nfinish shopping trip"
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
        if indices != nil {
            return indices!.count
        }
        else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: PayTableCell = self.tableViewOutlet.dequeueReusableCellWithIdentifier("payCell", forIndexPath: indexPath) as! PayTableCell
        
        cell.valueLabel.text = values[indices![indexPath.row]]
        cell.totalLabel.text = "\(toPayCounts[indexPath.row])"
        
        
        cell.picture.contentMode = UIViewContentMode.ScaleAspectFit    // make the size of the uiimageview the size of the image
        cell.picture.image = UIImage(named: images[indices![indexPath.row]] + ".jpg")
        
        cell.setConstraints()
        
        return cell
    }
    
    func calcTotal() {
        var total = 0.0
        for i in 0...values.count-1 {
            // why is making substrings so complicated
            let index1 = values[i].startIndex.advancedBy(1)
            let valueStr = values[i].substringFromIndex(index1)
            // also arithmetic can only be done with two numbers of the same type
            total += ((Double(totals[i])) * (valueStr as NSString).doubleValue)
        }
        //totalLabel.text = "Money in wallet: $"+String(format: "%.2f", total)
        moneyInWallet = total
    }
    
    // problem with algorithm:
    // when getting bill closest in value, doesn't take into account that there could be more than one of a smaller bill, making it a better option
    // eg. needToPay = 2.7
    // have 1 $5, 3 $1
    // algorithm will choose $5 (5 closer to 2.7 than 1), even though using 3 ones is better
    func calcBillsToPay() {
        //println("\n")
        
        if (needToPay > moneyInWallet) {     // don't have enough money
            // should probably make a popup or something to tell them
            let alert = UIAlertController(title: "Error", message: "You don't have enough money.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            
            toPayField.text = ""
            resetToZero()
            
            return
        }
        
        toPayCounts = [0,0,0,0,0,0,0,0,0,0,0,0,0]
        toPay = 0
        var moneyNeeded = needToPay - toPay
        var tempCounts = [0,0,0,0,0,0,0,0,0,0,0,0,0]
        for i in 0...tempCounts.count-1 {
            tempCounts[i] = totals[i]
        }
        
        while(toPay < needToPay) {
            var minDiff = moneyInWallet // should always be bigger than biggest possible diff
            var nextBillIndex = -1
            //println("moneyNeeded \(moneyNeeded)")
            for i in 0...tempCounts.count-1 {
                let currDiff = abs(valuesFloat[i]-moneyNeeded)
                if (tempCounts[i] > 0 && currDiff < minDiff) {
                    minDiff = currDiff
                    nextBillIndex = i
                }
            }
            
            if (nextBillIndex != -1) {
                //println("chosen \(valuesFloat[nextBillIndex])")
                toPayCounts[nextBillIndex]++
                toPay += valuesFloat[nextBillIndex]
                moneyNeeded = needToPay - toPay
                tempCounts[nextBillIndex]--
                tableViewOutlet.reloadData()
                //println(toPay)
            }
        }
        
        /*println("\nBEFORE\ntotals      \(totals)")
        println("tempCounts  \(tempCounts)")
        println("toPayCounts \(toPayCounts)")
        println("toPay \(toPay)")*/
        
        // start from smallest value, remove while still have enough money
        for var i = toPayCounts.count-1; i >= 0; i-- {
            var keepgoing = true
            while (toPayCounts[i] > 0 && keepgoing == true) {
                keepgoing = false
                //println("what 1 \(i)")
                var newTotal = toPay - valuesFloat[i]
                if (newTotal > needToPay) {      // then don't use that bill/coin
                    toPay -= valuesFloat[i]
                    toPayCounts[i]--
                    tempCounts[i]++
                    //println("what 2 \(i)")
                    
                    if (toPayCounts[i] > 0) {
                        newTotal = toPay - valuesFloat[i]
                        if (newTotal > needToPay) {
                            keepgoing = true
                        }
                    }
                }
            }
        }
        
        indices = Array<Int>()
        var index = 0
        for var i = 0; i < toPayCounts.count; i++ {
            if (toPayCounts[i] == 0) {
                toPayCounts.removeAtIndex(i)
                i--
            }
            else {
                indices!.append(index)
            }
            index++
        }
        
        /*println("\nAFTER\ntotals      \(totals)")
        println("tempCounts  \(tempCounts)")
        println("toPayCounts \(toPayCounts)")
        println("final toPay \(toPay)")*/
    }
    
    func resetToZero() {
        changeLabel.text = "Change: $" + String(format: "%.2f", 0.0)
        
        toPayCounts = []
        indices = []
        toPay = 0
    }
    
    func updateChange() -> Double {
        let change = toPay - needToPay
        if change > 0 {
            changeLabel.text = "Change: $" + String(format: "%.2f", change)
        }
        else {
            changeLabel.text = "Change: $" + String(format: "%.2f", 0.0)
        }
        return change
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {    // called when press return in the text field
        toPayField.resignFirstResponder()
        let enteredDouble = (textField.text! as NSString).doubleValue
        if (enteredDouble > 0) {
            somethingEntered = true
            needToPay = enteredDouble
            calcBillsToPay()
            if (toPay >= needToPay) {
                updateChange()
            }
        }
        else {
            resetToZero()
            let alert = UIAlertController(title: "Error", message: "Invalid input. Enter positive total, without dollar sign.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        tableViewOutlet.reloadData()
        
        return true
    }
    
    @IBAction func payButtonAction(sender: UIButton) {
        if somethingEntered {
            var savedStr = ""
        
            // make alert with expected change?
            // prompt for name of shopping trip, then add to history
            let changeStr = "Expected change: $"+String(format: "%.2f", updateChange())
            let alert = UIAlertController(title: "End Shopping Trip", message: changeStr, preferredStyle: UIAlertControllerStyle.Alert)
        
            savedStr = "$" + String(format: "%.2f", needToPay)
        
            // get current date string
            let now: NSDate = NSDate()
            let dateFormatter: NSDateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            let dateStr: String = dateFormatter.stringFromDate(now)
            savedStr = String(dateStr) + ": " + savedStr
        
            var inputTextField: UITextField?
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                if inputTextField != nil {
                    let textInField = inputTextField!.text!
                    if textInField.characters.count != 0 {
                        savedStr = textInField + ", " + savedStr
                    }
                    
                    let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
                    var tripsArr: NSMutableArray? = defaults.objectForKey("trips") as? NSMutableArray
                    if tripsArr == nil {
                        tripsArr = NSMutableArray()
                    }
                    else {
                        // as? used b/c the compiler is stupid. this attempt at casting will never return nil.
                        tripsArr = tripsArr!.mutableCopy() as? NSMutableArray
                    }
                    tripsArr!.addObject(savedStr)
                    defaults.setObject(tripsArr, forKey: "trips")
                }
            }))
            alert.addTextFieldWithConfigurationHandler({(textField: UITextField) in
                textField.placeholder = "Name of trip"
                textField.secureTextEntry = false
                inputTextField = textField
            })
            self.presentViewController(alert, animated: true, completion: nil)
        
            // deduct things from wallet, save to nsuserdefaults
            if indices == nil {
                return
            }
            for i in 0...indices!.count-1 {
                //println(totals[i])
                totals[indices![i]] -= toPayCounts[i]
                toPayCounts[i] = 0
            }
            let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(totals, forKey: "totals")
            calcTotal()
            defaults.setObject(moneyInWallet, forKey: "moneyInWallet")
            defaults.synchronize()
        
            // make text field empty
            toPayField.text = ""
        
            // clear all arrays and variables about paying
            needToPay = 0.0
            resetToZero()
            tableViewOutlet.reloadData()
        
            // or switch back to wallet, add a label in wallet with expected change nahhhh
        }
        else {
            let alert = UIAlertController(title: "Error", message: "No input.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
}
