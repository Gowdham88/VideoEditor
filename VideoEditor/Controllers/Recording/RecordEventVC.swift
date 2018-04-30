//
//  RecordEventVC.swift
//  FannerCam


import UIKit

class RecordEventVC: BaseVC, UITableViewDelegate, UITableViewDataSource {
   
    
    @IBOutlet weak var tblRecordEvent: UITableView!
    
    var twoDimensionalArray = NSArray()
    var arrBuyOptions: NSArray = NSArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        arrBuyOptions = ["", "Photo Tag", "Scoreboard", "Live Tags", "Live Overlay", "Live Streaming", "Recording source", "4K resolution"]
        tblRecordEvent.register(UINib(nibName: "RecordEventCell", bundle: nil), forCellReuseIdentifier: "RecordEventCell")
        
         twoDimensionalArray = [
            ["key":"REC A DAY EVENT",
             "data":[
                ["Option":"Highlights Button", "ProductKey": "true"],
                ["Option":"Photo Tag", "ProductKey": Constants.kFotoTag_PurchaseKey],
                ["Option":"Recording source", "ProductKey": Constants.kRecordingsource_PurchaseKey],
                ["Option":"4K resolution", "ProductKey": Constants.kRecording_PurchaseKey]
                ]
            ],
            ["key":"REC A MATCH EVENT",
             "data":[
                ["Option":"Highlights Button", "ProductKey": "true"],
                ["Option":"Photo Tag", "ProductKey": Constants.kFotoTag_PurchaseKey],
                ["Option":"Scoreboard", "ProductKey": Constants.kScoreboard_PurchaseKey],
                ["Option":"Live Tags", "ProductKey": Constants.kCustomTag_PurchaseKey],
                ["Option":"Live Overlay", "ProductKey": Constants.kImageOverlay_PurchaseKey],
                ["Option":"Live Streaming", "ProductKey": Constants.kLiveStreaming_PurchaseKey],
                ["Option":"Recording source", "ProductKey": Constants.kRecordingsource_PurchaseKey],
                ["Option":"4K resolution", "ProductKey": Constants.kRecording_PurchaseKey]
                ]
            ]
        ]
        
        tblRecordEvent.tableFooterView = UIView()
        
        self.navigationItem.title = "RECORD AN EVENT"
        
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //        self.view.layoutIfNeeded()
        self.navigationController?.navigationBar.isHidden = false
        NotificationCenter.default.addObserver(self, selector: #selector(self.handlePurchaseNotification), name: NSNotification.Name(rawValue: InAppHelper.IAPHelperPurchaseNotification), object: nil)

        DispatchQueue.main.async {
            APP_DELEGATE.myOrientation = .portrait
            APP_DELEGATE.landscaperSide = UIInterfaceOrientation.portrait
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            self.view.layoutIfNeeded()
            self.tblRecordEvent.reloadData()
        }
        
    }
    override func viewWillDisappear(_ animated: Bool)
    {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: InAppHelper.IAPHelperPurchaseNotification), object: nil)

    }
    //MARK: - TABLEVIEW METHODS
    func numberOfSections(in tableView: UITableView) -> Int {
        return twoDimensionalArray.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 40))
        
        let btnTitle = UIButton(frame: view.bounds)
        
        let titledata = twoDimensionalArray.object(at: section) as! NSDictionary
        btnTitle.setTitle(titledata.value(forKey: "key") as? String, for: .normal)
        btnTitle.backgroundColor = COLOR_APP_THEME()
        btnTitle.setTitleColor(UIColor.white, for: .normal)
        btnTitle.titleLabel?.font = UIFont(name: FONT_MONTSERRAT_Semi_Bold, size: 13)
        btnTitle.contentHorizontalAlignment = .left
        btnTitle.titleEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
        btnTitle.tag = section
        btnTitle.addTarget(self, action: #selector(createEventButtonClicked(_:)), for: .touchUpInside)
        
        let btnIcon = UIButton(frame: CGRect(x: view.frame.size.width - 45.0 , y: 0, width: 40.0, height: 40.0))
        btnIcon.setImage(UIImage(named: "forward_white"), for: .normal)
        btnIcon.isUserInteractionEnabled = false
        
        view.addSubview(btnTitle)
        view.addSubview(btnIcon)
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let rowdata = twoDimensionalArray.object(at: section) as? NSDictionary
        let dataarray = rowdata?.value(forKey: "data") as? NSArray
        return (dataarray?.count)!
        //return (rowdata?.count)!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 35
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecordEventCell", for: indexPath) as! RecordEventCell
        
        let rowdata = twoDimensionalArray.object(at: indexPath.section) as? NSDictionary
        let dataarray = rowdata?.value(forKey: "data") as? NSArray
        let dictionary = dataarray?[indexPath.row] as? [String:String]
        let optionName: String = (dictionary?["Option"])!
        cell.separatorInset = UIEdgeInsets.zero
        cell.lblName.textColor = COLOR_FONT_GRAY()
        cell.lblName.font = UIFont(name: FONT_MONTSERRAT_Regular, size: 11)
        
        cell.lblName.text = optionName
        cell.imagePurchase.image = UIImage.init(named: "check_blue")
        cell.btnIcon.addTarget(self, action: #selector(buyButtonClicked(_:)), for: .touchUpInside)

        cell.btnIcon.tag = indexPath.row
        cell.btnIcon.sectionNumber = indexPath.section
        if indexPath.row == 0
        {
            cell.imagePurchase.isHidden = false
            cell.btnIcon.isHidden = true
        }
        else
        {
            var isProductPurchased: Bool = false
            if UserDefaults.standard.value(forKey: (dictionary?["ProductKey"])!) != nil
            {
                let value: String = UserDefaults.standard.value(forKey: (dictionary?["ProductKey"])!) as! String
                
                if value == "YES"
                {
                    isProductPurchased = true
                }
            }
            if isProductPurchased
            {
//                cell.imagePurchase.image = UIImage.init(named: "check_blue")
                cell.btnIcon.isHidden = true
                cell.imagePurchase.isHidden = false
            }
            else
            {
//                cell.imagePurchase.image = UIImage.init(named: "cancel_red")
                cell.btnIcon.isHidden = false
                cell.imagePurchase.isHidden = true
            }
        }
        cell.selectionStyle = .none
        
        return cell
    }
    

    //MARK:- Button clicks
    @objc func createEventButtonClicked(_ sender: Any) {
        
        let button = sender as! UIButton
        
        if button.tag == 1 {
            let redirectTo = loadVC(strStoryboardId: SB_OTHERS, strVCId: idCreateMatchVC) as! CreateMatchVC
            APP_DELEGATE.currentRecordingEvent = Constants.RecordMatchEvent
            
            self.navigationController?.pushViewController(redirectTo, animated: true)
        }
        else {
            
            APP_DELEGATE.myOrientation = .all
            let redirectTo = loadVC(strStoryboardId: SB_LANDSCAPE, strVCId: idLiveCameraVC) as! LiveCameraVC
            
            let recordEventInfo: RecordingInfo = RecordingInfo()
            recordEventInfo.awayTeamLogo = nil
            recordEventInfo.homeTeamLogo = nil
            
            recordEventInfo.homeTeamName = ""
            recordEventInfo.awayTeamName = ""
            
            recordEventInfo.eventName = ""
            recordEventInfo.sportName = ""
            recordEventInfo.isDayEvent = true
            recordEventInfo.recADay = true
            recordEventInfo.createEvent = false
            redirectTo.recordEventInfo = recordEventInfo
            APP_DELEGATE.currentRecordingEvent = Constants.RecordDayEvent
            self.navigationController?.pushViewController(redirectTo, animated: true)
//            let redirectTo = loadVC(strStoryboardId: SB_LANDSCAPE, strVCId: idStreamSettingVC) as! StreamSettingVC
//            self.navigationController?.pushViewController(redirectTo, animated: true)
        }
        
    }
    @objc func handlePurchaseNotification()
    {
        self.tblRecordEvent.reloadData()
    }
    
    @objc func buyButtonClicked(_ sender: CustomButton)
    {
        var productIdentifier: String = ""
        var productSavedKey: String = ""
        var productName: String = ""
        productName = arrBuyOptions[sender.tag] as! String
//        if sender.tag == 1
//        {
//            productIdentifier = PurchaseProducts.SaveDeviceLibraryAccessProduct
//            productSavedKey = Constants.kSaveLibrary_PurchaseKey
//        }
        
        var clickedIndex = sender.tag
        if clickedIndex == 1
        {
            productIdentifier = PurchaseProducts.FotoTagAccessProduct
            productSavedKey = Constants.kFotoTag_PurchaseKey
        }
        else
        {
            if sender.sectionNumber == 0
            {
                clickedIndex = sender.tag + 4
            }
        }
        
        if clickedIndex == 2
        {
            productIdentifier = PurchaseProducts.ScoreboardAccessProduct
            productSavedKey = Constants.kScoreboard_PurchaseKey
        }
        else if clickedIndex == 3
        {
            productIdentifier = PurchaseProducts.CustomTagAccessProduct
            productSavedKey = Constants.kCustomTag_PurchaseKey
        }
        else if clickedIndex == 4
        {
            productIdentifier = PurchaseProducts.ImageOverlayAccessProduct
            productSavedKey = Constants.kImageOverlay_PurchaseKey
        }
        else if clickedIndex == 5
        {
            productIdentifier = PurchaseProducts.LiveStreamingAccessProduct
            productSavedKey = Constants.kLiveStreaming_PurchaseKey
        }
        else if clickedIndex == 6
        {
            productIdentifier = PurchaseProducts.RecordingSourceAccessProduct
            productSavedKey = Constants.kRecordingsource_PurchaseKey
        }
        else if clickedIndex == 7
        {
            productIdentifier = PurchaseProducts.RecordingAcessProduct // 4k recording
            productSavedKey = Constants.kRecording_PurchaseKey
        }
        
        APP_DELEGATE.currentProductKeyInProgress = productSavedKey
        if UserDefaults.standard.value(forKey: productSavedKey) != nil
        {
            let value: String = UserDefaults.standard.value(forKey: productSavedKey) as! String
            
            if value == "YES"
            {
                let alertMessage: String = "You already purchased " + productName + " Access"
                
                APP_DELEGATE.displayMessageAlertWithMessage(alertMessage: alertMessage, withTitle: "Alert")
                
                return
            }
        }
        
        if !APP_DELEGATE.CheckForInternetConnection()
        {
            APP_DELEGATE.displayMessageAlertWithMessage(alertMessage: NoInternetMessage, withTitle: "Alert")
            return
        }
        APP_DELEGATE.showHUDWithText(textMessage: "Purchasing...")
        PurchaseProducts.store.requestForProduct(identier: productIdentifier)
    }

}
