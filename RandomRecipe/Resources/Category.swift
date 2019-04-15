//
//  Category.swift
//  RandomRecipe
//
//  Created by Omar Abbasi on 2019-04-14.
//  Copyright © 2019 Omar Abbasi. All rights reserved.
//

import UIKit

class Category {
    
    var id: String
    var image: UIImage
    var name: String
    var description: String
    
    init(id: String, image: UIImage, name: String, description: String) {
        
        self.id = id
        self.image = image
        self.name = name
        self.description = description
        
    }
    
}

