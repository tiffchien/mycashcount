//
//  WalletTableCell.swift
//  MyCashCount
//
//  Created by Tiffany Chien on 3/15/15.
//  Copyright (c) 2015 Puppy Sized Elephants. All rights reserved.
//

import UIKit

class WalletTableCell: UITableViewCell {
    @IBOutlet var valueLabel: UILabel!
    @IBOutlet var picture: UIImageView!
    @IBOutlet var countLabel: UILabel!
    @IBOutlet var totalLabel: UILabel!
    
    @IBOutlet weak var leftLabelCenterX: NSLayoutConstraint!
    @IBOutlet weak var imageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var rightGrayLabelCenterX: NSLayoutConstraint!
    @IBOutlet weak var rightPurpleLabelCenterX: NSLayoutConstraint!
    
    func setConstraints() {
        let width = CGRectGetWidth(UIScreen.mainScreen().bounds)
        
        imageViewHeight.constant = width / 5
        leftLabelCenterX.constant = width/2.7
        rightGrayLabelCenterX.constant = -1*width/3
        rightPurpleLabelCenterX.constant = rightGrayLabelCenterX.constant - 30
        
        //println(imageViewHeight.constant)
    }
}
