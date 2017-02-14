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
    
    @IBOutlet weak var tacoQuoteLbl: UILabel!
    
    var taco: Taco!
    var tacos = [Taco]()
    var jumpTimer = Timer()
    
    @IBOutlet weak var tacoBtn: UIButton!
    @IBAction func tacoBtnTapped(_ sender: Any) {
        jumpTimer.invalidate()
        self.tacoMan.isHidden = true
        DispatchQueue.global().async {
            UserDefaults.standard.set(true, forKey: "HasTappedOnce")
            UserDefaults.standard.synchronize()
            print("Has tapped once")
        }
        checkForHasSwipedOnce()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        jumpTimer.invalidate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        
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
        
        jumpTimer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(MainVC.tacoManJump), userInfo: nil, repeats: true)
    }
    
    func showMainOnboard() {
        mainOnboard.isHidden = false
    }
    
    func checkForHasTappedOnce() {
        if(UserDefaults.standard.bool(forKey: "HasTappedOnce"))
        {
            // app already launched
            print("NOT first launch")
            mainOnboard.isHidden = true
        }
        else
        {
            // This is the first launch ever
            print("FIRST launch")
            UserDefaults.standard.set(true, forKey: "HasTappedOnce")
            UserDefaults.standard.synchronize()
            _ = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(MainVC.showMainOnboard), userInfo: nil, repeats: false)
        }
    }
    
    func checkForHasSwipedOnce() {
        if(UserDefaults.standard.bool(forKey: "HasSwipedOnce"))
        {
            // app already launched
            print("NOT first launch")
            let draggableBackground: DraggableViewBackground = DraggableViewBackground(frame: self.view.frame)
            self.view.addSubview(draggableBackground)
            tacoBtn.isHidden = true
            tacoQuoteLbl.isHidden = true
        }
        else
        {
            // This is the first launch ever
            print("FIRST launch")
            UserDefaults.standard.set(true, forKey: "HasSwipedOnce")
            UserDefaults.standard.synchronize()
            let draggableBackground: DraggableViewBackground = DraggableViewBackground(frame: self.view.frame)
            self.view.insertSubview(draggableBackground, at: 1)
            tacoBtn.isHidden = true
            tacoQuoteLbl.isHidden = true
            swipeOnboard.isHidden = false
        }
    }
    
    func checkForHasSavedTacoOnce(notification: NSNotification) {
        if(UserDefaults.standard.bool(forKey: "HasSavedTacosOnce"))
        {
            // app already launched
            print("NOT first launch")
            tacoBtn.isHidden = true
            tacoQuoteLbl.isHidden = true
        }
        else
        {
            // This is the first launch ever
            print("FIRST launch")
            UserDefaults.standard.set(true, forKey: "HasSavedTacosOnce")
            UserDefaults.standard.synchronize()
            savedTacosOnboard.isHidden = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainOnboard.isHidden = true
        swipeOnboard.isHidden = true
        savedTacosOnboard.isHidden = true
        
        
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

        NotificationCenter.default.addObserver(self, selector: #selector(showTacoQuote(notification:)), name:NSNotification.Name(rawValue: "showTacoQuote"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(clearTacoQuote(notification:)), name:NSNotification.Name(rawValue: "clearTacoQuote"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(checkForHasSavedTacoOnce(notification:)), name:NSNotification.Name(rawValue: "checkForHasSavedTacoOnce"), object: nil)
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
    
    func tacoManJump() {
        print("JUMPING")
        let shakeAnimation = CABasicAnimation(keyPath: "position")
        shakeAnimation.duration = 0.1
        shakeAnimation.repeatCount = 5
        shakeAnimation.autoreverses = true
        shakeAnimation.fromValue = CGPoint(x: tacoMan.center.x, y: tacoMan.center.y + 5)
        shakeAnimation.toValue = CGPoint(x: tacoMan.center.x, y: tacoMan.center.y - 5)
        tacoMan.layer.add(shakeAnimation, forKey: "position")
    }
    
    @IBOutlet weak var tacoMan: UIImageView!
    
    @IBOutlet weak var mainOnboard: UIView!
    @IBAction func gotItBtnTapped(_ sender: Any) {
        mainOnboard.isHidden = true
    }
    
    @IBOutlet weak var swipeOnboard: UIView!
    @IBAction func swipeGotItBtnTapped(_ sender: Any) {
        swipeOnboard.isHidden = true
    }
    @IBOutlet weak var savedTacosOnboard: UIView!
    @IBAction func savedBtnGotItTapped(_ sender: Any) {
        savedTacosOnboard.isHidden = true
    }
    
}
