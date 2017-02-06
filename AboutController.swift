//
//  AboutController.swift
//  MyCashCount
//
//  Created by Tiffany Chien on 3/28/15.
//  Copyright (c) 2015 Puppy Sized Elephants. All rights reserved.
//

import UIKit

class AboutController: UIViewController {
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var navBar: UINavigationBar!
    
    @IBAction func websiteButtonAction(sender: AnyObject) {
        if let url = NSURL(string: "http://mycashcount.weebly.com") {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            self.revealViewController().rearViewRevealWidth = 180
        }
        
        //textArea.editable = false
        
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
}
