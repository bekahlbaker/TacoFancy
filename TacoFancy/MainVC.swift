//
//  MainVC.swift
//  TacoFancy
//
//  Created by Rebekah Baker on 1/27/17.
//  Copyright © 2017 Rebekah Baker. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class MainVC: UIViewController {
    
    @IBOutlet weak var menuBtn: UIButton!
    @IBAction func menuBtnTapped(_ sender: Any) {
        performSegue(withIdentifier: "SavedTacosVC", sender: nil)
    }
    @IBAction func menuBtnTapped2(_ sender: Any) {
        performSegue(withIdentifier: "SavedTacosVC", sender: nil)
    }

    @IBOutlet weak var tacoQuoteLbl: UILabel!
    
    var taco: Taco!
    var tacos = [Taco]()
    
    @IBOutlet weak var tacoBtn: UIButton!
    @IBAction func tacoBtnTapped(_ sender: Any) {
        let draggableBackground: DraggableViewBackground = DraggableViewBackground(frame: self.view.frame)
        self.view.addSubview(draggableBackground)
        tacoBtn.isHidden = true
        tacoQuoteLbl.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let indexToUse = UserDefaults.standard.integer(forKey: "index")
        if indexToUse < 39 {
            let indexToStore = indexToUse + 1
            UserDefaults.standard.set(indexToStore, forKey: "index")
            print("APP DELEGATE BACKGROUND: \(indexToStore)")
        } else if indexToUse == 39 {
            UserDefaults.standard.set(0, forKey: "index")
            print("APP DELEGATE BACKGROUND: \(indexToUse)")
        }

        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showTacoQuote"), object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        //        try! FIRAuth.auth()?.signOut()
        
        if KeychainWrapper.standard.string(forKey: KEY_UID) != nil {
            let currentUser = KeychainWrapper.standard.string(forKey: KEY_UID)! as String
            print("CURRENT USER \(currentUser)")
        } else {
            FIRAuth.auth()?.signInAnonymously(completion: { (user, error) in
                print("AUTH IS RUNNING")
                if error != nil {
                    print("There was an error logging in anonymously")
                    print(error as Any)
                } else {
                    print("We are now logged in")
                    let uid = user!.uid
                    let userData = ["provider": user?.providerID]
                    DataService.ds.completeSignIn(uid, userData: userData as! Dictionary<String, String>)
                }
            })
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(tacoGlow(notification:)), name:NSNotification.Name(rawValue: "tacoGlow"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(stopTacoGlow(notification:)), name:NSNotification.Name(rawValue: "stopTacoGlow"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showTacoQuote(notification:)), name:NSNotification.Name(rawValue: "showTacoQuote"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(clearTacoQuote(notification:)), name:NSNotification.Name(rawValue: "clearTacoQuote"), object: nil)
    }
    
    func tacoGlow(notification: NSNotification) {
        menuBtn.layer.shadowColor = UIColor.yellow.cgColor
        menuBtn.layer.shadowRadius = 10.0
        menuBtn.layer.shadowOffset = CGSize.zero
        menuBtn.layer.shadowOpacity = 1.0
    }
    
    func stopTacoGlow(notification: NSNotification) {
        menuBtn.layer.shadowColor = UIColor.clear.cgColor
        menuBtn.layer.shadowRadius = 10.0
        menuBtn.layer.shadowOffset = CGSize.zero
        menuBtn.layer.shadowOpacity = 1.0
    }
    
    func clearTacoQuote(notification: NSNotification) {
        tacoQuoteLbl.text = ""
    }
    
    func showTacoQuote(notification: NSNotification) {
        tacoQuoteLbl.alpha = 0
        let indexToUse = UserDefaults.standard.integer(forKey: "index")
        print("VIEW APPEAR \(indexToUse)")
        let pList = Bundle.main.path(forResource: "TacoQuotes", ofType: "plist")
        guard let content = NSDictionary(contentsOfFile: pList!) as? [String:[String]] else {
            fatalError()
        }
        guard let quoteArray = content["Quote"] else { fatalError() }
        self.tacoQuoteLbl.text = quoteArray[indexToUse]
        UIView.animate(withDuration: 0.5) {
            self.tacoQuoteLbl.alpha = 1
        }
    }
}
