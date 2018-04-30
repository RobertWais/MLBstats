//
//  Player.swift
//  MLBStats
//
//  Created by Robert Wais on 4/7/18.
//  Copyright © 2018 Robert Wais. All rights reserved.
//

import Foundation
struct Player {
    
    //
    //Change Later, Structs, vs Classes
     var _firstName: String?
     var _lastName: String?
     var _playerID: Int?
     var _hits: Int?
     var _runsBattedIn: Int?
     var _battingAverage: Int?
     var _stolenBases: Int?
     var _homeRuns: Int?
     var _runs: Int?
     var _atBats: Int?
    
   
    init(fName: String, lName: String, playerID: Int?, h: Int?, rbi: Int?, avg: Int?,sb: Int?, hr:  Int?, r: Int?, ab: Int?){
        _firstName = fName
        _lastName = lName
        _playerID = playerID
        _hits = h
        _runsBattedIn = rbi
        _battingAverage = avg
        _stolenBases = sb
        _homeRuns = hr
        _runs=r
        _atBats=ab
    }
    
    
}
