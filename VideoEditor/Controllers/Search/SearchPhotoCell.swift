//
//  SearchPhotoCell.swift
//  VideoEditor


import UIKit

protocol openImageOnFullScreenDelegate: class {
    func openImageOnFullScreen(image: UIImage)
    func longPressOnCell(indexPath: IndexPath, indexPathTblSearch: IndexPath)
}

class SearchPhotoCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource
{
    
    open weak var delegate: openImageOnFullScreenDelegate?
    
    @IBOutlet weak var btnDate: UIButton!
    @IBOutlet weak var collPhotos: UICollectionView!
    
    var indexPathTblSearch = IndexPath(row: 0, section: 0)
    var numberOfCells = 0
    var arrPhotos = NSMutableArray()
    
    override func awakeFromNib() {
        super.awakeFromNib()

        collPhotos.register(UINib(nibName: "PhotoCell", bundle: nil), forCellWithReuseIdentifier: "PhotoCell")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configurePhotoCollectionview(){
        collPhotos.delegate = self
        collPhotos.dataSource = self
        self.collPhotos.collectionViewLayout = CustomPhotoFlowLayout() as UICollectionViewLayout
        
        collPhotos.reloadData()
    }
    
    //MARK:- collectionview methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfCells
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        
        let lpgrOnPhoto = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressOnHighlight(gestureReconizer:)))
        lpgrOnPhoto.minimumPressDuration = 0.5
        lpgrOnPhoto.delaysTouchesBegan = true
        lpgrOnPhoto.delegate = self
        
        cell.imgPhoto.isUserInteractionEnabled = true
        cell.imgPhoto.tag = indexPath.section
        cell.imgPhoto.addGestureRecognizer(lpgrOnPhoto)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if (delegate != nil)
        {
            self.delegate?.openImageOnFullScreen(image: UIImage(named: "2players_bg")!)
        }
    }
    
    @objc func handleLongPressOnHighlight(gestureReconizer: UISwipeGestureRecognizer)
    {
        if gestureReconizer.state != UIGestureRecognizerState.ended {
            return
        }
        
//        let point = gestureReconizer.location(in: self.collPhotos)
//        let indexPath = self.collPhotos.indexPathForItem(at: point)
//
//        if let index = indexPath {
//            if (delegate != nil)
//            {
//                self.delegate?.longPressOnCell(indexPath: index, indexPathTblSearch: indexPathTblSearch)
//            }
//        } else {
//            print("Could not find index path")
//        }
        
    }
}
