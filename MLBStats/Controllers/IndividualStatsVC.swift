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

    
    var db: OpaquePointer? = nil
    var pickerDataSource = [["1", "2", "3", "4"],["A","B","C"],["a","b","c","d"]];
    var stats = ["SB","RBI","AVG","H","HR","R","AB"]
    var options = ["Most","Least","Top 5"]
    var teams = ["Orioles","Blue Jays","Red Sox","Yankees","Rays","Indians","Tigers","Royals","White Sox","Twins","Rangers","Astros","Mariners","Angels","Athletics","Nationals","Mets","Marlins","Phillies","Braves","Cubs","Pirates","Cardinals","Brewers","Reds","Giants",    "Dodgers","Rockies","Padres","Diamondbacks"]
    var statsOption = "SB"
    var optionsSeperator = "Most"
    var teamOption = "Brewers"
    
 
    @IBAction func searchBtnPressed(_ sender: Any) {
        print("Stat: \(statsOption)")
        print("Option: \(optionsSeperator)")
        print("Team: \(teamOption)")
        //getvalues
        selectNonTeamStats(type: "Most", attribute: "Hits")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        teams.sort()
        teams.insert("-", at:0)
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
    
    
    //MARK: COLLECTION VIEW
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StatsCell", for: indexPath) as? StatsCell {
            cell.configureCell(fName: "Bob", lName: "Wais", hits: "12")
            print("Creating cel")
            return cell
        }else{
            return UICollectionViewCell()
        }
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    
    
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
    
    
    func selectNonTeamStats(type: String, attribute: NSString){
        print("Attempt")
        var queryStatement: OpaquePointer? = nil
        //case loop to decise string
        var queryString: String?
        queryString = "SELECT Player.FirstName, Player.LastName, Performance.Hits FROM Player JOIN Performance on Player.PlayerID = Performance.PlayerID ORDER BY (?)"
        
        if sqlite3_prepare_v2(db, queryString, -1, &queryStatement, nil) == SQLITE_OK {
                //Entering Elements
            sqlite3_bind_text(queryStatement, 1, attribute.utf8String, -1, nil)
            
            
            while(sqlite3_step(queryStatement)) == SQLITE_ROW {
                
                //let queryResultCol1 = sqlite3_column_int(queryStatement, 0)
                let queryResultCol1 = sqlite3_column_text(queryStatement, 0)
                let queryResultCol2 = sqlite3_column_text(queryStatement, 1)
                let queryResultCol3 = sqlite3_column_int(queryStatement, 2)
                let hits = Int32(queryResultCol3)
                let FirstName = String(cString: queryResultCol1!)
                let LastName = String(cString: queryResultCol2!)
                
                print("FirstName: \(FirstName) \(LastName) \(hits)")
                
            }
        }else {
            print("SELECT statement could not be prepared")
        }
        
        // 6
        sqlite3_finalize(queryStatement)
    }
    
    //DATABASE STUFF
    
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
        
        print("In prepareDatabase")
        let fileName: String = "MLBstatsFinal.db"
        
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
 

}