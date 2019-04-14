//
//  Recipe.swift
//  RandomRecipe
//
//  Created by Omar Abbasi on 2019-04-14.
//  Copyright © 2019 Omar Abbasi. All rights reserved.
//

import UIKit

class Recipe {
    
    var id: String
    var image: UIImage
    var name: String
    var category: String
    var area: String
    var tags: String
    var instructions: String
    var ingredients: [String: String]
    
    init(id: String, image: UIImage, name: String, category: String, area: String, tags: String, instructions: String, ingredients: [String: String]) {
        
        self.id = id
        self.image = image
        self.name = name
        self.category = category
        self.area = area
        self.tags = tags
        self.instructions = instructions
        self.ingredients = ingredients
        
    }
    
}
