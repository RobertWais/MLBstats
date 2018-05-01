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
    @IBOutlet var homeRunLbl: UILabel!
    @IBOutlet var runsBattedInLbl: UILabel!
    @IBOutlet var stolenBasesLbl: UILabel!
    
    func configureCell(player: Player){
        lastName.text = player._lastName!
        firstName.text = player._firstName!
        hitsLbl.text = String(describing: player._hits!)
        homeRunLbl.text = String(describing: player._homeRuns!)
        runsBattedInLbl.text = String(describing: player._runsBattedIn!)
        stolenBasesLbl.text = String(describing: player._stolenBases!)
        var view = UIView(frame: self.frame)
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.cgColor
        self.addSubview(view)
    }
    
    func configureCell(team: Team){
        lastName.text = team._teamName!
        firstName.text = team._cityName
        hitsLbl.text = String(describing: team._hits!)
        homeRunLbl.text = String(describing: team._homeRuns!)
        runsBattedInLbl.text = String(describing: team._runsBattedIn!)
        stolenBasesLbl.text = String(describing: team._stolenBases!)
        var view = UIView(frame: self.frame)
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.cgColor
        self.addSubview(view)
    }
}
