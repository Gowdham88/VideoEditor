//
//  SearchCell.swift
//  VideoEditor


import UIKit
import SwipeCellKit

class SearchCell: SwipeTableViewCell {

    @IBOutlet weak var lblSeriesName: UILabel!
    @IBOutlet weak var lblGameName: UILabel!
    @IBOutlet weak var lblGameDescription: UILabel!
    @IBOutlet weak var imgThumb: UIImageView!
    @IBOutlet weak var viewVideoDescriptionContainer: UIView!
    @IBOutlet weak var btnBest: UIButton!
    @IBOutlet weak var lblVideoName: UILabel!
    @IBOutlet weak var lblVideoTime: UILabel!
    @IBOutlet weak var btnStudio: UIButton!
    @IBOutlet weak var btnThumbTitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        viewVideoDescriptionContainer.layer.borderColor = UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1).cgColor
        viewVideoDescriptionContainer.layer.borderWidth = 1.0
        viewVideoDescriptionContainer.layer.opacity = 0.6
        viewVideoDescriptionContainer.layer.shadowRadius = 1
        viewVideoDescriptionContainer.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        viewVideoDescriptionContainer.layer.shadowOpacity = 0.5
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
