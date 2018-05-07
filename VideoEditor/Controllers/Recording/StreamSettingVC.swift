//
//  StreamSettingVC.swift
//  FannerCam

import UIKit
import AVFoundation

class StreamSettingVC: UIViewController {
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var lblScreenText: UILabel!
    @IBOutlet weak var btnPages: UIButton!
    @IBOutlet weak var btnProfile: UIButton!
    @IBOutlet weak var txtEventName: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var viewCameraContainer: UIView!
    
    let captureSession = AVCaptureSession()
    var currentDevice: AVCaptureDevice?
    var videoFileOutput: AVCaptureMovieFileOutput?
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    var loginButton: FBSDKLoginButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        btnProfile.isHidden = true
        //        btnPages.isHidden = true
        txtPassword.isHidden = true
        txtEventName.isHidden = true
        
        setCornerRadiusAndShadowOnButton(button: btnPages, backColor: COLOR_APP_THEME())
        setCornerRadiusAndShadowOnButton(button: btnProfile, backColor: UIColor.white)
        
        //        APP_DELEGATE.myOrientation = .landscape
        UIDevice.current.setValue(APP_DELEGATE.landscaperSide.rawValue, forKey: "orientation")
        self.navigationController?.navigationBar.isHidden = true
        //APP_DELEGATE.tabbarController?.tabBar.isHidden = true
        //APP_DELEGATE.tabbarController?.tabBar.layer.zPosition = -1
        
        // Do any additional setup after loading the view.
        configureVideoSession()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //        APP_DELEGATE.myOrientation = .landscape
        self.navigationController?.navigationBar.isHidden = true
        UIDevice.current.setValue(APP_DELEGATE.landscaperSide.rawValue, forKey: "orientation")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
        //APP_DELEGATE.tabbarController?.tabBar.isHidden = false
        // APP_DELEGATE.tabbarController?.tabBar.layer.zPosition = 0
    }
    
    //MARK:- Config video
    func configureVideoSession() {
        // Preset For 720p
        captureSession.sessionPreset = AVCaptureSession.Preset.hd1280x720
        
        // Get Available Devices Capable Of Recording Video
        let devices = AVCaptureDevice.devices(for: AVMediaType.video)
        
        // Get Back Camera
        for device in devices
        {
            if device.position == AVCaptureDevice.Position.back
            {
                currentDevice = device
            }
        }
        let camera = AVCaptureDevice.default(for: AVMediaType.video)
        
        // Audio Input
        let audioInputDevice = AVCaptureDevice.default(for: AVMediaType.audio)
        
        do
        {
            let audioInput = try AVCaptureDeviceInput(device: audioInputDevice!)
            
            // Add Audio Input
            if captureSession.canAddInput(audioInput)
            {
                captureSession.addInput(audioInput)
            }
            else
            {
                NSLog("Can't Add Audio Input")
            }
        }
        catch let error
        {
            NSLog("Error Getting Input Device: \(error)")
        }
        
        // Video Input
        let videoInput: AVCaptureDeviceInput
        do
        {
            videoInput = try AVCaptureDeviceInput(device: camera!)
            
            // Add Video Input
            if captureSession.canAddInput(videoInput)
            {
                captureSession.addInput(videoInput)
            }
            else
            {
                NSLog("ERROR: Can't add video input")
            }
        }
        catch let error
        {
            NSLog("ERROR: Getting input device: \(error)")
        }
        
        // Video Output
        videoFileOutput = AVCaptureMovieFileOutput()
        captureSession.addOutput(videoFileOutput!)
        
        // Show Camera Preview
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        viewCameraContainer.layer.addSublayer(cameraPreviewLayer!)
        cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        let width = view.bounds.width
        cameraPreviewLayer?.frame = CGRect(x: 0, y: 0, width: width, height: width)
        cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation(rawValue: UIDevice.current.orientation.rawValue)!
        // Bring Record Button To Front & Start Session
        //        viewCameraContainer.bringSubview(toFront:recordButton)
        
        captureSession.startRunning()
        print(captureSession.inputs)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnBackClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSaveClicked(_ sender: Any) {
        
        //        btnPages.isHidden = false
        //        btnProfile.isHidden = false
        //        let redirectTo = loadVC(strStoryboardId: SB_LANDSCAPE, strVCId: idStreamRecordingVC) as! StreamRecordingVC
        //        self.navigationController?.pushViewController(redirectTo, animated: true)
        
        //============== CHECK FB linked and set fbavailable to true/false
        
        
        fbAvailable = true
        //=============
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnPagesClicked(_ sender: Any) {
        txtEventName.isHidden = false
        
        lblScreenText.text = "FACEBOOK LIVE SETTINGS"
        
        if(txtPassword.isHidden == false)
        {
            txtPassword.isHidden = true
            txtPassword.text = ""
        }
    }
    
    @IBAction func btnProfileClicked(_ sender: Any) {
        
        lblScreenText.text = "LIVE SETTINGS"
        
        if(txtEventName.isHidden == true)
        {
            txtEventName.isHidden = false
            txtPassword.isHidden = false
        }
        else
        {
            txtEventName.isHidden = false
            txtPassword.isHidden = false
        }
        
        self.loginButton = FBSDKLoginButton()
        self.loginButton.publishPermissions = ["publish_actions"]
        self.loginButton.loginBehavior = .native
        self.loginButton.center = CGPoint(x: self.view.bounds.size.width / 2, y: 60)
        self.loginButton.delegate = self
        self.view.addSubview(self.loginButton)
        
        if FBSDKAccessToken.current() == nil {
            //            self.view.insertSubview(self.blurOverlay, at: 1)
            
            fbAvailable = false
            
        } else {
            
            //            self.recordButton.isHidden = false
            
            fbAvailable = true
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

extension StreamSettingVC : FBSDKLoginButtonDelegate {
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        if error != nil {
            print("Error logging in: \(error.localizedDescription)")
            return
        } else {
            print("Not loggedIn")
        }
        
        fbAvailable = false
        
        //        self.blurOverlay.removeFromSuperview()
    }
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
        //        self.btnStartRecoding.isHidden = true
        
        fbAvailable = false
        //        self.view.insertSubview(self.blurOverlay, at: 1)
    }
    
    
}
