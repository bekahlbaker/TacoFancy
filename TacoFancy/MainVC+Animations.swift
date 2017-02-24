//
//  MainVC+Animations.swift
//  TacoFancy
//
//  Created by Rebekah Baker on 2/22/17.
//  Copyright © 2017 Rebekah Baker. All rights reserved.
//

import UIKit

extension MainVC {
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
        
        flickerSign()
        UIView.animate(withDuration: 0.2, delay:0, options: [.repeat, .autoreverse], animations: {
            UIView.setAnimationRepeatCount(5)
            self.shadowImage.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            
        }, completion: {completion in
            self.shadowImage.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.neonSign.image = UIImage(named: "sign-off")
        })
    }
    
    func flickerSign() {
        var images: [UIImage] = []
        for i in 1...3 {
            images.append(UIImage(named: "sign\(i)")!)
        }
        self.neonSign.image = UIImage(named: "sign-on")
        neonSign.animationImages = images
        neonSign.animationDuration = 0.4
        neonSign.animationRepeatCount = 1
        neonSign.startAnimating()
    }
}
