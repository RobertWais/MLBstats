//
//  ViewController.swift
//  MLBStats
//
//  Created by Robert Wais on 2/24/18.
//  Copyright © 2018 Robert Wais. All rights reserved.
//

import UIKit
import Alamofire
import SQLite3
class StandingsVC: UIViewController {
    
    var db: OpaquePointer? = nil
    let path = Bundle.main.path(forResource: "MLBstats", ofType: ".db", inDirectory: "Shared")!
    
    let insertPlays_For = "INSERT INTO Player (PlayerID, FirstName, LastName, Position, JerseyNumber, Age, Height, Weight) VALUES (?, ?, ?, ?, ?, ?, ?, ?);"
    
    
    func openDB() -> OpaquePointer? {
        var db: OpaquePointer? = nil
        print("Path: \(String(describing: path))")
        if sqlite3_open(path, &db) == SQLITE_OK {
            print("Connected")
            return db
        } else {
            print("Unable to open database. ")
        }
        return db
    }
    
    func insert(playerID: Int, FirstName: NSString, LastName: NSString, Position: NSString, JerseyNumber: Int, Age: Int, Height: NSString, Weight: NSString) {
        var insertStatement: OpaquePointer? = nil
        // 1
        if sqlite3_prepare_v2(db, insertPlays_For , -1, &insertStatement, nil) == SQLITE_OK {
            
            //Entering Elements
            sqlite3_bind_int(insertStatement, 1, Int32(playerID))
            sqlite3_bind_text(insertStatement, 2, FirstName.utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 3, LastName.utf8String, -1,nil)
            sqlite3_bind_text(insertStatement, 4, Position.utf8String, -1, nil)
            sqlite3_bind_int(insertStatement, 5, Int32(JerseyNumber))
            sqlite3_bind_int(insertStatement, 6, Int32(Age))
            sqlite3_bind_text(insertStatement, 7, Height.utf8String, -1,nil)
            sqlite3_bind_text(insertStatement, 8, Weight.utf8String, -1, nil)
            
            //Check if SQL Statement is successful
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("Successfully inserted row.")
            } else {
                print("Could not insert row.")
            }
        } else {
            print("*INSERT statement could not be prepared*")
        }
        //Check functionality
        sqlite3_finalize(insertStatement)
    }
    
    
    let queryStatementString = "SELECT Player.PlayerID, Player.FirstName, Player.LastName FROM Player;"
    
    func query() {
        var queryStatement: OpaquePointer? = nil
        // 1
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            // 2
            if sqlite3_step(queryStatement) == SQLITE_ROW {
                // 3
                //let id = sqlite3_column_int(queryStatement, 0)
                print("Here: \(queryStatement?.debugDescription)")
                // 4
                let queryResultCol1 = sqlite3_column_int(queryStatement, 0)
                let queryResultCol2 = sqlite3_column_text(queryStatement, 1)
                let queryResultCol3 = sqlite3_column_text(queryStatement, 2)
                let id = Int32(queryResultCol1)
                let FirstName = String(cString: queryResultCol2!)
                let lastName = String(cString:queryResultCol3!)
                
                // 5
                print("Query Result:")
                print("ID: \(id)")
                print("FirstName: \(FirstName)")
                print("LastName: \(lastName)")
                
            } else {
                print("Query returned no results")
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        
        // 6
        sqlite3_finalize(queryStatement)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("Reappearing")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = openDB()
        
        
        insert(playerID: 1, FirstName: "Robert", LastName: "Wais", Position: "C", JerseyNumber: 12, Age: 45, Height: "5'8", Weight: "200lbs")
        print("Standings")
        query()
        //
        //https://api.mysportsfeeds.com/v1.2/pull/mlb/2018-regular/roster_players.json?fordate=20180401&sort=team.abbr
        //
        //https://api.mysportsfeeds.com/v1.2/pull/mlb/2017-regular/roster_players.json?fordate=20170910&team=bos"
        //Players: https://api.mysportsfeeds.com/v1.2/pull/mlb/2017-regular/roster_players.json?fordate=20170910&team=bos
        //All Teams: https://api.mysportsfeeds.com/v1.2/pull/mlb/2017-regular/roster_players.json?fordate=20170910&sort=team.abbr
        Alamofire.request("https://api.mysportsfeeds.com/v1.2/pull/mlb/2018-regular/roster_players.json?fordate=20180401&sort=team.abbr")
            .responseJSON { response  in
                let result = response.result
                print(result)
                print("Before-----------------")
               if let dict = result.value as? Dictionary<String,Any> {
                   if let allInfo = dict["rosterplayers"] as? Dictionary<String,Any> {
                    
                        if let allPlayers = allInfo["playerentry"] as? [Dictionary<String,Any>]{
                            print("All: \(allPlayers.count)")
                            for index in 0..<allPlayers.count{
                                if let playerArr = allPlayers[index] as? Dictionary<String,Any>{
                                    //print("\(index): \(playerArr)")
                                    
                                    if let player = playerArr["player"] as? Dictionary<String,Any>{
                                        if let firstName = player["FirstName"] as? String {
                                            print("FirstName: \(firstName)")
                                        }
                                        
                                        if let lastName = player["LastName"] as? String{
                                            print("LastName: \(lastName)")
                                        }
                                        
                                        if let playerID = player["ID"] as? String{
                                            print("PlayerID: \(playerID)")
                                        }
                                        
                                        if let jerseyNumber = player["JerseyNumber"] as? String{
                                            print("Jersey #: \(jerseyNumber)")
                                        }
                                        
                                        if let position = player["Position"] as? String{
                                            print("Position: \(position)")
                                        }
                                        
                                        if let height = player["Height"] as? String{
                                            print("Height: \(height)")
                                        }
                                        
                                        if let weight = player["Weight"] as? String{
                                            print("Weight: \(weight)")
                                        }
                                        
                                        if let age = player["Age"] as? String{
                                            print("Age: \(age)")
                                        }
                                    }
                                    
                                    if let team = playerArr["team"] as? Dictionary<String,Any>{
                                        if let teamId = team["ID"] as? String{
                                            print("teamId: \(teamId)")
                                        }
                                        
                                        if let city = team["City"] as? String{
                                            print("City: \(city)")
                                        }
                                        
                                        if let teamName = team["Name"] as? String{
                                            print("Team: \(teamName)")
                                        }
                                        if let abbrev = team["Abbreviation"] as? String{
                                            print("Abbreviation: \(abbrev)\n")
                                        }
                                        //More code to get team info
                                        //Check if team has already been seen when inserting into SQL
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .authenticate(user: "wais.robert", password: "Dirk1234")
        
        
        
        
        
        // Do any additional setup after loading the view, typically from a nib.
 
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
