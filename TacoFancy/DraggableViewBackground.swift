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
    var CARD_HEIGHT: CGFloat = 250
    var CARD_WIDTH: CGFloat = 250

    var loadedCard: DraggableView!
    var newCard: DraggableView!
    var menuButton: UIButton!
    var messageButton: UIButton!
    var checkButton: UIButton!
    var xButton: UIButton!
    var tacoButton: UIButton!
    
    var taco: Taco!
    var tacoString: String!
    
    let activitySpinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        super.layoutSubviews()
        self.tag = 100
        self.setupView()
        getRandomTaco()
        print("GETTING RANDOM TACO on INIT")
    }
    
    func getRandomTaco() {
        activitySpinner.startAnimating()
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
                            DispatchQueue.global().sync {
                                self.configureTaco(taco)
                            }
                        }
                        DispatchQueue.main.sync {
                            self.loadCards()
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
        tacoString = taco.baseLayer + "\n with " + taco.condiment + "\n and " + taco.mixin + "\n seasoned with " + taco.seasoning + "\n inside " + taco.shell
    }
    
    func saveTaco(_ taco: Taco) {
        self.taco = taco
        let tacoToSave = ["base-layer": taco.baseLayer, "condiment": taco.condiment, "mixin": taco.mixin, "seasoning": taco.seasoning, "shell": taco.shell]
        DataService.ds.REF_CURRENT_USER.child("full-tacos").child(taco.baseLayer + " , " + taco.condiment + " , " + taco.mixin + " , " + taco.seasoning + " , " + taco.shell).updateChildValues(tacoToSave)
        let ingredientsToSave = [taco.baseLayer: taco.baseLayerRecipe, taco.condiment: taco.condimentRecipe, taco.mixin: taco.mixinRecipe, taco.seasoning: taco.seasoningRecipe, taco.shell: taco.shellRecipe]
        DataService.ds.REF_CURRENT_USER.child("ingredients").updateChildValues(ingredientsToSave)
        DataService.ds.REF_CURRENT_USER.child("base-layers").updateChildValues([taco.baseLayer: true])
        DataService.ds.REF_CURRENT_USER.child("condiments").updateChildValues([taco.condiment: true])
        DataService.ds.REF_CURRENT_USER.child("mixins").updateChildValues([taco.mixin: true])
        DataService.ds.REF_CURRENT_USER.child("seasonings").updateChildValues([taco.seasoning: true])
        DataService.ds.REF_CURRENT_USER.child("shells").updateChildValues([taco.shell: true])
    }
    
    func setupView() -> Void {
        print("SETUP VIEW")
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height

        CARD_WIDTH = screenWidth * 0.75
        CARD_HEIGHT = screenHeight * 0.5


        self.backgroundColor = UIColor.clear
        self.frame = CGRect(x: 0, y: 85, width: screenWidth, height: screenHeight - 85)

        xButton = UIButton(frame: CGRect(x: (self.frame.size.width - CARD_WIDTH)/2 + 35, y: self.frame.size.height/2 + CARD_HEIGHT/2, width: screenWidth / 2 * 0.25, height: screenWidth / 2 * 0.25))
        xButton.setImage(UIImage(named: "dislike-off"), for: UIControlState())
        xButton.layer.shadowRadius = 3;
        xButton.layer.shadowOpacity = 0.2;
        xButton.layer.shadowOffset = CGSize(width: 1, height: 1);
        xButton.addTarget(self, action: #selector(DraggableViewBackground.swipeLeft), for: UIControlEvents.touchUpInside)
        
        checkButton = UIButton(frame: CGRect(x: self.frame.size.width/2 + CARD_WIDTH/2 - 85, y: self.frame.size.height/2 + CARD_HEIGHT/2, width: screenWidth / 2 * 0.25, height: screenWidth / 2 * 0.25))
        checkButton.setImage(UIImage(named: "like-off"), for: UIControlState())
        checkButton.layer.shadowRadius = 3;
        checkButton.layer.shadowOpacity = 0.2;
        checkButton.layer.shadowOffset = CGSize(width: 1, height: 1);
        checkButton.addTarget(self, action: #selector(DraggableViewBackground.swipeRight), for: UIControlEvents.touchUpInside)
        
        activitySpinner.center = CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.height/2 - 50)
        activitySpinner.color = UIColor.white
        self.addSubview(activitySpinner)
        
        self.addSubview(xButton)
        self.addSubview(checkButton)
    }
    
    func createDraggableViewWithData() -> DraggableView {
        print("CREATE DRAGGABLE VIEW")
        let draggableView = DraggableView(frame: CGRect(x: (self.frame.size.width - CARD_WIDTH)/2, y: (self.frame.size.height - CARD_HEIGHT)/2 - 50 , width: CARD_WIDTH, height: CARD_HEIGHT))
        draggableView.information.text = tacoString
        draggableView.delegate = self
        return draggableView
    }
    
    func loadCards() -> Void {
        print("LOAD CARDS")
        self.loadedCard = self.createDraggableViewWithData()
        UIView.animate(withDuration: 0.3, animations: {
            () -> Void in
            print("INSERTING NEXT CARD")
            self.checkButton.setImage(UIImage(named: "like-off"), for: .normal)
            self.xButton.setImage(UIImage(named: "dislike-off"), for: .normal)
            self.addSubview(self.loadedCard)
            self.activitySpinner.stopAnimating()
        })
    }
    
    //Adds new card to view after clicking
    func cardClickedLeft(_ card: UIView) -> Void {
        print("Clicked 3.CARD SWIPED LEFT")
        Timer.scheduledTimer(timeInterval: TimeInterval(0.3), target: self, selector: #selector(getRandomTaco), userInfo: nil, repeats: false)
        print("GETTING RANDOM TACO when SWIPED LEFT")
    }
    func cardClickedRight(_ card: UIView) -> Void {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "checkForHasSavedTacoOnce"), object: nil)
        print("Clicked 3.CARD SWIPED RIGHT")
        saveTaco(taco)
        Timer.scheduledTimer(timeInterval: TimeInterval(0.3), target: self, selector: #selector(getRandomTaco), userInfo: nil, repeats: false)
        print("GETTING RANDOM TACO when SWIPED RIGHT")
    }
    
    //Check image following dragging cards
    func swipeRight() -> Void {
        print("Clicked 1.SWIPe RIGHT")
        let dragView: DraggableView = loadedCard
        dragView.overlayView.setMode(GGOverlayViewMode.ggOverlayViewModeRight)
        UIView.animate(withDuration: 0.1, animations: {
            () -> Void in
            dragView.overlayView.alpha = 1
            self.likeBtn(isOn: 1)
        })
        dragView.rightClickAction()
    }
    func swipeLeft() -> Void {
        print("Clicked 1.SWIPE LEFT")
        let dragView: DraggableView = loadedCard
        dragView.overlayView.setMode(GGOverlayViewMode.ggOverlayViewModeLeft)
        UIView.animate(withDuration: 0.1, animations: {
            () -> Void in
            dragView.overlayView.alpha = 1
            self.likeBtn(isOn: 2)
        })
        dragView.leftClickAction()
    }
    
    func likeBtn(isOn: Int) {
        switch isOn {
        case 1:
            self.checkButton.setImage(UIImage(named: "like-on"), for: .normal)
            self.xButton.setImage(UIImage(named: "dislike-off"), for: .normal)
        case 2:
            self.checkButton.setImage(UIImage(named: "like-off"), for: .normal)
            self.xButton.setImage(UIImage(named: "dislike-on"), for: .normal)
        case 3:
            self.checkButton.setImage(UIImage(named: "like-off"), for: .normal)
            self.xButton.setImage(UIImage(named: "dislike-off"), for: .normal)
        default: break
        }
    }
}
