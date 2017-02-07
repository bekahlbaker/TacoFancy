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
    
    @IBOutlet weak var onboardView: UIView!
    @IBOutlet weak var dismissOnboardBtn: UIButton!
    @IBAction func dismissOnboardBtnTapped(_ sender: Any) {
        onboardView.isHidden = true
        dismissOnboardBtn.isHidden = true
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        onboardView.isHidden = true
        dismissOnboardBtn.isHidden = true
        
        if(UserDefaults.standard.bool(forKey: "HasLaunchedOnce"))
        {
            // app already launched
            print("NOT first launch")
        }
        else
        {
            // This is the first launch ever
            print("FIRST launch")
            onboardView.isHidden = false
            dismissOnboardBtn.isHidden = false
            UserDefaults.standard.set(true, forKey: "HasLaunchedOnce")
            UserDefaults.standard.synchronize()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(showOnboard(notification:)), name:NSNotification.Name(rawValue: "showOnboard"), object: nil)
        
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
    }
    
    func showOnboard(notification: NSNotification){
        print("Showing onboard")
        performSegue(withIdentifier: "FirstLaunchVC", sender: nil)
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
}
