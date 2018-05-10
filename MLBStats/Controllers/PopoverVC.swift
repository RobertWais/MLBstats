//
//  PopoverVC.swift
//  MLBStats
//
//  Created by Robert Wais on 5/3/18.
//  Copyright © 2018 Robert Wais. All rights reserved.
//

import UIKit
import SQLite3

class PopoverVC: UIViewController {
var db: OpaquePointer? = nil
    
    @IBOutlet var name: UILabel!
    @IBOutlet var jerseyNumber: UILabel!
    @IBOutlet var height: UILabel!
    @IBOutlet var weight: UILabel!
    @IBOutlet var age: UILabel!
    @IBOutlet var position: UILabel!
    
    var teamName: String?
    var PlayerID: Int?
    override func viewDidLoad() {
        super.viewDidLoad()
        db = openDB(path: prepareDatabaseFile())
        
        //Blur Effecr
        let blurEffect = UIBlurEffect(style: .regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.frame
        self.view.insertSubview(blurEffectView, at: 0)
        
        //Gesture Recognizer
        let recognizer = UITapGestureRecognizer(target: self, action:#selector(touchedSection(recognizer:)))
        self.view.addGestureRecognizer(recognizer)
        //
        selectPlayerStats()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func touchedSection(recognizer: UITapGestureRecognizer){
        dismiss(animated: true, completion: nil)
    }

    //MARK: Database connections
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
    
    //MARK: Used Queries
    func selectPlayerStats(){
        var queryStatement: OpaquePointer?
        let queryString = "SELECT  Player.FirstName, Player.LastName, Player.PlayerID, Player.Position,Player.JerseyNumber,Player.Age,Player.Height,Player.Weight FROM Player WHERE PlayerID = ?"
        
        if sqlite3_prepare_v2(db, queryString, -1, &queryStatement, nil) == SQLITE_OK {
            //Entering Elements
            sqlite3_bind_int(queryStatement, 1, Int32(PlayerID!))
            while(sqlite3_step(queryStatement)) == SQLITE_ROW {
                let queryResultCol1 = sqlite3_column_text(queryStatement, 0)
                let queryResultCol2 = sqlite3_column_text(queryStatement, 1)
                let PlayerID = sqlite3_column_int(queryStatement, 2)
                let position = sqlite3_column_text(queryStatement, 3)
                let jerseyNumber = sqlite3_column_text(queryStatement, 4)
                let age = sqlite3_column_text(queryStatement, 5)
                let height = sqlite3_column_text(queryStatement, 6)
                let weight = sqlite3_column_text(queryStatement, 7)
                
                name.text = "\(String(cString: queryResultCol1!)) \(String(cString: queryResultCol2!)) "
                self.position.text = "Position: \(String(cString: position!))"
                self.jerseyNumber.text = "#\(String(cString: jerseyNumber!))"
                self.age.text = "Age: \(String(cString: age!))"
                self.height.text = "Height: \(String(cString: height!))"
                self.weight.text = "Weight: \(String(cString: weight!))"
            }
        }else {
            print("SELECT statement could not be prepared")
        }
        sqlite3_finalize(queryStatement)
    }
    //END: Used Queries

}
