//
//  SearchVC.swift
//  VideoEditor


import UIKit
import Segmentio
import SwipeCellKit

class SearchVC: BaseVC, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, HighlightOptionsDelegate, FullPhotoDelegate, openImageOnFullScreenDelegate {
    
    
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var viewSegmentContainer: UIView!
    @IBOutlet weak var viewSeachContainer: UIView!
    @IBOutlet weak var tblSearchList: UITableView!
   
    @IBOutlet weak var viewVideoEditOptionsContainer: UIView!
    @IBOutlet weak var viewVideoEditOptionsTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var btnSpeed: UIButton!
    @IBOutlet weak var btnRotate: UIButton!
    @IBOutlet weak var btnDuplicate: UIButton!
    @IBOutlet weak var btnReverse: UIButton!
    @IBOutlet weak var btnSplit: UIButton!
    
    var segmentioView: Segmentio!
    
    var lpgrOnHighlightTable: UILongPressGestureRecognizer?
    var tapOnHighlightTable: UITapGestureRecognizer?
    
    
    //MARK:- View Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "SEARCH"
        
        lpgrOnHighlightTable = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressOnHighlight(gestureReconizer:)))
        lpgrOnHighlightTable?.minimumPressDuration = 0.5
        lpgrOnHighlightTable?.delaysTouchesBegan = true
        lpgrOnHighlightTable?.delegate = self
        
        self.tblSearchList.addGestureRecognizer(lpgrOnHighlightTable!)
        
        tblSearchList.tableFooterView = UIView()
        tblSearchList.register(UINib(nibName: "SearchCell", bundle: nil), forCellReuseIdentifier: "SearchCell")
        tblSearchList.register(UINib(nibName: "SearchPhotoCell", bundle: nil), forCellReuseIdentifier: "SearchPhotoCell")
        
        addTopLeftBackButton()
//        addTopRightNavigationBarButton(imageName: "search_gray")
        addLeftViewInTextField(txtSearch)
        addSegmentToView()
        
        viewSeachContainer.isHidden = true
        
        viewVideoEditOptionsContainer.isHidden = true
        viewVideoEditOptionsContainer.layer.shadowRadius = 2
        viewVideoEditOptionsContainer.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        viewVideoEditOptionsContainer.layer.shadowOpacity = 1
        viewVideoEditOptionsContainer.layer.shadowColor = UIColor.lightGray.cgColor
        
        alignVertical(button: btnDelete, spacing: 3)
        alignVertical(button: btnSpeed, spacing: 3)
        alignVertical(button: btnSplit, spacing: 3)
        alignVertical(button: btnReverse, spacing: 3)
        alignVertical(button: btnRotate, spacing: 3)
        alignVertical(button: btnDuplicate, spacing: 3)
        
        addSwipeGestureOnScrollview()
    }
    
    func addSwipeGestureOnScrollview () {
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(gesture:)))
        swipeRight.delegate = self
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(gesture:)))
        swipeLeft.delegate = self
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipeLeft)
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
                if segmentioView.selectedSegmentioIndex < 1 {
                    segmentioView.selectedSegmentioIndex = segmentioView.selectedSegmentioIndex + 1
                }
            case UISwipeGestureRecognizerDirection.up:
                print("Swiped up")
            default:
                break
            }
        }
    }

    @objc func handleLongPressOnHighlight(gestureReconizer: UISwipeGestureRecognizer)
    {
        if gestureReconizer.state != UIGestureRecognizerState.ended {
            return
        }
        
//        let point = gestureReconizer.location(in: self.tblSearchList)
//        let indexPath = self.tblSearchList.indexPathForRow(at: point)
//
//        if segmentioView.selectedSegmentioIndex == 0 {I cehcked on ipad
//            if let index = indexPath {
//                openHighlightButtonOptionsWindow()
//            } else {
//                print("Could not find index path")
//            }
//        }
    }
    
    func addSegmentToView() {
        let segmentioViewRect = viewSegmentContainer.bounds
        segmentioView = Segmentio(frame: segmentioViewRect)
        viewSegmentContainer.addSubview(segmentioView)
        
        var contentsArr = [SegmentioItem]()
        
        contentsArr.append(SegmentioBuilder.setupSegmentItem(stroption: "Clips", strImage: ""))
        contentsArr.append(SegmentioBuilder.setupSegmentItem(stroption: "Photo", strImage: ""))
        
        SegmentioBuilder.buildSegmentioView(
            segmentioView: segmentioView,
            contents: contentsArr,
            segmentioStyle: .onlyLabel,
            totalSegments: 3
        )
        segmentioView.selectedSegmentioIndex = 0
        
        segmentioView.valueDidChange = { [weak self] _, segmentIndex in
            self?.tblSearchList.reloadData()
            self?.viewVideoEditOptionsContainer.isHidden = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //MARK:- Tableview methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if segmentioView.selectedSegmentioIndex == 0 {
            return 90
        } else {
            let width = (self.view.frame.size.width - 24)/4
            
            if indexPath.row == 0 {
                return width + 30
            } else {
                return (width*2) + 30
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //        let cell = tableView.dequeueReusableCell(withIdentifier: "simpleCell", for: indexPath)
        //        cell.selectionStyle = .none
        //        cell.textLabel?.text = "Record your own videos."
        //        return cell
        
        if segmentioView.selectedSegmentioIndex == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath) as! SearchCell
            cell.selectionStyle = .none
            
            if (indexPath.row%2) == 0 {
                let myString = "Recorded"
                let myAttribute = [ NSAttributedStringKey.foregroundColor: UIColor.red ]
                let myAttrString = NSMutableAttributedString(string: myString, attributes: myAttribute)
                
                let strDateAndUser = " 12 Dec '17 Rome, Via A, Monti 189"
                let myAttributeDate = [ NSAttributedStringKey.foregroundColor: COLOR_FONT_GRAY() ]
                let myAttrStringDate = NSAttributedString(string: strDateAndUser, attributes: myAttributeDate)
                myAttrString.append(myAttrStringDate)
                // set attributed text on a UILabel
                cell.lblGameDescription.attributedText = myAttrString
            } else {
                let myString = "By Studio"
                let myAttribute = [ NSAttributedStringKey.foregroundColor: COLOR_APP_THEME() ]
                let myAttrString = NSMutableAttributedString(string: myString, attributes: myAttribute)
                
                let strDateAndUser = " 12 Dec '17 Rome, Via A, Monti 189"
                let myAttributeDate = [ NSAttributedStringKey.foregroundColor: COLOR_FONT_GRAY() ]
                let myAttrStringDate = NSAttributedString(string: strDateAndUser, attributes: myAttributeDate)
                myAttrString.append(myAttrStringDate)
                // set attributed text on a UILabel
                cell.lblGameDescription.attributedText = myAttrString
            }
        
            cell.delegate = self
            cell.btnBest.addTarget(self, action: #selector(btnBestClicked(_:)), for: .touchUpInside)
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SearchPhotoCell", for: indexPath) as! SearchPhotoCell
            cell.selectionStyle = .none
            if indexPath.row == 0 {
                cell.numberOfCells = 4
            } else {
                cell.numberOfCells = 8
            }
            cell.delegate = self
            cell.indexPathTblSearch = indexPath
            cell.configurePhotoCollectionview()
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
//        if segmentioView.selectedSegmentioIndex == 0  {
//            viewVideoEditOptionsTopConstraint.constant = CGFloat((indexPath.row + 1) * 100)
//
//            if viewVideoEditOptionsContainer.isHidden == true {
//                viewVideoEditOptionsContainer.isHidden = false
//            } else {
//                viewVideoEditOptionsContainer.isHidden = true
//            }
//        } else {
//
//
//        }
    }
    
    //MARK:- Button Click
    @objc func btnBestClicked(_ sender: Any) {
        let button = sender as! UIButton
        
        if button.image(for: .normal) == UIImage(named: "thunder_blue_filled") {
            button.setImage(UIImage(named: "thunder_gray"), for: .normal)
        } else {
            button.setImage(UIImage(named: "thunder_blue_filled"), for: .normal)
        }
    }
    
    @IBAction func btnDeleteClicked(_ sender: Any) {
        showDeleteAlertMessage(viewConstroller: self)
    }
    
    //MARK:- Textfield methods
    func textFieldDidBeginEditing(_ textField: UITextField) {
        viewSeachContainer.isHidden = false
    }

    //MARK:- Highlight button options
    func openHighlightButtonOptionsWindow() {
        viewVideoEditOptionsContainer.isHidden = true
        let redirectTo = HighlightOptionsVC(nibName: "HighlightOptionsVC", bundle: nil)
        redirectTo.delegate = self
        self.presentPopupViewController(redirectTo, animationType: MJPopupViewAnimationSlideTopBottom)
    }
    
    func cancelButtonClicked(controller: HighlightOptionsVC) {
        dismissPopupViewControllerWithanimationType(MJPopupViewAnimationSlideTopBottom)
    }
    
    //MARK:- Photo button options
    func openPhotoInFullScreen(image: UIImage) {
        self.view.endEditing(true)
        viewVideoEditOptionsContainer.isHidden = true
        let redirectTo = FullScreenPhotoVC(nibName: "FullScreenPhotoVC", bundle: nil)
        redirectTo.delegate = self
        redirectTo.image = image
        self.presentPopupViewController(redirectTo, animationType: MJPopupViewAnimationSlideTopBottom)
    }
    
    func closePhotoClicked(controller: FullScreenPhotoVC) {
        dismissPopupViewControllerWithanimationType (MJPopupViewAnimationSlideTopBottom)
    }
    
    func btnSharePhotoClicked(controller: FullScreenPhotoVC) {
        dismissPopupViewControllerWithanimationType (MJPopupViewAnimationSlideTopBottom)
        let redirectTo = loadVC(strStoryboardId: SB_OTHERS, strVCId: idSocialShareVC) as! SocialShareVC
        redirectTo.isPhoto = true
        self.navigationController?.pushViewController(redirectTo, animated: true)
    }
    
    func btnInfoPhotoClicked(controller: FullScreenPhotoVC) {
        dismissPopupViewControllerWithanimationType (MJPopupViewAnimationSlideTopBottom)
        let deadlineTime = DispatchTime.now() + .seconds(1)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            let redirectTo = HighlightOptionsVC(nibName: "HighlightOptionsVC", bundle: nil)
            redirectTo.delegate = self
            self.presentPopupViewController(redirectTo, animationType: MJPopupViewAnimationSlideTopBottom)
        }
    }
    
    func openImageOnFullScreen(image: UIImage) {
        openPhotoInFullScreen(image: image)
    }
    
    func longPressOnCell(indexPath: IndexPath, indexPathTblSearch: IndexPath) {
        var height = CGFloat((self.view.frame.size.width - 24)/4)
        
        if indexPathTblSearch.row == 0 {
            height = height + 30.0
        } else {
            if indexPath.row > 3 {
                height = (height*3.0) + (30.0*2.0)
            } else {
                height = (height*2.0) + (30.0*2.0)
            }
        }
        
//        viewVideoEditOptionsTopConstraint.constant = height
//
//        if viewVideoEditOptionsContainer.isHidden == true {
//            viewVideoEditOptionsContainer.isHidden = false
//        } else {
//            viewVideoEditOptionsContainer.isHidden = true
//        }
    }
    
}

extension SearchVC: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        if orientation == .left {
            
            let btnShare = SwipeAction(style: .default, title: "Share") { action, indexPath in
                self.redirectToShareScreen()
            }
            
            btnShare.hidesWhenSelected = true
            
            let btnInfo = SwipeAction(style: .default, title: "Info") { action, indexPath in
                self.openHighlightButtonOptionsWindow()
            }
            
            btnInfo.hidesWhenSelected = true
            
            configure(action: btnShare, with: "Share", with: "share_blue")
            configure(action: btnInfo, with: "Info", with: "info_blue")
            
            return [btnShare, btnInfo]
        } else {
            
            let btnDelete = SwipeAction(style: .default, title: nil) { action, indexPath in
                showDeleteAlertMessage(viewConstroller: self)
            }
            configure(action: btnDelete, with: "Delete", with: "trash_blue")
            return [btnDelete]
        }
    }
    
    func configure(action: SwipeAction, with title: String, with imgName: String)
    {
        action.title = title
        action.image = UIImage(named: imgName)
        action.backgroundColor = UIColor.white
        action.textColor = COLOR_FONT_GRAY()
        action.backgroundColor = UIColor(red: 235.0/255.0, green: 235.0/255.0, blue: 235.0/255.0, alpha: 1)
        action.font = UIFont.FontWithSize(FONT_MONTSERRAT_Medium, 12)
        action.transitionDelegate = ScaleTransition.default
    }
}
