//
//  Team.swift
//  MLBStats
//
//  Created by Robert Wais on 5/1/18.
//  Copyright © 2018 Robert Wais. All rights reserved.
//

import Foundation

struct Team{
    
    //
    //Change Later, Structs, vs Classes
    var _cityName: String?
    var _teamName: String?
    var _teamID: Int?
    var _hits: Int?
    var _runsBattedIn: Int?
    var _battingAverage: Int?
    var _stolenBases: Int?
    var _homeRuns: Int?
    var _runs: Int?
    var _atBats: Int?
    
    
    init(cityName: String, teamName: String, teamID: Int?, h: Int?, rbi: Int?, avg: Int?,sb: Int?, hr:  Int?, r: Int?, ab: Int?){
        _cityName = cityName
        _teamName = teamName
        _teamID = teamID
        _hits = h
        _runsBattedIn = rbi
        _battingAverage = avg
        _stolenBases = sb
        _homeRuns = hr
        _runs=r
        _atBats=ab
    }
    
    
}
