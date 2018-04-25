//
//  BaseVC.swift
//  iCoinsiOS


import UIKit

class BaseVC: UIViewController, UIGestureRecognizerDelegate, UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black, NSAttributedStringKey.font : UIFont.FontWithSize(FONT_MONTSERRAT_Bold, 18)]
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = COLOR_NAVIGATION_BAR()
        UIApplication.shared.statusBarStyle = .default
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self;
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK:- Set Navigation bar buttons
    func addTopLeftBackButton() {
        let btn1 = UIButton(type: .custom)
        btn1.setImage(UIImage(named: "back_gray"), for: .normal)
        btn1.frame = CGRect(x: 0, y: 0, width: 29, height: 29)
        btn1.contentMode = .scaleAspectFill
        btn1.addTarget(self, action: #selector(topLeftbackButtonClicked), for: .touchUpInside)
        let item1 = UIBarButtonItem(customView: btn1)
        self.navigationItem.setLeftBarButtonItems([item1], animated: true)
    }
    
    @objc func topLeftbackButtonClicked() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func addTopLeftMenuButton() {
        let btn1 = UIButton(type: .custom)
        btn1.setImage(UIImage(named: "menu_white"), for: .normal)
        btn1.frame = CGRect(x: 0, y: 0, width: 29, height: 29)
        btn1.contentMode = .scaleAspectFill
        btn1.addTarget(self, action: #selector(topLeftMenuButtonClicked), for: .touchUpInside)
        let item1 = UIBarButtonItem(customView: btn1)
        self.navigationItem.setLeftBarButtonItems([item1], animated: true)
    }

    @objc func topLeftMenuButtonClicked() {
        
    }
    
    func addTopRightNavigationBarButton(imageName: String) {
        let btn1 = UIButton(type: .custom)
        btn1.setImage(UIImage(named: imageName), for: .normal)
        btn1.frame = CGRect(x: 0, y: 0, width: 29, height: 29)
        btn1.contentMode = .scaleAspectFit
        btn1.addTarget(self, action: #selector(topRightNavigationBarButtonClicked), for: .touchUpInside)
        let item1 = UIBarButtonItem(customView: btn1)
        self.navigationItem.setRightBarButtonItems([item1], animated: true)
    }
    
    func addTopRightNavigationBarButtonBackgroundImage(imageName: String) {
        let btn1 = UIButton(type: .custom)
        btn1.setBackgroundImage(UIImage(named: imageName), for: .normal)

//        btn1.setImage(UIImage(named: imageName), for: .normal)
        btn1.frame = CGRect(x: 0, y: 0, width: 29, height: 29)
        btn1.contentMode = .scaleAspectFit
        btn1.addTarget(self, action: #selector(topRightNavigationBarButtonClicked), for: .touchUpInside)
        let item1 = UIBarButtonItem(customView: btn1)
        self.navigationItem.setRightBarButtonItems([item1], animated: true)
    }
    
    func addTopRightNavigationBarButtonWithText(strText: String) {
        let btn1 = UIButton(type: .custom)
        btn1.setTitle(strText, for: .normal)
        btn1.setBackgroundImage(UIImage(named: "button_bg_blue"), for: .normal)
        btn1.contentMode = .scaleToFill
        btn1.frame = CGRect(x: 0, y: 0, width: 66, height: 34)
        btn1.setTitleColor(UIColor.white, for: .normal)
        btn1.backgroundColor = UIColor.clear
//        btn1.titleEdgeInsets.left = 3
        btn1.titleLabel?.font = UIFont(name: FONT_MONTSERRAT_Regular, size: 10)
        btn1.addTarget(self, action: #selector(topRightNavigationBarButtonClicked), for: .touchUpInside)
        
        let customView: UIView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 63, height: 34))
//        customView.backgroundColor = UIColor.red
        
//        let imageView: UIImageView = UIImageView.init(frame: CGRect.init(x: 5, y: 0, width: 63, height: 34))
////        imageView.image = UIImage.init(named: "button_bg_blue")
//        imageView.isUserInteractionEnabled = false
//        customView.addSubview(imageView)
        customView.addSubview(btn1)
        
        let item1 = UIBarButtonItem(customView: customView)
        self.navigationItem.setRightBarButtonItems([item1], animated: true)
    }
    
    @objc func topRightNavigationBarButtonClicked() {
        
    }
    
    func redirectToShareScreen() {
        let redirectTo = loadVC(strStoryboardId: SB_OTHERS, strVCId: idSocialShareVC) as! SocialShareVC
        self.navigationController?.pushViewController(redirectTo, animated: true)
    }
    
    func openWebViewVCWithURL(strURL: String, strTitle: String)
    {
//        let redirectTo = loadVC(strStoryboardId: SB_OTHERS, strVCId: idWebViewVC) as! WebViewVC
//        redirectTo.strURLToLoad = strURL
//        redirectTo.strScreenTitle = strTitle
//        self.navigationController?.pushViewController(redirectTo, animated: true)
    }
}

extension UINavigationController {
    open override var shouldAutorotate: Bool {
        return true
    }
    
//    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
//        return APP_DELEGATE.myOrientation
//    }
//    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
//        return (visibleViewController?.supportedInterfaceOrientations)!;
//    }
}
//extension UIViewController: UINavigationControllerDelegate {
//    public func navigationControllerSupportedInterfaceOrientations(_ navigationController: UINavigationController) -> UIInterfaceOrientationMask {
//        return UIInterfaceOrientationMask.landscape
//    }
//}
