//
//  HighlightOptionsVC.swift
//  VideoEditor


import UIKit

protocol HighlightOptionsDelegate: class {
    func cancelButtonClicked(controller: HighlightOptionsVC)
}

class HighlightOptionsVC: UIViewController {

    open weak var delegate: HighlightOptionsDelegate?
    
    @IBOutlet weak var viewMainContainer: UIView!
    @IBOutlet weak var lblGameName: UILabel!
    @IBOutlet weak var lblGameDescription: UILabel!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var txtScore: UITextField!
    @IBOutlet weak var btnCancel: UIButton!
    
    @IBOutlet weak var btnTeam1: UIButton!
    @IBOutlet weak var btnTeam2: UIButton!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewMainContainer.layer.cornerRadius = 8.0
  
        let myString = "Recorded"
        let myAttribute = [ NSAttributedStringKey.foregroundColor: UIColor.red ]
        let myAttrString = NSMutableAttributedString(string: myString, attributes: myAttribute)
        
        let strDateAndUser = " 12 Dec '17 Rome, Via A, Monti 189"
        let myAttributeDate = [ NSAttributedStringKey.foregroundColor: COLOR_FONT_GRAY() ]
        let myAttrStringDate = NSAttributedString(string: strDateAndUser, attributes: myAttributeDate)
        myAttrString.append(myAttrStringDate)
        lblGameDescription.attributedText = myAttrString
        
        setCornerRadiusAndShadowOnButton(button: btnCancel, backColor: UIColor.white)
        setCornerRadiusAndShadowOnButton(button: btnSave, backColor: COLOR_APP_THEME())
        
        self.view.layoutIfNeeded()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnBackClicked(_ sender: Any) {
        if (delegate != nil)
        {
            self.delegate?.cancelButtonClicked(controller: self)
        }
    }
    
    @IBAction func btnGoClicked(_ sender: Any) {
        if (delegate != nil)
        {
            self.delegate?.cancelButtonClicked(controller: self)
        }
    }
    
    @IBAction func btnTagsClicked(_ sender: Any) {
        let button = sender as! UIButton
        
        if button.backgroundColor == COLOR_APP_THEME() {
//            button.setBackgroundImage(UIImage(named: "button_bg_white_video"), for: .normal)
            setCornerRadiusAndShadowOnButton(button: button, backColor: UIColor.white)

            button.setTitleColor(COLOR_FONT_GRAY(), for: .normal)
        } else {
//            button.setBackgroundImage(UIImage(named: "button_bg_blue_video"), for: .normal)
            setCornerRadiusAndShadowOnButton(button: button, backColor: COLOR_APP_THEME())
            button.setTitleColor(UIColor.white, for: .normal)
        }
    }
}
