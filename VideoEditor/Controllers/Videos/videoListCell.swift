//
//  videoListCell.swift
//  VideoEditor


import UIKit
import AVFoundation

class videoListCell: UITableViewCell {
    @IBOutlet weak var imgPhoto: UIImageView!
    @IBOutlet weak var btnPresetValue: UIButton!
    @IBOutlet weak var lblSeriesName: UILabel!
    @IBOutlet weak var lblGameName: UILabel!
    @IBOutlet weak var lblGameDescription: UILabel!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var btnOptimize: UIButton!
    @IBOutlet weak var btnRename: UIButton!
    @IBOutlet weak var btnVideoSize: UIButton!
    @IBOutlet weak var btnVideoLength: UIButton!
    @IBOutlet weak var lblScore: UILabel!
    @IBOutlet var deviceImage: UIImageView!
    @IBOutlet var deviceModel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        btnDelete.layer.cornerRadius = 12.5
        btnDelete.layer.masksToBounds = true
        
        btnOptimize.layer.cornerRadius = 12.5
        btnOptimize.layer.masksToBounds = true
        
        btnRename.layer.cornerRadius = 12.5
        btnRename.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func generateThumbnail(url: URL, cacheStorage: NSCache<AnyObject, AnyObject>)
    {
        DispatchQueue.global().async {
            let asset = AVURLAsset(url: url)
            
            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true
            let time = NSValue.init(time: kCMTimeZero)
            generator.generateCGImagesAsynchronously(forTimes: [time]) { [weak self] _, image, _, _, _ in
                
                DispatchQueue.main.async(execute: {
                    if let image = image, let _ = UIImagePNGRepresentation(UIImage(cgImage: image))
                    {
                        self?.imgPhoto.image = UIImage.init(cgImage: image)
                        if self?.imgPhoto.image != nil
                        {
                            cacheStorage.setObject((self?.imgPhoto.image)!, forKey: url.path as NSString)
                        }
                        
                        
                    }
                })
                
            }
        }
        
    }
    
}
