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

    var taco: Taco!
    var tacos = [Taco]()
    
    @IBOutlet weak var fullTacoName: UILabel!
    @IBOutlet weak var tacoBtn: UIButton!
    @IBAction func tacoBtnTapped(_ sender: Any) {
        let draggableBackground: DraggableViewBackground = DraggableViewBackground(frame: self.view.frame)
        self.view.addSubview(draggableBackground)
        tacoBtn.isHidden = true
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
    }
    
    
    @IBAction func tossBtnTapped(_ sender: Any) {
        getRandomTaco()
    }

    @IBAction func saveBtnTapped(_ sender: Any) {
        saveTaco(taco)
    }
    
    func getRandomTaco() {
        print("GETTING RANDOM TACO")
        guard let url = URL(string: random) else {
            print("Cannot create URL")
            return
        }
        let urlRequest = URLRequest(url: url)
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            
            self.tacos = []
            
            if error != nil {
                print(error as Any)
            } else {
                if let urlContent = data {
                    do {
                        let jsonResult = try JSONSerialization.jsonObject(with: urlContent, options: []) as? [String: Any]
//                        print(jsonResult as Any)
                            if let taco = Taco(json: jsonResult!) {
                                DispatchQueue.main.async {
                                    self.tacoBtn.isHidden = true
                                    self.configureTaco(taco)
                                }
                            }
                    } catch {
                        print("JSON processing failed.")
                    }
                }
            }
        }
        task.resume()
        
        let draggableBackground: DraggableViewBackground = DraggableViewBackground(frame: self.view.frame)
        self.view.addSubview(draggableBackground)
    }
    
    func configureTaco(_ taco: Taco) {
        self.taco = taco
        self.fullTacoName.text = taco.baseLayer + " , " + taco.condiment + " , " + taco.mixin + " , " + taco.seasoning + " , " + taco.shell
    }
    
    func saveTaco(_ taco: Taco) {
        self.taco = taco
        let tacoToSave = ["base-layer": taco.baseLayer, "condiment": taco.condiment, "mixin": taco.mixin, "seasoning": taco.seasoning, "shell": taco.shell]
        DataService.ds.REF_CURRENT_USER.child("saved-tacos").child(taco.baseLayer + " , " + taco.condiment + " , " + taco.mixin + " , " + taco.seasoning + " , " + taco.shell).updateChildValues(tacoToSave)
    }
}
