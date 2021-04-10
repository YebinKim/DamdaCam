//
//  HelpTableViewController.swift
//  DamdaCam
//
//  Created by 김예빈 on 2019. 4. 13..
//  Copyright © 2019년 김예빈. All rights reserved.
//

import UIKit

final class HelpTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    static var identifier: String {
        return String(describing: self)
    }
    
    @IBOutlet var navigationBar: UINavigationBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let font = Properties.shared.font.regular(15.0) else { return }
        
        navigationBar.titleTextAttributes = [NSAttributedString.Key.font: font, .foregroundColor: UIColor(named: "darkGray") ?? UIColor.darkGray]
        navigationBar.barTintColor = UIColor(named: "white")
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
    
}
