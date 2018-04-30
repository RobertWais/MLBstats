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
        ///////////
       
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        self.tableView.tableHeaderView = searchController.searchBar
        
        // Setup the Scope Bar
        
        
        ///////////
        db = openDB(path: prepareDatabaseFile())
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
                                      message: "Would you like to add \(arr[indexPath.row]._firstName!) \(arr[indexPath.row]._lastName!) to your Stars",
                                      preferredStyle: .alert)
        let submitAction = UIAlertAction(title: "Add", style: .default, handler: { (action) -> Void in
            // Get 1st TextField's text
           print("Yes")
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
    //MARK: Queries
    
    func selectAllPlayers(completion:()->()){
        var queryStatement: OpaquePointer? = nil
        var queryString: String?
        queryString = "SELECT * FROM (SELECT Player.FirstName,Player.LastName,Performance.PlayerID as ID, Performance.GameID, sum(Performance.Hits) as Hits, sum(Performance.RunsBattedIn) as RunsBattedIn, sum(Performance.BattingAverage) as BattingAverage, sum(Performance.StolenBases) as StolenBases, sum(Performance.HomeRuns) as HomeRuns, sum(Performance.Runs) as Runs, sum(Performance.AtBats) as AtBats, Team.Name as Name FROM Performance JOIN Player JOIN Plays_For JOIN Team on Performance.PlayerID = Player.PlayerID AND  Player.PlayerID = Plays_For.PlayerID AND Plays_For.TeamID = Team.TeamID GROUP BY Player.FirstName, Player.LastName)"
        
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
                //let sum = sqlite3_column_int(queryStatement, 11)
                //let queryResultCol13 = sqlite3_column_text(queryStatement, 12)
                print("CHecking: \(Hits)")
                
                let player = Player(fName: String(cString: queryResultCol1!), lName: String(cString: queryResultCol2!), playerID: Int(PlayerID), h: Int(Hits), rbi: Int(RunsBattedIn), avg: Int(BattingAverage), sb: Int(Stolenbases), hr: Int(HomeRuns), r: Int(Runs), ab: Int(AtBats))
                players.append(player)
            }
        }else {
            print("SELECT statement could not be prepared")
        }
        // 6
        sqlite3_finalize(queryStatement)
        completion()
    }
    
    
    
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
    
    
    //SearchBar
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
                return player._firstName!.lowercased().contains(searchText.lowercased()) || player._lastName!.lowercased().contains(searchText.lowercased())
            })
            tableView.reloadData()
        }
        
    }

}

extension IndividualVC: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        // TODO
        print("here---------")
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
