//
//  HomeVC.swift
//  VideoEditor


import UIKit
import StoreKit
import Alamofire

class HomeVC: BaseVC, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var lblCountryAndDate: UILabel!
    @IBOutlet weak var accountView: UIView!
    @IBOutlet weak var recordingView: UIView!
    @IBOutlet weak var lblBatteryPercentage: UILabel!
    @IBOutlet weak var lblStorage: UILabel!
    @IBOutlet weak var lblInterentStatus: UILabel!
    @IBOutlet weak var lblInterentStrength: UILabel!
    @IBOutlet weak var internetSymbolImageView: UIImageView!
    
    @IBOutlet weak var lblSeparatorAboveTable: UILabel!
    
    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var viewScrollContainer: UIView!
    @IBOutlet weak var viewScrollContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tblBuyOptionsHeightConstraint: NSLayoutConstraint!
    var arrBuyOptions: NSArray = NSArray()
    let reachability = Reachability()!
    @IBOutlet weak var tblBuyOptions: UITableView!
    var products = [SKProduct]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //declare this inside of viewWillAppear
        
        self.navigationItem.title = "HOME"
        addTopRightNavigationBarButtonWithText(strText: "Logout")
        
//        let item = UIBarButtonItem.init(image: UIImage.init(named: "button_bg_blue"), style: .plain, target: self, action: #selector(LogoutButtonClicke))
//        self.navigationItem.setRightBarButtonItems([item], animated: true)
        arrBuyOptions = ["Scoreboard","Custom Tag","Image in overlay","Live Streaming","4K recording","Foto tag","Save to device library","Recording source"]
        
        let currentLocaleIdentifier: String = (Locale.current as NSLocale).object(forKey: .countryCode) as! String
        
        let countryName: String = (Locale.current as NSLocale).displayName(forKey: .countryCode, value: currentLocaleIdentifier)!
        let dateFormatter = DateFormatter.init()

        dateFormatter.dateFormat = "dd MMMM yyyy"
        
        let dateString = dateFormatter.string(from: Date.init())
        
        self.lblCountryAndDate.text = "\(countryName), \(dateString)"
        
        tblBuyOptions.tableFooterView = UIView()
        tblBuyOptions.register(UINib(nibName: "ItemBuyCell", bundle: nil), forCellReuseIdentifier: "ItemBuyCell")
        
//        tblBuyOptions.reloadData()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tap.delegate = self
        recordingView.addGestureRecognizer(tap)
        
        let accountviewtap = UITapGestureRecognizer(target: self, action: #selector(accountTapClicked))
        accountviewtap.delegate = self
        accountView.addGestureRecognizer(accountviewtap)
        
        if !APP_DELEGATE.CheckTokenExpireStatus()
        {
            APP_DELEGATE.CheckForFannerServiceStatus()
        }
        
    }
    @objc func LogoutButtonClicke()
    {
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.handlePurchaseNotification), name: NSNotification.Name(rawValue: InAppHelper.IAPHelperPurchaseNotification), object: nil)
        if (!UIDevice.current.isBatteryMonitoringEnabled)
        {
            UIDevice.current.isBatteryMonitoringEnabled = true
        }
        var batteryLevel: Float = UIDevice.current.batteryLevel
        batteryLevel = batteryLevel * 100
        let batteryLevelInt:Int = Int(batteryLevel)

        self.lblBatteryPercentage.text = "\(batteryLevelInt)%"
        
        self.lblStorage.text = UIDevice.current.freeDiskSpaceInGB
        
        self.lblInterentStatus.text = APP_DELEGATE.CheckForInternetReachbilityStatus()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged(note:)), name: ReachabilityChangedNotification,object: reachability)
        
        do{
            try reachability.startNotifier()
        }catch{
//            print("could not start reachability notifier")
        }
        tblBuyOptions.reloadData()
        //NSLog("battery : %f", UIDevice.current.batteryLevel);
    }
    override func viewWillDisappear(_ animated: Bool)
    {
        reachability.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: ReachabilityChangedNotification, object: reachability)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: InAppHelper.IAPHelperPurchaseNotification), object: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func accountTapClicked()
    {
        let redirectTo = loadVC(strStoryboardId: SB_MAIN, strVCId: isWebviewVC) as! WebviewVC
        self.navigationController?.pushViewController(redirectTo, animated: true)
    }
    @objc func handleTap()
    {
        let redirectTo = loadVC(strStoryboardId: SB_MAIN, strVCId: idTagManageVC) as! TagManagementVC
        self.navigationController?.pushViewController(redirectTo, animated: true)
    }
    override func topRightNavigationBarButtonClicked() // Logout clicked
    {
        let userDict = UserDefaults.standard.value(forKey: Constants.USER_PROFILE_INFO) as! NSDictionary
        let authDict = userDict.value(forKey: "auth") as! NSDictionary
        
        let tokenDict = authDict.value(forKey: "token") as! NSDictionary
        
        let authToken = tokenDict.value(forKey: "string") as! String
        
        let Auth_header = ["Fanner-Auth-Token" : authToken]

        let requestURL: String = Constants.API_BASE_URL + Constants.LOGOUT_API
        APP_DELEGATE.showHUDWithText(textMessage: "")
        Alamofire.request(requestURL, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: Auth_header)
            .responseJSON { response in
                
                switch response.result
                {
                case .success(_):
                    if response.result.value != nil
                    {
                        
                        let dict = response.result.value as! NSDictionary
                        
                        let statusCode: String = dict.value(forKey: "code") as! String
                        
                        let message: String = dict.value(forKey: "message") as! String
                        DispatchQueue.main.async {
                            APP_DELEGATE.hideHUD()
                            if statusCode == Constants.SUCCESS_CODE
                            {
                                let myalert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertControllerStyle.alert)
                                
                                let cancelAction = UIAlertAction(title: "OK", style: .cancel) { (action:UIAlertAction!) in
                                    APP_DELEGATE.RedirectToLoginScreen()
                                }
                                
                                myalert.addAction(cancelAction)
                                
                                self.present(myalert, animated: true)
                            }
                            else
                            {
                                APP_DELEGATE.displayMessageAlertWithMessage(alertMessage: message, withTitle: "Login")
                            }
                        }
                        
                    }
                    else
                    {
                        DispatchQueue.main.async {
                            APP_DELEGATE.hideHUD()
                            APP_DELEGATE.displayMessageAlertWithMessage(alertMessage: "Error occurred, please try after some time.", withTitle: "Login")
                        }
                    }
                    break
                    
                case .failure(_):
                    print(response.result.error!)
                    APP_DELEGATE.hideHUD()
                    APP_DELEGATE.displayMessageAlertWithMessage(alertMessage: "Error occurred, please try after some time.", withTitle: "Login")
                    
                    break
                    
                }
        }
    }
    
    @objc func reachabilityChanged(note: Notification) {
        
        let reachability = note.object as! Reachability
        var reachabilityconnection = ""
        let netStatus = reachability.currentReachabilityStatus
        if netStatus == Reachability.NetworkStatus.reachableViaWiFi
        {
            reachabilityconnection = "Connected via Wifi"
        }
        else if netStatus == Reachability.NetworkStatus.reachableViaWWAN
        {
            reachabilityconnection = "Connected via Mobile Data"
        }
        else
        {
            reachabilityconnection = "Not connected"
        }
        DispatchQueue.main.async
        {
            self.lblInterentStatus.text = reachabilityconnection
        }
    }

    //MARK:- Tableview methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrBuyOptions.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 40.0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemBuyCell", for: indexPath) as! ItemBuyCell
        cell.selectionStyle = .none
        
        let strOption = arrBuyOptions[indexPath.row] as! String
        cell.lblOption.text = strOption
        cell.btnBuy.addTarget(self, action: #selector(buyButtonClicked(_:)), for: .touchUpInside)
        cell.btnBuy.tag = indexPath.row
        
        var productSavedKey: String = ""
        if indexPath.row == 0
        {
            productSavedKey = Constants.kScoreboard_PurchaseKey
        }
        else if indexPath.row == 1
        {
            productSavedKey = Constants.kCustomTag_PurchaseKey
        }
        else if indexPath.row == 2
        {
            productSavedKey = Constants.kImageOverlay_PurchaseKey
        }
        else if indexPath.row == 3
        {
            productSavedKey = Constants.kLiveStreaming_PurchaseKey
        }
        else if indexPath.row == 4
        {
            productSavedKey = Constants.kRecording_PurchaseKey
        }
        else if indexPath.row == 5
        {
            productSavedKey = Constants.kFotoTag_PurchaseKey
        }
        else if indexPath.row == 6
        {
            productSavedKey = Constants.kSaveLibrary_PurchaseKey
        }
        else if indexPath.row == 7
        {
            productSavedKey = Constants.kRecordingsource_PurchaseKey
        }
        var isProductPurchased: Bool = false
        if UserDefaults.standard.value(forKey: productSavedKey) != nil
        {
            let value: String = UserDefaults.standard.value(forKey: productSavedKey) as! String
            
            if value == "YES"
            {
                isProductPurchased = true
            }
        }
        if isProductPurchased
        {
            cell.btnBuy.setTitle("Purchased", for: .normal)
        }
        else
        {
            cell.btnBuy.setTitle("Buy", for: .normal)
        }
        
        return cell
    }
    @objc func buyButtonClicked(_ sender: UIButton)
    {
        var productIdentifier: String = ""
        var productSavedKey: String = ""
        var productName: String = ""
        productName = arrBuyOptions[sender.tag] as! String
        if sender.tag == 0
        {
            productIdentifier = PurchaseProducts.ScoreboardAccessProduct
            productSavedKey = Constants.kScoreboard_PurchaseKey
        }
        else if sender.tag == 1
        {
            productIdentifier = PurchaseProducts.CustomTagAccessProduct
            productSavedKey = Constants.kCustomTag_PurchaseKey
        }
        else if sender.tag == 2
        {
            productIdentifier = PurchaseProducts.ImageOverlayAccessProduct
            productSavedKey = Constants.kImageOverlay_PurchaseKey
        }
        else if sender.tag == 3
        {
            productIdentifier = PurchaseProducts.LiveStreamingAccessProduct
            productSavedKey = Constants.kLiveStreaming_PurchaseKey
        }
        else if sender.tag == 4
        {
            productIdentifier = PurchaseProducts.RecordingAcessProduct
            productSavedKey = Constants.kRecording_PurchaseKey
        }
        else if sender.tag == 5
        {
            productIdentifier = PurchaseProducts.FotoTagAccessProduct
            productSavedKey = Constants.kFotoTag_PurchaseKey
        }
        else if sender.tag == 6
        {
            productIdentifier = PurchaseProducts.SaveDeviceLibraryAccessProduct
            productSavedKey = Constants.kSaveLibrary_PurchaseKey
        }
        else if sender.tag == 7
        {
            productIdentifier = PurchaseProducts.RecordingSourceAccessProduct
            productSavedKey = Constants.kRecordingsource_PurchaseKey
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
    @objc func handlePurchaseNotification()
    {
//        DispatchQueue.main.sync {
//            
//            
//        }
        self.tblBuyOptions.reloadData()
    }
}
