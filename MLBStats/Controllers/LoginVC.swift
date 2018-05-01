//
//  LoginVC.swift
//  MLBStats
//
//  Created by Robert Wais on 5/1/18.
//  Copyright © 2018 Robert Wais. All rights reserved.
//

import UIKit
import SQLite3

class LoginVC: UIViewController {
    @IBOutlet var usernameLbl: UILabel!
    var db: OpaquePointer? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = openDB(path: prepareDatabaseFile())

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func signInAction(_ sender: Any) {
        getUserName()
    }
    
    func getUserName(){
        let query = "SELECT FavoritePlayer.PlayerID FROM User JOIN FavoritePlayer on User.UserID = FavoritePlayer.UserID WHERE User.Username = ?"
        var queryStatement: OpaquePointer? = nil
        var username: NSString = usernameLbl.text! as NSString
        // 1
        print("Starting SLECT_________________________")
        if sqlite3_prepare_v2(db, query, -1, &queryStatement, nil) == SQLITE_OK {
            //Enter username
           sqlite3_bind_text(queryStatement, 1, username.utf8String, -1, nil)
            while(sqlite3_step(queryStatement)) == SQLITE_ROW {
                
                let queryResultCol1 = sqlite3_column_int(queryStatement, 0)
                let PlayerID = Int32(queryResultCol1)
                print("Player ID's: \(PlayerID)")
                
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        
        // 6
        sqlite3_finalize(queryStatement)
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

}
