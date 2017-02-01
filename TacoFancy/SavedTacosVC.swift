//
//  SavedTacosVC.swift
//  TacoFancy
//
//  Created by Rebekah Baker on 2/1/17.
//  Copyright © 2017 Rebekah Baker. All rights reserved.
//

import UIKit
import Firebase

class SavedTacosVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var savedTacos = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
        
        downloadSavedTacos()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedTacos.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SavedTacoCell") as? SavedTacosCell
        cell?.tacoName.text = savedTacos[indexPath.row]
        return cell!
    }
    
    func downloadSavedTacos() {
        DataService.ds.REF_CURRENT_USER.child("saved-tacos").observe( .value, with: { (snapshot) in
           self.savedTacos = []
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    let taco = snap.key
                    self.savedTacos.append(taco)
                }
            }
            if self.savedTacos.count > 0 {
                self.tableView.reloadData()
            }
        })
    }
}
