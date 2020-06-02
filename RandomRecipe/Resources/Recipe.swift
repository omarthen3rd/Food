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
    var image: URL?
    var name: String
    var category: String
    var area: String
    var tags: String
    var instructions: String
    var ingredients: [Ingredient]
    var website: URL?
    var video: URL?
    
    init(id: String, image: URL?, name: String, category: String, area: String, tags: String, instructions: String, ingredients: [Ingredient], website: URL?, video: URL?) {
        
        self.id = id
        self.image = image
        self.name = name
        self.category = category
        self.area = area
        self.tags = tags
        self.instructions = instructions
        self.ingredients = ingredients
        self.website = website
        self.video = video
        
    }
    
}

class RecipePreview {
    
    var id: String
    var image: URL
    var name: String
    
    init(id: String, image: URL, name: String) {
        self.id = id
        self.image = image
        self.name = name
    }
    
}
