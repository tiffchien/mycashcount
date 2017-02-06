//
//  PayTableCell.swift
//  MyCashCount
//
//  Created by Tiffany Chien on 3/27/15.
//  Copyright (c) 2015 Puppy Sized Elephants. All rights reserved.
//

import UIKit

class PayTableCell: UITableViewCell {
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var totalLabel: UILabel!
    
    @IBOutlet weak var imageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var leftLabelCenterX: NSLayoutConstraint!
    @IBOutlet weak var rightLabelCenterX: NSLayoutConstraint!
    
    func setConstraints() {
        let width = CGRectGetWidth(UIScreen.mainScreen().bounds)
        
        imageViewHeight.constant = width / 5
        leftLabelCenterX.constant = width/2.7
        rightLabelCenterX.constant = -1*width/2.7
        
        //println(imageViewHeight.constant)
    }
}
