//
//  RecipesController.swift
//  RandomRecipe
//
//  Created by Omar Abbasi on 2019-04-14.
//  Copyright © 2019 Omar Abbasi. All rights reserved.
//

import UIKit

private let reuseIdentifier = "recipeCell"

class RecipeCell: UICollectionViewCell {
    
    @IBOutlet var img: UIImageView!
    @IBOutlet var name: UILabel!
    
    private var shadowLayer: CAShapeLayer!
    
    lazy var width: NSLayoutConstraint = {
        let width = contentView.widthAnchor.constraint(equalToConstant: bounds.size.width)
        width.isActive = true
        return width
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func displayData(_ recipe: RecipePreview) {
        img?.image = recipe.image
        name?.text = recipe.name
//        recipe.image.getColors { (colors) in
//            self.backgroundColor = colors?.background
//            self.name.textColor = colors?.primary
//        }
    }
    
    func commonInit() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        img?.contentMode = .scaleAspectFill

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
        // god bless this person: https://stackoverflow.com/a/50366615/6871025
        
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 8
        contentView.layer.borderWidth = 1.0
        contentView.layer.borderColor = UIColor.clear.cgColor
        contentView.layer.masksToBounds = true
        
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 5.0)
        layer.shadowRadius = 6
        layer.shadowOpacity = 0.3
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: contentView.layer.cornerRadius).cgPath
        layer.backgroundColor = UIColor.clear.cgColor
        
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        width.constant = targetSize.width
        let size = contentView.systemLayoutSizeFitting(CGSize(width: targetSize.width, height: 1), withHorizontalFittingPriority: .required, verticalFittingPriority: verticalFittingPriority)

        return size
    }
    
}

class RecipesController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var recipes = [RecipePreview]() {
        didSet {
            guard recipes.count != 0 else { return }
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    var category = "" {
        didSet {
            getRecipes(category)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let spacing: CGFloat = 15
        
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = CGSize(width: (collectionView!.bounds.width - 50) / 2, height: 200)
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.collectionViewLayout = layout
        collectionView.backgroundColor = UIColor(red:0.87, green:0.89, blue:0.92, alpha:1.0)

    }
    
    // MARK: - API functions
    
    func getRecipes(_ category: String) {
        
        // make sure category is not empty
        guard category.count != 0 else { return }
        guard let query = category.lowercased().addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        guard let url = URL(string: "https://www.themealdb.com/api/json/v1/1/filter.php?c=\(query)") else { return }
        getData(from: url) { (data, response, error) in
            
            guard let data = data else { return }
            let json = JSON(data)
            
            let recipesJSON = json["meals"].arrayValue
            
            for recipe in recipesJSON {
                guard let imageURL = URL(string: recipe["strMealThumb"].stringValue) else { return }
                self.getData(from: imageURL, completion: { (data, response, error) in
                    guard let data = data else { return }
                    guard let image = UIImage(data: data) else { return }
                    let id = recipe["idMeal"].stringValue
                    let name = recipe["strMeal"].stringValue.capitalized
                    let newRecipe = RecipePreview(id: id, image: image, name: name)
                    self.recipes.append(newRecipe)
                })
            }
            
        }
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recipes.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! RecipeCell
    
        let recipe = recipes[indexPath.row]
        cell.displayData(recipe)
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let id = recipes[indexPath.row].id
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        vc.id = id
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.1) {
            if let cell = collectionView.cellForItem(at: indexPath) as? RecipeCell {
                cell.contentView.transform = .init(scaleX: 0.95, y: 0.95)
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.1) {
            if let cell = collectionView.cellForItem(at: indexPath) as? RecipeCell {
                cell.contentView.transform = .identity
            }
        }
    }

    // MARK: - Data handler function
    
    private func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }

}
