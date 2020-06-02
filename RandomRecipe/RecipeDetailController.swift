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
    var loadingView: UIView!
    var imageContainer: UIView!
    var recipeImage: UIImageView!
    
    var ingredientsHeader: UILabel!
    var directionsHeader: UILabel!
    var directions: UILabel!
    
    var ingredientsCollectionView: UICollectionView!
    var ingredientsCollectionHeight: NSLayoutConstraint!
    
    var loadingIndicator: UIActivityIndicatorView!
    
    var scrollView = UIScrollView()
    var containerView = UIView()
    var heroImage: UIImageView!
    var recipeName: UILabel!
    var recipeDetails: UILabel!
    
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
            DispatchQueue.main.async {
                self.updateInterfaceWith(recipe: recipe)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        for name in UIFont.familyNames {
          print(name)
          if let nameString = name as? String {
            print(UIFont.fontNames(forFamilyName: nameString))
          }
        }

        
        navigationItem.largeTitleDisplayMode = .never
        
        isLoading = true
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        scrollView.frame = view.bounds
        containerView.frame = CGRect(x: 0, y: 0, width: scrollView.contentSize.width, height: scrollView.contentSize.height)
    }
    
    func setLoading(_ loading: Bool) {
        
        if loading {
            createLoadingView()
        }
        
    }
    
    func setIngredientLoading(_ loading: Bool) {
        
        if loading {
            ingredientsCollectionView.isScrollEnabled = false
        } else {
            ingredientsCollectionView.isScrollEnabled = true
        }
        
    }
    
    func createLoadingView() {
        
        loadingIndicator = UIActivityIndicatorView(frame: CGRect.zero)
        loadingIndicator.style = .large
        loadingIndicator.startAnimating()
        loadingIndicator.sizeToFit()
        loadingIndicator.center = view.center
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(loadingIndicator)
        view.layoutSubviews()
        
        loadingIndicator.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        loadingIndicator.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        
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
        
        imageContainer.backgroundColor = UIColor.clear
        
        recipeName.font = UIFont(name: "Merriweather-Black", size: recipeName.font.pointSize)
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
        
        loadingIndicator.removeFromSuperview()
        
        // start creating views
        containerView = UIView(frame: UIScreen.main.bounds)

        scrollView = UIScrollView(frame: UIScreen.main.bounds)
        scrollView.delegate = self
        scrollView.backgroundColor = .systemBackground
        scrollView.addSubview(containerView)
        view.addSubview(scrollView)
        
        // hero image
        heroImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 250, height: 250))
        heroImage.layer.cornerRadius = 8
        heroImage.layer.masksToBounds = true
        heroImage.sd_setImage(with: recipe.image, placeholderImage: UIImage(named: "placeholder"), options: SDWebImageOptions.delayPlaceholder, completed: { (img, error, cache, url) in
            self.isLoading = false
        })
        heroImage.translatesAutoresizingMaskIntoConstraints = false
        
        // recipe website/video buttons
        let buttonStackView = UIStackView()
        buttonStackView.alignment = .fill
        buttonStackView.axis = .horizontal
        buttonStackView.distribution = .fillEqually
        buttonStackView.spacing = 25
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        
        if (recipe.video != nil) {
            let playButtonImage = UIImage(systemName: "play.rectangle.fill")
            let playButton = UIButton(frame: CGRect.zero)
            playButton.setImage(playButtonImage, for: [])
            playButton.imageView?.tintColor = .label
            playButton.backgroundColor = .secondarySystemBackground
            playButton.layer.cornerRadius = 8
            playButton.setTitle(" Watch", for: [])
            playButton.setTitleColor(.label, for: [])
            
            buttonStackView.addArrangedSubview(playButton)
            playButton.heightAnchor.constraint(equalToConstant: 45).isActive = true
        }
        
        if (recipe.website != nil) {
            let webButtonImage = UIImage(systemName: "safari.fill")
            let webButton = UIButton(frame: CGRect.zero)
            webButton.setImage(webButtonImage, for: [])
            webButton.imageView?.tintColor = .label
            webButton.backgroundColor = .secondarySystemBackground
            webButton.layer.cornerRadius = 8
            webButton.setTitle(" Read", for: [])
            webButton.setTitleColor(.label, for: [])
            
            buttonStackView.addArrangedSubview(webButton)
            webButton.heightAnchor.constraint(equalToConstant: 45).isActive = true
        }
        
        // recipe name
        recipeName = UILabel(frame: CGRect.zero)
        recipeName.text = recipe.name
        recipeName.font = UIFont(name: "NewYorkSmall-Bold", size: 25)
        recipeName.textColor = .label
        recipeName.sizeToFit()
        recipeName.translatesAutoresizingMaskIntoConstraints = false
        
        // recipe description
        recipeDetails = UILabel(frame: CGRect.zero)
        recipeDetails.text = "\(recipe.category) · \(recipe.area)"
        recipeDetails.font = UIFont(name: "NewYorkSmall-Regular", size: 18)
        recipeDetails.textColor = .secondaryLabel
        recipeDetails.sizeToFit()
        recipeDetails.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(heroImage)
        containerView.addSubview(buttonStackView)
        containerView.addSubview(recipeName)
        containerView.addSubview(recipeDetails)
        
        // constraints
        let baseSpacing: CGFloat = 20
        
        let mainConstraints = [
            
            // hero image
            heroImage.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: baseSpacing * -1),
            heroImage.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: baseSpacing),
            heroImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: baseSpacing),
            heroImage.heightAnchor.constraint(equalTo: heroImage.widthAnchor, multiplier: 1, constant: 0),
            
            // read/watch button
            buttonStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: baseSpacing * -1),
            buttonStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: baseSpacing),
            buttonStackView.topAnchor.constraint(equalTo: heroImage.bottomAnchor, constant: baseSpacing),
            
            // recipe name label
            recipeName.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: baseSpacing * -1),
            recipeName.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: baseSpacing),
            recipeName.topAnchor.constraint(equalTo: buttonStackView.bottomAnchor, constant: 15),
            
            // recipe name label
            recipeDetails.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: baseSpacing * -1),
            recipeDetails.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: baseSpacing),
            recipeDetails.topAnchor.constraint(equalTo: recipeName.bottomAnchor, constant: 5),
        ]

        NSLayoutConstraint.activate(mainConstraints)

        // remove loading view
        
//        DispatchQueue.main.async {
//            for view in self.view.subviews {
//                view.removeFromSuperview()
//            }
//        }
        
//        DispatchQueue.main.async {
//
//            if (recipe.video != nil) {
//                // has video
//                let playButton = UIImage(systemName: "play.rectangle.fill")
//
//                let rightButton1 = UIBarButtonItem(image: playButton, style: .plain, target: self, action: #selector(self.openURL(_:)))
//                rightButton1.tag = 0
//                self.navigationItem.setRightBarButtonItems([rightButton1], animated: true)
//            }
//
//            if (recipe.website != nil) {
//                // has webpage or blogpost
//                let webButton = UIImage(systemName: "safari.fill")
//
//                let rightButton2 = UIBarButtonItem(image: webButton, style: .plain, target: self, action: #selector(self.openURL(_:)))
//                rightButton2.tag = 1
//
//                if (self.navigationItem.rightBarButtonItems != nil) {
//                    self.navigationItem.rightBarButtonItems?.append(rightButton2)
//                } else {
//                    self.navigationItem.setRightBarButton(rightButton2, animated: true)
//                }
//            }
//
//            self.recipeName.text = recipe.name
//            self.recipeName.sizeToFit()
//
//            self.details.text = "\(recipe.category) · \(recipe.area)"
//            self.directions.text = recipe.instructions
//
//            self.ingredientsCollectionView.reloadData()
//
//            let height = self.ingredientsCollectionView.collectionViewLayout.collectionViewContentSize.height
//            self.ingredientsCollectionHeight.constant = height
//            self.view.setNeedsLayout()
//
//            self.setIngredientLoading(false)
//
//        }
        
    }
    
    func fetchRecipe(_ id: String) {
        
        print("\(#function) - fetching recipe with id: \(id)")
        guard let url = URL(string: "https://www.themealdb.com/api/json/v1/1/lookup.php?i=\(id)") else { return }
        getData(from: url) { (data, response, error) in
            
            guard let data = data else { return }
            let json = JSON(data)
            let recipeJSON = json["meals"].arrayValue[0]
            // get image from URL
            let imageURL = URL(string: recipeJSON["strMealThumb"].stringValue)

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
            
            self.recipe = Recipe(id: id, image: imageURL, name: name, category: category, area: area, tags: tags, instructions: instructions, ingredients: ingredients, website: website, video: video)
                        
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

