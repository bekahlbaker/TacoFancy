//
//  MainVC.swift
//  TacoFancy
//
//  Created by Rebekah Baker on 1/27/17.
//  Copyright © 2017 Rebekah Baker. All rights reserved.

import UIKit
import Firebase
import SwiftKeychainWrapper

class MainVC: UIViewController {
    @IBOutlet weak var tacoQuoteLbl: UILabel!
    var hasInternetConnection = false
    var taco: Taco!
    var tacos = [Taco]()
    var jumpTimer = Timer()
    var draggableBackground = DraggableViewBackground()
    @IBOutlet weak var tacoBtn: UIButton!
    @IBAction func tacoBtnTapped(_ sender: Any) {
        if hasInternetConnection {
            jumpTimer.invalidate()
            self.tacoMan.isHidden = true
            DispatchQueue.global().async {
                UserDefaults.standard.set(true, forKey: "HasTappedOnce")
                UserDefaults.standard.synchronize()
                print("Has tapped once")
            }
            checkForHasSwipedOnce()
        } else {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "noInternetConnectionError"), object: nil)

        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        jumpTimer.invalidate()
    }
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        checkForInternetConnection()
    }
    func checkForInternetConnection() {
        DispatchQueue.main.async {
            guard let url = URL(string: random) else {
                print("Cannot create URL")
                return
            }
            let urlconfig = URLSessionConfiguration.default
            urlconfig.timeoutIntervalForRequest = 5
            urlconfig.timeoutIntervalForResource = 60
            let urlRequest = URLRequest(url: url)
            let session = URLSession(configuration: urlconfig)
            let task = session.dataTask(with: urlRequest) { (_, _, error) in
                if error != nil {
                    self.hasInternetConnection = false
                } else {
                    self.hasInternetConnection = true
                }
            }
            task.resume()
        }
    }
    func noInternetConnectionError(notification: NSNotification) {
        let alert = UIAlertController(title: "No Internet Connection", message: "Please check your internet connection and try again.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (_: UIAlertAction) in
            self.setUpTacoManScreen()
        }))
        self.present(alert, animated: true, completion: nil)
    }

    func setUpTacoManScreen() {
        self.checkForInternetConnection()
        self.neonSign.image = UIImage(named: "sign-off")
        self.tacoMan.isHidden = false
        self.shadowImage.isHidden = false
        tacoQuoteLbl.isHidden = false
        tacoBtn.isHidden = false
        draggableBackground.removeFromSuperview()
        jumpTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(MainVC.tacoManJump), userInfo: nil, repeats: true)
    }
    func setUpCardsScreen() {
        self.checkForInternetConnection()
        flickerSign()
        self.neonSign.image = UIImage(named: "sign-on")
        draggableBackground = DraggableViewBackground(frame: self.view.frame)
        self.view.insertSubview(draggableBackground, at: 1)
        tacoBtn.isHidden = true
        tacoQuoteLbl.isHidden = true
        tacoMan.isHidden = true
        shadowImage.isHidden = true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        mainOnboard.isHidden = true
        swipeOnboard.isHidden = true
        savedTacosOnboard.isHidden = true

        anonymouslyLogIn()
        NotificationCenter.default.addObserver(self, selector: #selector(showTacoQuote(notification:)), name:NSNotification.Name(rawValue: "showTacoQuote"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(clearTacoQuote(notification:)), name:NSNotification.Name(rawValue: "clearTacoQuote"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(checkForHasSavedTacoOnce(notification:)), name:NSNotification.Name(rawValue: "checkForHasSavedTacoOnce"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(noInternetConnectionError(notification:)), name:NSNotification.Name(rawValue: "noInternetConnectionError"), object: nil)
        checkForHasTappedOnce()
        setUpTacoManScreen()
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
                    DataService.ds.completeSignIn(uid, userData: (userData as? [String: String])!)
                }
            })
        }
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
