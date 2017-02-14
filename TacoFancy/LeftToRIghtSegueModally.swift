//
//  LeftToRIghtSegueModally.swift
//  TacoFancy
//
//  Created by Rebekah Baker on 2/14/17.
//  Copyright © 2017 Rebekah Baker. All rights reserved.
//

import UIKit
import QuartzCore

class LeftToRIghtSegueModally: UIStoryboardSegue {
    override func perform() {
        let src: UIViewController = self.source
        let dst: UIViewController = self.destination
        let transition: CATransition = CATransition()
        let timeFunc : CAMediaTimingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.duration = 0.4
        transition.timingFunction = timeFunc
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        src.navigationController!.view.layer.add(transition, forKey: kCATransition)
        src.navigationController!.pushViewController(dst, animated: false)
    }
}
