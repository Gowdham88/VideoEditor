//
//  LoginVC.swift
//  FannerCam

import UIKit
import Alamofire

class LoginVC: BaseVC {

    //MARK: - OUTLETS
    
    @IBOutlet weak var imgAppLogo: UIImageView!
    
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnSignUp: UIButton!
    @IBOutlet weak var btnClickhere: UIButton!
    
    //MARK: - VARIABLES
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        "username": "mario.rossi",
//        "password": "cypT7Qr9j5qJaa_w"
//        username: webmaster@fanner.it
//        password: 2c2pZkq4rrxj
        
        self.txtUsername.text = "webmaster@fanner.it"
        self.txtPassword.text = "2c2pZkq4rrxj"
        self.navigationController?.navigationBar.isHidden = true
        addLeftViewInTextField(txtPassword, imageName: "key_blue")
        addLeftViewInTextField(txtUsername, imageName: "user_blue")
        
        self.view.layoutIfNeeded()
        
//        btnLogin.layer.cornerRadius = btnLogin.frame.size.height/2
//        btnLogin.layer.masksToBounds = true
        btnLogin.setBackgroundImage(UIImage(named: "button_bg_blue_big"), for: .normal)
        self.view.layoutIfNeeded()

        btnLogin.setBackgroundImage(UIImage(named: ""), for: .normal)
        setCornerRadiusAndShadowOnButton(button: btnLogin, backColor: COLOR_APP_THEME())
        APP_DELEGATE.CheckForFannerServiceStatus()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnLoginClicked(_ sender: Any) {
        
      //  APP_DELEGATE.makeTabbarRootController()
//        return
        
        let userName: String = self.txtUsername.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let passwordStr: String = self.txtPassword.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if (userName.isEmpty)
        {
            APP_DELEGATE.displayMessageAlertWithMessage(alertMessage: "Please enter username.", withTitle: "Alert")
            return
        }        
        else if (passwordStr.isEmpty)
        {
            APP_DELEGATE.displayMessageAlertWithMessage(alertMessage: "Please enter password.", withTitle: "Alert")
            
            return
        }
        
        if !APP_DELEGATE.CheckForInternetConnection()
        {
            APP_DELEGATE.displayMessageAlertWithMessage(alertMessage: NoInternetMessage, withTitle: "Alert")
            
            return
        }
        let params: Parameters = [
            "username": userName,
            "password": passwordStr,
        ]
        let requestURL: String = Constants.API_BASE_URL + Constants.LOGIN_API
        APP_DELEGATE.showHUDWithText(textMessage: "")
        Alamofire.request(requestURL, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil)
            .responseJSON { response in
                
                switch response.result
                {
                case .success(_):
                    if response.result.value != nil
                    {
                        
                        let dict = response.result.value as! NSDictionary
                        if dict.value(forKey: "code") != nil
                        {
                            let statusCode: String = dict.value(forKey: "code") as! String
                            
                            let message: String = dict.value(forKey: "message") as! String
                            DispatchQueue.main.async {
                                APP_DELEGATE.hideHUD()
                                if statusCode == Constants.SUCCESS_CODE
                                {
                                    let myalert = UIAlertController(title: "Login", message: message, preferredStyle: UIAlertControllerStyle.alert)
                                    
                                    let cancelAction = UIAlertAction(title: "OK", style: .cancel) { (action:UIAlertAction!) in
                                        
                                        let responseDict = (dict.value(forKey: "response") as! NSDictionary)
                                        
                                        UserDefaults.standard.set(responseDict, forKey: Constants.USER_PROFILE_INFO)
                                        UserDefaults.standard.set("YES", forKey: Constants.ISUSERLOGIN)
                                        
                                        UserDefaults.standard.synchronize()
                                        
                                        APP_DELEGATE.makeTabbarRootController()
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
                    DispatchQueue.main.async {
                        APP_DELEGATE.hideHUD()
                        APP_DELEGATE.displayMessageAlertWithMessage(alertMessage: "Error occurred, please try after some time.", withTitle: "Login")
                    }
                    
                    break
                    
                }
                
                
        }
    }
    
    @IBAction func btnSignUpClicked(_ sender: Any) {
        let redirectTo = loadVC(strStoryboardId: SB_LOGIN, strVCId: idRegisterVC) as! RegisterVC
        self.navigationController?.pushViewController(redirectTo, animated: true)
    }
    
    @IBAction func btnClickhereClicked(_ sender: Any) {
        let redirectTo = loadVC(strStoryboardId: SB_LOGIN, strVCId: idForgotVC) as! ForgotPasswordVC
        self.navigationController?.pushViewController(redirectTo, animated: true)
    }
}
