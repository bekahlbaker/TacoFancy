//
//  DraggableViewBackground.swift
//  TacoFancy
//
//  Created by Rebekah Baker on 1/30/17.
//  Copyright © 2017 Rebekah Baker. All rights reserved.
//
//  Based off of github.com/cwRichardKim/TinderSimpleSwipeCards

import Foundation
import UIKit
import Firebase

class DraggableViewBackground: UIView, DraggableViewDelegate {
    
    let MAX_BUFFER_SIZE = 2
    let CARD_HEIGHT: CGFloat = 300
    let CARD_WIDTH: CGFloat = 300
    
    var loadedCard: DraggableView!
    var newCard: DraggableView!
    var menuButton: UIButton!
    var messageButton: UIButton!
    var checkButton: UIButton!
    var xButton: UIButton!
    
    var taco: Taco!
    var tacoString: String!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        super.layoutSubviews()
        self.setupView()
        getRandomTaco()
    }
    
    func getRandomTaco() {
        guard let url = URL(string: random) else {
            print("Cannot create URL")
            return
        }
        let urlRequest = URLRequest(url: url)
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            if error != nil {
                print(error as Any)
            } else {
                if let urlContent = data {
                    do {
                        let jsonResult = try JSONSerialization.jsonObject(with: urlContent, options: []) as? [String: Any]
                        if let taco = Taco(json: jsonResult!) {
                            DispatchQueue.global().async {
                                self.configureTaco(taco)
                                DispatchQueue.main.async {
                                    self.loadCards()
                                }
                            }
                        }
                    } catch {
                        print("JSON processing failed.")
                    }
                }
            }
        }
        task.resume()
    }
    
    func configureTaco(_ taco: Taco) {
        self.taco = taco
        tacoString = "How about some " + taco.baseLayer + ", with a little " + taco.condiment + ", mixin in some " + taco.mixin + ", and season with " + taco.seasoning + ", and stuff it into a " + taco.shell
    }
    
    func saveTaco(_ taco: Taco) {
        self.taco = taco
        let tacoToSave = ["base-layer": taco.baseLayer, "condiment": taco.condiment, "mixin": taco.mixin, "seasoning": taco.seasoning, "shell": taco.shell]
        DataService.ds.REF_CURRENT_USER.child("saved-tacos").child(taco.baseLayer + " , " + taco.condiment + " , " + taco.mixin + " , " + taco.seasoning + " , " + taco.shell).updateChildValues(tacoToSave)
        getRandomTaco()
    }
    
    func setupView() -> Void {
        self.backgroundColor = UIColor.clear
        
        xButton = UIButton(frame: CGRect(x: (self.frame.size.width - CARD_WIDTH)/2 + 35, y: self.frame.size.height/2 + CARD_HEIGHT/2 + 10, width: 59, height: 59))
        xButton.setImage(UIImage(named: "no"), for: UIControlState())
        xButton.addTarget(self, action: #selector(DraggableViewBackground.swipeLeft), for: UIControlEvents.touchUpInside)
        
        checkButton = UIButton(frame: CGRect(x: self.frame.size.width/2 + CARD_WIDTH/2 - 85, y: self.frame.size.height/2 + CARD_HEIGHT/2 + 10, width: 59, height: 59))
        checkButton.setImage(UIImage(named: "yes"), for: UIControlState())
        checkButton.addTarget(self, action: #selector(DraggableViewBackground.swipeRight), for: UIControlEvents.touchUpInside)
        
        self.addSubview(xButton)
        self.addSubview(checkButton)
    }
    
    func createDraggableViewWithData() -> DraggableView {
        let draggableView = DraggableView(frame: CGRect(x: (self.frame.size.width - CARD_WIDTH)/2, y: (self.frame.size.height - CARD_HEIGHT)/2, width: CARD_WIDTH, height: CARD_HEIGHT))
        draggableView.information.text = tacoString
        draggableView.delegate = self
        return draggableView
    }
    
    func loadCards() -> Void {
        self.loadedCard = self.createDraggableViewWithData()
        UIView.animate(withDuration: 0.5, animations: {
            () -> Void in
            self.insertSubview(self.loadedCard, aboveSubview: self.loadedCard)
        })
    }
    
    func cardSwipedLeft(_ card: UIView) -> Void {
        getRandomTaco()
        UIView.animate(withDuration: 0.5, animations: {
            () -> Void in
            self.insertSubview(self.loadedCard, aboveSubview: self.loadedCard)
        })
    }
    
    func cardSwipedRight(_ card: UIView) -> Void {
        saveTaco(taco)
        UIView.animate(withDuration: 0.5, animations: {
            () -> Void in
            self.insertSubview(self.loadedCard, aboveSubview: self.loadedCard)
        })
    }
    
    func swipeRight() -> Void {
        let dragView: DraggableView = loadedCard
        dragView.overlayView.setMode(GGOverlayViewMode.ggOverlayViewModeRight)
        UIView.animate(withDuration: 0.1, animations: {
            () -> Void in
            dragView.overlayView.alpha = 1
        })
        dragView.rightClickAction()
    }
    
    func swipeLeft() -> Void {
        let dragView: DraggableView = loadedCard
        dragView.overlayView.setMode(GGOverlayViewMode.ggOverlayViewModeLeft)
        UIView.animate(withDuration: 0.1, animations: {
            () -> Void in
            dragView.overlayView.alpha = 1
        })
        dragView.leftClickAction()
    }
}