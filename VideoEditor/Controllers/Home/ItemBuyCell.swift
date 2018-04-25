//
//  ItemBuyCell.swift
//  VideoEditor


import UIKit

class ItemBuyCell: UITableViewCell {

    @IBOutlet weak var lblOption: UILabel!
    @IBOutlet weak var btnBuy: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        btnBuy.layer.cornerRadius = 15.0
        btnBuy.layer.masksToBounds = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
