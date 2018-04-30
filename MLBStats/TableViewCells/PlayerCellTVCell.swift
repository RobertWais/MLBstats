//
//  PlayerCellTVCell.swift
//  MLBStats
//
//  Created by Robert Wais on 4/30/18.
//  Copyright © 2018 Robert Wais. All rights reserved.
//

import UIKit

class PlayerCellTVCell: UITableViewCell {
    
    @IBOutlet var firstNameLbl: UILabel!
    @IBOutlet var lastNameLbl: UILabel!
    
    func configureCell(player: Player){
        firstNameLbl.text = player._firstName!
        lastNameLbl.text = player._lastName!
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
