//
//  IngredientsVC.swift
//  TacoFancy
//
//  Created by Rebekah Baker on 2/2/17.
//  Copyright © 2017 Rebekah Baker. All rights reserved.
//

import UIKit
import Firebase

class IngredientsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var tacoNamePassed: String!
    var savedTaco = [String]()
    var recipe = [String]()
    var ingredientToPass: String!
    var tacosFound = true
    var backgroundColors = [UIColor(red:0.53, green:0.83, blue:0.49, alpha:1.0), UIColor(red:0.91, green:0.83, blue:0.41, alpha:1.0), UIColor(red:0.95, green:0.57, blue:0.20, alpha:1.0), UIColor(red:1.00, green:0.33, blue:0.48, alpha:1.0)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        
        let rightGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeRight(gestureRecognizer:)))
        rightGesture.direction = .right
        self.view.addGestureRecognizer(rightGesture)
        
        downloadSavedTaco()
    }
    
//    func setBackgroundColor(cell: IngredientCell, indexPath: IndexPath) {
//        cell.backgroundLayer.backgroundColor = backgroundColors[indexPath.row % backgroundColors.count]
//    }
    
    func swipeRight(gestureRecognizer: UISwipeGestureRecognizer) {
       _ = self.navigationController?.popViewController(animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipe.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "IngredientCell") as? IngredientCell
//        setBackgroundColor(cell: cell!, indexPath: indexPath)
        if recipe[indexPath.row] == "<null>" {
            cell?.isUserInteractionEnabled = false
//            cell?.recipeLbl.text = "Sorry. We can't find this ingredient. Please try again."
        } else {
            let regularFont = UIFont(name: "MyanmarSangamMN" , size: 16)
            let mediumFont = UIFont(name: "MyanmarSangamMN-Bold" , size: 16)
            _ = UIFont(name: "Avenir-Heavy", size: 14)
            let linkColor = UIColor(red:0.00, green:0.64, blue:0.66, alpha:1.0)

            let ingredients = String(recipe[indexPath.row])
            let ingredient = String(ingredients!.characters.prefix(100)) + "..."
            let title = String(savedTaco[indexPath.row])
            let wordRange = (ingredient as NSString).range(of: title!)
            let attributedString = NSMutableAttributedString(string: ingredient, attributes: [NSFontAttributeName: regularFont as Any])
            attributedString.setAttributes([NSFontAttributeName : mediumFont as Any, NSForegroundColorAttributeName : UIColor.black], range: wordRange)
            
            let combination = NSMutableAttributedString()
            combination.append(attributedString)
            
            cell?.ingredientLbl.attributedText = combination
            cell?.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
            cell?.tintColor = linkColor
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellValue = savedTaco[indexPath.row]
        self.ingredientToPass = cellValue
        if self.ingredientToPass != nil {
            performSegue(withIdentifier: "RecipeVC", sender: nil)
        }
    }
    
    func downloadSavedTaco() {
        DataService.ds.REF_CURRENT_USER.child("saved-tacos").child(tacoNamePassed).observe(.value, with: { (snapshot) in
            
            self.savedTaco = []
            self.recipe = []
            
            self.tacosFound = true
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    let ingredient = snap.value
                    self.savedTaco.append(String(describing: ingredient!))
                }
            }
            if self.savedTaco.count > 0 {
                for i in 0..<self.savedTaco.count {
                    DataService.ds.REF_INGREDIENTS.child(self.savedTaco[i]).observe( .value, with: { (snapshot) in
                        let recipe = snapshot.value
                        self.recipe.append(String(describing: recipe!))
                        if self.recipe.count > 0 {
                            self.perform(#selector(self.loadTableData(_:)), with: nil, afterDelay: 0.5)
                        }
                    })
                }
            }
        })
    }
    
    func loadTableData(_ sender:AnyObject) {
        if self.recipe.count > 0 {
            self.tableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "RecipeVC" {
            let myVC = segue.destination as? RecipeVC
            myVC?.ingredientPassed = self.ingredientToPass
        }
    }
    
}
