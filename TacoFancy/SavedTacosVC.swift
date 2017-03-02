//
//  SavedTacosVC.swift
//  TacoFancy
//
//  Created by Rebekah Baker on 2/1/17.
//  Copyright © 2017 Rebekah Baker. All rights reserved.
//

import UIKit
import Firebase
import QuartzCore

class SavedTacosVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!

    @IBOutlet weak var savedTacosOnboard: UIView!
    @IBAction func tacosGotItBtnTapped(_ sender: Any) {
        savedTacosOnboard.isHidden = true
        tableView.reloadData()
    }
    
    func checkForHasOpenedTacosOnce() {
        if(UserDefaults.standard.bool(forKey: "HasOpenedTacosOnce")) {
            print("NOT first launch")
            savedTacosOnboard.isHidden = true
        }
        else {
            print("FIRST launch")
            UserDefaults.standard.set(true, forKey: "HasOpenedTacosOnce")
            UserDefaults.standard.synchronize()
            savedTacosOnboard.isHidden = false
        }
    }
    
    @IBOutlet weak var searchBar: UISearchBar!

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBAction func segmentedIndexChanged(_ sender: Any) {
        switch segmentedControl.selectedSegmentIndex
        {
        case 0:
            print("Saved")
            downloadSavedTacos()
            if inSearchMode {
                searchBar(searchBar, textDidChange: searchBar.text!)
            }
        case 1:
            print("Ingredients")
            downloadSavedIngredients()
            if inSearchMode {
                searchBar(searchBar, textDidChange: searchBar.text!)
            }
        case 2:
            print("Created")
            downloadCreatedTacos()
            if inSearchMode {
                searchBar(searchBar, textDidChange: searchBar.text!)
            }
        default:
            break
        }
    }
    
    var savedTacos = [String]()
    var createdTacos = [String]()
    var savedIngredients = [String]()
    var tacoNameToPass: String!
    var tacoTypeToPass: String!
    var ingredientNameToPass: String!
    var hasSavedTacos = true
    var hasSavedIngredients = true
    var hasCreatedTacos = true
    var filteredSavedTacos = [String]()
    var filteredSavedIngredients = [String]()
    var filteredCreatedTacos = [String]()
    var inSearchMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activitySpinner.startAnimating()
        savedTacosOnboard.isHidden = true
        checkForHasOpenedTacosOnce()
        
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        tableView.contentOffset = CGPoint(x: 0.0, y: 44)
        
        downloadSavedTacos()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch segmentedControl.selectedSegmentIndex
        {
        case 0:
            if hasSavedTacos {
                if inSearchMode {
                    return filteredSavedTacos.count
                }
                return self.savedTacos.count
            }
        case 1:
            if hasSavedIngredients {
                if inSearchMode {
                    return filteredSavedIngredients.count
                }
                return self.savedIngredients.count
            }
        case 2:
            if hasCreatedTacos {
                if inSearchMode {
                    return filteredCreatedTacos.count
                }
                return createdTacos.count
            }
        default:
            break
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SavedTacoCell") as? SavedTacosCell
        switch segmentedControl.selectedSegmentIndex
        {
        case 0:
            if hasSavedTacos {
                if inSearchMode {
                    tableView.isUserInteractionEnabled = true
                    cell?.tacoName.textAlignment = .left
                    cell?.tacoName.text = filteredSavedTacos[indexPath.row]
                } else {
                    tableView.isUserInteractionEnabled = true
                    cell?.tacoName.textAlignment = .left
                    cell?.tacoName.text = savedTacos[indexPath.row]
                }
            } else {
                tableView.isUserInteractionEnabled = false
                cell?.tacoName.textAlignment = .center
                cell?.tacoName.text = "You haven't saved any tacos yet! :( \nWhat are you waiting for?"
            }
        case 1:
            if hasSavedIngredients {
                if inSearchMode {
                    tableView.isUserInteractionEnabled = true
                    cell?.tacoName.textAlignment = .left
                    cell?.tacoName.text = filteredSavedIngredients[indexPath.row]
                } else {
                    tableView.isUserInteractionEnabled = true
                    cell?.tacoName.textAlignment = .left
                    cell?.tacoName.text = savedIngredients[indexPath.row]
                }
            } else {
                tableView.isUserInteractionEnabled = false
                cell?.tacoName.textAlignment = .center
                cell?.tacoName.text = "You haven't saved any tacos yet! :( \nWhat are you waiting for?"
            }
        case 2:
            if hasCreatedTacos {
                if inSearchMode {
                    tableView.isUserInteractionEnabled = true
                    cell?.tacoName.textAlignment = .left
                    cell?.tacoName.text = filteredCreatedTacos[indexPath.row]
                } else {
                    tableView.isUserInteractionEnabled = true
                    cell?.tacoName.textAlignment = .left
                    cell?.tacoName.text = createdTacos[indexPath.row]
                }
            } else {
                tableView.isUserInteractionEnabled = false
                cell?.tacoName.textAlignment = .center
                cell?.tacoName.text = "You haven't created any tacos yet! :( \nWhat are you waiting for?"
        }
        default:
            break
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch segmentedControl.selectedSegmentIndex
        {
        case 0:
            if hasSavedTacos {
                if inSearchMode {
                    let cellValue = filteredSavedTacos[indexPath.row]
                    self.tacoNameToPass = cellValue
                    self.tacoTypeToPass = "full-tacos"
                    if self.tacoNameToPass != nil && self.tacoTypeToPass != nil {
                        performSegue(withIdentifier: "IngredientsVC", sender: nil)
                    }
                } else {
                    let cellValue = savedTacos[indexPath.row]
                    self.tacoNameToPass = cellValue
                    self.tacoTypeToPass = "full-tacos"
                    if self.tacoNameToPass != nil && self.tacoTypeToPass != nil {
                        performSegue(withIdentifier: "IngredientsVC", sender: nil)
                    }
                }
            } else {
                print("No tacos")
            }
            searchBar.resignFirstResponder()
        case 1:
            if hasSavedIngredients {
                if inSearchMode {
                    let cellValue = filteredSavedIngredients[indexPath.row]
                    self.ingredientNameToPass = cellValue
                    if self.ingredientNameToPass != nil {
                        performSegue(withIdentifier: "RecipeVC", sender: nil)
                    }
                }else {
                    let cellValue = savedIngredients[indexPath.row]
                    self.ingredientNameToPass = cellValue
                    if self.ingredientNameToPass != nil {
                        performSegue(withIdentifier: "RecipeVC", sender: nil)
                    }
                }
            } else {
                print("No ingredients")
            }
            searchBar.resignFirstResponder()
        case 2:
            if hasCreatedTacos {
                if inSearchMode {
                    let cellValue = filteredCreatedTacos[indexPath.row]
                    self.tacoNameToPass = cellValue
                    self.tacoTypeToPass = "created-tacos"
                    if self.tacoNameToPass != nil && self.tacoTypeToPass != nil {
                        performSegue(withIdentifier: "IngredientsVC", sender: nil)
                    }
                } else {
                    let cellValue = createdTacos[indexPath.row]
                    self.tacoNameToPass = cellValue
                    self.tacoTypeToPass = "created-tacos"
                    if self.tacoNameToPass != nil && self.tacoTypeToPass != nil {
                        performSegue(withIdentifier: "IngredientsVC", sender: nil)
                    }
                }
            } else {
                print("No tacos")
            }
            searchBar.resignFirstResponder()
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            switch segmentedControl.selectedSegmentIndex {
            case 0:
                self.savedTacos.remove(at: indexPath.row)
                self.tableView.reloadData()
            case 1:
                self.savedIngredients.remove(at: indexPath.row)
                self.tableView.reloadData()
            case 2:
                self.createdTacos.remove(at: indexPath.row)
                self.tableView.reloadData()
            default:
                break
            }
        }
    }
    
    func downloadSavedTacos() {
        DataService.ds.REF_CURRENT_USER.child("full-tacos").observe( .value, with: { (snapshot) in
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
            self.activitySpinner.stopAnimating()
        })
    }
    
    func downloadCreatedTacos() {
        DataService.ds.REF_CURRENT_USER.child("created-tacos").observe( .value, with: { (snapshot) in
            self.createdTacos = []
            if let _ = snapshot.value as? NSNull {
                print("No Tacos saved")
                self.hasCreatedTacos = false
            } else{
                self.hasCreatedTacos = true
                if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                    for snap in snapshot {
                        let taco = snap.key
                        self.createdTacos.append(taco)
                    }
                }
            }
            self.tableView.reloadData()
            self.activitySpinner.stopAnimating()
        })
    }
    
    func downloadSavedIngredients() {
        DataService.ds.REF_CURRENT_USER.child("Ingredients").observe( .value, with: { (snapshot) in
            self.savedIngredients = []
            if let _ = snapshot.value as? NSNull {
                print("No Ingredients saved")
                self.hasSavedIngredients = false
            } else{
                self.hasSavedIngredients = true
                if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                    for snap in snapshot {
                        let ing = snap.key
                        self.savedIngredients.append(ing)
                    }
                }
            }
            self.tableView.reloadData()
            self.activitySpinner.stopAnimating()
        })
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "IngredientsVC" {
            let myVC = segue.destination as? IngredientsVC
            myVC?.tacoNamePassed = self.tacoNameToPass
            myVC?.tacoTypePassed = self.tacoTypeToPass
        }
        if segue.identifier == "RecipeVC" {
            let myVC = segue.destination as? RecipeVC
            myVC?.ingredientPassed = self.ingredientNameToPass
        }
    }
}
