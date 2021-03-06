//
//  RecipeVC.swift
//  TacoFancy
//
//  Created by Rebekah Baker on 1/27/17.
//  Copyright © 2017 Rebekah Baker. All rights reserved.
//

import UIKit
import Firebase

class RecipeVC: UIViewController {
    @IBOutlet weak var recipeLbl: UILabel!
    var ingredientPassed: String!
    override func viewDidLoad() {
        super.viewDidLoad()
        let rightGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeRight(gestureRecognizer:)))
        rightGesture.direction = .right
        self.view.addGestureRecognizer(rightGesture)
        print(ingredientPassed)
        downloadRecipe(ingredient: ingredientPassed)
    }
    func swipeRight(gestureRecognizer: UISwipeGestureRecognizer) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    func downloadRecipe(ingredient: String!) {
        if ingredient == "<null>" {
            self.recipeLbl.text = "Sorry, we can't find the recipe for this. Please try again."
        } else {
            DataService.ds.REF_CURRENT_USER.child("ingredients").child(ingredient).observe( .value, with: { (snapshot) in
                if let _ = snapshot.value as? NSNull {
                    self.recipeLbl.text = "Sorry, we can't find the recipe for this. Please try again."
                } else {
                    if let recipe = snapshot.value as? String {
                        let regularFont = UIFont(name: "MyanmarSangamMN", size: 16)
                        let boldFont = UIFont(name: "MyanmarSangamMN-Bold", size: 18)
                        let recipeString = String(describing: recipe)
                        let title = self.ingredientPassed
                        let wordRange = (recipeString as NSString).range(of: title!)
                        let attributedString = NSMutableAttributedString(string: recipeString, attributes: [NSFontAttributeName: regularFont as Any])
                        attributedString.setAttributes([NSFontAttributeName: boldFont as Any, NSForegroundColorAttributeName: UIColor.black], range: wordRange)
                        let space = NSMutableAttributedString(string: "\n\n\n\n\n")
                        let combination = NSMutableAttributedString()
                        combination.append(attributedString)
                        combination.append(space)
                        self.recipeLbl.attributedText = combination
                    }
                }
            })
        }
    }
}
