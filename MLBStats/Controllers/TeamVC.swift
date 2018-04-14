//
//  TeamVC.swift
//  MLBStats
//
//  Created by Robert Wais on 4/5/18.
//  Copyright © 2018 Robert Wais. All rights reserved.
//

import UIKit
import SQLite3
class TeamVC: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource {
    @IBOutlet var picker: UIPickerView!
    
    var pickerDataSource = [["1", "2", "3", "4"],["A","B","C"],["a","b","c","d"]];
    var stats = ["SB","RBI","AVG","H","HR","R","AB"]
    var options = ["Most","Least","Top 5"]
    var teams = ["Brewers","Atlanta","Cubs"]
    
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
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        
        switch component {
        case 0:
            return stats[row]
        case 1:
            return options[row]
        case 2:
            return teams[row]
        default:
            return "?"
            
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        
        print("Selected: 1:\(picker.selectedRow(inComponent: 0)) 2:\(picker.selectedRow(inComponent: 1)) 3:\(picker.selectedRow(inComponent: 2).description)")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Team")
        picker.delegate = self
        picker.dataSource = self
    //et db = openDB()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    /*
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
 */
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
