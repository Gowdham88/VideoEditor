//
//  SocialShareVC.swift
//  FannerCam


import UIKit
import MobileCoreServices
import MediaWatermark
import AVFoundation

var SharevideoURL: URL!

class SocialShareVC: BaseVC, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var SocialCollectionView: UICollectionView!
    @IBOutlet weak var sliderVideoTimer: UISlider!
    @IBOutlet weak var lblVideoTime: UILabel!
    @IBOutlet weak var imgThumbnail: UIImageView!
    @IBOutlet weak var btnPlay: UIImageView!
    @IBOutlet weak var viewSliderContainer: UIView!
    
    @IBOutlet weak var viewScrollContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewCollShareHeightConstraint: NSLayoutConstraint!
    var arrSocialMedia = NSArray()
    @IBOutlet weak var viewTopContainerHeight: NSLayoutConstraint!
    
    var isPhoto = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.SocialCollectionView.collectionViewLayout = CustomFlowLayout() as UICollectionViewLayout
        self.navigationItem.title = "SHARE"
        addTopLeftBackButton()
//        addTopRightNavigationBarButton(imageName: "search_gray")
        
        if isIpad() {
            viewTopContainerHeight.constant = 340
        }
        
        if (isPhoto) {
            btnPlay.isHidden = true
        }
        
        sliderVideoTimer.setThumbImage(UIImage(named: "slider_thumb"), for: .normal)
        sliderVideoTimer.setMinimumTrackImage(UIImage(named: "slider_minimum"), for: .normal)
        sliderVideoTimer.setMaximumTrackImage(UIImage(named: "slider_maximum"), for: .normal)
        
        imgThumbnail.layer.cornerRadius = 3.0
        imgThumbnail.layer.masksToBounds = true
        
        arrSocialMedia = [
            ["key":"Facebook",
             "icon":"facebook"],
            ["key":"Instagram",
             "icon":"instagram"],
            ["key":"Whatsapp",
             "icon":"whatsapp"],
            ["key":"Messanger",
             "icon":"messanger"],
            ["key":"Youtube",
             "icon":"youtube"],
            ["key":"Twitter",
             "icon":"twitter"],
            ["key":"Fanner Device",
             "icon":"fanner_device"],
            ["key":"Other",
             "icon":"others"]
        ]
        
        SocialCollectionView.reloadData()
        
//        viewCollShareHeightConstraint.constant = SocialCollectionView.contentSize.height
//        viewScrollContainerHeightConstraint.constant = viewSliderContainer.frame.maxY + viewCollShareHeightConstraint.constant
        
//        self.view.layoutIfNeeded()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- Button clicks
    override func topRightNavigationBarButtonClicked() {
        let redirectTo = loadVC(strStoryboardId: SB_OTHERS, strVCId: idSearchVC) as! SearchVC
        self.navigationController?.pushViewController(redirectTo, animated: true)
    }
    
    //MARK:- Collectionview methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrSocialMedia.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = SocialCollectionView.dequeueReusableCell(withReuseIdentifier: "customCell", for: indexPath) as! CustomCollectionViewCell
        
        let objPlatform = arrSocialMedia.object(at: indexPath.row) as! [String:String]
        
        cell.btnPlatform.setTitle(objPlatform["key"], for: .normal)
        cell.btnPlatform.setImage(UIImage(named: objPlatform["icon"]!), for: .normal)
        alignVertical(button: cell.btnPlatform)
        cell.btnPlatform.isUserInteractionEnabled = false
        //cell.labelCell.sizeToFit()
        return cell
    }

   


    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == arrSocialMedia.count-1 {
            
//            let outputFileName = self.recordedEvent.videoFolderID
//
//            var outputFilePath = NSTemporaryDirectory() as String
//            outputFilePath = outputFilePath + outputFileName! + "/mynew.mov"
//            self.fullVideoPath = outputFilePath
//            let videoURL = URL.init(fileURLWithPath: self.fullVideoPath)
            
            print("SharevideoURL: \(SharevideoURL!)")
            
            share(sharingText: "Test", sharingImage: imgThumbnail.image, sharingURL: SharevideoURL!)
        }
    }
    
    var processedURL:URL!

    
    func share(sharingText: String?, sharingImage: UIImage?, sharingURL: URL?) {
        
        var isProductPurchased: Bool = false
        if UserDefaults.standard.value(forKey: Constants.kSaveLibrary_PurchaseKey) != nil
        {
            let value: String = UserDefaults.standard.value(forKey: Constants.kSaveLibrary_PurchaseKey) as! String
            
            if value == "YES"
            {
                isProductPurchased = true
            }
        }
//        isProductPurchased = true
        if !isProductPurchased
        {
            APP_DELEGATE.displayMessageAlertWithMessage(alertMessage: "You have to purchase Save to device library product to use sharing feature. You can purchase it from Home Page.", withTitle: "Alert")
            return
        }
        
        if let item = MediaItem(url: sharingURL!) {
            let logoImage = UIImage(named: "app_logo")
            
            let firstElement = MediaElement(image: logoImage!)
            firstElement.frame = CGRect(x: 0, y: 0, width: logoImage!.size.width, height: logoImage!.size.height)
            
            item.add(element: firstElement)
            
            //            item.add(elements: [firstElement])
            
            let mediaProcessor = MediaProcessor()
            mediaProcessor.processElements(item: item) { [weak self] (result, error) in
                //                DispatchQueue.main.async {
                //                    self?.playVideo(url: result.processedUrl!, view: (self?.resultImageView)!)
                //                }
                print("result.image: \(String(describing: result.image))")
                print("result.processedUrl!: \(result.processedUrl!)")
                self?.processedURL = result.processedUrl!
                self?.addlogo(logourl: (self?.processedURL)!)
                
            }
            
        }

    }
    
    func addlogo(logourl: URL) {
        
        let sharingItems:[AnyObject?] = [logourl as AnyObject]

        print("logourl: \(logourl)")
        
        let activityViewController = UIActivityViewController(activityItems: sharingItems.compactMap({$0}), applicationActivities: nil)
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            activityViewController.popoverPresentationController?.sourceView = view
        }
        
        present(activityViewController, animated: true, completion: nil)
        
    }
    
//    func addFannerLogo(sharingURL: AnyObject) -> AnyObject {
//
//        var shareurl: AnyObject?
//
//        if let item = MediaItem(url: sharingURL as! URL) {
//            let logoImage = UIImage(named: "app_logo.jpg")
//
//            let firstElement = MediaElement(image: logoImage!)
//            firstElement.frame = CGRect(x: 0, y: 0, width: logoImage!.size.width, height: logoImage!.size.height)
//
//
//            item.add(elements: [firstElement])
//
//            let mediaProcessor = MediaProcessor()
//            mediaProcessor.processElements(item: item) { [weak self] (result, error) in
//
//                shareurl = result.processedUrl as AnyObject
//
//
//            }
//
//        }
//
//        return shareurl!
//
//    }
}
//extension SocialShareVC: UICollectionViewDelegateFlowLayout {
//
//    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
////        return CGSize( width: floor(collectionView.frame.width / 3), height: 100)
//        return CGSize( width: 100, height: 100)
//
//    }
//
//}

