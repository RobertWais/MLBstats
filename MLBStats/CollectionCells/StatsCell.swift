//
//  StatsCell.swift
//  MLBStats
//
//  Created by Robert Wais on 4/14/18.
//  Copyright © 2018 Robert Wais. All rights reserved.
//

import UIKit

class StatsCell: UICollectionViewCell {
    
    
    @IBOutlet var imageViewTeam: UIImageView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var firstName: UILabel!
    @IBOutlet var hitsLbl: UILabel!
    @IBOutlet var homeRunLbl: UILabel!
    @IBOutlet var runsBattedInLbl: UILabel!
    @IBOutlet var stolenBasesLbl: UILabel!
    
    func configureCell(player: Player){
        firstName.text = "\(player._firstName!) \(player._lastName!)"
        hitsLbl.text = String(describing: player._hits!)
        homeRunLbl.text = String(describing: player._homeRuns!)
        runsBattedInLbl.text = String(describing: player._runsBattedIn!)
        stolenBasesLbl.text = String(describing: player._stolenBases!)
        let view = UIView(frame: self.frame)
        view.layer.borderColor = UIColor.white.cgColor
        self.addSubview(view)
        print("team: \(player._teamName!)")
        imageView.image = UIImage(named: player._teamName!)
    }
    
    func configureCell(team: Team){
        firstName.text = "\(team._cityName!) \(team._teamName!)"
        hitsLbl.text = String(describing: team._hits!)
        homeRunLbl.text = String(describing: team._homeRuns!)
        runsBattedInLbl.text = String(describing: team._runsBattedIn!)
        stolenBasesLbl.text = String(describing: team._stolenBases!)
        let view = UIView(frame: self.frame)
        view.layer.borderColor = UIColor.white.cgColor
        self.addSubview(view)
        print("teamname: \(team._teamName!)")
        imageViewTeam.image = UIImage(named: team._teamName!)
        print("Done")
    }
}
