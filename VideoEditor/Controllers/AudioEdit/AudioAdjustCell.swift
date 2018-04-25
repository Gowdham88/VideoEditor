//
//  AudioAdjustCell.swift
//  VideoEditor


import UIKit
import MARKRangeSlider

class AudioAdjustCell: UITableViewCell {

    var sliderAudioChange: MARKRangeSlider!
    
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var imgPhoto: UIImageView!
    @IBOutlet weak var btnDelete: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layoutIfNeeded()
        sliderAudioChange = MARKRangeSlider.init()
        self.viewContainer.addSubview(sliderAudioChange)
        self.layoutIfNeeded()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
