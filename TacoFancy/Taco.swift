//
//  Taco.swift
//  TacoFancy
//
//  Created by Rebekah Baker on 1/30/17.
//  Copyright © 2017 Rebekah Baker. All rights reserved.
//

import Foundation
import Firebase

struct Taco {
    
    let baseLayer: String
    let condiment: String
//    let mixin: String
//    let seasoning: String
//    let shell: String
    
}

extension Taco {
    init?(json: [String: Any]) {
        guard let baseLayerJSON = json["base_layer"] as? [String: String],
        let baseLayerName = baseLayerJSON["name"]
        else {
            return nil
        }
        guard let condimentJSON = json["condiment"] as? [String: String],
            let condimentName = condimentJSON["name"]
            else {
                return nil
        }
        
        self.baseLayer = baseLayerName
        self.condiment = condimentName
        
    }
}
