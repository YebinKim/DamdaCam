//
//  SettingTableViewController.swift
//  DamdaCam
//
//  Created by 김예빈 on 2019. 4. 13..
//  Copyright © 2019년 김예빈. All rights reserved.
//

import UIKit

class SettingTableViewController: UITableViewController {

    static let identifier: String = "SettingTableViewController"
    
    let numSection: [Int] = [2, 2, 5]
    @IBOutlet var timerLabel: UILabel!
    @IBOutlet var ratioLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if previewSize == 0 {
            ratioLabel.text = "와이드"
        } else if previewSize == 1 {
            ratioLabel.text = "1:1"
        } else if previewSize == 2 {
            ratioLabel.text = "3:4"
        }

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
//        self.navigationController?.navigationBar.frame = CGRect(x: 0, y: 0, width: 375, height: 47.5)
        self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "NotoSansCJKkr-Regular", size: 15.0)!, .foregroundColor: Properties.shared.color.darkGray]
        self.navigationController!.navigationBar.barTintColor = Properties.shared.color.white
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        return numSection[section]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         tableView.deselectRow(at: indexPath, animated: true)
        
//        if indexPath.section == 0 && indexPath.row == 0 {
//            if timerLabel.text == "OFF" {
//                timerLabel.text = "3s"
//            } else if timerLabel.text == "3s" {
//                timerLabel.text = "5s"
//            } else if timerLabel.text == "5s" {
//                timerLabel.text = "10s"
//            } else if timerLabel.text == "10s" {
//                timerLabel.text = "OFF"
//            }
//        }
        
        if indexPath.section == 0 && indexPath.row == 1 {
            if previewSize == 0 {
                ratioLabel.text = "1:1"
                    
                previewSize = 1
            } else if previewSize == 1 {
                ratioLabel.text = "3:4"
                    
                previewSize = 2
            } else if previewSize == 2 {
                ratioLabel.text = "와이드"
                    
                previewSize = 0
            }
        }
    }
    
    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }


//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "SetUpCell", for: indexPath)
//
//        cell.textLabel?.text = "Section \(indexPath.section) Row \(indexPath.row)"
//
//        return cell
//    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
