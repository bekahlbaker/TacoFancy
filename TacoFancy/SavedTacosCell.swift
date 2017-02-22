//
//  SavedTacosCell.swift
//  TacoFancy
//
//  Created by Rebekah Baker on 2/1/17.
//  Copyright © 2017 Rebekah Baker. All rights reserved.
//

import UIKit

class SavedTacosCell: UITableViewCell {

    @IBOutlet weak var tacoName: UILabel!
    @IBOutlet weak var backgroundLayer: UIView!
    @IBOutlet weak var shadowLayer: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        
//        backgroundLayer.layer.cornerRadius = 8
//        shadowLayer.layer.cornerRadius = 8
    }

}
