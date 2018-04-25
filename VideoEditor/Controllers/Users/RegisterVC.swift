//
//  RegisterVC.swift
//  FannerCam


import UIKit
import Alamofire

class RegisterVC: BaseVC {

    //MARK - OUTLETS
    @IBOutlet weak var imgAppLogo: UIImageView!
    
    @IBOutlet weak var txtUserName: UITextField!
    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtSurname: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtConfirmPassword: UITextField!
    
    @IBOutlet weak var btnSignUp: UIButton!
    @IBOutlet weak var btnLogin: UIButton!
    
    
    //MARK - VARIBALES
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.txtUserName.text = "ale1.ricci"
//        self.txtFirstName.text = "Ale1"
//        self.txtEmail.text = "ale.ricci1@finner.it"
//        self.txtSurname.text = "Ricci"
//        self.txtPassword.text = "ale123"
//        self.txtConfirmPassword.text = "ale123"
        
        addLeftViewInTextField(self.txtPassword, imageName: "key_blue")
        addLeftViewInTextField(self.txtFirstName, imageName: "user_blue")
        addLeftViewInTextField(self.txtSurname, imageName: "user_blue")
        addLeftViewInTextField(self.txtUserName, imageName: "user_blue")
        addLeftViewInTextField(self.txtEmail, imageName: "email_blue")
        addLeftViewInTextField(self.txtConfirmPassword, imageName: "key_blue")
        
        self.view.layoutIfNeeded()
        
//        btnSignUp.layer.cornerRadius = btnSignUp.frame.size.height/2
//        btnSignUp.layer.masksToBounds = true
        
        btnSignUp.setBackgroundImage(UIImage(named: ""), for: .normal)
        setCornerRadiusAndShadowOnButton(button: btnSignUp, backColor: COLOR_APP_THEME())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- FUNCTIONS
    
    //function for adding left view image to textfields
    func addLeftImageViewInTextField(textfield:UITextField, strImageName:String ,strPlaceHolderText:String)
    {
        textfield.leftView = UIImageView(image: UIImage(named: strImageName))
        textfield.leftViewMode = .always
        textfield.attributedPlaceholder = NSAttributedString(string:strPlaceHolderText, attributes: [NSAttributedStringKey.font:UIFont(name: "Georgia", size: 20.0)!])
    }

    
    @IBAction func btnLoginClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSignUpClicked(_ sender: Any)
    {
        
//        APP_DELEGATE.makeTabbarRootController()
        
        let emailStr: String = self.txtEmail.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let firstNameStr: String = self.txtFirstName.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let surnameStr: String = self.txtSurname.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let usernameStr: String = self.txtUserName.text!.trimmingCharacters(in: .whitespacesAndNewlines)

        let passwordStr: String = self.txtPassword.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let confirmPassword: String = self.txtConfirmPassword.text!.trimmingCharacters(in: .whitespacesAndNewlines)

        if (firstNameStr.isEmpty)
        {
            APP_DELEGATE.displayMessageAlertWithMessage(alertMessage: "Please enter first name.", withTitle: "Alert")
            return
        }
        else if (surnameStr.isEmpty)
        {
            APP_DELEGATE.displayMessageAlertWithMessage(alertMessage: "Please enter surname.", withTitle: "Alert")
            return
        }
        else if (usernameStr.isEmpty)
        {
            APP_DELEGATE.displayMessageAlertWithMessage(alertMessage: "Please enter username.", withTitle: "Alert")
            return
        }
        else if (emailStr.isEmpty)
        {
            APP_DELEGATE.displayMessageAlertWithMessage(alertMessage: "Please enter email.", withTitle: "Alert")
            return
        }
        else if (passwordStr.isEmpty)
        {
            APP_DELEGATE.displayMessageAlertWithMessage(alertMessage: "Please enter password.", withTitle: "Alert")
            
            return
        }
        else if (confirmPassword.isEmpty)
        {
            APP_DELEGATE.displayMessageAlertWithMessage(alertMessage: "Please enter confirm password.", withTitle: "Alert")
            
            return
        }
        
        let isEmailValid: Bool = isValidEmail(testStr: emailStr)
        
        if !isEmailValid
        {
            APP_DELEGATE.displayMessageAlertWithMessage(alertMessage: "Please enter valid email.", withTitle: "Alert")
            return
        }
        if (confirmPassword != passwordStr)
        {
            APP_DELEGATE.displayMessageAlertWithMessage(alertMessage: "Password and confirm password should be same.", withTitle: "Alert")
            
            return
        }
        
        if !APP_DELEGATE.CheckForInternetConnection()
        {
            APP_DELEGATE.displayMessageAlertWithMessage(alertMessage: NoInternetMessage, withTitle: "Alert")

            return
        }
        let params: Parameters = [
            "firstname": firstNameStr,
            "surname": surnameStr,
            "email": emailStr,
            "username" : "mario.mark",
            "password": passwordStr,
            "password_confirm": confirmPassword
        ]
        let requestURL: String = Constants.API_BASE_URL + Constants.REGISTER_API
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
                                    
                                    let myalert = UIAlertController(title: "Register", message: message, preferredStyle: UIAlertControllerStyle.alert)
                                    
                                    let cancelAction = UIAlertAction(title: "OK", style: .cancel) { (action:UIAlertAction!) in
                                        
                                        self.navigationController?.popViewController(animated: true)
                                    }
                                    
                                    myalert.addAction(cancelAction)
                                    
                                    self.present(myalert, animated: true)
                                }
                                else
                                {
                                    APP_DELEGATE.displayMessageAlertWithMessage(alertMessage: message, withTitle: "Register")
                                }
                            }
                        }
                        else
                        {
                            DispatchQueue.main.async {
                                APP_DELEGATE.hideHUD()
                                APP_DELEGATE.displayMessageAlertWithMessage(alertMessage: "Error occurred, please try after some time.", withTitle: "Register")
                            }
                        }
                        
                    }
                    else
                    {
                        DispatchQueue.main.async {
                            APP_DELEGATE.hideHUD()
                            APP_DELEGATE.displayMessageAlertWithMessage(alertMessage: "Error occurred, please try after some time.", withTitle: "Register")
                        }
                    }
                    break
                    
                case .failure(_):
                    print(response.result.error!)
                    DispatchQueue.main.async {
                        APP_DELEGATE.hideHUD()
                        APP_DELEGATE.displayMessageAlertWithMessage(alertMessage: "Error occurred, please try after some time.", withTitle: "Register")
                    }
                    
                    break
                    
                }
                
                
        }
    }
}
