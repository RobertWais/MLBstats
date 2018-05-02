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
class TeamStatsVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource,UIPickerViewDelegate,UIPickerViewDataSource {
    
    @IBOutlet var pickerView: UIPickerView!
    @IBOutlet var collectionView: UICollectionView!
    
    var teams = [Team]()
    var word: [String:String] = ["SB":"StolenBases","RBI":"RunsBattedIn","AVG":"BattingAverage","H":"Hits","HR":"HomeRuns","R":"Runs","AB":"AtBats"]
    var stats = ["SB","RBI","AVG","H","HR","R","AB"]
    var statsOption = "SB"
    var namesArr = [String]()
    var march = [29,30,31]
    var april = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,27,28]
    var teamsAdded = Set<NSString>()
    var nums = 0;
    
    var db: OpaquePointer? = nil
    //let path = Bundle.main.path(forResource: "MLBstats", ofType: ".db", inDirectory: "Shared")!
    
    
    let insertPlays_For = "INSERT INTO Player (PlayerID, FirstName, LastName, Position, JerseyNumber, Age, Height, Weight) VALUES (?, ?, ?, ?, ?, ?, ?, ?);"
    let insertPlayerIDTeamID = "INSERT INTO Plays_For (PlayerID, TeamID) VALUES (?,?);"
    let insertTeamInfo = "INSERT INTO Team (TeamID, City, Stadium, Name) VALUES (?, ?, ?, ?)"
    let insertStats = "INSERT INTO Performance (PlayerID, GameID, Hits, RunsBattedIn, BattingAverage, StolenBases, HomeRuns, Runs, AtBats) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)"
    

    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.tintColor=UIColor.white
        collectionView.dataSource = self
        collectionView.delegate = self
        db = openDB(path: prepareDatabaseFile())
        getAllTeams {
            collectionView.reloadData()
        }
        //
        //https://api.mysportsfeeds.com/v1.2/pull/mlb/2018-regular/roster_players.json?fordate=20180401&sort=team.abbr
        //
        //https://api.mysportsfeeds.com/v1.2/pull/mlb/2017-regular/roster_players.json?fordate=20170910&team=bos"
        //Players: https://api.mysportsfeeds.com/v1.2/pull/mlb/2017-regular/roster_players.json?fordate=20170910&team=bos
        //All Teams: https://api.mysportsfeeds.com/v1.2/pull/mlb/2017-regular/roster_players.json?fordate=20170910&sort=team.abbr
        //DAILY STATS:https://api.mysportsfeeds.com/v1.2/pull/mlb/2018-regular/daily_player_stats.json?fordate=20180425&playerstats=SB,RBI,AVG,H,HR,R,AB&team=bos
    }
    
    //MARK: COLLECTION VIEWS
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return teams.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StatsCell", for: indexPath) as? StatsCell {
            cell.configureCell(team: teams[indexPath.row])
            return cell
        }else{
            return UICollectionViewCell()
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    /////////////////////////////////////////////////////////////////////////////
    
    //MARK: PickerView
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return stats.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        var returnString: NSAttributedString!
            returnString = NSAttributedString(string: stats[row], attributes: [NSAttributedStringKey.foregroundColor : UIColor.white])
        return returnString
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        statsOption = stats[pickerView.selectedRow(inComponent: 0)]
        
    }
    
    
    //MARK: API CALL
    
    
    func prepareDatabaseFile() -> String {
        
       let fileName: String = "Stats.db"
        
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
    @IBAction func searchPressed(_ sender: Any) {
        getAllTeams {
            collectionView.reloadData()
        }
    }
    
    func getAllTeams(completion:()->()){
        teams.removeAll(keepingCapacity: false)
        var queryStatement: OpaquePointer? = nil
        var queryString: String?
        queryString = "SELECT Team.City, Team.Name, Team.TeamID as ID, sum(Performance.Hits) as Hits, sum(Performance.RunsBattedIn) as RunsBattedIn, sum(Performance.BattingAverage) as BattingAverage, sum(Performance.StolenBases) as StolenBases, sum(Performance.HomeRuns) as HomeRuns, sum(Performance.Runs) as Runs, sum(Performance.AtBats) as AtBats FROM Performance JOIN Player JOIN Plays_For JOIN Team on Performance.PlayerID = Player.PlayerID AND  Player.PlayerID = Plays_For.PlayerID AND Plays_For.TeamID = Team.TeamID GROUP BY Team.Name ORDER BY \(word[statsOption]!) DESC"
        
        if sqlite3_prepare_v2(db, queryString, -1, &queryStatement, nil) == SQLITE_OK {
            while(sqlite3_step(queryStatement)) == SQLITE_ROW {
                //let queryResultCol1 = sqlite3_column_int(queryStatement, 0)
                let queryResultCol1 = sqlite3_column_text(queryStatement, 0)
                let queryResultCol2 = sqlite3_column_text(queryStatement, 1)
                let teamID = sqlite3_column_int(queryStatement, 2)
                let Hits = sqlite3_column_int(queryStatement, 3)
                let RunsBattedIn = sqlite3_column_int(queryStatement, 4)
                let BattingAverage = sqlite3_column_int(queryStatement, 5)
                let Stolenbases = sqlite3_column_int(queryStatement, 6)
                let HomeRuns = sqlite3_column_int(queryStatement, 7)
                let Runs = sqlite3_column_int(queryStatement, 8)
                let AtBats = sqlite3_column_int(queryStatement, 9)
                
                let team = Team(cityName: String(cString: queryResultCol1!), teamName: String(cString: queryResultCol2!), teamID: Int(teamID), h: Int(Hits), rbi: Int(RunsBattedIn), avg: Int(BattingAverage), sb: Int(Stolenbases), hr: Int(HomeRuns), r: Int(Runs), ab: Int(AtBats))
                teams.append(team)
            }
        }else {
            print("SELECT statement could not be prepared")
        }
        // 6
        sqlite3_finalize(queryStatement)
        completion()
    }
    
    ///
    ///
    ///CODE TO INSERT DATA INTO DATABASE
    ///
    ///
    /*
    //INSERT TEAM
    func insertTeam(teamID: Int, cityName: NSString, stadium:  NSString, teamName: NSString){
        //(TeamID, City, Stadium, Name)
        var insertStatement: OpaquePointer?=nil
        if sqlite3_prepare(db, insertTeamInfo, -1, &insertStatement, nil) == SQLITE_OK {
            
            sqlite3_bind_int(insertStatement, 1, Int32(teamID))
            sqlite3_bind_text(insertStatement, 2, cityName.utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 3, stadium.utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 4, teamName.utf8String, -1, nil)
            
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
        
        sqlite3_finalize(insertStatement)
    }
    
    func deleteTableInfo(){
        var insertStatement: OpaquePointer? = nil
        var deleteString = "DELETE FROM Performance"
        if sqlite3_prepare_v2(db, deleteString , -1, &insertStatement, nil) == SQLITE_OK {
            //Check if SQL Statement is successful
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("Successfully Deleted Info")
            } else {
                print("Could not insert row.")
                let errorMessage = String.init(cString: sqlite3_errmsg(db))
                print("Query could not be prepared! \(errorMessage)")
            }
        }else {
            print("Delete Failed")
            let errorMessage = String.init(cString: sqlite3_errmsg(db))
            print("Error: \(errorMessage)")
        }
        //Check functionality
        sqlite3_finalize(insertStatement)
    }
    
    //INSERT PLAYERID with TEAMID
    func insertPlayerTeam(playerID: Int, teamID: Int){
        print("Inserting")
        var insertStatement: OpaquePointer? = nil
        if sqlite3_prepare(db, insertPlayerIDTeamID, -1, &insertStatement, nil) == SQLITE_OK {
            
            //ENTER ELEMENTS
            sqlite3_bind_int(insertStatement, 1, Int32(playerID))
            sqlite3_bind_int(insertStatement, 2, Int32(teamID))
            
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
        
        sqlite3_finalize(insertStatement)
    }
    
    //INSERT PLAYER INFO
    //"INSERT INTO Performance (PlayerID, GameID, Hits, RunsBattedIn, BattingAverage, StolenBases, HomeRuns, Runs, AtBats) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)"
    func insertStats(playerID: Int, SB: Int, RBI: Int, AVG: Int, Hits: Int, HR: Int, Runs: Int, AtBats: Int){
       var insertStatement: OpaquePointer? = nil
        var temp = 0
        if sqlite3_prepare_v2(db, insertStats , -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(insertStatement, 1, Int32(playerID))
            sqlite3_bind_int(insertStatement, 2, Int32(temp))
            sqlite3_bind_int(insertStatement, 3, Int32(Hits))
            sqlite3_bind_int(insertStatement, 4, Int32(RBI))
            sqlite3_bind_int(insertStatement, 5, Int32(AVG))
            sqlite3_bind_int(insertStatement, 6, Int32(SB))
            sqlite3_bind_int(insertStatement, 7, Int32(HR))
            sqlite3_bind_int(insertStatement, 8, Int32(Runs))
            sqlite3_bind_int(insertStatement, 9, Int32(AtBats))
            
            
            //Check if SQL Statement is successful
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("Successfully inserted row.")
            } else {
                print("Could not insert row.")
                let errorMessage = String.init(cString: sqlite3_errmsg(db))
                print("Query could not be prepared! \(errorMessage)")
            }
        }else {
            print("*INSERT statement could not be prepared*")
            let errorMessage = String.init(cString: sqlite3_errmsg(db))
            print("Error: \(errorMessage)")
        }
        //Check functionality
        sqlite3_finalize(insertStatement)
    }
    func insert(playerID: Int, FirstName: NSString, LastName: NSString, Position: NSString, JerseyNumber: Int, Age: Int, Height: NSString, Weight: NSString,completion: (Int)->()) {
        var flag = 1
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
                flag = 0
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
        completion(flag)
    }
    
    func checkingTeamID(){
        let query = "SELECT * FROM Plays_For"
        var queryStatement: OpaquePointer? = nil
        // 1
        print("Starting SLECT_________________________")
        if sqlite3_prepare_v2(db, query, -1, &queryStatement, nil) == SQLITE_OK {
            // 2
            var count = 0
            while(sqlite3_step(queryStatement)) == SQLITE_ROW {
                
                let queryResultCol1 = sqlite3_column_int(queryStatement, 0)
                let queryResultCol2 = sqlite3_column_int(queryStatement, 1)
                let Pid = Int32(queryResultCol1)
                let Tid = Int32(queryResultCol2)
                
                print("PlayerID: \(Pid)")
                print("TeamID: \(Tid)")
                count+=1
            }
            print("Count \(count)")
        } else {
            print("SELECT statement could not be prepared")
        }
        
        // 6
        sqlite3_finalize(queryStatement)
    }
    
    func getAllTeams(){
        let query = "SELECT (Name) FROM TEAM"
        var queryStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, query, -1, &queryStatement, nil) == SQLITE_OK {
            // 2
            var count = 0
            var arr = [String]()
            while(sqlite3_step(queryStatement)) == SQLITE_ROW {
                
                let queryResultCol1 = sqlite3_column_text(queryStatement, 0)
                let name = String(cString: queryResultCol1!)
                
                arr.append(name)
                print("Team: \(name)")
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        
        // 6
        sqlite3_finalize(queryStatement)

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
    
    
    func readData(){
        Alamofire.request("https://api.mysportsfeeds.com/v1.2/pull/mlb/2018-regular/roster_players.json?fordate=20180329&sort=team.abbr")
            .responseJSON { response  in
                let result = response.result
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
                                var teamID: Int?
                                var teamCityName: NSString?
                                var teamNAME: NSString?
                                var stadium:NSString = "Default"
                                
                                if let playerArr = allPlayers[index] as? Dictionary<String,Any>{
                                    //print("\(index): \(playerArr)")
                                    
                                    if let player = playerArr["player"] as? Dictionary<String,Any>{
                                        if let firstName = player["FirstName"] as? NSString {
                                            print("FirstName: \(firstName)")
                                            inputFirstName = firstName
                                        }
                                        
                                        if let lastName = player["LastName"] as? NSString{
                                            //print("LastName: \(lastName)")
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
                                    
                                    //FOR INSERTING ALL PLAYERS
                                    
                                    if let team = playerArr["team"] as? Dictionary<String,Any>{
                                        if let teamId = team["ID"] as? NSString{
                                            teamID = Int(teamId as String!)
                                        }
                                        
                                        if let city = team["City"] as? NSString{
                                            //print("City: \(city)")
                                            teamCityName = city
                                        }
                                        
                                        if let teamName = team["Name"] as? NSString{
                                            //print("Team: \(teamName)")
                                            teamNAME = teamName
                                        }
                                        
                                        if let abbrev = team["Abbreviation"] as? String{
                                            //print("Abbreviation: \(abbrev)\n")
                                        }
                                        //More code to get team info
                                        //Check if team has already been seen when inserting into SQL
                                    }
                                    
                                    //INSERT PlayerID to TeamID
                                    self.insert(playerID: inputPlayerID!,FirstName: inputFirstName!,LastName: inputLastName!,Position: inputPosition!,JerseyNumber: inputJerseyNumber, Age: inputAge,Height: inputHeight, Weight: inputWeight, completion: { (num) in
                                        if(num==0){
                                            print("Player: \(inputFirstName!)")
                                            self.insertPlayerTeam(playerID: inputPlayerID!, teamID: teamID!)
                                        }else{
                                            print("Didnt enter row")
                                        }
                                    }
                                    )
                                    
                                    
                                    //INSERT TEAMS
                                    
                                    /*
                                             if(self.teamsAdded.contains(teamNAME!)==false){
                                             self.insertTeam(teamID: teamID!, cityName: teamCityName!, stadium: stadium, teamName: teamNAME!)
                                             self.teamsAdded.insert(teamNAME!)
                                             self.nums+=1
                                             print("Teams added t;hsu far: \(self.nums)")
                                             }
                                        */
 
                                    
                                }
                            }
                        }
                    }
                }
            }
            .authenticate(user: "wais.robert", password: "Dirk1234")
    }
    
    func getStats(num: Int){
        var enter = "\(num)"
        if(num<10){
            enter = "0\(num)"
        }
        Alamofire.request("https://api.mysportsfeeds.com/v1.2/pull/mlb/2018-regular/daily_player_stats.json?fordate=201804\(enter)&playerstats=SB,RBI,AVG,H,HR,R,AB")
            .responseJSON { (response) in
                let result = response.result
                //print("Result: \(response)")
                if let dict = result.value as? Dictionary<String,Any>{
                    if let allinfo = dict["dailyplayerstats"] as? Dictionary<String,Any>{
                        if let date = allinfo["lastUpdatedOn"] as? String{
                            
                        }
                        if let playerstatsentry = allinfo["playerstatsentry"] as? [Dictionary<String,Any>]{
                            //PLAYER INFO
                            for index in 0..<playerstatsentry.count{
                                
                                var tempSB: Int?
                                var tempRBI: Int?
                                var tempAVG :Int? = 0
                                var tempHR :Int?
                                var tempH :Int?
                                var tempR :Int?
                                var tempAB :Int?
                                var tempID: Int?
                                
                                if let playerArr = playerstatsentry[index] as? Dictionary<String,Any>{
                                    if let player = playerArr["player"] as? Dictionary<String,Any>{
                                        if let playerID = player["ID"] as? NSString{
                                            print("PlayerID: \(playerID)")
                                            tempID = Int(playerID as String)
                                            //inputPlayerID = Int(playerID as String)
                                        }
                                    }
                                    //TEAM INFO
                                    if let team = playerArr["team"] as? Dictionary<String,Any>{}
                                    
                                    if let stats = playerArr["stats"] as? Dictionary<String,Any>{
                                        if let atBats = stats["AtBats"] as? Dictionary<String,Any>{
                                            if let numberAtBats = atBats["#text"] as? NSString{
                                                print("Number of AtBats: \(numberAtBats)")
                                                tempAB = Int(numberAtBats as String)
                                            }
                                        }
                                        
                                        if let runs = stats["Runs"] as? Dictionary<String,Any>{
                                            if let numberRuns = runs["#text"] as? NSString{
                                                print("Number of Runs: \(numberRuns)")
                                                tempR = Int(numberRuns as String)
                                            }
                                        }
                                        
                                        if let hits = stats["Hits"] as? Dictionary<String,Any>{
                                            if let numberHits = hits["#text"] as? NSString{
                                                print("Number of hits \(numberHits)")
                                                tempH = Int(numberHits as String)
                                            }
                                        }
                                        
                                        if let homeRuns = stats["Homeruns"] as? Dictionary<String,Any>{
                                            if let numberHomeRuns = homeRuns["#text"] as? NSString{
                                                print("Number of homeruns: \(numberHomeRuns)")
                                                tempHR = Int(numberHomeRuns as String)
                                            }
                                        }
                                        
                                        if let rbi = stats["RunsBattedIn"] as? Dictionary<String,Any>{
                                            if let numberRBI = rbi["#text"] as? NSString{
                                                print("Number of RBI: \(numberRBI)")
                                                tempRBI = Int(numberRBI as String)
                                            }
                                        }
                                        
                                        if let stolenBases = stats["StolenBases"] as? Dictionary<String,Any>{
                                            if let numberSB = stolenBases["#text"] as? NSString{
                                                print("Number of Stolen Bases \(numberSB)")
                                                tempSB = Int(numberSB as String)
                                            }
                                        }
                                        
                                        if let battingAVG = stats["BattingAvg"] as? Dictionary<String,Any>{
                                            if let numberBattingAVG = battingAVG["#text"] as? NSString{
                                                print("Batting average: \(numberBattingAVG)")
                                                //tempAVG = Int(numberBattingAVG as String)
                                            }
                                        }
                                        
                                        self.insertStats(playerID: tempID!, SB: tempSB! , RBI: tempRBI!, AVG:tempAVG!, Hits: tempH!, HR: tempHR!, Runs: tempR!, AtBats: tempAB!)
                                    }
                                }
                            }
                        }
                    }
                    
                }
            }.authenticate(user: "wais.robert", password: "Dirk1234")
    }
 */
    
}

