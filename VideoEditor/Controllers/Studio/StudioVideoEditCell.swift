//
//  StudioVideoEditCell.swift
//  VideoEditor


import UIKit
import MARKRangeSlider

class StudioVideoEditCell: UITableViewCell {

    var sliderRange: MARKRangeSlider!
    
    @IBOutlet weak var viewSliderContainer: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var imgThumb: UIImageView!
    @IBOutlet weak var lblThumbTitle: UILabel!
    @IBOutlet weak var btnMore: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
//        self.layoutIfNeeded()
        sliderRange = MARKRangeSlider.init()
        self.viewSliderContainer.addSubview(sliderRange)
//        self.layoutIfNeeded()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
