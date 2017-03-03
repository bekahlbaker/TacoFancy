//
//  MainVC+Onboarding.swift
//  TacoFancy
//
//  Created by Rebekah Baker on 2/22/17.
//  Copyright © 2017 Rebekah Baker. All rights reserved.
//

import UIKit

extension MainVC {
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
            print("NOT first launch")        }
        else {
            print("FIRST launch")
            UserDefaults.standard.set(true, forKey: "HasSavedTacosOnce")
            UserDefaults.standard.synchronize()
            savedTacosOnboard.isHidden = false
        }
    }

}
