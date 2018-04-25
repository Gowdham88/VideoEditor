//
//  BestVC.swift
//  VideoEditor


import UIKit
import SwipeCellKit

class BestVC: BaseVC, UITableViewDelegate, UITableViewDataSource, HighlightOptionsDelegate {

    @IBOutlet weak var tblBestList: UITableView!
    
    @IBOutlet weak var viewOptionsContainer: UIView!
    @IBOutlet weak var viewOptionsTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var btnInfo: UIButton!

    
    var lpgrOnHighlightTable: UILongPressGestureRecognizer?
    
    
    //MARK:- View cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "BEST"
        addTopRightNavigationBarButton(imageName: "search_gray")
        
        tblBestList.tableFooterView = UIView()
        tblBestList.register(UINib(nibName: "videoListCell", bundle: nil), forCellReuseIdentifier: "videoListCell")
        tblBestList.register(UINib(nibName: "SearchCell", bundle: nil), forCellReuseIdentifier: "SearchCell")
        
        lpgrOnHighlightTable = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressOnHighlight(gestureReconizer:)))
        lpgrOnHighlightTable?.minimumPressDuration = 0.5
        lpgrOnHighlightTable?.delaysTouchesBegan = true
        lpgrOnHighlightTable?.delegate = self
        
        self.tblBestList.addGestureRecognizer(lpgrOnHighlightTable!)
        
        viewOptionsContainer.isHidden = true
        viewOptionsContainer.layer.shadowRadius = 2
        viewOptionsContainer.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        viewOptionsContainer.layer.shadowOpacity = 1
        viewOptionsContainer.layer.shadowColor = UIColor.lightGray.cgColor
        
        alignVertical(button: btnShare, spacing: 3)
        alignVertical(button: btnInfo, spacing: 3)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func handleLongPressOnHighlight(gestureReconizer: UISwipeGestureRecognizer)
    {
        if gestureReconizer.state != UIGestureRecognizerState.ended {
            return
        }
        
//        let point = gestureReconizer.location(in: self.tblBestList)
//        let indexPath = self.tblBestList.indexPathForRow(at: point)
//        
//        if let index = indexPath {
//            openHighlightButtonOptionsWindow()
//        } else {
//            print("Could not find index path")
//        }
//        
    }

    //MARK:- Button clicks
    override func topRightNavigationBarButtonClicked() {
        let redirectTo = loadVC(strStoryboardId: SB_OTHERS, strVCId: idSearchVC) as! SearchVC
        self.navigationController?.pushViewController(redirectTo, animated: true)
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
    
    @IBAction func btnShareClicked(_ sender: Any) {
        showDeleteAlertMessage(viewConstroller: self)
    }
    
    @IBAction func btnInfoClicked(_ sender: Any) {
    }
    
    //MARK:- Tableview methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 90
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //        let cell = tableView.dequeueReusableCell(withIdentifier: "simpleCell", for: indexPath)
        //        cell.selectionStyle = .none
        //        cell.textLabel?.text = "Record your own videos."
        //        return cell
//        let cell = tableView.dequeueReusableCell(withIdentifier: "videoListCell", for: indexPath) as! videoListCell
//        cell.selectionStyle = .none
//
//        if (indexPath.row%2) == 0 {
//            let myString = "Recorded"
//            let myAttribute = [ NSAttributedStringKey.foregroundColor: UIColor.red ]
//            let myAttrString = NSMutableAttributedString(string: myString, attributes: myAttribute)
//
//            let strDateAndUser = " 12 Dec '17 Rome, Via A, Monti 189"
//            let myAttributeDate = [ NSAttributedStringKey.foregroundColor: UIColor.white ]
//            let myAttrStringDate = NSAttributedString(string: strDateAndUser, attributes: myAttributeDate)
//            myAttrString.append(myAttrStringDate)
//            // set attributed text on a UILabel
//            cell.lblGameDescription.attributedText = myAttrString
//            cell.lblScore.isHidden = false
//        } else {
//            let myString = "By Studio"
//            let myAttribute = [ NSAttributedStringKey.foregroundColor: COLOR_APP_THEME() ]
//            let myAttrString = NSMutableAttributedString(string: myString, attributes: myAttribute)
//
//            let strDateAndUser = " 12 Dec '17 Rome, Via A, Monti 189"
//            let myAttributeDate = [ NSAttributedStringKey.foregroundColor: UIColor.white ]
//            let myAttrStringDate = NSAttributedString(string: strDateAndUser, attributes: myAttributeDate)
//            myAttrString.append(myAttrStringDate)
//            // set attributed text on a UILabel
//            cell.lblGameDescription.attributedText = myAttrString
//            cell.lblScore.isHidden = true
//        }
//
        
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
        cell.btnBest.setImage(UIImage(named: "thunder_blue_filled"), for: .normal)
        cell.btnBest.addTarget(self, action: #selector(btnBestClicked(_:)), for: .touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
//        viewOptionsTopConstraint.constant = CGFloat((indexPath.row + 1) * 100)
//
//        if viewOptionsContainer.isHidden == true {
//            viewOptionsContainer.isHidden = false
//        } else {
//            viewOptionsContainer.isHidden = true
//        }
//        let redirectTo = loadVC(strStoryboardId: SB_MAIN, strVCId: idVideoDetailsVC) as! VideoDetailsVC
//        if (indexPath.row%2) == 0 {
//            redirectTo.strScreenType = "Recorded"
//        } else {
//            redirectTo.strScreenType = "By Studio"
//        }
//        self.navigationController?.pushViewController(redirectTo, animated: true)
    }

    //MARK:- Highlight button options
    func openHighlightButtonOptionsWindow() {
        let redirectTo = HighlightOptionsVC(nibName: "HighlightOptionsVC", bundle: nil)
        redirectTo.delegate = self
        self.presentPopupViewController(redirectTo, animationType: MJPopupViewAnimationSlideTopBottom)
    }
    
    func cancelButtonClicked(controller: HighlightOptionsVC) {
        dismissPopupViewControllerWithanimationType(MJPopupViewAnimationSlideTopBottom)
    }
    
}

extension BestVC: SwipeTableViewCellDelegate {
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
