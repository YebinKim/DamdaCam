//
//  MadeByTableViewController.swift
//  DamdaCam
//
//  Created by 김예빈 on 2019. 4. 13..
//  Copyright © 2019년 김예빈. All rights reserved.
//

import UIKit

class MadeByTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    static let identifier: String = "MadeByTableViewController"
    
    @IBOutlet var navigationBar: UINavigationBar!
    
    let myLove: [String] = ["김예빈", "김지연", "안다은", "이정은", "고혜영"]
    let mySunshine: [String] = ["개발", "AR모션, 브랜딩", "UI/UX", "UI/UX", "지도교수"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let font = Properties.shared.font.regular(15.0) else { return }
        
        navigationBar.titleTextAttributes = [NSAttributedString.Key.font: font, .foregroundColor: UIColor(named: "darkGray") ?? UIColor.darkGray]
        navigationBar.barTintColor = UIColor(named: "white")
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "서울여자대학교 디지털미디어학과"
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.backgroundColor = UIColor(named: "white")
            headerView.textLabel?.font = UIFont(name: "NotoSansCJKkr-Regular", size: 15.0)
            headerView.textLabel?.textColor = UIColor(named: "lightGray")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 47
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myLove.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MadeByCell", for: indexPath)
        
        cell.textLabel!.text = myLove[indexPath.row]
        cell.textLabel!.font = UIFont(name: "NotoSansCJKkr-Regular", size: 15.0)
        cell.textLabel!.textColor = UIColor(named: "lightGray")
        
        cell.detailTextLabel!.text = mySunshine[indexPath.row]
        cell.detailTextLabel!.font = UIFont(name: "NotoSansCJKkr-Regular", size: 10.0)
        cell.detailTextLabel!.textColor = UIColor(named: "lightGray")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 47
    }
    
    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

}
