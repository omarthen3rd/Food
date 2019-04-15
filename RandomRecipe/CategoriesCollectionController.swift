//
//  CategoriesCollectionController.swift
//  RandomRecipe
//
//  Created by Omar Abbasi on 2019-04-15.
//  Copyright © 2019 Omar Abbasi. All rights reserved.
//

import UIKit

private let reuseIdentifier = "categoryCell"

class CategoryCollectionCell: UICollectionViewCell {
    
    @IBOutlet var name: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func displayData(_ recipe: Category) {
        name?.text = recipe.name
    }
    
    func commonInit() {
        
        
        
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
    
}

class CategoriesCollectionController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var categories = [Category]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let spacing: CGFloat = 15
        
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = CGSize(width: (UIScreen.main.bounds.width - 30), height: 80)
        layout.sectionInset = UIEdgeInsets(top: spacing, left: 0, bottom: spacing, right: 0)
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        
        collectionView.collectionViewLayout = layout
        collectionView.backgroundColor = UIColor(red:0.87, green:0.89, blue:0.92, alpha:1.0)
        
        getCategories()

    }
    
    // MARK: - API functions
    
    func getCategories() {
        
        guard let url = URL(string: "https://www.themealdb.com/api/json/v1/1/categories.php") else { return }
        getData(from: url) { (data, response, error) in
            
            guard let data = data else { return }
            let json = JSON(data)
            
            let categories = json["categories"].arrayValue
            
            for category in categories {
                let id = category["idCategory"].stringValue
                let name = category["strCategory"].stringValue
                let description = category["strCategoryDescription"].stringValue
//                guard let imageURL = URL(string: category["strCategoryThumb"].stringValue) else { return }
//                self.getData(from: imageURL, completion: { (data, response, error) in
//                    guard let data = data else { return }
//                    guard let image = UIImage(data: data) else { return }
//                    let newCategory = Category(id: id, image: image, name: name, description: description)
//                    self.categories.append(newCategory)
//                })
                let image = UIImage(named: "placeholder")
                let newCategory = Category(id: id, image: image!, name: name, description: description)
                self.categories.append(newCategory)
            }
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
            
        }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CategoryCollectionCell
    
        let category = categories[indexPath.row]
        cell.name?.text = category.name.uppercased()
    
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let name = categories[indexPath.row].name
        let recipeController = storyboard?.instantiateViewController(withIdentifier: "RecipesController") as! RecipesController
        recipeController.category = name
        
        self.navigationController?.pushViewController(recipeController, animated: true)
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.1) {
            if let cell = collectionView.cellForItem(at: indexPath) as? CategoryCollectionCell {
                cell.contentView.transform = .init(scaleX: 0.95, y: 0.95)
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.1) {
            if let cell = collectionView.cellForItem(at: indexPath) as? CategoryCollectionCell {
                cell.contentView.transform = .identity
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (UIScreen.main.bounds.width - 30), height: 80)
    }
    
    // MARK: - Data handler function
    
    private func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }

}
