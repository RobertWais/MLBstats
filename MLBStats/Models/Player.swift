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
    private var _firstName: String?
    private  var _lastName: String?
    private  var _playerID: Int?
    private  var _hits: Int?
    private  var _runsBattedIn: Int?
    private  var _battingAverage: Int?
    private  var _stolenBases: Int?
    private  var _homeRuns: Int?
    private   var _runs: Int?
    private   var _atBats: Int?
    private  var _teamName: String?
    
   
    init(fName: String, lName: String, playerID: Int?, h: Int?, rbi: Int?, avg: Int?,sb: Int?, hr:  Int?, r: Int?, ab: Int?,teamname:String){
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
        _teamName=teamname
    }
    
    var firstName: String {
        return _firstName!
    }
    
    var lastName: String {
        return _lastName!
    }
    var playerID: Int {
        return _playerID!
    }
    var hits: Int {
        return _hits!
    }
    var runsBattedIn: Int {
        return _runsBattedIn!
    }
    
    var stolenBases: Int {
        return _stolenBases!
    }
    
    var homeRuns: Int{
        return _homeRuns!
    }
    
    var runs: Int{
        return _runs!
    }
    
    var atBats: Int{
        return _atBats!
    }
    
    var teamName: String{
        return _teamName!
    }
    
    
    
}
