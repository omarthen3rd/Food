//
//  ViewController.swift
//  RandomRecipe
//
//  Created by Omar Abbasi on 2019-04-14.
//  Copyright © 2019 Omar Abbasi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet var imageContainer: UIView!
    @IBOutlet var recipeImage: UIImageView!
    @IBOutlet var recipeName: UILabel!
    @IBOutlet var details: UILabel!
    @IBOutlet var ingredients: UILabel!
    @IBOutlet var directions: UILabel!
    
    var recipe: Recipe! {
        didSet {
            guard let recipe = recipe else { return }
            self.updateInterfaceWith(recipe: recipe)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        setupUI()
        fetchRandomRecipe()
        
    }
    
    func setupUI() {
        
        recipeImage.contentMode = .scaleAspectFill
        recipeImage.layer.cornerRadius = 8
        recipeImage.clipsToBounds = true
        
        imageContainer.backgroundColor = UIColor.clear
//        imageContainer.layer.shadowPath = UIBezierPath(roundedRect: imageContainer.bounds, cornerRadius: 8).cgPath
//        imageContainer.layer.shadowColor = UIColor.darkGray.cgColor
//        imageContainer.layer.shadowOffset = CGSize(width: 0, height: 0)
//        imageContainer.layer.shadowRadius = 10
//        imageContainer.layer.shadowOpacity = 0.4
        
        recipeName.font = UIFont(name: "Merriweather-Black", size: recipeName.font.pointSize)
        details.font = UIFont(name: "Merriweather-Light", size: details.font.pointSize)
        ingredients.font = UIFont(name: "Merriweather-Regular", size: ingredients.font.pointSize)
        directions.font = UIFont(name: "Merriweather-Regular", size: directions.font.pointSize)
        
    }
    
    func updateInterfaceWith(recipe: Recipe) {
        
        DispatchQueue.main.async {
            
            self.recipeName.text = recipe.name.uppercased()
            self.recipeName.sizeToFit()
            
            self.details.text = "\(recipe.category) · \(recipe.area)"
            
        }
        
    }
    
    func fetchRandomRecipe() {
        
        guard let url = URL(string: "https://www.themealdb.com/api/json/v1/1/random.php") else { return }
        getData(from: url) { (data, response, error) in
            
            guard let data = data else { return }
            let json = JSON(data)
            let recipeJSON = json["meals"].arrayValue[0]
            
            // get uiimage from URL
            let image = UIImage(imageLiteralResourceName: "placeholder")
            guard let imageURL = URL(string: recipeJSON["strMealThumb"].stringValue) else { return }
            self.getData(from: imageURL, completion: { (data, response, error) in
                guard let data = data, error == nil else { return }
                guard let im = UIImage(data: data) else { return }
                print("ran this")
                DispatchQueue.main.async {
                    self.recipeImage.image = im
                }
            })
            
            let id = recipeJSON["idMeal"].stringValue
            let name = recipeJSON["strMeal"].stringValue
            let tags = recipeJSON["strTags"].stringValue.replacingOccurrences(of: ",", with: ", ")
            let area = recipeJSON["strArea"].stringValue
            let category = recipeJSON["strCategory"].stringValue
            let instructions = recipeJSON["strInstructions"].stringValue
            
            self.recipe = Recipe(id: id, image: image, name: name, category: category, area: area, tags: tags, instructions: instructions, ingredients: ["": ""])
            
        }
        
    }
    
    // MARK: - Data handler function
    
    private func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }

}

