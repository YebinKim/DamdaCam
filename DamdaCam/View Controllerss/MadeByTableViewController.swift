//
//  MadeByTableViewController.swift
//  DamdaCam
//
//  Created by 김예빈 on 2019. 4. 13..
//  Copyright © 2019년 김예빈. All rights reserved.
//

import UIKit

class MadeByTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var navigationBar: UINavigationBar!
    
    let myLove: [String] = ["김예빈", "김지연", "안다은", "이정은", "고혜영"]
    let mySunshine:[String] = ["개발", "AR모션, 브랜딩", "UI/UX", "UI/UX", "지도교수"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "NotoSansCJKkr-Regular", size: 15.0)!, .foregroundColor: UIColor(red: 84.0/255.0, green: 84.0/255.0, blue: 84.0/255.0, alpha: 1.0)]
        navigationBar.barTintColor = UIColor.white
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int{
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "서울여자대학교 디지털미디어학과"
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.backgroundColor = UIColor.white
            headerView.textLabel?.font = UIFont(name: "NotoSansCJKkr-Regular", size: 15.0)
            headerView.textLabel?.textColor = UIColor(red: 112.0/255.0, green: 112.0/255.0, blue: 112.0/255.0, alpha: 1.0)
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
        cell.textLabel!.textColor = UIColor(red: 112.0/255.0, green: 112.0/255.0, blue: 112.0/255.0, alpha: 1.0)
        
        cell.detailTextLabel!.text = mySunshine[indexPath.row]
        cell.detailTextLabel!.font = UIFont(name: "NotoSansCJKkr-Regular", size: 10.0)
        cell.detailTextLabel!.textColor = UIColor(red: 112.0/255.0, green: 112.0/255.0, blue: 112.0/255.0, alpha: 1.0)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 47
    }
    
    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
