//
//  DraggableView.swift
//  TacoFancy
//
//  Created by Rebekah Baker on 1/30/17.
//  Copyright © 2017 Rebekah Baker. All rights reserved.
//
//  Based off of github.com/cwRichardKim/TinderSimpleSwipeCards

import Foundation
import UIKit

let ACTION_MARGIN: Float = 50      //%%% distance from center where the action applies. Higher = swipe further in order for the action to be called
let SCALE_STRENGTH: Float = 20       //%%% how quickly the card shrinks. Higher = slower shrinking
let SCALE_MAX:Float = 0.93          //%%% upper bar for how much the card shrinks. Higher = shrinks less
let ROTATION_MAX: Float = 1         //%%% the maximum rotation allowed in radians.  Higher = card can keep rotating longer
let ROTATION_STRENGTH: Float = 320  //%%% strength of rotation. Higher = weaker rotation
let ROTATION_ANGLE: Float = 3.14/8  //%%% Higher = stronger rotation angle

protocol DraggableViewDelegate {
    func cardClickedLeft(_ card: UIView) -> Void
    func cardClickedRight(_ card: UIView) -> Void
    func likeBtn(isOn: Int)
}

class DraggableView: UIView {
    var delegate: DraggableViewDelegate!
    var panGestureRecognizer: UIPanGestureRecognizer!
    var originPoint: CGPoint!
    var overlayView: OverlayView!
    var information: UILabel!
    var xFromCenter: Float!
    var yFromCenter: Float!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupView()
        
        let regularFont = UIFont(name: "MyanmarSangamMN" , size: 16)
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height

        information = UILabel(frame: CGRect(x: 0, y: 50, width: screenWidth * 0.5 + 10, height: screenHeight * 0.5))
        information.center = CGPoint(x: Int(self.frame.size.width/2), y: Int(self.frame.size.height/2))
        information.numberOfLines = 0
        information.textAlignment = NSTextAlignment.center
        information.textColor = UIColor.black
        information.font = regularFont
        
        self.backgroundColor = UIColor.clear
        
//        UIGraphicsBeginImageContext(self.frame.size)
        UIGraphicsBeginImageContextWithOptions(self.frame.size, false, 0.0)
        UIImage(named: "Card")?.draw(in: self.bounds)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.backgroundColor = UIColor(patternImage: image)
        
        
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(DraggableView.beingDragged(_:)))
        
        self.addGestureRecognizer(panGestureRecognizer)
        self.addSubview(information)
        
        overlayView = OverlayView(frame: CGRect(x: self.frame.size.width/2-100, y: 0, width: 100, height: 100))
        overlayView.alpha = 0
        self.addSubview(overlayView)
        
        xFromCenter = 0
        yFromCenter = 0
    }
    
    func setupView() -> Void {
        self.layer.cornerRadius = 4;
        self.layer.shadowRadius = 3;
        self.layer.shadowOpacity = 0.2;
        self.layer.shadowOffset = CGSize(width: 1, height: 1);
    }
    
    //Follow dragging gesture around screen
    func beingDragged(_ gestureRecognizer: UIPanGestureRecognizer) -> Void {
        xFromCenter = Float(gestureRecognizer.translation(in: self).x)
        yFromCenter = Float(gestureRecognizer.translation(in: self).y)
        
        switch gestureRecognizer.state {
        case UIGestureRecognizerState.began:
            self.originPoint = self.center
        case UIGestureRecognizerState.changed:
            let rotationStrength: Float = min(xFromCenter/ROTATION_STRENGTH, ROTATION_MAX)
            let rotationAngle = ROTATION_ANGLE * rotationStrength
            let scale = max(1 - fabsf(rotationStrength) / SCALE_STRENGTH, SCALE_MAX)
            
            self.center = CGPoint(x: self.originPoint.x + CGFloat(xFromCenter), y: self.originPoint.y + CGFloat(yFromCenter))
            
            let transform = CGAffineTransform(rotationAngle: CGFloat(rotationAngle))
            let scaleTransform = transform.scaledBy(x: CGFloat(scale), y: CGFloat(scale))
            self.transform = scaleTransform
            self.updateOverlay(CGFloat(xFromCenter))
        case UIGestureRecognizerState.ended:
            self.afterSwipeAction()
        case UIGestureRecognizerState.possible:
            fallthrough
        case UIGestureRecognizerState.cancelled:
            fallthrough
        case UIGestureRecognizerState.failed:
            fallthrough
        default:
            break
        }
    }
    
    //Check image following dragging cards
    func updateOverlay(_ distance: CGFloat) -> Void {
        if distance > 0 {
            overlayView.setMode(GGOverlayViewMode.ggOverlayViewModeRight)
            delegate.likeBtn(isOn: 1)
        } else {
            overlayView.setMode(GGOverlayViewMode.ggOverlayViewModeLeft)
            delegate.likeBtn(isOn: 2)
        }
        overlayView.alpha = 1
    }
    
    //Drags card off screen and calls left or right action and hides check image
    func afterSwipeAction() -> Void {
        delegate.likeBtn(isOn: 3)
        let floatXFromCenter = Float(xFromCenter)
        if floatXFromCenter > ACTION_MARGIN {
            self.rightAction()
        } else if floatXFromCenter < -ACTION_MARGIN {
            self.leftAction()
        } else {
            UIView.animate(withDuration: 0.3, animations: {() -> Void in
                self.center = self.originPoint
                self.transform = CGAffineTransform(rotationAngle: 0)
                self.overlayView.alpha = 0
            })
        }
    }
    
    //Removes card from screen
    func rightAction() -> Void {
        let finishPoint = CGPoint(x: 700, y: self.center.y)
        UIView.animate(withDuration: 0.5,
                       animations: {
                        self.center = finishPoint
                        self.transform = CGAffineTransform(rotationAngle: 1)
        }, completion: {
            (value: Bool) in
            UIView.animate(withDuration: 0.5, animations: {() -> Void in
                self.overlayView.alpha = 0
            })
        })
        delegate.cardClickedRight(self)
    }
    func leftAction() -> Void {
        let finishPoint: CGPoint = CGPoint(x: -700, y: self.center.y)
        UIView.animate(withDuration: 0.5,
                       animations: {
                        self.center = finishPoint
                        self.transform = CGAffineTransform(rotationAngle: 1)
        }, completion: {
            (value: Bool) in
            UIView.animate(withDuration: 0.5, animations: {() -> Void in
                self.overlayView.alpha = 0
            })
        })
        delegate.cardClickedLeft(self)
    }
}

