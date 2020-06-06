//
//  CategoriesListController.swift
//  RandomRecipe
//
//  Created by Omar Abbasi on 2019-04-15.
//  Copyright © 2019 Omar Abbasi. All rights reserved.
//

import UIKit
import SDWebImage

private let reuseIdentifier = "categoryCell"

class CategoryCollectionCell: UICollectionViewCell {
    
    var name: UILabel!
    var catImage: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func displayData(_ category: Category) {
        name?.text = category.name
        name.sizeToFit()
        
        guard let image = UIImage(named: "\(category.name.lowercased())") else { return }
        catImage.image = image
//        imageView.sd_setImage(with: recipe.image, placeholderImage: placeholder, options: SDWebImageOptions.scaleDownLargeImages, completed: nil)
    }
    
    func commonInit() {
        
        contentView.backgroundColor = UIColor.tertiarySystemBackground
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
        
        name = UILabel(frame: .zero)
        name.font = UIFont(name: "NewYorkSmall-Bold", size: 21)
        name.numberOfLines = 1
        
        catImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        catImage.contentMode = .scaleAspectFit
        
        name.translatesAutoresizingMaskIntoConstraints = false
        catImage.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(name)
        contentView.addSubview(catImage)
        
        // constraints
        
        let spacing: CGFloat = 10
        
        let mainConstraints: [NSLayoutConstraint] = [
            // name label
            name.topAnchor.constraint(equalTo: contentView.topAnchor, constant: spacing),
            name.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: spacing * -1),
            name.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: spacing),
            
            // image view
            catImage.leadingAnchor.constraint(equalTo: name.trailingAnchor, constant: spacing),
            catImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: spacing * -1),
            catImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: spacing),
            catImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: spacing * -1),
            catImage.heightAnchor.constraint(equalToConstant: 50),
            catImage.widthAnchor.constraint(equalTo: catImage.heightAnchor, multiplier: 1)
            
        ]
        
        NSLayoutConstraint.activate(mainConstraints)
        
    }
    
}

class CategoriesCollectionController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var categories = [Category]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "NewYorkSmall-Black", size: 30)!]
        
        let spacing: CGFloat = 15
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: (UIScreen.main.bounds.width - (spacing * 2)), height: 70)
        layout.sectionInset = UIEdgeInsets(top: spacing, left: 0, bottom: spacing, right: 0)
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        
        collectionView.collectionViewLayout = layout
        collectionView.backgroundColor = UIColor.secondarySystemBackground
        collectionView.register(CategoryCollectionCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
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
                let imageURL = URL(string: category["strCategoryThumb"].stringValue)
                print(category["strCategoryThumb"].stringValue)
                let newCategory = Category(id: id, image: imageURL, name: name, description: description)
                self.categories.append(newCategory)
            }
            
            // sort by descending name
            self.categories.sort { (a, b) -> Bool in
                return b.name > a.name
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
        cell.displayData(category)
    
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let name = categories[indexPath.row].name
        let recipeController = storyboard?.instantiateViewController(withIdentifier: "RecipesController") as! RecipesController
        recipeController.category = name
        recipeController.title = name
        
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
        return CGSize(width: (UIScreen.main.bounds.width - 30), height: 70)
    }
    
    // MARK: - Data handler function
    
    private func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }

}
