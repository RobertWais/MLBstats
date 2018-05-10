//
//  IndividualVC.swift
//  MLBStats
//
//  Created by Robert Wais on 4/5/18.
//  Copyright © 2018 Robert Wais. All rights reserved.
//

import UIKit
import SQLite3

class IndividualVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    
    
    let searchController = UISearchController(searchResultsController: nil)
    var players = [Player]()
    var filteredPlayers=[Player]()
    var db: OpaquePointer? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        
        self.tableView.tableHeaderView = searchController.searchBar
        
        ///////////
        db = openDB(path: prepareDatabaseFile())
        checkAllFavPlayers()
        tableView.delegate = self
        tableView.dataSource = self
        selectAllPlayers {
            tableView.reloadData()
        }
        // Do any additional setup after loading the view.
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //Mark: SearchBar
    
    
    
    
    //MARK: TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredPlayers.count
        }
        return players.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerCell") as? PlayerCellTVCell else{
            return UITableViewCell()
        }
        let player: Player
        if isFiltering(){
            player = filteredPlayers[indexPath.row]
        }else{
            player = players[indexPath.row]
        }
        cell.configureCell(player: player)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var arr: [Player]
        if isFiltering(){
            print("fistler")
            arr = filteredPlayers
        }else{
            print("regular")
            arr = players
            print("Arr: \(arr.count)")
        }
        let alert = UIAlertController(title: "Add Player",
                                      message: "Would you like to add \(arr[indexPath.row].firstName) \(arr[indexPath.row].lastName) to your Stars",
                                      preferredStyle: .alert)
        let submitAction = UIAlertAction(title: "Add", style: .default, handler: { (action) -> Void in
            self.checkPlayerID(playerID: arr[indexPath.row].playerID, userID: User.instance
                .userId!, completion: { (num) in
                if(num==1){
                    //Already Exists
                    print("Already there")
                    
                }else{
                    self.insertFavoritePlayer(playerID: arr[indexPath.row].playerID)
                    //Doesnt exist
                }
            })
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) -> Void in })
        alert.addAction(cancel)
        alert.addAction(submitAction)
        
        if(searchController.isActive){
            searchController.present(alert, animated: true, completion: nil)
        }else{
            self.present(alert, animated: true, completion: nil)
        }
    }
    //END: TableView
    
    //MARK: Insert queries not used in program
    func insertFavoritePlayer(playerID: Int){
        var insertStatement: OpaquePointer? = nil
        let insertString = "INSERT INTO FavoritePlayer (UserID,PlayerID) VALUES (?,?)"
        let username:NSString = User.instance.username! as NSString
        
        if sqlite3_prepare_v2(db, insertString, -1, &insertStatement, nil) == SQLITE_OK {
            //Enter username
            sqlite3_bind_int(insertStatement, 1, Int32(User.instance.userId!))
            sqlite3_bind_int(insertStatement, 2, Int32(playerID))
            
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("Successfully inserted row.")
            } else {
                print("Could not insert row.")
                let errorMessage = String.init(cString: sqlite3_errmsg(db))
                print("Query could not be prepared! \(errorMessage)")
            }
        } else {
            print("Insert statement could not be prepared")
        }
        
        // 6
        sqlite3_finalize(insertStatement)
    }
    //END: Insert queries not used in program
    
    //MARK: Used Queries
    func checkAllFavPlayers(){
        var queryStatement: OpaquePointer? = nil
        var queryString: String?
        queryString = "SELECT FavoritePlayer.UserID, FavoritePlayer.PlayerID FROM FavoritePlayer JOIN Users on FavoritePlayer.UserID = Users.UserID"
        
        if sqlite3_prepare_v2(db, queryString, -1, &queryStatement, nil) == SQLITE_OK {
            while(sqlite3_step(queryStatement)) == SQLITE_ROW {
                let queryResultCol1 = sqlite3_column_text(queryStatement, 0)
                let queryResultCol2 = sqlite3_column_text(queryStatement, 1)
                
                print("FavoritePlayerID: \(String(cString: queryResultCol1!))")
                print("USerID: \(String(cString: queryResultCol2!))")
            }
            
        }else {
            print("SELECT statement could not be prepared")
            let errorMessage = String.init(cString: sqlite3_errmsg(db))
            print("Error: \(errorMessage)")
        }
        sqlite3_finalize(queryStatement)
    }
    func checkPlayerID(playerID: Int, userID: Int, completion: (Int)->()){
        var queryStatement: OpaquePointer? = nil
        var queryString: String?
        var flag = 0
        queryString = "SELECT * FROM FavoritePlayer JOIN Users on FavoritePlayer.UserID = Users.UserID WHERE FavoritePlayer.UserID = ? AND FavoritePlayer.PlayerID = ?"
        
        if sqlite3_prepare_v2(db, queryString, -1, &queryStatement, nil) == SQLITE_OK {
            print("UserID before: \(userID)")
            print("PlayerID before: \(playerID)")
            sqlite3_bind_int(queryStatement, 1, Int32(userID))
            sqlite3_bind_int(queryStatement, 2, Int32(playerID))
            while(sqlite3_step(queryStatement)) == SQLITE_ROW {
                flag = 1
                print("Already Exists: ")
            }
            if flag == 0 {
                print("Doesn't exist")
            }
            
        }else {
            print("SELECT statement could not be prepared")
            let errorMessage = String.init(cString: sqlite3_errmsg(db))
            print("Error: \(errorMessage)")
        }
        // 6
        sqlite3_finalize(queryStatement)
        completion(flag)
    }
    
    func selectAllPlayers(completion:()->()){
        players.removeAll(keepingCapacity: false)
        var queryStatement: OpaquePointer? = nil
        var queryString: String?
        queryString = "SELECT * FROM (SELECT Player.FirstName,Player.LastName,Performance.PlayerID as ID, Performance.GameID, sum(Performance.Hits) as Hits, sum(Performance.RunsBattedIn) as RunsBattedIn, sum(Performance.BattingAverage) as BattingAverage, sum(Performance.StolenBases) as StolenBases, sum(Performance.HomeRuns) as HomeRuns, sum(Performance.Runs) as Runs, sum(Performance.AtBats) as AtBats, Team.Name as Name FROM Performance JOIN Player JOIN Plays_For JOIN Team on Performance.PlayerID = Player.PlayerID AND  Player.PlayerID = Plays_For.PlayerID AND Plays_For.TeamID = Team.TeamID GROUP BY Player.FirstName, Player.LastName)"
        
        if sqlite3_prepare_v2(db, queryString, -1, &queryStatement, nil) == SQLITE_OK {
            while(sqlite3_step(queryStatement)) == SQLITE_ROW {
                //let queryResultCol1 = sqlite3_column_int(queryStatement, 0)
                let queryResultCol1 = sqlite3_column_text(queryStatement, 0)
                let queryResultCol2 = sqlite3_column_text(queryStatement, 1)
                let PlayerID = sqlite3_column_int(queryStatement, 2)
                //let GameID = sqlite3_column_int(queryStatement, 3)
                let Hits = sqlite3_column_int(queryStatement, 4)
                let RunsBattedIn = sqlite3_column_int(queryStatement, 5)
                let BattingAverage = sqlite3_column_int(queryStatement, 6)
                let Stolenbases = sqlite3_column_int(queryStatement, 7)
                let HomeRuns = sqlite3_column_int(queryStatement, 8)
                let Runs = sqlite3_column_int(queryStatement, 9)
                let AtBats = sqlite3_column_int(queryStatement, 10)
                 let teamName = sqlite3_column_text(queryStatement, 11)
                
                let player = Player(fName: String(cString: queryResultCol1!), lName: String(cString: queryResultCol2!), playerID: Int(PlayerID), h: Int(Hits), rbi: Int(RunsBattedIn), avg: Int(BattingAverage), sb: Int(Stolenbases), hr: Int(HomeRuns), r: Int(Runs), ab: Int(AtBats),teamname: String(cString: teamName!))
                players.append(player)
            }
        }else {
            print("SELECT statement could not be prepared")
        }
        // 6
        sqlite3_finalize(queryStatement)
        completion()
    }
    //END: Used Queries
    
    
    
    
    //MARK: Database Connections
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
    //END: Database Connections
    
    
    //Mark: SearchBar helper functions
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String) {
        if searchBarIsEmpty(){
            
        }else{
            filteredPlayers = players.filter({( player : Player) -> Bool in
                return player.firstName.lowercased().contains(searchText.lowercased()) || player.lastName.lowercased().contains(searchText.lowercased())
            })
            tableView.reloadData()
        }
        
    }
    //END: SearchBar helper functions

}

//Mark: SearchBar
extension IndividualVC: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        if searchBarIsEmpty(){
            selectAllPlayers {
                tableView.reloadData()
            }
        }
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    override func pressesCancelled(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        print("Cancels")
    }
}
//END: SearchBar
