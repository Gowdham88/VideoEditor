//
//  ForgotPasswordVC.swift
//  VideoEditor
//
//  Copyright © 2018 Ark Inc. All rights reserved.
//

import Foundation
import Alamofire

class ForgotPasswordVC: BaseVC
{
    @IBOutlet weak var imgAppLogo: UIImageView!
    @IBOutlet weak var txtEmail: UITextField!
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    @IBAction func SubmitForgotPasswordRequest(_ sender: Any)
    {
        
        //        APP_DELEGATE.makeTabbarRootController()
        //        return
        self.view.endEditing(true)
        
//        return
        let emailAddress: String = self.txtEmail.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if (emailAddress.isEmpty)
        {
            APP_DELEGATE.displayMessageAlertWithMessage(alertMessage: "Please enter email.", withTitle: "Alert")
            return
        }
        let isEmailValid: Bool = isValidEmail(testStr: emailAddress)
        
        if !isEmailValid
        {
            APP_DELEGATE.displayMessageAlertWithMessage(alertMessage: "Please enter valid email.", withTitle: "Alert")
            return
        }
        
        if !APP_DELEGATE.CheckForInternetConnection()
        {
            APP_DELEGATE.displayMessageAlertWithMessage(alertMessage: NoInternetMessage, withTitle: "Alert")
            
            return
        }
        let params: Parameters = [
            "email": emailAddress,
            ]
        let requestURL: String = Constants.API_BASE_URL + Constants.FORGOTPASS_API
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
                                    
                                    let myalert = UIAlertController(title: "Forgot Password", message: message, preferredStyle: UIAlertControllerStyle.alert)
                                    
                                    let okAction = UIAlertAction(title: "OK", style: .cancel) { (action:UIAlertAction!) in
                                        
                                        self.navigationController?.popViewController(animated: true)
                                        
                                    }
                                    
                                    myalert.addAction(okAction)
                                    
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
    @IBAction func BackToLogin(_ sender: Any)
    {
        self.navigationController?.popViewController(animated: true)
    }
}
