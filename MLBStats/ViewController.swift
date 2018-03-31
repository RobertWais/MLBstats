//
//  ViewController.swift
//  MLBStats
//
//  Created by Robert Wais on 2/24/18.
//  Copyright © 2018 Robert Wais. All rights reserved.
//

import UIKit
import Alamofire
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Players: https://api.mysportsfeeds.com/v1.2/pull/mlb/2017-regular/roster_players.json?fordate=20170910&team=bos
        //All Teams: https://api.mysportsfeeds.com/v1.2/pull/mlb/2017-regular/roster_players.json?fordate=20170910&sort=team.abbr
        Alamofire.request("https://api.mysportsfeeds.com/v1.2/pull/mlb/2017-regular/roster_players.json?fordate=20170910&team=bos")
            .responseJSON { response  in
                let result = response.result
                
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
            .authenticate(user: "wais.robert", password: "????????")
        
        
        
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

