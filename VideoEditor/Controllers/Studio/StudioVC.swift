//
//  StudioVC.swift
//  VideoEditor

import UIKit
import Segmentio

class StudioVC: BaseVC, UITableViewDelegate, UITableViewDataSource,DragableTableDelegate {
    

    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var viewSegmentControl: UIView!
    var segmentioView: Segmentio!
    @IBOutlet weak var sliderVideo: UISlider!
    @IBOutlet weak var lblStartTime: UILabel!
    @IBOutlet weak var lblEndTime: UILabel!
    @IBOutlet weak var viewThumbContainer: UIView!
    @IBOutlet weak var imgThumb: UIImageView!
    @IBOutlet weak var imgThumbHeight: NSLayoutConstraint!
    @IBOutlet weak var imgThumbWidth: NSLayoutConstraint!
    @IBOutlet weak var btnPlay: UIImageView!
    @IBOutlet weak var viewEditContainer: UIView!
    @IBOutlet weak var viewRatioContainer: UIView!
    @IBOutlet weak var viewOverlayContainer: UIView!
    @IBOutlet weak var viewVideoEditOptionsContainer: UIView!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var btnSpeed: UIButton!
    @IBOutlet weak var btnRotate: UIButton!
    @IBOutlet weak var btnDuplicate: UIButton!
    @IBOutlet weak var btnReverse: UIButton!
    @IBOutlet weak var btnSplit: UIButton!
    
    @IBOutlet weak var btnPlusInEdit: UIButton!
    @IBOutlet weak var btnFromDeviceLibrary: UIButton!
    @IBOutlet weak var btnFromAppLibrary: UIButton!
    @IBOutlet weak var tblVideoEdit: UITableView!
    
    @IBOutlet weak var btnPlusInOverlay: UIButton!
    
    @IBOutlet weak var tblOverlayVoiceEdit: UITableView!
    
    @IBOutlet weak var viewTopContainer: UIView!
    @IBOutlet weak var viewTopContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var viewScrollContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var viewRatioContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var viewEditContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var viewOverlayContainerHeight: NSLayoutConstraint!
    
    @IBOutlet weak var viewVideoEditOptionsTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var btnRationOption169: UIButton!
     @IBOutlet weak var btnRationOption11: UIButton!
     @IBOutlet weak var btnRationOption43: UIButton!
    
    @IBOutlet weak var btnDeleteLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var btnEditSelectAll: UIButton!
    @IBOutlet weak var btnEditOnlyLast10: UIButton!
    @IBOutlet weak var btnOverlaySelectAll: UIButton!
    
    
    
    var indexSelectedForOverlay = -1
    var indexSelectedForEdit = -1
    
    var isSelectAllForEdit = false
    var isSelectAllForOverlay = false
    
    var swipeRight = UISwipeGestureRecognizer()
    var swipeLeft = UISwipeGestureRecognizer()
    
    //MARK:- View Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setCornerRadiusAndShadowOnButton(button: btnEditSelectAll, backColor: COLOR_APP_THEME())
        setCornerRadiusAndShadowOnButton(button: btnOverlaySelectAll, backColor: COLOR_APP_THEME())
        setCornerRadiusAndShadowOnButton(button: btnFromAppLibrary, backColor: COLOR_APP_THEME())
        setCornerRadiusAndShadowOnButton(button: btnFromDeviceLibrary, backColor: COLOR_APP_THEME())
        setCornerRadiusAndShadowOnButton(button: btnEditOnlyLast10, backColor: COLOR_APP_THEME())
        
        setCornerRadiusAndShadowOnButton(button: btnRationOption169, backColor: COLOR_APP_THEME())
        setCornerRadiusAndShadowOnButton(button: btnRationOption11, backColor: UIColor.white)
        setCornerRadiusAndShadowOnButton(button: btnRationOption43, backColor: UIColor.white)
        
        self.navigationItem.title = "Studio"
        addTopRightNavigationBarButton(imageName: "share_gray")
        
        self.tblVideoEdit.register(UINib(nibName: "StudioVideoEditCell", bundle: nil), forCellReuseIdentifier: "StudioVideoEditCell")
        self.tblVideoEdit.tableFooterView = UIView()
        
        self.tblOverlayVoiceEdit.register(UINib(nibName: "AudioAdjustCell", bundle: nil), forCellReuseIdentifier: "AudioAdjustCell")
        self.tblOverlayVoiceEdit.tableFooterView = UIView()
        
        if isIpad() {
            viewTopContainerHeight.constant = 400
        }
        
        self.tblVideoEdit.dragable = true
        self.tblVideoEdit.dragableDelegate = self
        
        self.view.layoutIfNeeded()
        
        let segmentioViewRect = viewSegmentControl.bounds
        segmentioView = Segmentio(frame: segmentioViewRect)
        viewSegmentControl.addSubview(segmentioView)
        
        var contentsArr = [SegmentioItem]()
        
        contentsArr.append(SegmentioBuilder.setupSegmentItem(stroption: "Edit", strImage: ""))
        contentsArr.append(SegmentioBuilder.setupSegmentItem(stroption: "Ratio", strImage: ""))
        contentsArr.append(SegmentioBuilder.setupSegmentItem(stroption: "Overlay", strImage: ""))
        
        SegmentioBuilder.buildSegmentioView(
            segmentioView: segmentioView,
            contents: contentsArr,
            segmentioStyle: .onlyLabel,
            totalSegments: 3
        )
        segmentioView.selectedSegmentioIndex = 0
        
        sliderVideo.setThumbImage(UIImage(named: "slider_thumb"), for: .normal)
        sliderVideo.setMinimumTrackImage(UIImage(named: "slider_minimum"), for: .normal)
        sliderVideo.setMaximumTrackImage(UIImage(named: "slider_maximum"), for: .normal)
        
        lblStartTime.layer.cornerRadius = lblStartTime.frame.size.height/2
        lblStartTime.layer.masksToBounds = true
        
        self.view.layoutIfNeeded()
        
        viewEditContainer.isHidden = false
        viewRatioContainer.isHidden = true
        viewOverlayContainer.isHidden = true
        viewVideoEditOptionsContainer.isHidden = true
        
        viewVideoEditOptionsContainer.layer.shadowRadius = 2
        viewVideoEditOptionsContainer.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        viewVideoEditOptionsContainer.layer.shadowOpacity = 1
        viewVideoEditOptionsContainer.layer.shadowColor = UIColor.lightGray.cgColor
        
        btnPlusInEdit.backgroundColor = COLOR_APP_THEME()
        
        imgThumb.layer.cornerRadius = 3.0
        imgThumb.layer.masksToBounds = true
        
        btnFromAppLibrary.isHidden = true
        btnFromDeviceLibrary.isHidden = true
        btnPlusInEdit.isHidden = false
        btnPlusInEdit.layer.cornerRadius = btnPlusInEdit.frame.size.height/2
        btnPlusInEdit.layer.masksToBounds = true
        
        btnPlusInOverlay.layer.cornerRadius = btnPlusInEdit.frame.size.height/2
        btnPlusInOverlay.layer.masksToBounds = true

        
        segmentioView.valueDidChange = { [weak self] _, segmentIndex in
            if segmentIndex == 0   {
                self?.viewEditContainer.isHidden = false
                self?.viewRatioContainer.isHidden = true
                self?.viewOverlayContainer.isHidden = true
                
                self?.btnFromAppLibrary.isHidden = true
                self?.btnFromDeviceLibrary.isHidden = true
                self?.btnPlusInEdit.isHidden = false
                
                self?.view.removeGestureRecognizer((self?.swipeLeft)!)
                self?.view.removeGestureRecognizer((self?.swipeRight)!)
                self?.viewTopContainer.addGestureRecognizer((self?.swipeRight)!)
                self?.viewTopContainer.addGestureRecognizer((self?.swipeLeft)!)
            } else if segmentIndex == 1 {
                self?.viewEditContainer.isHidden = true
                self?.viewRatioContainer.isHidden = false
                self?.viewOverlayContainer.isHidden = true
                self?.view.addGestureRecognizer((self?.swipeLeft)!)
                self?.view.addGestureRecognizer((self?.swipeRight)!)
                
            } else if segmentIndex == 2{
                self?.viewEditContainer.isHidden = true
                self?.viewRatioContainer.isHidden = true
                self?.viewOverlayContainer.isHidden = false
                self?.hidesBottomBarWhenPushed = false
                
                self?.view.removeGestureRecognizer((self?.swipeLeft)!)
                self?.view.removeGestureRecognizer((self?.swipeRight)!)
                self?.viewTopContainer.addGestureRecognizer((self?.swipeRight)!)
                self?.viewTopContainer.addGestureRecognizer((self?.swipeLeft)!)
            }
        }
        
        self.view.layoutIfNeeded()
        
        imgThumbWidth.constant = viewThumbContainer.frame.size.width
        imgThumbHeight.constant = viewThumbContainer.frame.size.height - 10
        
        alignVertical(button: btnDelete, spacing: 3)
        alignVertical(button: btnSpeed, spacing: 3)
        alignVertical(button: btnSplit, spacing: 3)
        alignVertical(button: btnReverse, spacing: 3)
        alignVertical(button: btnRotate, spacing: 3)
        alignVertical(button: btnDuplicate, spacing: 3)
        
        viewOverlayContainerHeight.constant = tblOverlayVoiceEdit.contentSize.height + 90 + 10
        viewEditContainerHeight.constant = tblVideoEdit.contentSize.height + 90 + 50
        
        if viewOverlayContainerHeight.constant > viewEditContainerHeight.constant {
            viewScrollContainerHeight.constant = viewTopContainer.frame.maxY + viewOverlayContainerHeight.constant
        } else {
            viewScrollContainerHeight.constant = viewTopContainer.frame.maxY + viewEditContainerHeight.constant
        }
        
        sliderVideo.minimumValue = 0
        sliderVideo.maximumValue = 1
        
        addSwipeGestureOnScrollview()
    }
    
    func addSwipeGestureOnScrollview () {
        swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(gesture:)))
        swipeRight.delegate = self
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
        
        swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(gesture:)))
        swipeLeft.delegate = self
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.viewTopContainer.addGestureRecognizer(swipeLeft)
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                if segmentioView.selectedSegmentioIndex > 0 {
                    segmentioView.selectedSegmentioIndex = segmentioView.selectedSegmentioIndex - 1
                }
            case UISwipeGestureRecognizerDirection.down:
                print("Swiped down")
            case UISwipeGestureRecognizerDirection.left:
                if segmentioView.selectedSegmentioIndex < 2 {
                    segmentioView.selectedSegmentioIndex = segmentioView.selectedSegmentioIndex + 1
                }
            case UISwipeGestureRecognizerDirection.up:
                print("Swiped up")
            default:
                break
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- BUttons click
    override func topRightNavigationBarButtonClicked() {
        let redirectTo = loadVC(strStoryboardId: SB_OTHERS, strVCId: idSocialShareVC) as! SocialShareVC
        self.navigationController?.pushViewController(redirectTo, animated: true)
    }

    @IBAction func btnPlusInEditClicked(_ sender: Any) {
        btnFromAppLibrary.isHidden = false
        btnFromDeviceLibrary.isHidden = false
        btnPlusInEdit.isHidden = true
    }
    
    @objc func videoEditMoreButtonClicked(_ sender: Any) {
        
        let button = sender as! UIButton
        indexSelectedForEdit = button.tag
        tblVideoEdit.reloadData()
        viewVideoEditOptionsTopConstraint.constant = CGFloat((button.tag + 1) * 70)
        
        if viewVideoEditOptionsContainer.isHidden == true {
            viewVideoEditOptionsContainer.isHidden = false
            btnDelete.isHidden = false
            btnSpeed.isHidden = false
            btnRotate.isHidden = false
            btnDuplicate.isHidden = false
            btnReverse.isHidden = false
            btnSplit.isHidden = false
            
            btnDeleteLeadingConstraint.constant = 0
        } else {
            viewVideoEditOptionsContainer.isHidden = true
        }
    }
    
    @IBAction func btnRationOption169Clicked(_ sender: Any) {
        imgThumbWidth.constant = viewThumbContainer.frame.size.width
        imgThumbHeight.constant = viewThumbContainer.frame.size.height - 10
        
        self.view.layoutIfNeeded()
        let imgToCrop = UIImage(named: "2players_bg")
        cropImage(cropSize: (imgToCrop?.size)!)
        
        imgThumb.contentMode = .scaleToFill
        
//        btnRationOption169.setBackgroundImage(UIImage(named: "button_bg_blue_video"), for: .normal)
        btnRationOption169.setTitleColor(UIColor.white, for: .normal)
        
//        btnRationOption43.setBackgroundImage(UIImage(named: "button_bg_white_video"), for: .normal)
        btnRationOption43.setTitleColor(UIColor.black, for: .normal)
        
        setCornerRadiusAndShadowOnButton(button: btnRationOption169, backColor: COLOR_APP_THEME())
        setCornerRadiusAndShadowOnButton(button: btnRationOption11, backColor: UIColor.white)
        setCornerRadiusAndShadowOnButton(button: btnRationOption43, backColor: UIColor.white)
//        btnRationOption11.setBackgroundImage(UIImage(named: "button_bg_white_video"), for: .normal)
        btnRationOption11.setTitleColor(UIColor.black, for: .normal)
    }
    
    @IBAction func btnRationOption11Clicked(_ sender: Any) {
//        imgThumbWidth.constant = viewThumbContainer.frame.size.height - 10
//        imgThumbHeight.constant = viewThumbContainer.frame.size.height - 10
        
        let imgToCrop = UIImage(named: "2players_bg")
        
        cropImage(cropSize: CGSize(width: (imgToCrop?.size.height)!, height: (imgToCrop?.size.height)!))
        
        self.view.layoutIfNeeded()
        
        imgThumb.contentMode = .scaleAspectFit
        
//        btnRationOption11.setBackgroundImage(UIImage(named: "button_bg_blue_video"), for: .normal)
        btnRationOption11.setTitleColor(UIColor.white, for: .normal)
        
//        btnRationOption43.setBackgroundImage(UIImage(named: "button_bg_white_video"), for: .normal)
        btnRationOption43.setTitleColor(UIColor.black, for: .normal)
        
//        btnRationOption169.setBackgroundImage(UIImage(named: "button_bg_white_video"), for: .normal)
        btnRationOption169.setTitleColor(UIColor.black, for: .normal)
        setCornerRadiusAndShadowOnButton(button: btnRationOption169, backColor: UIColor.white)
        setCornerRadiusAndShadowOnButton(button: btnRationOption11, backColor: COLOR_APP_THEME())
        setCornerRadiusAndShadowOnButton(button: btnRationOption43, backColor: UIColor.white)
    }
    
    @IBAction func btnRationOption43Clicked(_ sender: Any) {
        
//        imgThumbWidth.constant = (viewThumbContainer.frame.size.width - (viewThumbContainer.frame.size.width/4))
//        imgThumbHeight.constant = viewThumbContainer.frame.size.height - 10
        
        let imgToCrop = UIImage(named: "2players_bg")

        cropImage(cropSize: CGSize(width: ((imgToCrop?.size.width)! - ((imgToCrop?.size.width)!/5)), height: (imgToCrop?.size.height)!))
        
        self.view.layoutIfNeeded()
        
        imgThumb.contentMode = .scaleAspectFit
        
//        btnRationOption43.setBackgroundImage(UIImage(named: "button_bg_blue_video"), for: .normal)
        btnRationOption43.setTitleColor(UIColor.white, for: .normal)
        
//        btnRationOption11.setBackgroundImage(UIImage(named: "button_bg_white_video"), for: .normal)
        btnRationOption11.setTitleColor(UIColor.black, for: .normal)
        
//        btnRationOption169.setBackgroundImage(UIImage(named: "button_bg_white_video"), for: .normal)
        btnRationOption169.setTitleColor(UIColor.black, for: .normal)
        setCornerRadiusAndShadowOnButton(button: btnRationOption169, backColor: UIColor.white)
        setCornerRadiusAndShadowOnButton(button: btnRationOption11, backColor: UIColor.white)
        setCornerRadiusAndShadowOnButton(button: btnRationOption43, backColor: COLOR_APP_THEME())
    }
    
    @IBAction func btnSelectAllEditClicked(_ sender: Any) {
        isSelectAllForEdit = !isSelectAllForEdit
        tblVideoEdit.reloadData()
        
        if isSelectAllForEdit {
            viewVideoEditOptionsContainer.isHidden = false
            viewVideoEditOptionsTopConstraint.constant = 0
            
            btnDelete.isHidden = false
            btnSpeed.isHidden = true
            btnRotate.isHidden = true
            btnDuplicate.isHidden = true
            btnReverse.isHidden = true
            btnSplit.isHidden = true
            btnDeleteLeadingConstraint.constant = viewVideoEditOptionsContainer.frame.size.width/2 - btnDelete.frame.size.width/2
        } else {
            viewVideoEditOptionsContainer.isHidden = true
            
            btnDelete.isHidden = false
            btnSpeed.isHidden = false
            btnRotate.isHidden = false
            btnDuplicate.isHidden = false
            btnReverse.isHidden = false
            btnSplit.isHidden = false
            btnDeleteLeadingConstraint.constant = 0
        }
    }
    
    @IBAction func btnSelectAllOverlayClicked(_ sender: Any) {
        isSelectAllForOverlay = !isSelectAllForOverlay
        tblOverlayVoiceEdit.reloadData()
    }
    
    @objc func btnDeleteOnAudioCellClicked()
    {
        showDeleteAlertMessage(viewConstroller: self)
    }
    
    @IBAction func btnDeleteClicked(_ sender: Any) {
        showDeleteAlertMessage(viewConstroller: self)
    }
    
    func cropImage(cropSize: CGSize) {
        
        let imgToCrop = UIImage(named: "2players_bg")
        
        let imageWidth = imgToCrop?.size.width
        let imageHeight = imgToCrop?.size.height
        let width = cropSize.width
        let height = imageHeight!
        let origin = CGPoint(x: (imageWidth! - width)/2, y: 0)//(imageHeight! - height)/2)
        let size = CGSize(width: width, height: height)
    
        imgThumb?.image = imgToCrop?.crop(rect: CGRect(origin: origin, size: size))
    }
    
    
    //MARK:- Tableview methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tblOverlayVoiceEdit == tableView {
            return 4
        } else {
            return 4
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if tblOverlayVoiceEdit == tableView {
            return 50
        }
        return 70
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tblOverlayVoiceEdit == tableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AudioAdjustCell", for: indexPath) as! AudioAdjustCell
            cell.layoutIfNeeded()
            cell.sliderAudioChange.frame = CGRect(x: cell.imgPhoto.frame.maxX, y: 10, width: self.view.frame.size.width - cell.imgPhoto.frame.maxX - cell.btnDelete.frame.size.width - 16, height: cell.viewContainer.frame.size.height - 20)
            cell.sliderAudioChange.leftThumbImage = UIImage(named: "forward_border_arrow")
            cell.sliderAudioChange.rightThumbImage = UIImage(named: "back_border_arrow")
            cell.sliderAudioChange.trackImage = UIImage(named: "slider_left_empty_image")
            cell.sliderAudioChange.rangeImage = UIImage(named: "red_audio_wave")
            
            cell.selectionStyle = .none
            
            if isSelectAllForOverlay == true
            {
                cell.contentView.backgroundColor = COLOR_APP_THEME()
            }
            else if indexSelectedForOverlay == indexPath.row
            {
                cell.contentView.backgroundColor = COLOR_APP_THEME()
            }
            else
            {
                cell.contentView.backgroundColor = UIColor.white
            }
            
            cell.btnDelete.addTarget(self, action: #selector(btnDeleteOnAudioCellClicked), for: .touchUpInside)
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "StudioVideoEditCell", for: indexPath) as! StudioVideoEditCell
            cell.layoutIfNeeded()
            cell.sliderRange.frame = CGRect(x: cell.imgThumb.frame.maxX, y: 10, width: self.view.frame.size.width - cell.imgThumb.frame.maxX - cell.btnMore.frame.size.width - 16, height: cell.viewSliderContainer.frame.size.height - 20)
            cell.sliderRange.leftThumbImage = UIImage(named: "forward_border_arrow")
            cell.sliderRange.rightThumbImage = UIImage(named: "back_border_arrow")
            cell.sliderRange.trackImage = UIImage(named: "slider_left_empty_image")
            
//            if (indexPath.row%2) == 0 {
//                cell.sliderRange.rangeImage = UIImage(named: "slider_range_blue")
//            } else {
                cell.sliderRange.rangeImage = UIImage(named: "slider_range_white")
//            }
        
            cell.btnMore.addTarget(self, action: #selector(videoEditMoreButtonClicked(_:)), for: .touchUpInside)
            cell.btnMore.tag = indexPath.row
            
            cell.contentView.backgroundColor = UIColor.white
            
            if isSelectAllForEdit == true {
//                cell.contentView.backgroundColor = COLOR_APP_THEME()
                cell.sliderRange.rangeImage = UIImage(named: "slider_range_blue")
            } else if indexSelectedForEdit == indexPath.row {
//                cell.contentView.backgroundColor = COLOR_APP_THEME()
                cell.sliderRange.rangeImage = UIImage(named: "slider_range_blue")
            } else {
                cell.contentView.backgroundColor = UIColor.white
//                cell.sliderRange.rangeImage = UIImage(named: "slider_range_blue")
            }
            
            cell.selectionStyle = .none

            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tblVideoEdit == tableView {
            indexSelectedForEdit = indexPath.row
            viewVideoEditOptionsContainer.isHidden = true
            tblVideoEdit.reloadData()
        } else if tblOverlayVoiceEdit == tableView {
            indexSelectedForOverlay = indexPath.row
            
            tblOverlayVoiceEdit.reloadData()
        }
        
        sliderVideo.setValue(Float(indexPath.row)/Float(tableView.numberOfRows(inSection: 0)), animated: true)
    }
    
    // MARK: - DragableTableDelegate
    
    func tableView(_ tableView: UITableView, canDragCellFrom indexPath: IndexPath, withTouchPoint point:CGPoint) -> Bool
    {
        
        let previousIndex = indexSelectedForEdit
        indexSelectedForEdit = indexPath.row
//        tblVideoEdit.reloadRows(at: [IndexPath(row: previousIndex, section: 0), indexPath], with: .none)
//        tblVideoEdit.reloadRows(at: [indexPath], with: .none)
        return true
    }
    
    func tableView(_ tableView: UITableView, dragCellFrom fromIndexPath: IndexPath, toIndexPath: IndexPath) {
//        dataArray.exchangeObject(at: fromIndexPath.row, withObjectAt: toIndexPath.row)
//        indexSelectedForEdit = toIndexPath.row
//        tblVideoEdit.reloadData()
    }
    func tableView(_ tableView: UITableView, dragCellFrom fromIndexPath: IndexPath, overIndexPath: IndexPath) {
//        dataArray.removeObject(at: fromIndexPath.row)
    }
    
    func tableView(_ tableView: UITableView, endDragCellTo indexPath: IndexPath)
    {
        indexSelectedForEdit = indexPath.row
//        tblVideoEdit.reloadData()
    }
}

extension UIImage {
    func crop( rect: CGRect) -> UIImage {
        var rect = rect
        rect.origin.x*=self.scale
        rect.origin.y*=self.scale
        rect.size.width*=self.scale
        rect.size.height*=self.scale
        
        let imageRef = self.cgImage!.cropping(to: rect)
        let image = UIImage(cgImage: imageRef!, scale: self.scale, orientation: self.imageOrientation)
        return image
    }
}
