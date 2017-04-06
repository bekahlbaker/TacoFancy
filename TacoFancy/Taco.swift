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
    //Names
    let baseLayer: String
    let condiment: String
    let mixin: String
    let seasoning: String
    let shell: String
    //Recipes
    let baseLayerRecipe: String
    let condimentRecipe: String
    let mixinRecipe: String
    let seasoningRecipe: String
    let shellRecipe: String
}

extension Taco {
    init?(json: [String: Any]) {
        guard let baseLayerJSON = json["base_layer"] as? [String: String],
        let baseLayerResult = baseLayerJSON["name"],
        let baseLayerRecipeResult = baseLayerJSON["recipe"]
        else {
            return nil
        }
        guard let condimentJSON = json["condiment"] as? [String: String],
            let condimentResult = condimentJSON["name"],
            let condimentRecipeResult = condimentJSON["recipe"]
            else {
                return nil
        }
        guard let mixinJSON = json["mixin"] as? [String: String],
            let mixinResult = mixinJSON["name"],
            let mixinRecipeResult = mixinJSON["recipe"]
            else {
                return nil
        }
        guard let seasoningJSON = json["seasoning"] as? [String: String],
            let seasoningResult = seasoningJSON["name"],
            let seasoningRecipeResult = seasoningJSON["recipe"]
        else {
            return nil
        }
        guard let shellJSON = json["shell"] as? [String: String],
            let shellResult = shellJSON["name"],
            let shellRecipeResult = shellJSON["recipe"]
            else {
                return nil
        }
        self.baseLayer = baseLayerResult
        self.condiment = condimentResult
        self.mixin = mixinResult
        self.seasoning = seasoningResult
        self.shell = shellResult
        self.baseLayerRecipe = baseLayerRecipeResult
        self.condimentRecipe = condimentRecipeResult
        self.mixinRecipe = mixinRecipeResult
        self.seasoningRecipe = seasoningRecipeResult
        self.shellRecipe = shellRecipeResult
    }
}
