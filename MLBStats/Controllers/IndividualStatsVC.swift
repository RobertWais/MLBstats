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
    
    var pickerDataSource = [["1", "2", "3", "4"],["A","B","C"],["a","b","c","d"]];
    var stats = ["SB","RBI","AVG","H","HR","R","AB"]
    var options = ["Most","Least","Top 5"]
    var teams = ["Brewers","Atlanta","Cubs"]
    var statsOption = "SB"
    var optionsSeperator = "Most"
    var teamOption = "Brewers"
    
 
    @IBAction func searchBtnPressed(_ sender: Any) {
        print("Stat: \(statsOption)")
        print("Option: \(optionsSeperator)")
        print("Team: \(teamOption)")
        //getvalues
        
        //if option, must be stat
        if(){
        //team empty
            //SELCT * FROM player WHERE ?(stat) ?(option)
        }else if(){
        //team not empty
            //Stat and option
            //SELECT * FROM player where
            
            //just team
            //
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Team")
        collectionView.delegate = self
        collectionView.dataSource = self
        picker.delegate = self
        picker.dataSource = self
        picker.tintColor=UIColor.white
    //et db = openDB()
        // Do any additional setup after loading the view.
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
