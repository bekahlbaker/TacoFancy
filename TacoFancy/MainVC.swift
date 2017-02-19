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
    var draggableBackground = DraggableViewBackground()
    
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
        setUpTacoManScreen()
        
        let indexToUse = UserDefaults.standard.integer(forKey: "index")
        if indexToUse < 38 {
            let indexToStore = indexToUse + 1
            UserDefaults.standard.set(indexToStore, forKey: "index")
            print("APP DELEGATE BACKGROUND: \(indexToStore)")
        } else if indexToUse == 38 {
            UserDefaults.standard.set(0, forKey: "index")
            print("APP DELEGATE BACKGROUND: \(indexToUse)")
        }

        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showTacoQuote"), object: nil)
    }
    
    func setUpTacoManScreen() {
        self.neonSign.image = UIImage(named: "sign-off")
        self.tacoMan.isHidden = false
        self.shadowImage.isHidden = false
        tacoQuoteLbl.isHidden = false
        tacoBtn.isHidden = false
        draggableBackground.removeFromSuperview()
        jumpTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(MainVC.tacoManJump), userInfo: nil, repeats: true)
    }
    
    func setUpCardsScreen() {
        self.neonSign.image = UIImage(named: "sign-on")
        self.view.insertSubview(draggableBackground, at: 1)
        tacoBtn.isHidden = true
        tacoQuoteLbl.isHidden = true
        tacoMan.isHidden = true
        shadowImage.isHidden = true
    }
    
    func checkForHasTappedOnce() {
        if(UserDefaults.standard.bool(forKey: "HasTappedOnce")) {
            print("NOT first launch")
            mainOnboard.isHidden = true
        }
        else{
            print("FIRST launch")
            UserDefaults.standard.set(true, forKey: "HasTappedOnce")
            UserDefaults.standard.synchronize()
            _ = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(MainVC.showMainOnboard), userInfo: nil, repeats: false)
        }
    }
    
    func showMainOnboard() {
        mainOnboard.isHidden = false
    }
    
    func checkForHasSwipedOnce() {
        if(UserDefaults.standard.bool(forKey: "HasSwipedOnce")) {
            print("NOT first launch")
            setUpCardsScreen()
        }
        else {
            print("FIRST launch")
            UserDefaults.standard.set(true, forKey: "HasSwipedOnce")
            UserDefaults.standard.synchronize()
            swipeOnboard.isHidden = false
            setUpCardsScreen()
        }
    }
    
    func checkForHasSavedTacoOnce(notification: NSNotification) {
        if(UserDefaults.standard.bool(forKey: "HasSavedTacosOnce")) {
            print("NOT first launch")
            setUpCardsScreen()
        }
        else {
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
        
        draggableBackground = DraggableViewBackground(frame: self.view.frame)

        anonymouslyLogIn()
        
        NotificationCenter.default.addObserver(self, selector: #selector(showTacoQuote(notification:)), name:NSNotification.Name(rawValue: "showTacoQuote"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(clearTacoQuote(notification:)), name:NSNotification.Name(rawValue: "clearTacoQuote"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(checkForHasSavedTacoOnce(notification:)), name:NSNotification.Name(rawValue: "checkForHasSavedTacoOnce"), object: nil)
    }
    
    func anonymouslyLogIn() {
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
        shakeAnimation.duration = 0.2
        shakeAnimation.repeatCount = 5
        shakeAnimation.autoreverses = true
        shakeAnimation.fromValue = CGPoint(x: tacoMan.center.x, y: tacoMan.center.y + 10)
        shakeAnimation.toValue = CGPoint(x: tacoMan.center.x, y: tacoMan.center.y - 10)
        tacoMan.layer.add(shakeAnimation, forKey: "position")
        
        UIView.animate(withDuration: 0.2, delay:0, options: [.repeat, .autoreverse], animations: {
            UIView.setAnimationRepeatCount(5)
            self.neonSign.image = UIImage(named: "sign-on")
            self.shadowImage.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            
        }, completion: {completion in
            self.shadowImage.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.neonSign.image = UIImage(named: "sign-off")
        })
    }
    
    @IBOutlet weak var tacoMan: UIImageView!
    @IBOutlet weak var shadowImage: UIImageView!
    @IBOutlet weak var neonSign: UIImageView!
    
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
