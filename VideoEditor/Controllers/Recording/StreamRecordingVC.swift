//
//  StreamRecordingVC.swift
//  FannerCam

import UIKit

class StreamRecordingVC: UIViewController {

    @IBOutlet weak var btnAddOverlayTozone: UIButton!
    
    @IBOutlet weak var viewOverlay: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewOverlay.isHidden = true
        btnAddOverlayTozone.isHidden = false
        
        btnAddOverlayTozone.layer.cornerRadius = btnAddOverlayTozone.frame.size.height / 2
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
//        APP_DELEGATE.myOrientation = .landscape
        self.navigationController?.navigationBar.isHidden = true
        UIDevice.current.setValue(APP_DELEGATE.landscaperSide.rawValue, forKey: "orientation")
        //APP_DELEGATE.tabbarController?.tabBar.isHidden = true
        //APP_DELEGATE.tabbarController?.tabBar.layer.zPosition = -1
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
        //APP_DELEGATE.tabbarController?.tabBar.isHidden = false
       // APP_DELEGATE.tabbarController?.tabBar.layer.zPosition = 0
    }

    //MARK: - FUNCTIONS
    @IBAction func btnAddOverlayClicked(_ sender: Any) {
        
        viewOverlay.isHidden = false
        btnAddOverlayTozone.isHidden = true
    
        let deadlineTime = DispatchTime.now() + .seconds(2)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            let redirectTo = loadVC(strStoryboardId: SB_LANDSCAPE, strVCId: idLiveCameraVC) as! LiveCameraVC
            self.navigationController?.pushViewController(redirectTo, animated: true)
        }
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
