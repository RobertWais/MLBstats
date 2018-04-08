//
//  IndyCell.swift
//  MLBStats
//
//  Created by Robert Wais on 4/7/18.
//  Copyright © 2018 Robert Wais. All rights reserved.
//

import UIKit

class IndyCell: UICollectionViewCell {
    
    @IBOutlet var firstNameDisplay: UILabel!
    
    func configureCell(fName: String){
        firstNameDisplay.text = fName
    }
}
