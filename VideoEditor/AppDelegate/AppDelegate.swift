//
//  AppDelegate.swift
//  VideoEditor
//com.arkinc.VideoEditor

// com.simpsip.VideoEditor
import UIKit
import IQKeyboardManagerSwift
import MBProgressHUD
import CoreData
import Alamofire
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var currentRecordingEvent: String = ""
    var lastActiveDate: Date = Date.init()
    var window: UIWindow?
    var myOrientation: UIInterfaceOrientationMask = .portrait
    var landscaperSide: UIInterfaceOrientation = .portrait
    var tabbarController: MainTabbarVC?
    var isCheckedForServiceStatus: Bool = false
    var currentProductKeyInProgress: String = ""
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        isCheckedForServiceStatus = false
        IQKeyboardManager.sharedManager().enable = true
        APP_DELEGATE.landscaperSide = UIInterfaceOrientation.portrait
        // var outputFilePath = NSTemporaryDirectory() as String
        var isUserLogin: Bool = false
        if UserDefaults.standard.value(forKey: Constants.ISUSERLOGIN) != nil
        {
            let value: String = UserDefaults.standard.value(forKey: Constants.ISUSERLOGIN) as! String
            
            if value == "YES"
            {
                isUserLogin = true
            }
        }
        if isUserLogin
        {
            APP_DELEGATE.makeTabbarRootController()
        }
        
        //  APP_DELEGATE.makeTabbarRootController()
        _ = CoreDataHelperInstance.sharedInstance.manageObjectContext1()
        
        self.InsertTagInfoToDB()
        
        //self.CheckForFannerServiceStatus()
        
        UserDefaults.standard.set("YES", forKey: Constants.kScoreboard_PurchaseKey)
        UserDefaults.standard.set("YES", forKey: Constants.kCustomTag_PurchaseKey)
        UserDefaults.standard.set("YES", forKey: Constants.kImageOverlay_PurchaseKey)
        UserDefaults.standard.set("YES", forKey: Constants.kLiveStreaming_PurchaseKey)
        UserDefaults.standard.set("YES", forKey: Constants.kRecording_PurchaseKey)
        UserDefaults.standard.set("YES", forKey: Constants.kFotoTag_PurchaseKey)
        UserDefaults.standard.set("YES", forKey: Constants.kSaveLibrary_PurchaseKey)
        UserDefaults.standard.set("YES", forKey: Constants.kRecordingsource_PurchaseKey)
        UserDefaults.standard.synchronize()
        
        let session: AVAudioSession = AVAudioSession.sharedInstance()
        do {
            try session.setPreferredSampleRate(44_100)
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .allowBluetooth)
            try session.setMode(AVAudioSessionModeDefault)
            try session.setActive(true)
        } catch {
        }
        
        if FBSDKAccessToken.current() == nil {
            
            FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
            
        } else {
            
            FBSDKLoginManager().logOut()
            
        }
        
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        
        
        let fbhandled: Bool = FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
        
        
        return  fbhandled
    }
    
    func application(_ application: UIApplication,
                     open url: URL, options: [UIApplicationOpenURLOptionsKey: Any]) -> Bool {
        
        let facebookDidHandle =  FBSDKApplicationDelegate.sharedInstance().application(application,
                                                                                       open: url,
                                                                                       sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String,
                                                                                       annotation: options [UIApplicationOpenURLOptionsKey.annotation])
        
        
        
        
        return facebookDidHandle
        
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        
        self.lastActiveDate = Date.init()
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        let diffInMins = Calendar.current.dateComponents([.minute], from: self.lastActiveDate, to: Date.init()).minute
        self.lastActiveDate = Date.init()
        
        if diffInMins != nil
        {
            if diffInMins! > 30
            {
                self.CheckTokenExpireStatus()
            }
        }
        
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return myOrientation
    }
    
    func application(_ application: UIApplication, didChangeStatusBarOrientation oldStatusBarOrientation: UIInterfaceOrientation) {
        UIDevice.current.setValue(landscaperSide.rawValue, forKey: "orientation")
    }
    
    func application(_ application: UIApplication, willChangeStatusBarOrientation newStatusBarOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        UIDevice.current.setValue(landscaperSide.rawValue, forKey: "orientation")
    }
    
    func makeTabbarRootController() {
        tabbarController = loadVC(strStoryboardId: SB_MAIN, strVCId: idMainTabbarVC) as? MainTabbarVC
        let navController = UINavigationController(rootViewController: tabbarController!)
        APP_DELEGATE.window?.rootViewController = navController
    }
    func displayMessageAlertWithMessage(alertMessage: String, withTitle alertTitle: String)
    {
        let topViewController = UIApplication.topViewController()
        //        UIApplication.shared.keyWindow!.rootViewController!.topMostViewController()
        
        if Thread.isMainThread
        {
            let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertControllerStyle.alert)
            
            let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            
            alert.addAction(cancelAction)
            topViewController?.present(alert, animated: true, completion: nil)
        }
        else
        {
            DispatchQueue.main.sync {
                let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertControllerStyle.alert)
                
                let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                
                alert.addAction(cancelAction)
                topViewController?.present(alert, animated: true, completion: nil)
            }
        }
    }
    func isValidEmail(testStr:String) -> Bool
    {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func CheckForInternetConnection() -> Bool
    {
        
        let reachability: Reachability = Reachability()!
        
        let netStatus = reachability.currentReachabilityStatus
        
        if netStatus == Reachability.NetworkStatus.notReachable
        {
            return false
        }
        
        return true
    }
    
    func CheckForInternetReachbilityStatus() -> String
    {
        let reachability: Reachability = Reachability()!
        let netStatus = reachability.currentReachabilityStatus
        if netStatus == Reachability.NetworkStatus.reachableViaWiFi
        {
            return "Connected via Wifi"
        }
        if netStatus == Reachability.NetworkStatus.reachableViaWWAN
        {
            return "Connected via Mobile Data"
        }
        return "Not connected"
    }
    func showHUDWithText(textMessage: String) {
        DispatchQueue.main.async {
            
            let topViewController = UIApplication.topViewController()
            let progressHUD = MBProgressHUD.showAdded(to: (topViewController?.view)!, animated: true)
            
            progressHUD.label.text = textMessage
        }
    }
    func hideHUD() {
        
        if Thread.isMainThread
        {
            let topViewController = UIApplication.topViewController()
            MBProgressHUD.hideAllHUDs(for: (topViewController?.view)!, animated: true)
        }
        else
        {
            DispatchQueue.main.async {
                
                let topViewController = UIApplication.topViewController()
                MBProgressHUD.hideAllHUDs(for: (topViewController?.view)!, animated: true)
                
            }
        }
    }
    
    func InsertTagInfoToDB()
    {
        // In this method we will check if tag static data inserted first time or not
        // When app open fisrt time then we will insert static tag info to DB
        
        var isNeedToInsertData: Bool = true
        if UserDefaults.standard.value(forKey: Constants.InsertDataFirstTime) != nil
        {
            let value: String = UserDefaults.standard.value(forKey: Constants.InsertDataFirstTime) as! String
            
            if value == "YES"
            {
                isNeedToInsertData = false
            }
        }
        if isNeedToInsertData
        {
            let tagRecordingNames = ["Action", "End Period", "Favourite", "Foul", "Interview" , "MVP" ,"Pre match", "Start/End game"]
            
            //            let tagNotRecordingNames = ["Start/End game", "Yellow card"]
            let tagRecordingImages = ["actiontag","end-periodtag","favouritetag","foultag","interviewtag","MVPtag","pre-matchtag","start-end-gametag"]
            
            //            let tagNotRecordingImages = ["start-end-gametag","yellow-cardtag"]
            
            for i in 0..<tagRecordingNames.count
            {
                let tagObj: TagInfo = (NSEntityDescription.insertNewObject(forEntityName: "TagInfo", into: CoreDataHelperInstance.sharedInstance.manageObjectContext) as? TagInfo)!
                
                tagObj.tagName = tagRecordingNames[i]
                tagObj.tagSecondValue = 15
                tagObj.tagImageName = tagRecordingImages[i]
                tagObj.tagIndex = Int64(i)
                tagObj.isPersonalTag = false
                tagObj.isRecordingPageTag = false
            }
            
            //            for i in 0..<tagNotRecordingNames.count
            //            {
            //                let tagObj: TagInfo = (NSEntityDescription.insertNewObject(forEntityName: "TagInfo", into: CoreDataHelperInstance.sharedInstance.manageObjectContext) as? TagInfo)!
            //                tagObj.tagName = tagNotRecordingNames[i]
            //                tagObj.tagImageName = tagNotRecordingImages[i]
            //                tagObj.tagIndex = Int64(i)
            //                tagObj.isPersonalTag = false
            //                tagObj.isRecordingPageTag = false
            //            }
            CoreDataHelperInstance.sharedInstance.saveContext()
            UserDefaults.standard.set("YES", forKey: Constants.InsertDataFirstTime)
            UserDefaults.standard.synchronize()
        }
    }
    func CheckTokenExpireStatus() -> Bool
    {
        var isUserLogin: Bool = false
        if UserDefaults.standard.value(forKey: Constants.ISUSERLOGIN) != nil
        {
            let value: String = UserDefaults.standard.value(forKey: Constants.ISUSERLOGIN) as! String
            
            if value == "YES"
            {
                isUserLogin = true
            }
        }
        if !isUserLogin
        {
            return false
        }
        let userDict = UserDefaults.standard.value(forKey: Constants.USER_PROFILE_INFO) as! NSDictionary
        let authDict = userDict.value(forKey: "auth") as! NSDictionary
        let tokenDict = authDict.value(forKey: "token") as! NSDictionary
        let authExpiryDateStr = tokenDict.value(forKey: "expires") as! String
        
        let currentDate = Date()
        
        let dateFormatter: DateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let expiryDate = dateFormatter.date(from: authExpiryDateStr)
        //   self.RedirectToLoginScreen()
        if expiryDate! < currentDate
        {
            self.RedirectToLoginScreen()
            return true
        }
        return false
    }
    func RedirectToLoginScreen()
    {
        //        return
        UserDefaults.standard.removeObject(forKey: Constants.USER_PROFILE_INFO)
        UserDefaults.standard.removeObject(forKey: Constants.ISUSERLOGIN)
        UserDefaults.standard.synchronize()
        let redirectTo = loadVC(strStoryboardId: SB_LOGIN, strVCId: idLoginVC) as! LoginVC
        let navController = UINavigationController(rootViewController: redirectTo)
        APP_DELEGATE.window?.rootViewController = navController
    }
    func CheckForFannerServiceStatus()
    {
        return
        if self.isCheckedForServiceStatus
        {
            return
        }
        if !APP_DELEGATE.CheckForInternetConnection()
        {
            let topViewController = UIApplication.topViewController()
            
            let alert = UIAlertController(title: "Alert", message: NoInternetMessageWithRetry, preferredStyle: UIAlertControllerStyle.alert)
            
            let cancelAction = UIAlertAction(title: "Retry", style: .cancel) { (action:UIAlertAction!) in
                
                self.CheckForFannerServiceStatus()
            }
            alert.addAction(cancelAction)
            topViewController?.present(alert, animated: true, completion: nil)
            return
        }
        let requestURL: String = Constants.API_SERVICE_URL + Constants.SERVICE_STATUS_API
        let credentialData = "\(Constants.Fanner_UserName):\(Constants.Fanner_Password)".data(using: String.Encoding.utf8)!
        let base64Credentials = credentialData.base64EncodedString()
        let headers = ["Authorization": "Basic \(base64Credentials)"]
        APP_DELEGATE.showHUDWithText(textMessage: "")
        Alamofire.request(requestURL, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                
                switch response.result
                {
                case .success(_):
                    if response.result.value != nil
                    {
                        
                        let dict = response.result.value as! NSDictionary
                        
                        let statusCode: String = dict.value(forKey: "code") as! String
                        
                        // let message: String = dict.value(forKey: "message") as! String
                        DispatchQueue.main.async {
                            APP_DELEGATE.hideHUD()
                            if statusCode == Constants.SUCCESS_CODE
                            {
                                var isURLFound: Bool = false
                                
                                if (dict.value(forKey: "response")) != nil
                                {
                                    let responseDict = (dict.value(forKey: "response") as! NSDictionary)
                                    if (responseDict.value(forKey: "services")) != nil
                                    {
                                        let serviceDict = (responseDict.value(forKey: "services") as! NSDictionary)
                                        
                                        if (serviceDict.value(forKey: "current_api_server")) != nil
                                        {
                                            let current_api_server = (serviceDict.value(forKey: "current_api_server") as! NSDictionary)
                                            
                                            isURLFound = true
                                            
                                            Constants.API_BASE_URL = current_api_server.value(forKey: "full_path") as! String
                                        }
                                    }
                                    
                                }
                                if isURLFound
                                {
                                    self.isCheckedForServiceStatus = true
                                }
                            }
                            else
                            {
                                DispatchQueue.main.async {
                                    self.RetryMessageAlertToCheckFannerService()
                                }
                            }
                        }
                        
                    }
                    else
                    {
                        DispatchQueue.main.async {
                            self.RetryMessageAlertToCheckFannerService()
                        }
                    }
                    break
                    
                case .failure(_):
                    DispatchQueue.main.async {
                        self.RetryMessageAlertToCheckFannerService()
                    }
                    break
                    
                }
        }
        
    }
    func RetryMessageAlertToCheckFannerService()
    {
        APP_DELEGATE.hideHUD()
        
        let topViewController = UIApplication.topViewController()
        
        let alert = UIAlertController(title: "Alert", message: FannerServiceDownMessage, preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelAction = UIAlertAction(title: "Retry", style: .cancel) { (action:UIAlertAction!) in
            
            self.CheckForFannerServiceStatus()
        }
        alert.addAction(cancelAction)
        topViewController?.present(alert, animated: true, completion: nil)
    }
    func FetchFullVideoPath(videoFolderName: String) -> String
    {
        var outputFilePath = NSTemporaryDirectory() as String
        
        outputFilePath = outputFilePath + "\(videoFolderName)"
        
        return outputFilePath
    }
    func FetchTempVideoFolderPath() -> String
    {
        var outputFilePath = NSTemporaryDirectory() as String
        outputFilePath = outputFilePath + "MyTemp"
        return outputFilePath
    }
    func DeleteAllFilesInTempFolder()
    {
        let fileManager = FileManager.default
        let tempFolderPath: String = self.FetchTempVideoFolderPath()
        
        if !fileManager.fileExists(atPath: tempFolderPath as String)
        {
            do
            {
                try fileManager.createDirectory(atPath: tempFolderPath, withIntermediateDirectories: true, attributes: nil)
            }
            catch
            {
                
            }
            return
        }
        
        do {
            let filePaths = try fileManager.contentsOfDirectory(atPath: tempFolderPath)
            for filePath in filePaths
            {
                try fileManager.removeItem(atPath: "\(tempFolderPath)/\(filePath)")
            }
        } catch {
            print("Could not clear temp folder: \(error)")
        }
    }
    func resolutionForLocalVideo(url:URL) -> CGSize?
    {
        guard let track = AVURLAsset(url: url).tracks(withMediaType: AVMediaType.video).first else { return nil }
        let size = track.naturalSize.applying(track.preferredTransform)
        return CGSize(width: fabs(size.width), height: fabs(size.height))
    }
}
extension UIApplication {
    
    class func topViewController(base: UIViewController? = (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController) -> UIViewController? {
        
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        
        return base
    }
}
extension UIDevice {
    func MBFormatter(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = ByteCountFormatter.Units.useMB
        formatter.countStyle = ByteCountFormatter.CountStyle.decimal
        formatter.includesUnit = false
        return formatter.string(fromByteCount: bytes) as String
    }
    
    //MARK: Get String Value
    var totalDiskSpaceInGB:String {
        return ByteCountFormatter.string(fromByteCount: totalDiskSpaceInBytes, countStyle: ByteCountFormatter.CountStyle.decimal)
    }
    
    var freeDiskSpaceInGB:String {
        return ByteCountFormatter.string(fromByteCount: freeDiskSpaceInBytes, countStyle: ByteCountFormatter.CountStyle.decimal)
    }
    
    var usedDiskSpaceInGB:String {
        return ByteCountFormatter.string(fromByteCount: usedDiskSpaceInBytes, countStyle: ByteCountFormatter.CountStyle.decimal)
    }
    
    var totalDiskSpaceInMB:String {
        return MBFormatter(totalDiskSpaceInBytes)
    }
    
    var freeDiskSpaceInMB:String {
        return MBFormatter(freeDiskSpaceInBytes)
    }
    
    var usedDiskSpaceInMB:String {
        return MBFormatter(usedDiskSpaceInBytes)
    }
    
    //MARK: Get raw value
    var totalDiskSpaceInBytes:Int64 {
        guard let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String),
            let space = (systemAttributes[FileAttributeKey.systemSize] as? NSNumber)?.int64Value else { return 0 }
        return space
    }
    
    /*
     Total available capacity in bytes for "Important" resources, including space expected to be cleared by purging non-essential and cached resources. "Important" means something that the user or application clearly expects to be present on the local system, but is ultimately replaceable. This would include items that the user has explicitly requested via the UI, and resources that an application requires in order to provide functionality.
     Examples: A video that the user has explicitly requested to watch but has not yet finished watching or an audio file that the user has requested to download.
     This value should not be used in determining if there is room for an irreplaceable resource. In the case of irreplaceable resources, always attempt to save the resource regardless of available capacity and handle failure as gracefully as possible.
     */
    var freeDiskSpaceInBytes:Int64 {
        if #available(iOS 11.0, *) {
            if let space = try? URL(fileURLWithPath: NSHomeDirectory() as String).resourceValues(forKeys: [URLResourceKey.volumeAvailableCapacityForImportantUsageKey]).volumeAvailableCapacityForImportantUsage {
                return space ?? 0
            } else {
                return 0
            }
        } else {
            if let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String),
                let freeSpace = (systemAttributes[FileAttributeKey.systemFreeSize] as? NSNumber)?.int64Value {
                return freeSpace
            } else {
                return 0
            }
        }
    }
    
    var usedDiskSpaceInBytes:Int64 {
        return totalDiskSpaceInBytes - freeDiskSpaceInBytes
    }
    
    
}
