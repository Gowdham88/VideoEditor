//
//  CustomFlowLayout.swift
//  FannerCam


import UIKit

class CustomFlowLayout: UICollectionViewFlowLayout {
    
    //init function for class
    override init() {
        super.init()
        setupLayout()
    }
    
    //calling setupLayout() function on class initialization
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLayout()
    }
    
    //function for setting constraints of flow layoyt
    func setupLayout() {
        minimumInteritemSpacing = 1
        minimumLineSpacing = 1
        scrollDirection = .vertical
    }
    
    //itemsize corresponding to cell size in collection view layout
    override var itemSize: CGSize {
        set {
            
        }
        get {
            let numberOfColumns: CGFloat = 3.0
            let itemWidth = CGFloat((((collectionView?.frame.width)! - (numberOfColumns - 1)) / numberOfColumns))
            return CGSize(width: itemWidth, height: 85)
            
        }
    }
}
