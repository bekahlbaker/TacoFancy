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
    var tacoNameToPass: String!
    var hasSavedTacos = false
    
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
        if hasSavedTacos {
            return self.savedTacos.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SavedTacoCell") as? SavedTacosCell
        if hasSavedTacos {
            cell?.tacoName.text = savedTacos[indexPath.row]
        } else {
            tableView.isUserInteractionEnabled = false
            cell?.tacoName.textAlignment = .center
            cell?.tacoName.text = "You haven't saved any tacos yet! :( \nWhat are you waiting for?"
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if hasSavedTacos {
            let cellValue = savedTacos[indexPath.row]
            self.tacoNameToPass = cellValue
            if self.tacoNameToPass != nil {
                performSegue(withIdentifier: "RecipeVC", sender: nil)
            }
        } else {
            print("No tacos")
        }
    }
    
    func downloadSavedTacos() {
        DataService.ds.REF_CURRENT_USER.child("saved-tacos").observe( .value, with: { (snapshot) in
           self.savedTacos = []
            if let _ = snapshot.value as? NSNull {
                print("No Tacos saved")
                self.hasSavedTacos = false
            } else{
                self.hasSavedTacos = true
                if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                    for snap in snapshot {
                        let taco = snap.key
                        self.savedTacos.append(taco)
                    }
                }
            }
            self.tableView.reloadData()
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "RecipeVC" {
            let myVC = segue.destination as? RecipeVC
            myVC?.tacoNamePassed = self.tacoNameToPass
        }
    }
}
