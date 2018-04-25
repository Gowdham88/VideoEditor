//
//  MusicSelectionCell.swift
//  VideoEditor


import UIKit

class MusicSelectionCell: UITableViewCell {

    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var btnCheck: UIButton!
    @IBOutlet weak var lblMusicTitle: UILabel!
    @IBOutlet weak var lblMusicDescription: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
