//
//  StatsCell.swift
//  MLBStats
//
//  Created by Robert Wais on 4/14/18.
//  Copyright © 2018 Robert Wais. All rights reserved.
//

import UIKit

class StatsCell: UICollectionViewCell {
    
    @IBOutlet var lastName: UILabel!
    @IBOutlet var firstName: UILabel!
    @IBOutlet var hitsLbl: UILabel!
    
    func configureCell(fName: String,lName: String, hits: String){
        lastName.text = lName
        firstName.text = fName
        hitsLbl.text = hits
        var view = UIView(frame: self.frame)
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.cgColor
        self.addSubview(view)
    }
}
