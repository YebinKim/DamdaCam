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
        
        guard let font = Properties.shared.font.regular(15.0) else { return }
        
        self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: font, .foregroundColor: Properties.shared.color.darkGray]
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
    
}
