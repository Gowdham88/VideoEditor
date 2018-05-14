//
//  constant.swift


import Foundation
import UIKit
import CoreLocation
import SystemConfiguration
import CoreMedia

struct DIRECTORY_NAME
{
    public static let IMAGES = "Images"
    public static let AUDIOS = "Audios"
    public static let VIDEOS = "Videos"
    public static let DOWNLOAD_VIDEOS = "Download_videos"
}

struct Constants {
    
    enum CurrentDevice : Int {
        case Phone // iPhone and iPod touch style UI
        case Pad // iPad style UI
    }
    
    struct MixpanelConstants {
        static let activeScreen = "Active Screen";
    }
    
    struct CrashlyticsConstants {
        static let userType = "User Type";
    }
    
    static let Fanner_UserName = "fanner_api_status"
    static let Fanner_Password = "bqgMVAtzliwoKeEF"
    static let ACCOUNT_FANNER_URL = "http://fanner.it/beta/login"
    static let API_SERVICE_URL = "https://api.fanner.it"
    
    static var API_BASE_URL = "https://api.fanner.it/v1.1/resources"
    static let LOGOUT_API = "/users/logout"
    static let LOGIN_API = "/users/login"
    static let REGISTER_API = "/users/register"
    
    static let FORGOTPASS_API = "users/password_recovery"
    static let SERVICE_STATUS_API = "/services_status"
    
    static let SUCCESS_CODE = "2000"
    
    static let LOGIN_ERROR_CODE = "400"
    
    static let SCOREBOARD_PRODUCT = "users/register"
    
    static let InsertDataFirstTime = "IsDataInsertedFirstTime"
    static let USER_PROFILE_INFO = "UserProfileInfo"
    
    static let ISUSERLOGIN = "ISUSERLOGIN"
    
    static let kScoreboard_PurchaseKey = "Scoreboard_PurchaseKey"
    static let kCustomTag_PurchaseKey = "CustomTag_PurchaseKey"
    static let kImageOverlay_PurchaseKey = "ImageOverlay_PurchaseKey"
    static let kLiveStreaming_PurchaseKey = "LiveStreaming_PurchaseKey"
    static let kRecording_PurchaseKey = "Recording_PurchaseKey" // 4k Recording
    static let kFotoTag_PurchaseKey = "FotoTag_PurchaseKey"
    static let kSaveLibrary_PurchaseKey = "SaveLibrary_PurchaseKey"
    static let kRecordingsource_PurchaseKey = "Recordingsource_PurchaseKey"
    static let HDQuality = "HDQuality"
    static let FHDQuality = "FHDQuality"
    static let UltraQuality = "4KQuality" //4k Recording
    
    static let FrontCamera = "FrontCamera"
    static let BackCamera = "BackCamera"
    
    static let FPS30 = "FPS30"
    static let FPS60 = "FPS60"
    
    static let CodecH264 = "CodecH264"
    static let CodecH265 = "CodecH265"
    
    static var fbLive = false
    
    
    static let RecordDayEvent = "RecordDayEvent"
    static let RecordMatchEvent = "RecordMatchEvent"
}



public let FannerServiceDownMessage: String = "Not able to connect to fanner service, please try again."
public let NoInternetMessageWithRetry: String = "Please check your internet connection, enable it and try again."

public let NoInternetMessage: String = "Please check your internet connection."
public let SB_MAIN :String = "Main"
public let SB_LOGIN :String = "Login"
public let SB_LANDSCAPE :String = "Landscape"
public let SB_OTHERS :String = "Others"

public let idWebViewVC = "webView_view"
public let idVideoDetailsVC = "videoDetails_view"
public let idLoginVC = "login_view"
public let idTagManageVC = "TagManagementVC"
public let isWebviewVC = "WebviewVC"
public let idRegisterVC = "register_view"
public let idForgotVC = "ForgotPasswordVC"
public let idMainTabbarVC = "mainTabbar_view"
public let idNavMainTabbarVC = "navMainTabbar_view"
public let idSocialShareVC = "socialShare_view"
public let idCreateMatchVC = "createMatch_view"
public let idStreamSettingVC = "streamSetting_view"
public let idStreamRecordingVC = "streamRecording_view"
public let idSearchVC = "search_view"
public let idLiveCameraVC = "liveCamera_view"
public let idRecordCameraVideoVC = "recordCameraVideo_view"
public let idFacebookCameraVideoVC = "facebookCameraVideo_view"
public var fbAvailable = Bool()


//MARK:-
//MARK:- Application related variables
let APP_DELEGATE = UIApplication.shared.delegate as! AppDelegate
public let APP_NAME: String = Bundle.main.infoDictionary!["CFBundleName"] as! String
public let APP_VERSION: String = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
let getStoryboard2 = UIStoryboard(name: "MyStoryboardName", bundle: nil)
public var FILE_NAME: String = ""

public func DegreesToRadians(degrees: Float) -> Float {
    return Float(Double(degrees) * Double.pi / 180)
}

public let isSimulator: Bool = {
    var isSim = false
    #if arch(i386) || arch(x86_64)
    isSim = true
    #endif
    return isSim
}()

//MARK:- Open URL in safari
func openURLInSafari(strURL: String) {
    if UIApplication.shared.canOpenURL(URL(string: strURL)!) {
        UIApplication.shared.openURL(URL(string: strURL)!)
    }
}

//MARK:- FONT NAMES
let FONT_MONTSERRAT_Regular = "Montserrat"
let FONT_MONTSERRAT_Bold = "Montserrat-Bold"
let FONT_MONTSERRAT_Bold_Italic = "Montserrat-BoldItalic"
let FONT_MONTSERRAT_Italic = "Montserrat-Italic"
let FONT_MONTSERRAT_Medium = "Montserrat-Medium"
let FONT_MONTSERRAT_Semi_Bold = "Montserrat-SemiBold"

//MARK:-  Get VC for navigation

public func getStoryboard(storyboardName: String) -> UIStoryboard {
    return UIStoryboard(name: storyboardName, bundle: nil)
}

public func loadVC(strStoryboardId: String, strVCId: String) -> UIViewController {
    
    let vc = getStoryboard(storyboardName: strStoryboardId).instantiateViewController(withIdentifier: strVCId)
    return vc
}

public var CurrentTimeStamp: String
{
    return "\(NSDate().timeIntervalSince1970 * 1000)"
}

func randomString() -> String
{
    var text = ""
    text = text.appending(CurrentTimeStamp)
    text = text.replacingOccurrences(of: ".", with: "")
    // text = text.stringByReplacingOccurrencesOfString("-", withString: "")
    return text
}
//MARK:- Helper
public func TableEmptyMessage(message:String, tbl:UITableView)
{
    let messageLabel = UILabel(frame: Frame_XYWH(0, 0, tbl.frame.size.width, 100))
    messageLabel.text = message
    let bubbleColor = Color_RGBA(54, 81, 104, 1)
    messageLabel.textColor = bubbleColor
    messageLabel.numberOfLines = 0;
    messageLabel.textAlignment = .center;
    messageLabel.font = UIFont.FontWithSize(FONT_MONTSERRAT_Regular, 15)
    messageLabel.sizeToFit()
    
    tbl.backgroundView = messageLabel;
    tbl.separatorStyle = .none;
}

//MARK:-  Check Device is iPad or not

public func isIpad( ) ->Bool {
    switch UIDevice.current.userInterfaceIdiom {
    case .phone:
        return false
    case .pad:
        return true
    case .unspecified:
        return false
        
    default :
        return false
    }
}


//MARK:- iOS version checking Functions

public func IOS_VERSION() -> String {
    return UIDevice.current.systemVersion
}

public func SCREENWIDTH() -> CGFloat
{
    let screenSize = UIScreen.main.bounds
    return screenSize.width
}

public func SCREENHEIGHT() -> CGFloat
{
    let screenSize = UIScreen.main.bounds
    return screenSize.height
}


func alignVertical(button: UIButton, spacing: CGFloat = 10.0) {
    guard let imageSize = button.imageView?.image?.size,
        let text = button.titleLabel?.text,
        let font = button.titleLabel?.font
        else { return }
    button.titleEdgeInsets = UIEdgeInsets(top: 0.0, left: -imageSize.width, bottom: -(imageSize.height + spacing), right: 0.0)
    let labelString = NSString(string: text)
    let titleSize = labelString.size(withAttributes: [NSAttributedStringKey.font: font])
    button.imageEdgeInsets = UIEdgeInsets(top: -(titleSize.height + spacing), left: 0.0, bottom: 0.0, right: -titleSize.width)
    let edgeOffset = abs(titleSize.height - imageSize.height) / 2.0;
    button.contentEdgeInsets = UIEdgeInsets(top: edgeOffset, left: 0.0, bottom: edgeOffset, right: 0.0)
}
extension UIImage {
    static func from(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}
func setCornerRadiusAndShadowOnButton(button : UIButton, backColor: UIColor) {
    button.layoutIfNeeded()
    button.setBackgroundImage(UIImage(named: ""), for: .normal)
    button.layer.cornerRadius = button.frame.size.height/2
    
    button.layer.shadowRadius = 1
    button.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
    button.layer.shadowOpacity = 0.4
    button.backgroundColor = backColor
}
func setCornerRadiusAndColorWidth(button : UIButton, backColor: UIColor, borderHeight: Float) {
    button.layoutIfNeeded()
    button.setBackgroundImage(UIImage(named: ""), for: .normal)
    button.layer.cornerRadius = CGFloat(borderHeight/2)
    
    button.layer.shadowRadius = 1
    button.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
    button.layer.shadowOpacity = 0.4
    button.backgroundColor = backColor
}
func setCornerRadiusWithBGImage(button : UIButton, backColor: UIColor) {
    button.layoutIfNeeded()
    
    let img = UIImage.from(color: backColor)
    
    let img1 = UIImage.from(color: UIColor.white)
    
    button.setBackgroundImage(img, for: .normal)
    button.setImage(img1, for: .normal)
    button.layer.cornerRadius = button.frame.size.height/2
    button.layer.masksToBounds = true
    //    button.layer.shadowRadius = 1
    //    button.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
    //    button.layer.shadowOpacity = 0.4
    //    button.backgroundColor = backColor
}


func setCornerRadiusAndBorderButton(button : UIButton, borderWidth: Float) {
    button.layoutIfNeeded()
    button.setBackgroundImage(UIImage(named: ""), for: .normal)
    button.layer.cornerRadius = button.frame.size.height/2
    
    button.layer.borderWidth = CGFloat(borderWidth)
    
    button.layer.borderColor = UIColor.white.cgColor
    
    button.layer.shadowRadius = 1
    button.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
    button.layer.shadowOpacity = 0.4
}

//MARK:- Network indicator

public func ShowNetworkIndicator(xx :Bool)
{
    UIApplication.shared.isNetworkActivityIndicatorVisible = xx
}

//MARK : Length validation
public func TRIM(string: Any) -> String
{
    return (string as AnyObject).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
}
public func validateTxtFieldLength(_ txtVal: UITextField, withMessage msg: String) -> Bool {
    if TRIM(string: txtVal.text ?? "").characters.count == 0
    {
        return false
    }
    return true
}
public func validateTxtLength(_ txtVal: String, withMessage msg: String) -> Bool {
    if TRIM(string: txtVal).characters.count == 0
    {
        return false
    }
    return true
}
public func passwordMismatch(_ txtVal: String, _ txtVal1: String, withMessage msg: String) -> Bool {
    if TRIM(string: txtVal) != TRIM(string: txtVal1)
    {
        return false
    }
    return true
}

func isValidEmail(testStr:String) -> Bool {
    // print("validate calendar: \(testStr)")
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailTest.evaluate(with: testStr)
}

//MARK:- Add views in textfield
public func addLeftViewInTextField(_ textField: UITextField) {
    let imageView = UIView();
    imageView.frame = CGRect(x: 0, y: 0, width: 10, height: textField.frame.size.height)
    textField.leftView = imageView;
    textField.leftViewMode = UITextFieldViewMode.always
}

//function for adding left view image to textfields
func addLeftImageViewInTextField(textfield:UITextField, strImageName:String)
{
    textfield.leftView = UIImageView(image: UIImage(named: strImageName))
    textfield.leftViewMode = .always
    //    textfield.attributedPlaceholder = NSAttributedString(string:strPlaceHolderText, attributes: [NSAttributedStringKey.font:UIFont(name: FONT_MONTSERRAT_Regular, size: 20.0)!])
}


public func addRighViewInTextField(_ textField: UITextField, imageName: String) {
    let btnRight = UIButton(type: .system)
    btnRight.setImage(UIImage(named: imageName), for: .normal)
    btnRight.frame = CGRect(x: 0, y: 0, width: 25, height: 20)
    btnRight.contentMode = .scaleAspectFill
    btnRight.imageView?.contentMode = .scaleAspectFit
    btnRight.tintColor = COLOR_APP_THEME()
    btnRight.isUserInteractionEnabled = false
    textField.rightView = btnRight;
    textField.rightViewMode = UITextFieldViewMode.always
}

public func addLeftViewInTextField(_ textField: UITextField, imageName: String) {
    
    let view = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: textField.frame.size.height))
    let btnRight = UIButton(type: .custom)
    btnRight.setImage(UIImage(named: imageName), for: .normal)
    btnRight.frame = CGRect(x: 5, y: 0, width: 25, height: textField.frame.size.height)
    //    btnRight.contentMode = .scaleAspectFill
    //    btnRight.imageView?.contentMode = .scaleAspectFit
    btnRight.tintColor = COLOR_APP_THEME()
    btnRight.isUserInteractionEnabled = false
    view.addSubview(btnRight)
    textField.leftView = view;
    textField.leftViewMode = UITextFieldViewMode.always
}

/**
 Get image from image name
 */
//MARK:- - Get image from image name
public func Set_Local_Image(imageName :String) -> UIImage
{
    return UIImage(named:imageName)!
}

//MARK:- FONT
extension UIFont {
    class func FontWithSize(_ fname: String,_ fsize: Int) -> UIFont
    {
        return UIFont(name: fname, size: CGFloat(fsize))!
    }
}


//MARK:- COLOR RGB
public func Color_RGBA(_ R: Int,_ G: Int,_ B: Int,_ A: Int) -> UIColor
{
    return UIColor(red: CGFloat(R)/255.0, green: CGFloat(G)/255.0, blue: CGFloat(B)/255.0, alpha :CGFloat(A))
}

public func COLOR_APP_THEME() -> UIColor {
    return  UIColor(red: 0.0/255.0, green: 165.0/255.0, blue: 251.0/255.0, alpha: 1)
}

public func COLOR_APP_THEME_GRAY() -> UIColor {
    return  UIColor(red: 236.0/255.0, green: 236.0/255.0, blue: 236.0/255.0, alpha: 1)
}

public func COLOR_SELECTED_FONT() -> UIColor {
    return  UIColor(red: 255.0/255.0, green: 200.0/255.0, blue: 0.0/255.0, alpha: 1)
}

public func COLOR_FONT_GRAY() -> UIColor {
    return  UIColor(red: 162.0/255.0, green: 162.0/255.0, blue: 162.0/255.0, alpha: 1)
}

public func COLOR_BACKGROUND_VIEW() -> UIColor {
    return  UIColor.white//UIColor(red: 20.0/255.0, green: 20.0/255.0, blue: 30.0/255.0, alpha: 1)
}

public func COLOR_NAVIGATION_BAR() -> UIColor {
    return  UIColor.white//UIColor(red: 236.0/255.0, green: 11.0/255.0, blue: 91.0/255.0, alpha: 1)
}

public func COLOR_GRAY() -> UIColor {
    return  UIColor(red: 177.0/255.0, green: 177.0/255.0, blue: 177.0/255.0, alpha: 1)
}

public func COLOR_WHITE_ALPHA_40() -> UIColor {
    return  UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.40)
}

public func COLOR_BLACK_ALPHA_60() -> UIColor {
    return  UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.60)
}

public func COLOR_BLACK_OR_WHITE() -> UIColor {
    if (true) {
        return  UIColor.white
    } else {
        return  UIColor.black
    }
}

public func COLOR_WHITE_OR_BLACK() -> UIColor {
    if (true) {
        return  UIColor.black
    } else {
        return  UIColor.white
    }
}

//MARK:- SET FRAME
public func Frame_XYWH(_ originx: CGFloat,_ originy: CGFloat,_ fwidth: CGFloat,_ fheight: CGFloat) -> CGRect
{
    return CGRect(x: originx, y:originy, width: fwidth, height: fheight)
}

public func randomColor() -> UIColor {
    let r: UInt32 = arc4random_uniform(255)
    let g: UInt32 = arc4random_uniform(255)
    let b: UInt32 = arc4random_uniform(255)
    
    return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: 1.0)
}

struct Platform
{
    static let isSimulator: Bool = {
        var isSim = false
        #if arch(i386) || arch(x86_64)
        isSim = true
        #endif
        return isSim
    }()
}
/**
 Log trace
 */
//MARK:- - Log trace

public func DLog<T>(message:T,  file: String = #file, function: String = #function, lineNumber: Int = #line ) {
    #if DEBUG
    if let text = message as? String {
        
        print("\((file as NSString).lastPathComponent) -> \(function) line: \(lineNumber): \(text)")
    }
    #endif
}

//Mark : string to dictionary
public func convertStringToDictionary(str:String) -> [String: Any]? {
    if let data = str.data(using: .utf8) {
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        } catch {
            print(error.localizedDescription)
        }
    }
    return nil
}

//MARK:- - Check string is available or not

public func isLike(source: String , compare: String) ->Bool
{
    var exists = true
    ((source).lowercased().range(of: compare) != nil) ? (exists = true) :  (exists = false)
    return exists
}

//MARK:- - Calculate heght of label
public func calculatedHeight(string :String,withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat
{
    let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
    let boundingBox = string.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
    return boundingBox.height
}

public func calculatedWidth(string :String,withConstraintedHeight height: CGFloat, font: UIFont) -> CGFloat
{
    let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
    let boundingBox = string.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
    return boundingBox.width
}

public func mileToKilometer(myDistance : Int) -> Float {
    
    return Float(myDistance) * 1.60934
    
}

//MARK:- Kilometer to Mile
//Convert Kilometer to Mile

public func KilometerToMile(myDistance : Double) -> Double {
    
    return (myDistance) * 0.621371192
    
}

//MARK:- NULL to NIL

public func NULL_TO_NIL(value : AnyObject?) -> AnyObject? {
    
    if value is NSNull {
        return "" as AnyObject?
    } else {
        return value
    }
}

//MARK:- calculate Distanve between two Locations


//public func calculateDisatnceBetweenTwoLocations(sourceLat:Double, sourceLong:Double) -> Double{
//
//    let sourceLocation:CLLocation?
//
//    if iskeyAlreadyExist(KEY_DEVICE_LOCATION) {
//
//        sourceLocation =  getCustomObjFromUserDefaults_ForKey(KEY_DEVICE_LOCATION) as? CLLocation
//    }else{
//        sourceLocation = CLLocation(latitude: 0.0000, longitude: 0.0000)
//    }
//
//    let destinationLocation =  CLLocation(latitude: sourceLat, longitude: sourceLong)
//
//    let distanceMeters = sourceLocation!.distanceFromLocation(destinationLocation)
//    let distanceKM = distanceMeters / 1000
//    let distanceMile = KilometerToMile(distanceKM)
//    let roundedTwoDigit = distanceMile.roundedTwoDigit
//    return roundedTwoDigit
//
//}
//MARK:- Rounded two digit
//Rounded two digit value

//extension Double{
//
//    var roundedTwoDigit:Double{
//
//        return Double(round(100*self)/100)
//
//    }
//}

//MARK:- Random string Generator
//Generate random string with specified length


//func randomString(length: Int, justLowerCase: Bool = false) -> String {
//
//    var text = ""
//    for _ in 1...length {
//        var decValue = 0  // ascii decimal value of a character
//        var charType = 3  // default is lowercase
//        if justLowerCase == false {
//            // randomize the character type
//            charType =  Int(arc4random_uniform(4))
//        }
//        switch charType {
//        case 1:  // digit: random Int between 48 and 57
//            decValue = Int(arc4random_uniform(10)) + 48
//        case 2:  // uppercase letter
//            decValue = Int(arc4random_uniform(26)) + 65
//        case 3:  // lowercase letter
//            decValue = Int(arc4random_uniform(26)) + 97
//        default:  // space character
//            decValue = 32
//        }
//        // get ASCII character from random decimal value
//        let char = String(UnicodeScalar(decValue))
//        text = text + char
//        // remove double spaces
//        text = text.stringByReplacingOccurrencesOfString("  ", withString: "")
//        text = text.stringByReplacingOccurrencesOfString(" ", withString: "")
//
//    }
//    text = text.stringByAppendingString(CurrentTimeStamp)
//    text = text.stringByReplacingOccurrencesOfString(".", withString: "")
//   // text = text.stringByReplacingOccurrencesOfString("-", withString: "")
//
//    return text
//}

//MARK:- Time Ago Function

func timeAgoSinceDate(date:Date, numericDates:Bool) -> String {
    let calendar = NSCalendar.current
    let unitFlags: NSCalendar.Unit = [.second, .minute, .hour, .day, .weekOfYear, .month, .year]
    let now = NSDate()
    let components = (calendar as NSCalendar).components(unitFlags, from: date, to: now as Date, options: [])
    
    if (components.year! >= 2)
    {
        return "\(components.year!)" + "y ago"
    } else if (components.year! >= 1){
        if (numericDates){
            return "1y ago"
        } else {
            return "Last year"
        }
    } else if (components.month! >= 2) {
        return "\(components.month!)" + "m ago"
    } else if (components.month! >= 1){
        if (numericDates){
            return "1m ago"
        } else {
            return "Last month"
        }
    } else if (components.weekOfYear! >= 2) {
        return "\(components.weekOfYear!)" + "w ago"
    } else if (components.weekOfYear! >= 1){
        if (numericDates){
            return "1w ago"
        } else {
            return "Last week"
        }
    } else if (components.day! >= 2) {
        return "\(components.day!)" + "d ago"
    } else if (components.day! >= 1){
        if (numericDates){
            return "1d ago"
        } else {
            return "Yesterday"
        }
    } else if (components.hour! >= 2) {
        return "\(components.hour!)" + "h ago"
    } else if (components.hour! >= 1){
        if (numericDates){
            return "1h ago"
        } else {
            return "An hour ago"
        }
    } else if (components.minute! >= 2)
    {
        return "\(components.minute!)" + "m ago"
    } else if (components.minute! >= 1){
        if (numericDates){
            return "1m ago"
        } else {
            return "A minute ago"
        }
    } else if (components.second! >= 3) {
        return "\(components.second!)" + "s ago"
    } else {
        return "Just now"
    }
}

let ENTITY_GROUP = "CDGroups"
let ENTITY_WORD = "CDWords"
let ENTITY_MESSAGING_NUMBER = "CDMessagingNumbers"
let ENTITY_PHRASES = "CDPhrases"
let ENTITY_QUESTION = "CDQuestions"


//func showAlertMessage(_ message: String, okButtonTitle: String = "Ok") -> Void
//{
//    let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
//    let okAction = UIAlertAction(title: okButtonTitle, style: .default, handler: nil)
//    alert.addAction(okAction)
//    self.present(alert, animated: true, completion: nil)
//}

func showDeleteAlertMessage(viewConstroller: UIViewController) {
    let ac = UIAlertController(title: "Fanner Cam", message: "Are you sure you want to delete?", preferredStyle: .alert)
    ac.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (alert) in
        
    }))
    ac.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
    viewConstroller.present(ac, animated: true)
}

//MARK:- Animation
func animateview(vw1 : UIView,vw2:UIView)
{
    UIView.animate(withDuration: 0.1,
                   delay: 0.1,
                   options: UIViewAnimationOptions.curveEaseIn,
                   animations: { () -> Void in
                    vw1.alpha = 0;
                    vw2.alpha = 1;
    }, completion: { (finished) -> Void in
        vw1.isHidden = true;
    })
}

//MARK:- Country code
func setDefaultCountryCode() -> String
{
    let countryCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String
    return "+" + getCountryPhonceCode(countryCode!)
}

func fixOrientationOfImage(image: UIImage) -> UIImage?
{
    if image.imageOrientation == .up
    {
        return image
    }
    var transform = CGAffineTransform.identity
    switch image.imageOrientation
    {
    case .down, .downMirrored:
        transform = transform.translatedBy(x: image.size.width, y: image.size.height)
        transform = transform.rotated(by: CGFloat(Double.pi))
    case .left, .leftMirrored:
        transform = transform.translatedBy(x: image.size.width, y: 0)
        transform = transform.rotated(by:  CGFloat(Double.pi / 2))
    case .right, .rightMirrored:
        transform = transform.translatedBy(x: 0, y: image.size.height)
        transform = transform.rotated(by:  -CGFloat(Double.pi / 2))
    default:
        break
    }
    switch image.imageOrientation
    {
    case .upMirrored, .downMirrored:
        transform = transform.translatedBy(x: image.size.width, y: 0)
        transform = transform.scaledBy(x: -1, y: 1)
    case .leftMirrored, .rightMirrored:
        transform = transform.translatedBy(x: image.size.height, y: 0)
        transform = transform.scaledBy(x: -1, y: 1)
    default:
        break
    }
    guard let context = CGContext(data: nil, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: image.cgImage!.bitsPerComponent, bytesPerRow: 0, space: image.cgImage!.colorSpace!, bitmapInfo: image.cgImage!.bitmapInfo.rawValue) else {
        return nil
    }
    context.concatenate(transform)
    switch image.imageOrientation
    {
    case .left, .leftMirrored, .right, .rightMirrored:
        context.draw(image.cgImage!, in: CGRect(x: 0, y: 0, width: image.size.height, height: image.size.width))
    default:
        context.draw(image.cgImage!, in: CGRect(origin: .zero, size: image.size))
    }
    guard let CGImage = context.makeImage() else {
        return nil
    }
    return UIImage(cgImage: CGImage)
}
func getCountryPhonceCode (_ country : String) -> String
{
    var countryDictionary  = ["AF":"93",
                              "AL":"355",
                              "DZ":"213",
                              "AS":"1",
                              "AD":"376",
                              "AO":"244",
                              "AI":"1",
                              "AG":"1",
                              "AR":"54",
                              "AM":"374",
                              "AW":"297",
                              "AU":"61",
                              "AT":"43",
                              "AZ":"994",
                              "BS":"1",
                              "BH":"973",
                              "BD":"880",
                              "BB":"1",
                              "BY":"375",
                              "BE":"32",
                              "BZ":"501",
                              "BJ":"229",
                              "BM":"1",
                              "BT":"975",
                              "BA":"387",
                              "BW":"267",
                              "BR":"55",
                              "IO":"246",
                              "BG":"359",
                              "BF":"226",
                              "BI":"257",
                              "KH":"855",
                              "CM":"237",
                              "CA":"1",
                              "CV":"238",
                              "KY":"345",
                              "CF":"236",
                              "TD":"235",
                              "CL":"56",
                              "CN":"86",
                              "CX":"61",
                              "CO":"57",
                              "KM":"269",
                              "CG":"242",
                              "CK":"682",
                              "CR":"506",
                              "HR":"385",
                              "CU":"53",
                              "CY":"537",
                              "CZ":"420",
                              "DK":"45",
                              "DJ":"253",
                              "DM":"1",
                              "DO":"1",
                              "EC":"593",
                              "EG":"20",
                              "SV":"503",
                              "GQ":"240",
                              "ER":"291",
                              "EE":"372",
                              "ET":"251",
                              "FO":"298",
                              "FJ":"679",
                              "FI":"358",
                              "FR":"33",
                              "GF":"594",
                              "PF":"689",
                              "GA":"241",
                              "GM":"220",
                              "GE":"995",
                              "DE":"49",
                              "GH":"233",
                              "GI":"350",
                              "GR":"30",
                              "GL":"299",
                              "GD":"1",
                              "GP":"590",
                              "GU":"1",
                              "GT":"502",
                              "GN":"224",
                              "GW":"245",
                              "GY":"595",
                              "HT":"509",
                              "HN":"504",
                              "HU":"36",
                              "IS":"354",
                              "IN":"91",
                              "ID":"62",
                              "IQ":"964",
                              "IE":"353",
                              "IL":"972",
                              "IT":"39",
                              "JM":"1",
                              "JP":"81",
                              "JO":"962",
                              "KZ":"77",
                              "KE":"254",
                              "KI":"686",
                              "KW":"965",
                              "KG":"996",
                              "LV":"371",
                              "LB":"961",
                              "LS":"266",
                              "LR":"231",
                              "LI":"423",
                              "LT":"370",
                              "LU":"352",
                              "MG":"261",
                              "MW":"265",
                              "MY":"60",
                              "MV":"960",
                              "ML":"223",
                              "MT":"356",
                              "MH":"692",
                              "MQ":"596",
                              "MR":"222",
                              "MU":"230",
                              "YT":"262",
                              "MX":"52",
                              "MC":"377",
                              "MN":"976",
                              "ME":"382",
                              "MS":"1",
                              "MA":"212",
                              "MM":"95",
                              "NA":"264",
                              "NR":"674",
                              "NP":"977",
                              "NL":"31",
                              "AN":"599",
                              "NC":"687",
                              "NZ":"64",
                              "NI":"505",
                              "NE":"227",
                              "NG":"234",
                              "NU":"683",
                              "NF":"672",
                              "MP":"1",
                              "NO":"47",
                              "OM":"968",
                              "PK":"92",
                              "PW":"680",
                              "PA":"507",
                              "PG":"675",
                              "PY":"595",
                              "PE":"51",
                              "PH":"63",
                              "PL":"48",
                              "PT":"351",
                              "PR":"1",
                              "QA":"974",
                              "RO":"40",
                              "RW":"250",
                              "WS":"685",
                              "SM":"378",
                              "SA":"966",
                              "SN":"221",
                              "RS":"381",
                              "SC":"248",
                              "SL":"232",
                              "SG":"65",
                              "SK":"421",
                              "SI":"386",
                              "SB":"677",
                              "ZA":"27",
                              "GS":"500",
                              "ES":"34",
                              "LK":"94",
                              "SD":"249",
                              "SR":"597",
                              "SZ":"268",
                              "SE":"46",
                              "CH":"41",
                              "TJ":"992",
                              "TH":"66",
                              "TG":"228",
                              "TK":"690",
                              "TO":"676",
                              "TT":"1",
                              "TN":"216",
                              "TR":"90",
                              "TM":"993",
                              "TC":"1",
                              "TV":"688",
                              "UG":"256",
                              "UA":"380",
                              "AE":"971",
                              "GB":"44",
                              "US":"1",
                              "UY":"598",
                              "UZ":"998",
                              "VU":"678",
                              "WF":"681",
                              "YE":"967",
                              "ZM":"260",
                              "ZW":"263",
                              "BO":"591",
                              "BN":"673",
                              "CC":"61",
                              "CD":"243",
                              "CI":"225",
                              "FK":"500",
                              "GG":"44",
                              "VA":"379",
                              "HK":"852",
                              "IR":"98",
                              "IM":"44",
                              "JE":"44",
                              "KP":"850",
                              "KR":"82",
                              "LA":"856",
                              "LY":"218",
                              "MO":"853",
                              "MK":"389",
                              "FM":"691",
                              "MD":"373",
                              "MZ":"258",
                              "PS":"970",
                              "PN":"872",
                              "RE":"262",
                              "RU":"7",
                              "BL":"590",
                              "SH":"290",
                              "KN":"1",
                              "LC":"1",
                              "MF":"590",
                              "PM":"508",
                              "VC":"1",
                              "ST":"239",
                              "SO":"252",
                              "SJ":"47",
                              "SY":"963",
                              "TW":"886",
                              "TZ":"255",
                              "TL":"670",
                              "VE":"58",
                              "VN":"84",
                              "VG":"284",
                              "VI":"340"]
    let cname = country.uppercased()
    if countryDictionary[cname] != nil
    {
        return countryDictionary[cname]!
    }
    else
    {
        return cname
    }
    //        let myfrndObj = CoreDBManager.sharedDatabase.getMyFriendsStory(userid: UserDefaultManager.getStringFromUserDefaults(key: UD_UserId))
    //   let objNCountSorted = myfrndObj.sorted (by: {$0.story_id! > $1.story_id!})
    //        let objNCountSorted = myfrndObj.sorted(by: { $0.created_date?.compare($1.created_date!) == .orderedDescending })
    //        let groupedUser = objNCountSorted.filterDuplicate { ($0.user_id)} as NSArray
}


