//
//  HelpTableViewController.swift
//  DamdaCam
//
//  Created by 김예빈 on 2019. 4. 13..
//  Copyright © 2019년 김예빈. All rights reserved.
//

import UIKit

class HelpTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    static let identifier: String = "HelpTableViewController"
    
    @IBOutlet var navigationBar: UINavigationBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let font = Properties.shared.font.regular(15.0) else { return }
        
        navigationBar.titleTextAttributes = [NSAttributedString.Key.font: font, .foregroundColor: Properties.shared.color.darkGray]
        navigationBar.barTintColor = Properties.shared.color.white
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HelpCell", for: indexPath)
        
        return cell
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
