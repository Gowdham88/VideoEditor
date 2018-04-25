//
//  SimpleButtonCell.swift
//  VideoEditor


import UIKit

class SimpleButtonCell: UITableViewCell {

    @IBOutlet weak var btnSubmit: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
//        btnSubmit.layer.cornerRadius = 20.0
//        btnSubmit.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
