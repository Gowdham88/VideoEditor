//
//  VolumeCell.swift
//  VideoEditor


import UIKit

class VolumeCell: UITableViewCell {

    @IBOutlet weak var sliderVolume: UISlider!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        sliderVolume.setThumbImage(UIImage(named: "slider_thumb"), for: .normal)
        sliderVolume.setMinimumTrackImage(UIImage(named: "slider_minimum"), for: .normal)
        sliderVolume.setMaximumTrackImage(UIImage(named: "slider_maximum"), for: .normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
