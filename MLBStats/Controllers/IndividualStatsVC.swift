//
//  TeamVC.swift
//  MLBStats
//
//  Created by Robert Wais on 4/5/18.
//  Copyright © 2018 Robert Wais. All rights reserved.
//

import UIKit
import SQLite3
class IndividualStatsVC: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource,UICollectionViewDelegate, UICollectionViewDataSource{
  
    
    @IBOutlet var searchBtn: UIButton!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var picker: UIPickerView!
    let queryStatementString = "SELECT PlayerID, FirstName, LastName, Position, JerseyNumber, Age, Height, Weight FROM Player"
    
    private var players = [Player]()
    private var word: [String:String] = ["SB":"StolenBases","RBI":"RunsBattedIn","AVG":"BattingAverage","H":"Hits","HR":"HomeRuns","R":"Runs","AB":"AtBats"]
    private var db: OpaquePointer? = nil
    private var pickerDataSource = [["1", "2", "3", "4"],["A","B","C"],["a","b","c","d"]];
    private var stats = ["SB","RBI","H","HR","R","AB"]
    private var options = ["Most","Least","Top 5"]
    private var teams = ["Orioles","Blue Jays","Red Sox","Yankees","Rays","Indians","Tigers","Royals","White Sox","Twins","Rangers","Astros","Mariners","Angels","Athletics","Nationals","Mets","Marlins","Phillies","Braves","Cubs","Pirates","Cardinals","Brewers","Reds","Giants","Dodgers","Rockies","Padres","Diamondbacks"]
    private var statsOption = "SB"
    private var optionsSeperator = "Most"
    private var teamOption = "Stars"
    private var tempID: Int?
    private var teamName: String?
    
    //Action for Search Button Presses
    @IBAction func searchBtnPressed(_ sender: Any) {
        print("Stat: \(statsOption)")
        print("Option: \(optionsSeperator)")
        print("Team: \(teamOption)")
        //getvalues
        //selectPlayerStats()
        //selectNonTeamStats(type: "Most", attribute: statsOption, option: optionsSeperator)
        if(teamOption=="Stars"){
            selectStarsStats(type: "Most", attribute: statsOption, option: optionsSeperator)
            collectionView.reloadData()
        }else if(teamOption=="-"){
            selectNonTeamStats(type: "Most", attribute: statsOption, option: optionsSeperator)
            collectionView.reloadData()
        }else{
            selectTeamStats(type: "Most", attribute: statsOption, option: optionsSeperator)
            collectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        teams.sort()
        teams.insert("-", at:0)
        teams.insert("Stars",at:0)
        collectionView.delegate = self
        collectionView.dataSource = self
        picker.delegate = self
        picker.dataSource = self
        picker.tintColor=UIColor.white
        //DB handling
        db = openDB(path: prepareDatabaseFile())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: SEGUES
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "displayInfo"){
            let vc = segue.destination as! PopoverVC
            vc.PlayerID = tempID
            vc.teamName = self.teamName
        }
    }
    //END: SEGUES
    
    //MARK: PICKER VIEW
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0{
            return stats.count;
        }else if component == 1 {
            return options.count;
        }else{
            return teams.count;
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        var returnString: NSAttributedString!
        switch component {
        case 0:
            returnString = NSAttributedString(string: stats[row], attributes: [NSAttributedStringKey.foregroundColor : UIColor.white])
        case 1:
            returnString = NSAttributedString(string: options[row], attributes: [NSAttributedStringKey.foregroundColor : UIColor.white])
        case 2:
            returnString = NSAttributedString(string: teams[row], attributes: [NSAttributedStringKey.foregroundColor : UIColor.white])
        default:
            returnString = NSAttributedString(string: "?", attributes: [NSAttributedStringKey.foregroundColor : UIColor.white])
            
        }
        return returnString
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        statsOption = stats[picker.selectedRow(inComponent: 0)]
        optionsSeperator = options[picker.selectedRow(inComponent: 1)]
        teamOption = teams[picker.selectedRow(inComponent: 2)]
        
        
        print("Selected: 1:\(stats[picker.selectedRow(inComponent: 0)]) 2:\(options[picker.selectedRow(inComponent: 1)]) 3:\(teams[picker.selectedRow(inComponent: 2)])")
    }
    //END: PickerView
    
    //MARK: COLLECTION VIEW
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return players.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StatsCell", for: indexPath) as? StatsCell {
            cell.configureCell(player: players[indexPath.row])
            print("Creating cell")
            return cell
        }else{
            return UICollectionViewCell()
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        tempID = players[indexPath.row].playerID
        teamName = players[indexPath.row].teamName
        self.performSegue(withIdentifier: "displayInfo", sender: self)
    }
    //END: COLLECTION VIEW
    
    //Mark: TEST QUERIES
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
                count+=1
            }
            print("Count \(count)")
        } else {
            print("SELECT statement could not be prepared")
        }
        
        // 6
        sqlite3_finalize(queryStatement)
    }
    
    func selectPlayerStats(){
        print("Checking indy Stats")
        var queryStatement: OpaquePointer?
        let name:NSString = "Harper"
        let queryString = "SELECT Player.FirstName, Player.LastName, Performance.PlayerID, Performance.GameID, Performance.Hits, Performance.RunsBattedIn, Performance.BattingAverage, Performance.StolenBases, Performance.HomeRuns, Performance.Runs, Performance.AtBats  FROM Player JOIN Performance on Player.PlayerID = Performance.PlayerID GROUP BY Player.FirstName, Player.LastName HAVING Player.LastName = ?"
        
        if sqlite3_prepare_v2(db, queryString, -1, &queryStatement, nil) == SQLITE_OK {
            //Entering Elements
            sqlite3_bind_text(queryStatement, 1, name.utf8String, -1, nil)
            while(sqlite3_step(queryStatement)) == SQLITE_ROW {
                let queryResultCol1 = sqlite3_column_text(queryStatement, 0)
                let queryResultCol2 = sqlite3_column_text(queryStatement, 1)
                let PlayerID = sqlite3_column_int(queryStatement, 2)
                let GameID = sqlite3_column_int(queryStatement, 3)
                let Hits = sqlite3_column_int(queryStatement, 4)
                let RunsBattedIn = sqlite3_column_int(queryStatement, 5)
                let BattingAverage = sqlite3_column_int(queryStatement, 6)
                let Stolenbases = sqlite3_column_int(queryStatement, 7)
                let HomeRuns = sqlite3_column_int(queryStatement, 8)
                let Runs = sqlite3_column_int(queryStatement, 9)
                let AtBats = sqlite3_column_int(queryStatement, 10)
            }
        }else {
            print("SELECT statement could not be prepared")
        }
        
        // 6
        sqlite3_finalize(queryStatement)
    }
    //END: Test Queries
    
    //MARK: Used Queries
    //Subquery
    //OrderBy
    //Aggregate
    func selectStarsStats(type: String, attribute: String, option: String){
        print("Stars")
        players.removeAll(keepingCapacity: false)
        var queryStatement: OpaquePointer? = nil
        var delimeter: String?
        if(option=="Most"){
            delimeter = "DESC"
        }else if (option=="Least"){
            delimeter = "ASC"
        }else{
            delimeter = "DESC LIMIT 5"
        }
        //case loop to decise string
        var queryString: String?
        
        queryString = "SELECT * FROM (SELECT Player.FirstName, Player.LastName , Performance.PlayerID as ID, Performance.GameID, sum(Performance.Hits) as Hits, sum(Performance.RunsBattedIn) as RunsBattedIn, sum(Performance.BattingAverage) as BattingAverage, sum(Performance.StolenBases) as StolenBases, sum(Performance.HomeRuns) as HomeRuns, sum(Performance.Runs) as Runs, sum(Performance.AtBats) as AtBats, sum(\(word[attribute]!)), Team.Name as Name, FavoritePlayer.UserID as UserID FROM Performance JOIN Player JOIN Plays_For JOIN Team JOIN FavoritePlayer on Performance.PlayerID = Player.PlayerID AND  Player.PlayerID = Plays_For.PlayerID AND Plays_For.TeamID = Team.TeamID AND FavoritePlayer.PlayerID = Player.PlayerID GROUP BY Player.FirstName, Player.LastName) WHERE UserID = ? ORDER BY \(word[attribute]!) \(delimeter!)"
        
        if sqlite3_prepare_v2(db, queryString, -1, &queryStatement, nil) == SQLITE_OK {
            //ATTEMPTS
            sqlite3_bind_int(queryStatement, 1, Int32(User.instance.userId!))
            while(sqlite3_step(queryStatement)) == SQLITE_ROW {
                //let queryResultCol1 = sqlite3_column_int(queryStatement, 0)
                let queryResultCol1 = sqlite3_column_text(queryStatement, 0)
                let queryResultCol2 = sqlite3_column_text(queryStatement, 1)
                let PlayerID = sqlite3_column_int(queryStatement, 2)
                let GameID = sqlite3_column_int(queryStatement, 3)
                let Hits = sqlite3_column_int(queryStatement, 4)
                let RunsBattedIn = sqlite3_column_int(queryStatement, 5)
                let BattingAverage = sqlite3_column_int(queryStatement, 6)
                let Stolenbases = sqlite3_column_int(queryStatement, 7)
                let HomeRuns = sqlite3_column_int(queryStatement, 8)
                let Runs = sqlite3_column_int(queryStatement, 9)
                let AtBats = sqlite3_column_int(queryStatement, 10)
                //let sum = sqlite3_column_int(queryStatement, 11)
                let teamName = sqlite3_column_text(queryStatement, 12)
                
                let player = Player(fName: String(cString: queryResultCol1!), lName: String(cString: queryResultCol2!), playerID: Int(PlayerID), h: Int(Hits), rbi: Int(RunsBattedIn), avg: Int(BattingAverage), sb: Int(Stolenbases), hr: Int(HomeRuns), r: Int(Runs), ab: Int(AtBats),teamname: String(cString: teamName!))
                players.append(player)
            }
        }else {
            print("SELECT statement could not be prepared")
        }
        // 6
        sqlite3_finalize(queryStatement)
    }
    
    //Subquery
    //OrderBy
    //Aggregate
    func selectTeamStats(type: String, attribute: String, option: String){
        players.removeAll(keepingCapacity: false)
        var queryStatement: OpaquePointer? = nil
        var delimeter: String?
        if(option=="Most"){
            delimeter = "DESC"
        }else if (option=="Least"){
            delimeter = "ASC"
        }else{
            delimeter = "DESC LIMIT 5"
        }
        //case loop to decise string
        var queryString: String?
        let name:NSString = teamOption as NSString
        queryString = "SELECT * FROM (SELECT Player.FirstName, Player.LastName , Performance.PlayerID as ID, Performance.GameID, sum(Performance.Hits) as Hits, sum(Performance.RunsBattedIn) as RunsBattedIn, sum(Performance.BattingAverage) as BattingAverage, sum(Performance.StolenBases) as StolenBases, sum(Performance.HomeRuns) as HomeRuns, sum(Performance.Runs) as Runs, sum(Performance.AtBats) as AtBats, sum(\(word[attribute]!)), Team.Name as Name FROM Performance JOIN Player JOIN Plays_For JOIN Team on Performance.PlayerID = Player.PlayerID AND  Player.PlayerID = Plays_For.PlayerID AND Plays_For.TeamID = Team.TeamID GROUP BY Player.FirstName, Player.LastName) WHERE Name = ? ORDER BY \(word[attribute]!) \(delimeter!)"
        
        if sqlite3_prepare_v2(db, queryString, -1, &queryStatement, nil) == SQLITE_OK {
            //ATTEMPTS
            sqlite3_bind_text(queryStatement, 1, name.utf8String, -1, nil)
            while(sqlite3_step(queryStatement)) == SQLITE_ROW {
                //let queryResultCol1 = sqlite3_column_int(queryStatement, 0)
                let queryResultCol1 = sqlite3_column_text(queryStatement, 0)
                let queryResultCol2 = sqlite3_column_text(queryStatement, 1)
                let PlayerID = sqlite3_column_int(queryStatement, 2)
                let GameID = sqlite3_column_int(queryStatement, 3)
                let Hits = sqlite3_column_int(queryStatement, 4)
                let RunsBattedIn = sqlite3_column_int(queryStatement, 5)
                let BattingAverage = sqlite3_column_int(queryStatement, 6)
                let Stolenbases = sqlite3_column_int(queryStatement, 7)
                let HomeRuns = sqlite3_column_int(queryStatement, 8)
                let Runs = sqlite3_column_int(queryStatement, 9)
                let AtBats = sqlite3_column_int(queryStatement, 10)
                let sum = sqlite3_column_int(queryStatement, 11)
                let teamName = sqlite3_column_text(queryStatement, 12)
               
                let player = Player(fName: String(cString: queryResultCol1!), lName: String(cString: queryResultCol2!), playerID: Int(PlayerID), h: Int(Hits), rbi: Int(RunsBattedIn), avg: Int(BattingAverage), sb: Int(Stolenbases), hr: Int(HomeRuns), r: Int(Runs), ab: Int(AtBats), teamname: String(cString: teamName!))
                players.append(player)
            }
        }else {
            print("SELECT statement could not be prepared")
        }
        sqlite3_finalize(queryStatement)
    }
    
    //Subquery
    //OrderBy
    //Aggregate
    //GroupBy
    func selectNonTeamStats(type: String, attribute: String, option: String){
        players.removeAll(keepingCapacity: false)
        var queryStatement: OpaquePointer? = nil
        var delimeter: String?
        if(option=="Most"){
            delimeter = "DESC"
        }else if (option=="Least"){
            delimeter = "ASC"
        }else{
            delimeter = "DESC LIMIT 5"
        }
        //case loop to decise string
        var queryString: String?
        queryString = "SELECT Player.FirstName, Player.LastName, Performance.PlayerID, Performance.GameID, sum(Performance.Hits), sum(Performance.RunsBattedIn), sum(Performance.BattingAverage), sum(Performance.StolenBases), sum(Performance.HomeRuns), sum(Performance.Runs), sum(Performance.AtBats), sum(\(word[attribute]!)) , Team.Name as Name FROM Performance JOIN Player JOIN Plays_For JOIN Team on Performance.PlayerID = Player.PlayerID AND  Player.PlayerID = Plays_For.PlayerID AND Plays_For.TeamID = Team.TeamID GROUP BY Player.FirstName, Player.LastName ORDER BY sum(\(word[attribute]!)) \(delimeter!)"
        
        if sqlite3_prepare_v2(db, queryString, -1, &queryStatement, nil) == SQLITE_OK {
            while(sqlite3_step(queryStatement)) == SQLITE_ROW {
                //let queryResultCol1 = sqlite3_column_int(queryStatement, 0)
                let queryResultCol1 = sqlite3_column_text(queryStatement, 0)
                let queryResultCol2 = sqlite3_column_text(queryStatement, 1)
                let PlayerID = sqlite3_column_int(queryStatement, 2)
                let GameID = sqlite3_column_int(queryStatement, 3)
                let Hits = sqlite3_column_int(queryStatement, 4)
                let RunsBattedIn = sqlite3_column_int(queryStatement, 5)
                let BattingAverage = sqlite3_column_int(queryStatement, 6)
                let Stolenbases = sqlite3_column_int(queryStatement, 7)
                let HomeRuns = sqlite3_column_int(queryStatement, 8)
                let Runs = sqlite3_column_int(queryStatement, 9)
                let AtBats = sqlite3_column_int(queryStatement, 10)
                let sum = sqlite3_column_int(queryStatement, 11)
                let teamName = sqlite3_column_text(queryStatement, 12)
                
                let player = Player(fName: String(cString: queryResultCol1!), lName: String(cString: queryResultCol2!), playerID: Int(PlayerID), h: Int(Hits), rbi: Int(RunsBattedIn), avg: Int(BattingAverage), sb: Int(Stolenbases), hr: Int(HomeRuns), r: Int(Runs), ab: Int(AtBats), teamname: String(cString: teamName!))
                players.append(player)
            }
        }else {
            print("SELECT statement could not be prepared")
        }
        // 6
        sqlite3_finalize(queryStatement)
    }
    //END: Used Queries
    
    //DATABASE CONNECTIONS
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
    //END: Database Connections
 

}
