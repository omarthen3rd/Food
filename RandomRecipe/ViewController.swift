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
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var loadingView: UIView!
    @IBOutlet var imageContainer: UIView!
    @IBOutlet var recipeImage: UIImageView!
    @IBOutlet var recipeName: UILabel!
    @IBOutlet var details: UILabel!
    @IBOutlet var ingredients: UILabel!
    @IBOutlet var directions: UILabel!
    @IBOutlet var watchBtn: UIButton!
    @IBOutlet var sourceBtn: UIButton!
    
    var isLoading = true {
        didSet {
            setLoading(isLoading)
        }
    }
    
    var id = "" {
        didSet {
            guard id.count != 0 else { return }
            fetchRecipe(id)
        }
    }
    
    var recipe: Recipe! {
        didSet {
            guard let recipe = recipe else { return }
            self.updateInterfaceWith(recipe: recipe)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        for family in UIFont.familyNames.sorted() {
//            let names = UIFont.fontNames(forFamilyName: family)
//            print("Family: \(family) Font names: \(names)")
//        }
        
        isLoading = true
        setupUI()
        
    }
    
    func setLoading(_ loading: Bool) {
        
        if loading {
            scrollView.isScrollEnabled = false
            loadingView.isHidden = false
        } else {
            scrollView.isScrollEnabled = true
            loadingView.isHidden = true
        }
        
    }
    
    func setupUI() {
                
        recipeImage.contentMode = .scaleAspectFill
        recipeImage.layer.cornerRadius = 8
        recipeImage.layer.masksToBounds = true
        recipeImage.layer.borderWidth = 1.0
        recipeImage.layer.borderColor = UIColor.clear.cgColor
        
        imageContainer.backgroundColor = UIColor.clear
        
        recipeName.font = UIFont(name: "Merriweather-Black", size: recipeName.font.pointSize)
        details.font = UIFont(name: "Merriweather-Light", size: details.font.pointSize)
        ingredients.font = UIFont(name: "Merriweather-Regular", size: ingredients.font.pointSize)
        directions.font = UIFont(name: "Merriweather-Regular", size: directions.font.pointSize)
        
        guard let awesomeFont = UIFont(name: "FontAwesome5BrandsRegular", size: 25) else { return }
        
        let watchTitle = ""
        let attrWatchStr = NSMutableAttributedString(string: watchTitle)
        attrWatchStr.setFontForText("", awesomeFont)
        watchBtn.setAttributedTitle(attrWatchStr, for: [])
        watchBtn.tag = 0
        watchBtn.addTarget(self, action: #selector(openURL(button:)), for: .touchUpInside)
        
        let sourceTitle = ""
        let attrSourceStr = NSMutableAttributedString(string: sourceTitle)
        attrSourceStr.setFontForText("", awesomeFont)
        sourceBtn.setAttributedTitle(attrSourceStr, for: [])
        sourceBtn.tag = 1
        sourceBtn.addTarget(self, action: #selector(openURL(button:)), for: .touchUpInside)
        
    }
    
    @objc func openURL(button: UIButton) {
        
        if button.tag == 0 {
            // video
            UIApplication.shared.open(recipe!.video!, options: [:], completionHandler: nil)
        } else {
            // website
            UIApplication.shared.open(recipe!.website!, options: [:], completionHandler: nil)
        }
        
    }
    
    func updateInterfaceWith(recipe: Recipe) {
        
        print("updating interface with: \(recipe.name)")
        
        DispatchQueue.main.async {
            
            self.recipeName.text = recipe.name.uppercased()
            self.recipeName.sizeToFit()
            
            self.details.text = "\(recipe.category) · \(recipe.area)"
            self.directions.text = recipe.instructions
            
            // show ingredients
            guard let smallMerriweather = UIFont(name: "Merriweather-Light", size: 12) else { return }
            self.ingredients.text = ""
            let finalAttrString = NSMutableAttributedString(string: "")
            let keys = Array(recipe.ingredients.keys)
            for (key, value) in recipe.ingredients {
                let ingredientStr = keys.last == key ? "\(key)\n\(value)" :"\(key)\n\(value)\n\n"
                let attrStr = NSMutableAttributedString(string: ingredientStr)
                attrStr.setFontForText("\(value)", smallMerriweather)
                attrStr.setColorForText("\(value)", with: UIColor.gray)
                finalAttrString.append(attrStr)
            }
            self.ingredients.attributedText = finalAttrString
            
            // check if urls is valid
            if recipe.video?.absoluteString == "www.google.com" {
                self.watchBtn.isEnabled = false
            } else if recipe.website?.absoluteString == "www.google.com" {
                self.sourceBtn.isEnabled = false
            }
            
        }
        
    }
    
    func fetchRecipe(_ id: String) {
        
        print("\(#function): fetching recipe with id: \(id)")
        guard let url = URL(string: "https://www.themealdb.com/api/json/v1/1/lookup.php?i=\(id)") else { return }
        getData(from: url) { (data, response, error) in
            
            guard let data = data else { return }
            let json = JSON(data)
            let recipeJSON = json["meals"].arrayValue[0]
            // get image from URL
            let image = UIImage(imageLiteralResourceName: "placeholder")
            guard let imageURL = URL(string: recipeJSON["strMealThumb"].stringValue) else { return }
            self.getData(from: imageURL, completion: { (data, response, error) in
                guard let data = data, error == nil else { return }
                guard let im = UIImage(data: data) else { return }
                DispatchQueue.main.async {
                    print("setting image")
                    self.recipeImage.image = im
                    self.isLoading = false
                }
            })
            
            print("getting other values...")
            // get ingredients
            var ingredients = [String: String]()
            var index = 1
            while recipeJSON["strIngredient\(index)"].stringValue.count != 0 {
                
                let ingredientName = recipeJSON["strIngredient\(index)"].stringValue.capitalized
                let ingredientMeasure = recipeJSON["strMeasure\(index)"].stringValue.capitalized
                
                ingredients[ingredientName] = ingredientMeasure
                
                index += 1
                
            }
            
            // get all other values
            let id = recipeJSON["idMeal"].stringValue
            let name = recipeJSON["strMeal"].stringValue
            let tags = recipeJSON["strTags"].stringValue.replacingOccurrences(of: ",", with: ", ")
            let area = recipeJSON["strArea"].stringValue
            let category = recipeJSON["strCategory"].stringValue
            let instructions = recipeJSON["strInstructions"].stringValue.replacingOccurrences(of: "\n", with: "\n\n") // double space
            let website = URL(string: recipeJSON["strSource"].stringValue) == nil ? URL(string: "www.google.com") : URL(string: recipeJSON["strSource"].stringValue)
            let video = URL(string: recipeJSON["strYoutube"].stringValue) == nil ? URL(string: "www.google.com") : URL(string: recipeJSON["strSource"].stringValue)
            
            print("setting recipe")
            self.recipe = Recipe(id: id, image: image, name: name, category: category, area: area, tags: tags, instructions: instructions, ingredients: ingredients, website: website!, video: video!)
            
        }
        
    }
    
    // MARK: - Data handler function
    
    private func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }

}

