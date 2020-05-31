//
//  ViewController.swift
//  RandomRecipe
//
//  Created by Omar Abbasi on 2019-04-14.
//  Copyright © 2019 Omar Abbasi. All rights reserved.
//

import UIKit
import SDWebImage
import CyaneaOctopus

struct Ingredient {
    
    var image: URL
    var name: String
    var amount: String
    
}

class IngredientCell: UICollectionViewCell {
    
    @IBOutlet var image: UIImageView!
    @IBOutlet var name: UILabel!
    @IBOutlet var amount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        image.contentMode = .scaleAspectFit
        
    }
    
    func displayData(_ ingredient: Ingredient) {
        
        name.text = ingredient.name
        amount.text = ingredient.amount
        guard let imageView = image else { return }
        imageView.sd_setImage(with: ingredient.image, placeholderImage: UIImage(named: "placeholder")!, options: SDWebImageOptions.scaleDownLargeImages, context: nil)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // god bless this person: https://stackoverflow.com/a/50366615/6871025
        
        contentView.backgroundColor = UIColor.tertiarySystemBackground
        contentView.layer.cornerRadius = 5
        contentView.layer.borderWidth = 0.7
        contentView.layer.borderColor = UIColor(red:0.64, green:0.69, blue:0.75, alpha:1.0).cgColor
        contentView.layer.masksToBounds = true
        
//        layer.shadowColor = UIColor.lightGray.cgColor
//        layer.shadowOffset = CGSize(width: 0, height: 5.0)
//        layer.shadowRadius = 6
//        layer.shadowOpacity = 0.3
//        layer.masksToBounds = false
//        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: contentView.layer.cornerRadius).cgPath
//        layer.backgroundColor = UIColor.clear.cgColor
        
    }
    
}

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: - IBOutlets
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var loadingView: UIView!
    @IBOutlet var imageContainer: UIView!
    @IBOutlet var recipeImage: UIImageView!
    @IBOutlet var recipeName: UILabel!
    @IBOutlet var details: UILabel!
    @IBOutlet var ingredientsHeader: UILabel!
    @IBOutlet var directionsHeader: UILabel!
    @IBOutlet var directions: UILabel!
    
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet var ingredientsCollectionView: UICollectionView!
    
    // show loading labels on image
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
    
    var colors: UIImageColors! {
        didSet {
            setColors()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        isLoading = true
        setIngredientLoading(true)
        setupUI()
        
    }
    
    func setLoading(_ loading: Bool) {
        
        if loading {
            scrollView.isScrollEnabled = false
            loadingView.isHidden = false
            loadingIndicator.startAnimating()
            ingredientsHeader.isHidden = true
            directionsHeader.isHidden = true
        } else {
            scrollView.isScrollEnabled = true
            loadingView.isHidden = true
            loadingIndicator.stopAnimating()
            ingredientsHeader.isHidden = false
            directionsHeader.isHidden = false
        }
        
    }
    
    func setIngredientLoading(_ loading: Bool) {
        
        if loading {
            ingredientsCollectionView.isScrollEnabled = false
        } else {
            ingredientsCollectionView.isScrollEnabled = true
        }
        
    }
    
    func setupUI() {
        
        self.scrollView.backgroundColor = .systemBackground
        
        ingredientsCollectionView.delegate = self
        ingredientsCollectionView.dataSource = self
        
        let rightButton1 = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(openURL(_:)))
        rightButton1.tag = 0
        let rightButton2 = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(openURL(_:)))
        rightButton2.tag = 1
        
        navigationItem.rightBarButtonItems = [rightButton1, rightButton2]
        
        let spacing: CGFloat = 15
        
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = CGSize(width: 130, height: 150)
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        ingredientsCollectionView.collectionViewLayout = layout
        
        self.navigationController?.navigationBar.prefersLargeTitles = false
        
        recipeImage.contentMode = .scaleAspectFill
        recipeImage.layer.cornerRadius = 8
        recipeImage.layer.masksToBounds = true
        recipeImage.layer.borderWidth = 1.0
        recipeImage.layer.borderColor = UIColor.clear.cgColor
        
        imageContainer.backgroundColor = UIColor.clear
        
        recipeName.font = UIFont(name: "Merriweather-Black", size: recipeName.font.pointSize)
        details.font = UIFont(name: "Merriweather-Light", size: details.font.pointSize)
        details.textColor = .secondaryLabel
        // ingredients.font = UIFont(name: "Merriweather-Regular", size: ingredients.font.pointSize)
        directions.font = UIFont(name: "Merriweather-Regular", size: directions.font.pointSize)
        directions.textColor = .label
//        guard let awesomeFont = UIFont(name: "FontAwesome5BrandsRegular", size: 25) else { return }
        
    }
    
    @objc func openURL(_ button: UIBarButtonItem) {
        
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
            
            self.ingredientsCollectionView.reloadData()
            self.setIngredientLoading(false)
            
            
            
        }
        
    }
    
    func setColors() {
        
        
    
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
            self.recipeImage.sd_setImage(with: imageURL, placeholderImage: UIImage(named: "placeholder"), options: SDWebImageOptions.delayPlaceholder, completed: { (img, error, cache, url) in

                img?.getColors(quality: .highest, { (colors) in
                    self.colors = colors
                })
                self.isLoading = false
                
            })
            
            print("getting other values...")
            // get ingredients
            var ingredients = [Ingredient]()
            var index = 1
            while recipeJSON["strIngredient\(index)"].stringValue.count != 0 {
                
                let ingredientName = recipeJSON["strIngredient\(index)"].stringValue.capitalized
                let ingredientMeasure = recipeJSON["strMeasure\(index)"].stringValue.capitalized
                guard let query = ingredientName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
                guard let ingredientURL = URL(string: "https://www.themealdb.com/images/ingredients/\(query).png") else { return }
                let newIngredient = Ingredient(image: ingredientURL, name: ingredientName, amount: ingredientMeasure)
                ingredients.append(newIngredient)
                
                index += 1
                
            }
            
            // get all other values
            let id = recipeJSON["idMeal"].stringValue
            let name = recipeJSON["strMeal"].stringValue
            let tags = recipeJSON["strTags"].stringValue.replacingOccurrences(of: ",", with: ", ")
            let area = recipeJSON["strArea"].stringValue
            let category = recipeJSON["strCategory"].stringValue
            let instructions = recipeJSON["strInstructions"].stringValue.replacingOccurrences(of: "\n", with: "\n\n") // double space
            let website = recipeJSON["strSource"].stringValue == "" ? URL(string: "www.google.com") : URL(string: recipeJSON["strSource"].stringValue)
            let video = recipeJSON["strYoutube"].stringValue == "" ? URL(string: "www.google.com") : URL(string: recipeJSON["strYoutube"].stringValue)
            
            self.recipe = Recipe(id: id, image: image, name: name, category: category, area: area, tags: tags, instructions: instructions, ingredients: ingredients, website: website!, video: video!)
                        
        }
        
    }
    
    // MARK: - Collection view
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard recipe != nil else { return 0 }
        return recipe.ingredients.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ingredientCell", for: indexPath) as! IngredientCell
        
        let ingredient = recipe.ingredients[indexPath.row]
        cell.displayData(ingredient)
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 130, height: 150)
    }
    
    // MARK: - Data handler function
    
    private func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }

}

