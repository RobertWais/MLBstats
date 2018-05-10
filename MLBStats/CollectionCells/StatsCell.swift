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
    @IBOutlet var averageLbl: UILabel!
    
    func configureCell(player: Player){
        firstName.text = "\(player.firstName) \(player.lastName)"
        hitsLbl.text = String(describing: player.hits)
        homeRunLbl.text = String(describing: player.homeRuns)
        runsBattedInLbl.text = String(describing: player.runsBattedIn)
        stolenBasesLbl.text = String(describing: player.stolenBases)
        var average: Double = 0
        if player.atBats != 0{
            average = Double(player.hits)/Double(player.atBats)
        }
        averageLbl.text = String(format: "AVG: %0.3f", arguments: [average])
        //averageLbl.text = NSString(format: "%f.3f",average) as String
        let view = UIView(frame: self.frame)
        view.layer.borderColor = UIColor.white.cgColor
        self.addSubview(view)
        print("team: \(player.teamName)")
        imageView.image = UIImage(named: player.teamName)
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




