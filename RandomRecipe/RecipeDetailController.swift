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
    
    var imageView: UIImageView!
    var name: UILabel!
    var amount: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = .tertiarySystemFill
        
        // ingredient image
        imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFit
        
        // ingredient name
        name = UILabel(frame: .zero)
        name.numberOfLines = 1
        name.font = UIFont(name: "NewYorkSmall-Regular", size: 16)

        // ingredient amount
        amount = UILabel(frame: .zero)
        amount.numberOfLines = 1
        amount.font = UIFont(name: "NewYork-Light", size: 12)
        
        contentView.addSubview(imageView)
//        contentView.addSubview(name)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        // set constraints
        let cellConstraints: [NSLayoutConstraint] = [
            // image constraints
            imageView.heightAnchor.constraint(equalToConstant: 40),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 1),
            imageView.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            imageView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 10),
            imageView.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: 10),
            
            // name constraints
//            name.trailingAnchor.constraint(equalTo: imageView.safeAreaLayoutGuide.leadingAnchor, constant: -10),
//            name.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 10),
//            name.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 10),
//            name.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: 10),
        ]
        
        NSLayoutConstraint.activate(cellConstraints)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func displayData(_ ingredient: Ingredient, _ row: Int, _ count: Int) {
                
        name.text = ingredient.name
        amount.text = ingredient.amount
        imageView.sd_setImage(with: ingredient.image, placeholderImage: UIImage(named: "placeholder")!, options: SDWebImageOptions.scaleDownLargeImages, context: nil)
        
        name.sizeToFit()
        amount.sizeToFit()
        
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
        
    }
    
}

class RecipeDetailController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: - IBOutlets
    var loadingView: UIView!
    var imageContainer: UIView!
    var recipeImage: UIImageView!
    
    var directionsHeader: UILabel!
    var directions: UILabel!
    
    var loadingIndicator: UIActivityIndicatorView!
    
    var scrollView = UIScrollView()
    var contentView = UIView()
    var heroImage: UIImageView!
    var recipeName: UILabel!
    var recipeDetails: UILabel!
    var ingredientsHeader: UILabel!
    var ingredientsCollectionView: UICollectionView!
    
    var reuseIdentifier = "ingredientCell"
    
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
        
        navigationItem.largeTitleDisplayMode = .never
        isLoading = true
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        print("scrollView \(scrollView.bounds.height)")
        print("contentView \(contentView.bounds.height)")
        scrollView.contentSize = CGSize(width: contentView.bounds.width, height: 900)
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
        scrollView.backgroundColor = .systemBackground
        scrollView.isScrollEnabled = true
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        
        contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: 0).isActive = true
        contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 0).isActive = true
        contentView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 0).isActive = true
        contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 0).isActive = true
        contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: 0).isActive = true
        
        // hero image
        heroImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 250, height: 250))
        heroImage.layer.cornerRadius = 8
        heroImage.layer.masksToBounds = true
        heroImage.sd_setImage(with: recipe.image, placeholderImage: UIImage(named: "placeholder"), options: SDWebImageOptions.delayPlaceholder, completed: { (img, error, cache, url) in
            self.isLoading = false
        })
        
        // recipe website/video buttons
        let buttonStackView = UIStackView()
        buttonStackView.alignment = .fill
        buttonStackView.axis = .horizontal
        buttonStackView.distribution = .fillEqually
        buttonStackView.spacing = 25
        
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
        
        // recipe details
        recipeDetails = UILabel(frame: CGRect.zero)
        recipeDetails.text = "\(recipe.category) · \(recipe.area)"
        recipeDetails.font = UIFont(name: "NewYorkSmall-Regular", size: 18)
        recipeDetails.textColor = .secondaryLabel
        recipeDetails.sizeToFit()
        
        // recipe ingredients header
        ingredientsHeader = UILabel(frame: CGRect.zero)
        ingredientsHeader.text = "Ingredients"
        ingredientsHeader.font = UIFont(name: "NewYorkSmall-Semibold", size: 19)
        ingredientsHeader.textColor = .label
        ingredientsHeader.sizeToFit()
        
        // ingredients collectionview
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width - 40, height: 60)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        ingredientsCollectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 200, height: 200), collectionViewLayout: layout)
        ingredientsCollectionView.backgroundColor = .clear
        ingredientsCollectionView.delegate = self
        ingredientsCollectionView.dataSource = self
        ingredientsCollectionView.register(IngredientCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        ingredientsCollectionView.reloadData()
        
        // add all the views
        contentView.addSubview(heroImage)
        contentView.addSubview(buttonStackView)
        contentView.addSubview(recipeName)
        contentView.addSubview(recipeDetails)
        contentView.addSubview(ingredientsHeader)
        contentView.addSubview(ingredientsCollectionView)
        
        heroImage.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        recipeName.translatesAutoresizingMaskIntoConstraints = false
        recipeDetails.translatesAutoresizingMaskIntoConstraints = false
        ingredientsHeader.translatesAutoresizingMaskIntoConstraints = false
        ingredientsCollectionView.translatesAutoresizingMaskIntoConstraints = false
                
        // constraints
        let baseSpacing: CGFloat = 20
        let ingredientsCollectionViewHeight = ingredientsCollectionView.collectionViewLayout.collectionViewContentSize.height
        
        let mainConstraints = [
            
            // hero image
            heroImage.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: baseSpacing * -1),
            heroImage.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: baseSpacing),
            heroImage.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: baseSpacing),
            heroImage.heightAnchor.constraint(equalTo: heroImage.widthAnchor, multiplier: 1, constant: 0),
            
            // read/watch button
            buttonStackView.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: baseSpacing * -1),
            buttonStackView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: baseSpacing),
            buttonStackView.topAnchor.constraint(equalTo: heroImage.bottomAnchor, constant: baseSpacing),
            
            // recipe name label
            recipeName.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: baseSpacing * -1),
            recipeName.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: baseSpacing),
            recipeName.topAnchor.constraint(equalTo: buttonStackView.bottomAnchor, constant: 15),
            
            // recipe details label
            recipeDetails.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: baseSpacing * -1),
            recipeDetails.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: baseSpacing),
            recipeDetails.topAnchor.constraint(equalTo: recipeName.bottomAnchor, constant: 5),
            
            // recipe ingredients header label
            ingredientsHeader.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: baseSpacing * -1),
            ingredientsHeader.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: baseSpacing),
            ingredientsHeader.topAnchor.constraint(equalTo: recipeDetails.bottomAnchor, constant: baseSpacing),
            
            // recipe ingredients collectionview
            ingredientsCollectionView.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: baseSpacing * -1),
            ingredientsCollectionView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: baseSpacing),
            ingredientsCollectionView.topAnchor.constraint(equalTo: ingredientsHeader.bottomAnchor, constant: 5),
            ingredientsCollectionView.heightAnchor.constraint(equalToConstant: ingredientsCollectionViewHeight)
        ]

        NSLayoutConstraint.activate(mainConstraints)
        
        contentView.layoutSubviews()
        
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
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? IngredientCell else { return UICollectionViewCell() }
        
        let ingredient = recipe.ingredients[indexPath.row]
        cell.displayData(ingredient, indexPath.row, recipe.ingredients.count)
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width - 40, height: 60)
    }
    
    // MARK: - Data handler function
    
    private func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }

}

