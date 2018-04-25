//
//  MainTabbarVC.swift
//  iCoinsiOS

import UIKit

class MainTabbarVC: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.layoutIfNeeded()
//        [self.viewControllers objectAtIndex:0].tabBarItem.image = [[UIImage imageNamed:@"car_gray"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//        [self.viewControllers objectAtIndex:0].tabBarItem.selectedImage = [[UIImage imageNamed:@"car_white"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//        [self.viewControllers objectAtIndex:0].tabBarItem.tag = 0;
        
        var imageInsets = UIEdgeInsets(top: 2, left: 0, bottom: -2, right: 0)
        var titleInsets = UIOffsetMake(0, -4)
        
        let tabBarItem1 = (self.tabBar.items?[0])! as UITabBarItem
        tabBarItem1.image = UIImage(named: "home_gray")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        
        let tabBarItem2 = (self.tabBar.items?[1])! as UITabBarItem
        tabBarItem2.image = UIImage(named: "video_gray")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        
        let imageInsetsForRecord = UIEdgeInsets(top: 8, left: 0, bottom: -8, right: 0)
        let tabBarItem3 = (self.tabBar.items?[2])! as UITabBarItem
        tabBarItem3.image = UIImage(named: "record_blue")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        
        let tabBarItem4 = (self.tabBar.items?[3])! as UITabBarItem
        tabBarItem4.image = UIImage(named: "studio_gray")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        
        let tabBarItem5 = (self.tabBar.items?[4])! as UITabBarItem
        tabBarItem5.image = UIImage(named: "thunder_gray")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        
        if ((isIpad() && UIDevice.current.modelName == "iPad Pro 9.7 Inch") ||
            (isIpad() && UIDevice.current.modelName == "iPad Pro 12.9 Inch") ||
            (isIpad() && UIDevice.current.modelName == "iPad Pro 12.9 Inch 2. Generation") ||
            (isIpad() && UIDevice.current.modelName == "iPad Pro 10.5 Inch")) {

            titleInsets = UIOffsetMake(0, 0)
            imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            
            tabBarItem3.titlePositionAdjustment = titleInsets
            tabBarItem3.imageInsets = UIEdgeInsets(top: 2, left: 0, bottom: -2, right: 0)
//            tabBarItem3.titlePositionAdjustment = titleInsets
//            tabBarItem3.imageInsets = imageInsetsForRecord
        } else {
            tabBarItem3.titlePositionAdjustment = titleInsets
            tabBarItem3.imageInsets = imageInsetsForRecord
        }
        
        tabBarItem1.titlePositionAdjustment = titleInsets
        tabBarItem1.imageInsets = imageInsets
        
        tabBarItem2.titlePositionAdjustment = titleInsets
        tabBarItem2.imageInsets = imageInsets
        
        
        
        tabBarItem4.titlePositionAdjustment = titleInsets
        tabBarItem4.imageInsets = imageInsets
        
        tabBarItem5.titlePositionAdjustment = titleInsets
        tabBarItem5.imageInsets = imageInsets
        
        tabBarItem1.selectedImage = UIImage(named: "home_blue")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        tabBarItem2.selectedImage = UIImage(named: "video_blue")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        tabBarItem3.selectedImage = UIImage(named: "record_blue")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        tabBarItem4.selectedImage = UIImage(named: "studio_blue")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        tabBarItem5.selectedImage = UIImage(named: "thunder_blue")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        
        self.selectedIndex = 0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = true
        self.tabBar.tintColor = COLOR_APP_THEME()
        self.tabBar.barTintColor = COLOR_BACKGROUND_VIEW()
        self.tabBar.isTranslucent = false
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        APP_DELEGATE.myOrientation = .portrait
        APP_DELEGATE.landscaperSide = UIInterfaceOrientation.portrait
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        self.view.layoutIfNeeded()
    }
}

public extension UIDevice {
    
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
        case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
        case "iPhone8,4":                               return "iPhone SE"
        case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
        case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
        case "iPhone10,3", "iPhone10,6":                return "iPhone X"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad6,11", "iPad6,12":                    return "iPad 5"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,3", "iPad6,4":                      return "iPad Pro 9.7 Inch"
        case "iPad6,7", "iPad6,8":                      return "iPad Pro 12.9 Inch"
        case "iPad7,1", "iPad7,2":                      return "iPad Pro 12.9 Inch 2. Generation"
        case "iPad7,3", "iPad7,4":                      return "iPad Pro 10.5 Inch"
        case "AppleTV5,3":                              return "Apple TV"
        case "AppleTV6,2":                              return "Apple TV 4K"
        case "AudioAccessory1,1":                       return "HomePod"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
        }
    }
}
