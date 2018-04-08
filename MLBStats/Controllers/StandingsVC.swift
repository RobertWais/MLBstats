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
class StandingsVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet var collectionView: UICollectionView!
    var namesArr = [String]()
    
    var db: OpaquePointer? = nil
    //let path = Bundle.main.path(forResource: "MLBstats", ofType: ".db", inDirectory: "Shared")!

    
    let insertPlays_For = "INSERT INTO Player (PlayerID, FirstName, LastName, Position, JerseyNumber, Age, Height, Weight) VALUES (?, ?, ?, ?, ?, ?, ?, ?);"
    
    
    override func viewDidAppear(_ animated: Bool) {
        print("Reappearing")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        db = openDB(path: prepareDatabaseFile())
        query()
        
        /*
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
                                
                                var inputPlayerID: Int?
                                var inputFirstName: NSString?
                                var inputLastName: NSString?
                                var inputPosition: NSString?
                                var inputJerseyNumber = 0
                                var inputAge = 0
                                var inputHeight:NSString = "Null"
                                var inputWeight:NSString = "Null"
                                
                                if let playerArr = allPlayers[index] as? Dictionary<String,Any>{
                                    //print("\(index): \(playerArr)")
                                    
                                    if let player = playerArr["player"] as? Dictionary<String,Any>{
                                        if let firstName = player["FirstName"] as? NSString {
                                            print("FirstName: \(firstName)")
                                            inputFirstName = firstName
                                        }
                                        
                                        if let lastName = player["LastName"] as? NSString{
                                            print("LastName: \(lastName)")
                                            inputLastName = lastName
                                        }
                                        
                                        if let playerID = player["ID"] as? NSString{
                                            //print("PlayerID: \(playerID)")
                                            inputPlayerID = Int(playerID as String)
                                            
                                        }
                                        
                                        if let jerseyNumber = player["JerseyNumber"] as? NSString{
                                            //print("Jersey #: \(jerseyNumber)")
                                            inputJerseyNumber = Int(jerseyNumber as String)!
                                        }
                                        
                                        if let position = player["Position"] as? NSString{
                                            //print("Position: \(position)")
                                            inputPosition = position
                                        }
                                        
                                        if let height = player["Height"] as? NSString{
                                            //print("Height: \(height)")
                                            inputHeight = height
                                        }
                                        
                                        if let weight = player["Weight"] as? NSString{
                                            //print("Weight: \(weight)")
                                            inputWeight = weight
                                        }
                                        
                                        if let age = player["Age"] as? NSString{
                                            //print("Age: \(age)")
                                            inputAge = Int(age as String)!
                                        }
                                    }
                                    
                                    self.insert(playerID: inputPlayerID!,FirstName: inputFirstName!,LastName: inputLastName!,Position: inputPosition!,JerseyNumber: inputJerseyNumber, Age: inputAge,Height: inputHeight, Weight: inputWeight)
                                    
                                    if let team = playerArr["team"] as? Dictionary<String,Any>{
                                        if let teamId = team["ID"] as? String{
                                            //print("teamId: \(teamId)")
                                        }
                                        
                                        if let city = team["City"] as? String{
                                            //print("City: \(city)")
                                        }
                                        
                                        if let teamName = team["Name"] as? String{
                                            //print("Team: \(teamName)")
                                        }
                                        if let abbrev = team["Abbreviation"] as? String{
                                            //print("Abbreviation: \(abbrev)\n")
                                        }
                                        //More code to get team info
                                        //Check if team has already been seen when inserting into SQL
                                    }
                                }
                                
                                
                            }
                        }
                    }
                }
                //self.query()
            }
            .authenticate(user: "wais.robert", password: "Dirk1234")
        */
        
        
        print("Here")
        
        
        // Do any additional setup after loading the view, typically from a nib.
 
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: COLLECTION VIEWS
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return namesArr.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        print("Yes")
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IndyCell", for: indexPath) as? IndyCell {
            cell.configureCell(fName: namesArr[indexPath.row])
            return cell
        }else{
            return UICollectionViewCell()
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    //MARK: API CALL
    
    
    func prepareDatabaseFile() -> String {
        
        print("In prepareDatabase")
        let fileName: String = "MLBstats.db"
        
        let fileManager:FileManager = FileManager.default
        let directory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let documentUrl = directory.appendingPathComponent(fileName)
        let bundleUrl = Bundle.main.url(forResource: "MLBstats", withExtension: "db", subdirectory: "Shared")
        
        // here check if file already exists on simulator
        if fileManager.fileExists(atPath: (documentUrl.path)) {
            print("document file exists!")
            return documentUrl.path
        }else if fileManager.fileExists(atPath: (bundleUrl?.path)!) {
            print("document file does not exist, copy from bundle!")
            do {
                try fileManager.copyItem(at: bundleUrl!, to: documentUrl)
            }catch let error {
                print("Error---------------------")
                print(error.localizedDescription)
            }
            
        }
        
        return documentUrl.path
    }
    
    func openDB(path: String) -> OpaquePointer? {
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
                let errorMessage = String.init(cString: sqlite3_errmsg(db))
                print("Query could not be prepared! \(errorMessage)")
            }
        } else {
            print("*INSERT statement could not be prepared*")
            let errorMessage = String.init(cString: sqlite3_errmsg(db))
            print("Error: \(errorMessage)")
        }
        //Check functionality
        sqlite3_finalize(insertStatement)
    }
    
    
    let queryStatementString = "SELECT PlayerID, FirstName, LastName, Position, JerseyNumber, Age, Height, Weight FROM Player"
    
    func query() {
        var queryStatement: OpaquePointer? = nil
        // 1
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            // 2
            var count=0;
            while(sqlite3_step(queryStatement)) == SQLITE_ROW {
                
                let queryResultCol1 = sqlite3_column_int(queryStatement, 0)
                let queryResultCol2 = sqlite3_column_text(queryStatement, 1)
                let queryResultCol3 = sqlite3_column_text(queryStatement, 2)
                let id = Int32(queryResultCol1)
                let FirstName = String(cString: queryResultCol2!)
                let lastName = String(cString:queryResultCol3!)
                
                // 5
                namesArr.append(FirstName)
                print("Query Result:")
                print("ID: \(id)")
                print("FirstName: \(FirstName)")
                print("LastName: \(lastName)")
                count+=1
                print("Count : \(count)")
            }
            print("Count \(count)")
        } else {
            print("SELECT statement could not be prepared")
        }
        
        // 6
        sqlite3_finalize(queryStatement)
    }
    


}

