//
//  RecipeDetailController.swift
//  RandomRecipe
//
//  Created by Omar Abbasi on 2019-04-14.
//  Copyright © 2019 Omar Abbasi. All rights reserved.
//

import UIKit
import SDWebImage

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
    
    func displayData(_ ingredient: Ingredient, _ row: Int, _ count: Int) {
        
        name.text = ingredient.name
        amount.text = ingredient.amount
        guard let imageView = image else { return }
        imageView.sd_setImage(with: ingredient.image, placeholderImage: UIImage(named: "placeholder")!, options: SDWebImageOptions.scaleDownLargeImages, context: nil)
        
        contentView.backgroundColor = .tertiarySystemFill
        if (row == 0) {
            contentView.layer.cornerRadius = 8
            contentView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        } else if (row == count - 1) {
            contentView.layer.cornerRadius = 8
            contentView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        }
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // god bless this person: https://stackoverflow.com/a/50366615/6871025
        
//        contentView.backgroundColor = .systemGroupedBackground
//        contentView.layer.cornerRadius = 8
//        contentView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
//        contentView.layer.borderWidth = 0.7
//        contentView.layer.borderColor = UIColor(red:0.64, green:0.69, blue:0.75, alpha:1.0).cgColor
//        contentView.layer.masksToBounds = true
        
    }
    
}

class RecipeDetailController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
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
    @IBOutlet var ingredientsCollectionHeight: NSLayoutConstraint!
    
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
        navigationItem.largeTitleDisplayMode = .never
        
        ingredientsCollectionView.delegate = self
        ingredientsCollectionView.dataSource = self
                
        let spacing: CGFloat = 15
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width - 30, height: 60)
        layout.sectionInset = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: spacing)
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        ingredientsCollectionView.collectionViewLayout = layout
                
        recipeImage.contentMode = .scaleAspectFill
        recipeImage.layer.cornerRadius = 8
        recipeImage.layer.masksToBounds = true
        recipeImage.layer.borderWidth = 1.0
        recipeImage.layer.borderColor = UIColor.clear.cgColor
        
        imageContainer.backgroundColor = UIColor.clear
        
        recipeName.font = UIFont(name: "Merriweather-Black", size: recipeName.font.pointSize)
        details.font = UIFont(name: "Merriweather-Light", size: details.font.pointSize)
        details.textColor = .secondaryLabel
        directions.font = UIFont(name: "Merriweather-Regular", size: 15)
        directions.textColor = .label
        
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
            
            if (recipe.video != nil) {
                // has video
                let playButton = UIImage(systemName: "play.rectangle.fill")

                let rightButton1 = UIBarButtonItem(image: playButton, style: .plain, target: self, action: #selector(self.openURL(_:)))
                rightButton1.tag = 0
                self.navigationItem.setRightBarButtonItems([rightButton1], animated: true)
            }
            
            if (recipe.website != nil) {
                // has webpage or blogpost
                let webButton = UIImage(systemName: "safari.fill")

                let rightButton2 = UIBarButtonItem(image: webButton, style: .plain, target: self, action: #selector(self.openURL(_:)))
                rightButton2.tag = 1
                
                if (self.navigationItem.rightBarButtonItems != nil) {
                    self.navigationItem.rightBarButtonItems?.append(rightButton2)
                } else {
                    self.navigationItem.setRightBarButton(rightButton2, animated: true)
                }
            }
            
            self.recipeName.text = recipe.name
            self.recipeName.sizeToFit()
            
            self.details.text = "\(recipe.category) · \(recipe.area)"
            self.directions.text = recipe.instructions
            
            self.ingredientsCollectionView.reloadData()
            
            let height = self.ingredientsCollectionView.collectionViewLayout.collectionViewContentSize.height
            self.ingredientsCollectionHeight.constant = height
            self.view.setNeedsLayout()
            
            self.setIngredientLoading(false)
            
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
            self.recipeImage.sd_setImage(with: imageURL, placeholderImage: UIImage(named: "placeholder"), options: SDWebImageOptions.delayPlaceholder, completed: { (img, error, cache, url) in
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
            
            let websiteString = recipeJSON["strSource"].stringValue
            let videoString = recipeJSON["strYoutube"].stringValue
            
            let website = URL(string: websiteString)
            let video = URL(string: videoString)
            
            self.recipe = Recipe(id: id, image: image, name: name, category: category, area: area, tags: tags, instructions: instructions, ingredients: ingredients, website: website, video: video)
                        
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
        cell.displayData(ingredient, indexPath.row, recipe.ingredients.count)
        
        return cell
        
    }
    
    // MARK: - Data handler function
    
    private func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }

}

