//
//  TeamVC.swift
//  MLBStats
//
//  Created by Robert Wais on 4/5/18.
//  Copyright © 2018 Robert Wais. All rights reserved.
//

import UIKit
import SQLite3
class TeamVC: UIViewController {
let path = Bundle.main.path(forResource: "MLBstats", ofType: ".db", inDirectory: "Shared")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Team")
        let db = openDB()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func openDB()->OpaquePointer? {
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
