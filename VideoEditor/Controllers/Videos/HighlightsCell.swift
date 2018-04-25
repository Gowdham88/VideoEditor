//
//  HighlightsCell.swift
//  VideoEditor


import UIKit
import SwipeCellKit

class HighlightsCell: SwipeTableViewCell {

    @IBOutlet weak var viewHighLightInfo: UIView!
    @IBOutlet weak var btnBest: UIButton!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    
    @IBOutlet weak var imgThumb: UIImageView!
    @IBOutlet weak var btnStudio: UIButton!
    @IBOutlet weak var lblThumbTitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        viewHighLightInfo.layer.borderColor = UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1).cgColor
        viewHighLightInfo.layer.borderWidth = 1.0
        viewHighLightInfo.layer.opacity = 0.6
        viewHighLightInfo.layer.shadowRadius = 1
        viewHighLightInfo.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        viewHighLightInfo.layer.shadowOpacity = 0.5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func generateThumbnail(url: URL, atSecond: Int64)
    {
        DispatchQueue.global().async {
            let asset = AVURLAsset(url: url)
            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true
            let actionTime: CMTime = CMTimeMake(atSecond, 1)
            let time = NSValue.init(time: actionTime)
            generator.generateCGImagesAsynchronously(forTimes: [time]) { [weak self] _, image, _, _, _ in
                
                DispatchQueue.main.async(execute: {
                    if let image = image, let _ = UIImagePNGRepresentation(UIImage(cgImage: image))
                    {
                        self?.imgThumb.image = UIImage.init(cgImage: image)
                    }
                })
                
            }
        }
        
    }
}
