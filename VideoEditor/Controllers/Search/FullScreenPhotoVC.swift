//
//  FullScreenPhotoVC.swift
//  VideoEditor


import UIKit
protocol FullPhotoDelegate: class {
    func closePhotoClicked(controller: FullScreenPhotoVC)
    func btnSharePhotoClicked(controller: FullScreenPhotoVC)
    func btnInfoPhotoClicked(controller: FullScreenPhotoVC)
}


class FullScreenPhotoVC: UIViewController {
    open weak var delegate: FullPhotoDelegate?
    @IBOutlet weak var imgPhoto: UIImageView!
    var image: UIImage?
    
    @IBOutlet weak var viewButtonContainers: UIView!
    @IBOutlet weak var btnInfo: UIButton!
    @IBOutlet weak var btnDelte: UIButton!
    @IBOutlet weak var btnShare: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        imgPhoto.image = image
//        setCornerRadiusAndShadowOnButton(button: btnInfo, backColor: UIColor.white)
//        setCornerRadiusAndShadowOnButton(button: btnDelte, backColor: UIColor.white)
//        setCornerRadiusAndShadowOnButton(button: btnShare, backColor: UIColor.white)
        
        viewButtonContainers.layer.shadowRadius = 2
        viewButtonContainers.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        viewButtonContainers.layer.shadowOpacity = 1
        viewButtonContainers.layer.shadowColor = UIColor.lightGray.cgColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnBackClicked(_ sender: Any) {
        if (delegate != nil)
        {
            self.delegate?.closePhotoClicked(controller: self)
        }
    }

    @IBAction func btnShareClicked(_ sender: Any) {
        if (delegate != nil)
        {
            self.delegate?.btnSharePhotoClicked(controller: self)
        }
    }
    
    @IBAction func btnDeleteClicked(_ sender: Any) {
        showDeleteAlertMessage(viewConstroller: self)
    }
    
    @IBAction func btnInfoClicked(_ sender: Any) {
        if (delegate != nil)
        {
            self.delegate?.btnInfoPhotoClicked(controller: self)
        }
    }
}
