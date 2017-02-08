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

class SavedTacosVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var savedTacos = [String]()
    var tacoNameToPass: String!
    var hasSavedTacos = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        savedTacosOnboard.isHidden = true
        checkForHasOpenedTacosOnce()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
        
        downloadSavedTacos()
        setUpGradientNavBar()
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
            tableView.isUserInteractionEnabled = true
            cell?.tacoName.textAlignment = .left
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
                performSegue(withIdentifier: "IngredientsVC", sender: nil)
            }
        } else {
            print("No tacos")
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.savedTacos.remove(at: indexPath.row)
            self.tableView.reloadData()
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
        if segue.identifier == "IngredientsVC" {
            let myVC = segue.destination as? IngredientsVC
            myVC?.tacoNamePassed = self.tacoNameToPass
        }
    }
    
    func setUpGradientNavBar() {
        let titleFont = UIFont(name: "Avenir-Heavy", size: 18)
        let backFont = UIFont(name: "Avenir-Medium", size: 16)
        let orange = UIColor(red:0.95, green:0.58, blue:0.00, alpha:1.0)
        let yellow = UIColor(red:0.99, green:0.77, blue:0.07, alpha:1.0)
        let darkOrange = UIColor(red:0.91, green:0.32, blue:0.05, alpha:1.0)
        let gradientLayer = CAGradientLayer()
        var updatedFrame = self.navigationController!.navigationBar.bounds
        let navAppearence = UINavigationBar.appearance()
        updatedFrame.size.height += 20
        gradientLayer.frame = updatedFrame
        gradientLayer.colors = [orange.cgColor, yellow.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0, y: 0.8)
        
        UIGraphicsBeginImageContext(gradientLayer.bounds.size)
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.navigationController!.navigationBar.setBackgroundImage(image, for: UIBarMetrics.default)
        navAppearence.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        navAppearence.titleTextAttributes = [NSFontAttributeName: titleFont!]
        navAppearence.tintColor = darkOrange
        UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName: backFont!], for: .normal)
    }
    
    @IBOutlet weak var savedTacosOnboard: UIView!
    @IBAction func tacosGotItBtnTapped(_ sender: Any) {
        savedTacosOnboard.isHidden = true
    }
    
    func checkForHasOpenedTacosOnce() {
        if(UserDefaults.standard.bool(forKey: "HasOpenedTacosOnce"))
        {
            // app already launched
            print("NOT first launch")
            savedTacosOnboard.isHidden = true
        }
        else
        {
            // This is the first launch ever
            print("FIRST launch")
            UserDefaults.standard.set(true, forKey: "HasOpenedTacosOnce")
            UserDefaults.standard.synchronize()
            savedTacosOnboard.isHidden = false
        }
    }
    
}
