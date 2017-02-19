//
//  Overlay.swift
//  TacoFancy
//
//  Created by Rebekah Baker on 1/30/17.
//  Copyright © 2017 Rebekah Baker. All rights reserved.
//
//  Based off of github.com/cwRichardKim/TinderSimpleSwipeCards

import Foundation
import UIKit

enum GGOverlayViewMode {
    case ggOverlayViewModeLeft
    case ggOverlayViewModeRight
}

class OverlayView: UIView{
    var _mode: GGOverlayViewMode! = GGOverlayViewMode.ggOverlayViewModeLeft
    var imageView: UIImageView!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        imageView = UIImageView(image: UIImage(named: "dislike-on"))
        self.addSubview(imageView)
    }
    
    func setMode(_ mode: GGOverlayViewMode) -> Void {
        if _mode == mode {
            return
        }
        _mode = mode
        
        if _mode == GGOverlayViewMode.ggOverlayViewModeLeft {
            imageView.image = UIImage(named: "dislike-on")
        } else {
            imageView.image = UIImage(named: "like-on")
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = CGRect(x: 50, y: 100, width: 100, height: 100)
    }
}
