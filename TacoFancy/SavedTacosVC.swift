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
            print("Saved Tacos")
            isSearchingTacos = true
            downloadSavedTacos()
            if inSearchMode {
                searchBar(searchBar, textDidChange: searchBar.text!)
            }
        case 1:
            print("Ingredients")
            isSearchingTacos = false
            downloadSavedIngredients()
            if inSearchMode {
                searchBar(searchBar, textDidChange: searchBar.text!)
            }
        default:
            break
        }
    }
    
    var savedTacos = [String]()
    var savedIngredients = [String]()
    var tacoNameToPass: String!
    var ingredientNameToPass: String!
    var hasSavedTacos = true
    var hasSavedIngredients = true
    var isSearchingTacos = true
    var filteredSavedTacos = [String]()
    var filteredSavedIngredients = [String]()
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
        downloadSavedIngredients()
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
                    if self.tacoNameToPass != nil {
                        performSegue(withIdentifier: "IngredientsVC", sender: nil)
                    }
                } else {
                    let cellValue = savedTacos[indexPath.row]
                    self.tacoNameToPass = cellValue
                    if self.tacoNameToPass != nil {
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
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if isSearchingTacos {
                self.savedTacos.remove(at: indexPath.row)
                self.tableView.reloadData()
            } else {
                self.savedIngredients.remove(at: indexPath.row)
                self.tableView.reloadData()
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
    
    func downloadSavedIngredients() {
        DataService.ds.REF_CURRENT_USER.child("ingredients").observe( .value, with: { (snapshot) in
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
        }
        if segue.identifier == "RecipeVC" {
            let myVC = segue.destination as? RecipeVC
            myVC?.ingredientPassed = self.ingredientNameToPass
        }
    }
}
