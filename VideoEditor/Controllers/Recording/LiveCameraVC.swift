//
//  LiveCameraVC.swift
//  VideoEditor


import UIKit
import AVFoundation
import MobileCoreServices
import MBProgressHUD
import Alamofire

class LiveCameraVC: BaseVC, UIImagePickerControllerDelegate, URLSessionDelegate, URLSessionDownloadDelegate
{
    var progressHUD: MBProgressHUD!
    typealias ProgressHandler = (Float) -> ()
    
    var onProgress : ProgressHandler? {
        didSet {
            if onProgress != nil {
                let _ = activate()
            }
        }
    }
    var selectedVideoURL: URL!
    var selectedCameraSource: Int = 1
    let picker = UIImagePickerController()
    var recordEventInfo: RecordingInfo!
    
    var videoSettingDict: Dictionary<String, Any> = Dictionary.init()
    
    fileprivate let sessionQueue                 = DispatchQueue(label: "session queue", attributes: [])
    
    fileprivate var backgroundRecordingID        : UIBackgroundTaskIdentifier? = nil
    
    fileprivate var zoomScale                    = CGFloat(1.0)
    /// Variable for storing initial zoom scale before Pinch to Zoom begins
    fileprivate var beginZoomScale               = CGFloat(1.0)
    
    var videoURLType: String = "other"
    @IBOutlet weak var imgRotateScreen: UIView!
    @IBOutlet weak var lblHomeTeam: UILabel!
    @IBOutlet weak var btnZoom: UIButton!
    @IBOutlet weak var btnZoomSwitch: UIButton!
    @IBOutlet weak var btnMinusZoom: UIButton!
    @IBOutlet weak var btnPlusZoom: UIButton!
    @IBOutlet weak var btnMinusZoomSpeed: UIButton!
    @IBOutlet weak var btnPlusZoomSpeed: UIButton!
    @IBOutlet weak var lblZoomSpeed: UILabel!
    
    @IBOutlet weak var txtScore: UITextField!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblHalf: UILabel!
    @IBOutlet weak var btnStartRecoding: UIButton!
    @IBOutlet weak var btnBackToDetails: UIButton!
    @IBOutlet weak var btnLiveSettings: UIButton!
    
    @IBOutlet weak var scoreView: UIView!
    @IBOutlet weak var btnTime: UIButton!
    @IBOutlet weak var btnPeriod: UIButton!
    @IBOutlet weak var btnHomeName: UIButton!
    @IBOutlet weak var btnAwayName: UIButton!
    
    @IBOutlet weak var lblAwayTeam: UILabel!
    @IBOutlet weak var btnHD: UIButton!
    @IBOutlet weak var btnFHD: UIButton!
    @IBOutlet weak var btn4K: UIButton!
    @IBOutlet weak var btnFrontCam: UIButton!
    @IBOutlet weak var btnBackCam: UIButton!
    @IBOutlet weak var btnURLRec: UIButton!
    @IBOutlet weak var btnRollRec: UIButton!
    
    @IBOutlet weak var btnFPS30: UIButton!
    @IBOutlet weak var btnFPS60: UIButton!
    @IBOutlet weak var btnH264: UIButton!
    @IBOutlet weak var btnH265: UIButton!
    @IBOutlet weak var btnFBYT: UIButton!
    
    @IBOutlet weak var viewCameraContainer: UIView!
    
    @IBOutlet weak var phototagONbutton: UIButton!
    @IBOutlet weak var phototagOFFbutton: UIButton!
    
    let captureSession = AVCaptureSession()
    var currentDevice: AVCaptureDevice?
    var videoFileOutput: AVCaptureMovieFileOutput?
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    var previewLayerConnection: AVCaptureConnection?
    
    @IBOutlet weak var livesettingEqaulheight: NSLayoutConstraint!
    @IBOutlet weak var liveSettingTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var BactBtnTopConstraint: NSLayoutConstraint!
//    let notificationhide = Notification.Name("hideLiveBtn")
    override func viewDidLoad() {
        super.viewDidLoad()
        
       

      
        
        APP_DELEGATE.myOrientation = .all
        setCornerRadiusToButton(button: btnHD)
        setCornerRadiusToButton(button: btnFHD)
        setCornerRadiusToButton(button: btn4K)
       
        setCornerRadiusToButton(button: btnFrontCam)
        setCornerRadiusToButton(button: btnBackCam)
        setCornerRadiusToButton(button: btnRollRec)
        setCornerRadiusToButton(button: btnURLRec)
        
        btnFrontCam.backgroundColor = COLOR_APP_THEME()
        btnBackCam.backgroundColor = COLOR_WHITE_ALPHA_40()
        btnRollRec.backgroundColor = COLOR_WHITE_ALPHA_40()
        btnURLRec.backgroundColor = COLOR_WHITE_ALPHA_40()
        
        setCornerRadiusToButton(button: btnFPS30)
        setCornerRadiusToButton(button: btnFPS60)
        setCornerRadiusToButton(button: btnH264)
        setCornerRadiusToButton(button: btnH265)
        setCornerRadiusToButton(button: phototagONbutton)
        setCornerRadiusToButton(button: phototagOFFbutton)
        
        //        setCornerRadiusToButton(button: btnFBYT)
        
        //        setCornerRadiusAndShadowOnButton(button: btnZoom, backColor: COLOR_APP_THEME())
        setCornerRadiusAndShadowOnButton(button: btnStartRecoding, backColor: COLOR_APP_THEME())
        setCornerRadiusAndShadowOnButton(button: btnLiveSettings, backColor: COLOR_APP_THEME())
        setCornerRadiusAndShadowOnButton(button: btnBackToDetails, backColor: COLOR_APP_THEME())
        
        
        

        
        // set default to back camera
        btnFrontCam.backgroundColor = COLOR_WHITE_ALPHA_40()
        btnBackCam.backgroundColor = COLOR_APP_THEME()
        
        self.imgRotateScreen.isHidden = false
        self.view.bringSubview(toFront: viewCameraContainer)
        self.view.bringSubview(toFront: imgRotateScreen)
        btnZoomSwitch.setImage(UIImage(named: "switch_on"), for: .normal)
        videoSettingDict["Quality"] = Constants.FHDQuality
        videoSettingDict["RecordingSource"] = Constants.BackCamera
        videoSettingDict["FPS"] = Constants.FPS30
        
        videoSettingDict["ZoomSpeed"] = 20
        videoSettingDict["IsZoomOn"] = true
        
        self.addGestureRecognizers()
        //        self.configureVideoSession()
        
        self.AddCameraViewAndSetConfig()
        self.captureSession.startRunning()
        self.viewCameraContainer.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.height, height: self.view.frame.size.width)
        
        if self.recordEventInfo.recADay {
            self.btnLiveSettings.isHidden = true
             liveSettingTopConstraint.constant = 0
             livesettingEqaulheight.constant = 0
        }
        
        if self.recordEventInfo.createEvent {
            liveSettingTopConstraint.constant = 7
            livesettingEqaulheight.constant = 40
            self.btnLiveSettings.isHidden = false
        }
        
        
        
        if self.recordEventInfo.isDayEvent
        {
//            self.lblTime.isHidden = true
//            self.lblHalf.isHidden = true
//            self.txtScore.isHidden = true
//            self.lblHomeTeam.isHidden = true
//            self.lblAwayTeam.isHidden = true
            
            self.scoreView.isHidden = true
        }
        else
        {
            self.scoreView.isHidden = false
            self.btnHomeName.setTitle(self.recordEventInfo.homeTeamName, for: .normal)
            self.btnAwayName.setTitle(self.recordEventInfo.awayTeamName, for: .normal)
//            self.lblHomeTeam.text = self.recordEventInfo.homeTeamName
//            self.lblAwayTeam.text = self.recordEventInfo.awayTeamName
        }
        if self.CheckForCodecSupports(codecvalue: Constants.CodecH264) == true
        {
            btnH264.backgroundColor = COLOR_APP_THEME()
            btnH265.backgroundColor = COLOR_WHITE_ALPHA_40()
            videoSettingDict["Codec"] = Constants.CodecH264
        }
        else if self.CheckForCodecSupports(codecvalue: Constants.CodecH265) == true
        {
            btnH264.backgroundColor = COLOR_WHITE_ALPHA_40()
            btnH265.backgroundColor = COLOR_APP_THEME()
            videoSettingDict["Codec"] = Constants.CodecH265
        }
        else
        {
            videoSettingDict["Codec"] = "not exist"
        }
        
        phototagONbutton.backgroundColor = COLOR_WHITE_ALPHA_40()
        phototagOFFbutton.backgroundColor = COLOR_APP_THEME()
        
        APP_DELEGATE.DeleteAllFilesInTempFolder()
       
     
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = true
        
        //        let deadlineTime = DispatchTime.now() + .seconds(3)
        //        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
        //            self.imgRotateScreen.isHidden = true
        //            APP_DELEGATE.myOrientation = .landscape
        //            UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
        //        }
        
        //APP_DELEGATE.tabbarController?.tabBar.isHidden = true
        //APP_DELEGATE.tabbarController?.tabBar.layer.zPosition = -1
        
        //  self.AddCameraViewAndSetConfig()
        //        viewCameraContainer.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.height, height: self.view.frame.size.width)
      
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        if UIDevice.current.orientation.isLandscape
        {
//            print("Landscape")
            previewLayerConnection?.videoOrientation = AVCaptureVideoOrientation(rawValue: UIDevice.current.orientation.rawValue)!
            self.imgRotateScreen.isHidden = true
            self.view.sendSubview(toBack: viewCameraContainer)
            //            let rotation = UIDevice.current.orientation
            //            UIInterfaceOrientationMask
            if UIDevice.current.orientation.rawValue == 4 {
                APP_DELEGATE.myOrientation = .landscapeLeft
                APP_DELEGATE.landscaperSide = UIInterfaceOrientation.landscapeLeft
            } else {
                APP_DELEGATE.myOrientation = .landscapeRight
                APP_DELEGATE.landscaperSide = UIInterfaceOrientation.landscapeRight
            }
            
            UIDevice.current.setValue (APP_DELEGATE.landscaperSide.rawValue, forKey: "orientation")
        } else {
            print("Portrait")
            self.imgRotateScreen.isHidden = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
        //APP_DELEGATE.tabbarController?.tabBar.isHidden = false
    
       // APP_DELEGATE.tabbarController?.tabBar.layer.zPosition = 0
         NotificationCenter.default.removeObserver("hideLiveBtn")
    }
    
 
    
    func setCornerRadiusToButton(button: UIButton) {
        button.layer.cornerRadius = 3.0
        button.layer.masksToBounds = true
    }
    func GetPresetValue() -> String
    {
        let videoQuality: String = self.videoSettingDict["Quality"] as! String
        var sessionPreset: String = AVCaptureSession.Preset.hd1280x720.rawValue
        if videoQuality == Constants.HDQuality
        {
            sessionPreset = AVCaptureSession.Preset.hd1280x720.rawValue
        }
        else if videoQuality == Constants.HDQuality
        {
            sessionPreset = AVCaptureSession.Preset.hd1920x1080.rawValue
        }
        else if videoQuality == Constants.HDQuality
        {
            sessionPreset = AVCaptureSession.Preset.hd4K3840x2160.rawValue
        }
        return sessionPreset
    }
    //MARK:- Config video
    func configureVideoSession()
    {
        
        // Preset For 720p
        if !UIImagePickerController.isSourceTypeAvailable(.camera)
        {
            return
        }
        
        //        sessionQueue.async { [unowned self] in
        
        let videoQuality: String = self.videoSettingDict["Quality"] as! String
        
        if videoQuality == Constants.HDQuality
        {
            self.captureSession.sessionPreset = AVCaptureSession.Preset.hd1280x720
        }
        else if videoQuality == Constants.HDQuality
        {
            self.captureSession.sessionPreset = AVCaptureSession.Preset.hd1920x1080
        }
        else if videoQuality == Constants.HDQuality
        {
            self.captureSession.sessionPreset = AVCaptureSession.Preset.hd4K3840x2160
        }
        
        // Get Available Devices Capable Of Recording Video
        let devices = AVCaptureDevice.devices(for: AVMediaType.video)
        
        // Get Back Camera
        for device in devices
        {
            let recordingSource: String = self.videoSettingDict["RecordingSource"] as! String
            if recordingSource == Constants.FrontCamera
            {
                if device.position == AVCaptureDevice.Position.front
                {
                    self.currentDevice = device
                    break
                }
                
            }
            else if recordingSource == Constants.BackCamera
            {
                if device.position == AVCaptureDevice.Position.back
                {
                    self.currentDevice = device
                    break
                }
            }
        }
        
        // Audio Input
        for input in self.captureSession.inputs {
            self.captureSession.removeInput(input )
        }
        do
        {
            var deviceInput: AVCaptureDeviceInput!
            do {
                deviceInput = try AVCaptureDeviceInput(device: self.currentDevice!)
            } catch let error {
                print(error.localizedDescription)
                return
            }
            
            // Add Audio Input
            if self.captureSession.canAddInput(deviceInput)
            {
                self.captureSession.addInput(deviceInput)
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
        let camera = AVCaptureDevice.default(for: AVMediaType.video)
        
        // Video Input
        let videoInput: AVCaptureDeviceInput
        do
        {
            videoInput = try AVCaptureDeviceInput(device: camera!)
            
            // Add Video Input
            if self.captureSession.canAddInput(videoInput)
            {
                self.captureSession.addInput(videoInput)
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
        
        let FPSValue: String = self.videoSettingDict["FPS"] as! String
        for vFormat in self.currentDevice!.formats {
            
            var ranges = vFormat.videoSupportedFrameRateRanges as [AVFrameRateRange]
            let frameRates = ranges[0]
            
            if FPSValue == Constants.FPS30
            {
                if frameRates.maxFrameRate == 30
                {
                    do {
                        try self.currentDevice?.lockForConfiguration()
                        //                                self.currentDevice?.activeFormat = vFormat as AVCaptureDevice.Format
                        self.currentDevice?.activeVideoMinFrameDuration = CMTimeMake(1, 30)
                        self.currentDevice?.activeVideoMaxFrameDuration = CMTimeMake(1, 30)
                        self.currentDevice?.unlockForConfiguration()
                    }
                    catch {
                        print("Error locking configuration")
                    }
                    break
                }
            }
            if FPSValue == Constants.FPS60
            {
                if frameRates.maxFrameRate == 60
                {
                    do {
                        try self.currentDevice?.lockForConfiguration()
                        //                                self.currentDevice?.activeFormat = vFormat as AVCaptureDevice.Format
                        self.currentDevice?.activeVideoMinFrameDuration = CMTimeMake(1, 60)
                        self.currentDevice?.activeVideoMaxFrameDuration = CMTimeMake(1, 60)
                        self.currentDevice?.unlockForConfiguration()
                    }
                    catch {
                        print("Error locking configuration")
                    }
                    break
                }
            }
        }
        
        for output in self.captureSession.outputs {
            self.captureSession.removeOutput(output)
        }
        
        self.videoFileOutput = AVCaptureMovieFileOutput()
        self.captureSession.addOutput(self.videoFileOutput!)
//        self.videoFileOutput?.availableVideoCodecTypes
        
        //        self.cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        //        self.viewCameraContainer.layer.addSublayer(self.cameraPreviewLayer!)
        //        self.cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        //
        //        let width = self.view.bounds.height
        //        self.cameraPreviewLayer?.frame = CGRect(x: 0, y: 0, width: width, height: width)
        //        self.previewLayerConnection = self.cameraPreviewLayer?.connection
        
        //        }
        
        //        print(captureSession.inputs)
        
    }
    func AddCameraViewAndSetConfig()
    {
        self.configureVideoSession()
        self.cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        self.viewCameraContainer.layer.addSublayer(self.cameraPreviewLayer!)
        self.cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        let width = self.view.bounds.height
        self.cameraPreviewLayer?.frame = CGRect(x: 0, y: 0, width: width, height: width)
        self.previewLayerConnection = self.cameraPreviewLayer?.connection
    }
    fileprivate func addGestureRecognizers() {
        
        let pinchGesture: UIPinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(zoomGesture(pinch:)))
        pinchGesture.delegate = self
        viewCameraContainer.addGestureRecognizer(pinchGesture)
    }
    @objc fileprivate func zoomGesture(pinch: UIPinchGestureRecognizer) {
        //        guard pinchToZoom == true && self.currentCamera == .rear else {
        //            //ignore pinch
        //            return
        //        }
        
        guard let device = AVCaptureDevice.devices().first else { return }
        
        // Return zoom value between the minimum and maximum zoom values
        func minMaxZoom(_ factor: CGFloat) -> CGFloat {
            return min(min(max(factor, beginZoomScale), device.activeFormat.videoMaxZoomFactor), device.activeFormat.videoMaxZoomFactor)
        }
        
        func update(scale factor: CGFloat) {
            do {
                try device.lockForConfiguration()
                defer { device.unlockForConfiguration() }
                device.videoZoomFactor = factor
            } catch {
                print("\(error.localizedDescription)")
            }
        }
        
        let newScaleFactor = minMaxZoom(pinch.scale * zoomScale)
        
        switch pinch.state {
        case .began: fallthrough
        case .changed: update(scale: newScaleFactor)
        case .ended:
            zoomScale = minMaxZoom(newScaleFactor)
            update(scale: zoomScale)
        default: break
        }
    }
    //MARK:- button click events
    @IBAction func btnZoomSwitchClicked(_ sender: Any) {
        
        if btnZoomSwitch.image(for: .normal) == UIImage(named: "switch_off")
        {
            btnZoomSwitch.setImage(UIImage(named: "switch_on"), for: .normal)
            videoSettingDict["IsZoomOn"] = true
            
            self.btnPlusZoom.isEnabled = true
            self.btnMinusZoom.isEnabled = true
            self.btnPlusZoomSpeed.isEnabled = true
            self.btnMinusZoomSpeed.isEnabled = true
        }
        else
        {
            btnZoomSwitch.setImage(UIImage(named: "switch_off"), for: .normal)
            videoSettingDict["IsZoomOn"] = false
            
            self.btnPlusZoom.isEnabled = false
            self.btnMinusZoom.isEnabled = false
            self.btnPlusZoomSpeed.isEnabled = false
            self.btnMinusZoomSpeed.isEnabled = false
        }
    }
    var isProductPurchased = Bool()

    @IBAction func phototagON(_ sender: Any) {
        
        if UserDefaults.standard.value(forKey: Constants.kFotoTag_PurchaseKey) != nil
        {
            let value: String = UserDefaults.standard.value(forKey: Constants.kFotoTag_PurchaseKey) as! String
            
            if value == "YES"
            {
                phototagONbutton.backgroundColor = COLOR_APP_THEME()
                phototagOFFbutton.backgroundColor = COLOR_WHITE_ALPHA_40()
                
                isProductPurchased = true
            }
        }
        //        isProductPurchased = true
        if !isProductPurchased
        {
            APP_DELEGATE.displayMessageAlertWithMessage(alertMessage: "You have to purchase Photo Tag product to use Photo Tag feature. You can purchase it from Home Page.", withTitle: "Alert")
            return
        }
        
       
        
    }
    
    @IBAction func phototagOFF(_ sender: Any) {
        
        phototagONbutton.backgroundColor = COLOR_WHITE_ALPHA_40()
        phototagOFFbutton.backgroundColor = COLOR_APP_THEME()
        
    }
    
    
    @IBAction func btnStartRecodingClicked(_ sender: UIButton) {
       
        if selectedCameraSource == 3
        {
            self.OpenAlertForSelectVideo(sender: sender)
        }
        else if selectedCameraSource == 2
        {
//            self.OpenAlertToEnterURL()
            
            self.OpenURLTypeOptionSheet()
        }
        else
        {
            self.OpenRecordingView()
        }
        
    }
    func OpenRecordingView()
    {
        let redirectTo = loadVC(strStoryboardId: SB_LANDSCAPE, strVCId: idRecordCameraVideoVC) as! RecordCameraVideoVC
        redirectTo.recordEventInfo = self.recordEventInfo
        redirectTo.videoSettingDict = self.videoSettingDict
        redirectTo.selectedCameraSource = selectedCameraSource
        if selectedCameraSource == 3 || selectedCameraSource == 2
        {
            redirectTo.selectedVideoURL = selectedVideoURL
        }
        self.navigationController?.pushViewController(redirectTo, animated: true)
    }
    @IBAction func btnBackToDetailsClicked(_ sender: Any) {
        //        APP_DELEGATE.myOrientation = .portrait
        //        APP_DELEGATE.landscaperSide = UIInterfaceOrientation.portrait
        //        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        //        self.view.layoutIfNeeded()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnLiveSettingsClicked(_ sender: Any) {
        
        var isProductPurchased: Bool = false
        if UserDefaults.standard.value(forKey: Constants.kLiveStreaming_PurchaseKey) != nil
        {
            let value: String = UserDefaults.standard.value(forKey: Constants.kLiveStreaming_PurchaseKey) as! String
            
            if value == "YES"
            {
                isProductPurchased = true
            }
        }
        //        isProductPurchased = true
        if !isProductPurchased
        {
            APP_DELEGATE.displayMessageAlertWithMessage(alertMessage: "You have to purchase Live Streaming product to use Live Streaming. You can purchase it from Home Page.", withTitle: "Alert")
            return
        }
        
        let redirectTo = loadVC(strStoryboardId: SB_LANDSCAPE, strVCId: idStreamSettingVC) as! StreamSettingVC
        self.navigationController?.pushViewController(redirectTo, animated: true)
    }
    @IBAction func btnFrontCamClicked(_ sender: Any) {
        
        
        let fpsValue: String = self.videoSettingDict["FPS"] as! String

        let sessionPreset: String = self.GetPresetValue()
        let isSupports: Bool = self.CheckForCameraSupportsWith(presetValue: sessionPreset, cameraPosition: Constants.FrontCamera, FPSValue: fpsValue, forselection: 2)
        if (!isSupports)
        {
            NSLog("Not supports: ", sessionPreset)
            return
        }
        
        var isProductPurchased: Bool = false
        if UserDefaults.standard.value(forKey: Constants.kRecordingsource_PurchaseKey) != nil
        {
            let value: String = UserDefaults.standard.value(forKey: Constants.kRecordingsource_PurchaseKey) as! String
            
            if value == "YES"
            {
                isProductPurchased = true
            }
        }
        //        isProductPurchased = true
        if !isProductPurchased
        {
            APP_DELEGATE.displayMessageAlertWithMessage(alertMessage: "You have to purchase Recording source product to change Recording source. You can purchase it from Home Page.", withTitle: "Alert")
            return
        }
        
        btnFrontCam.backgroundColor = COLOR_APP_THEME()
        btnURLRec.backgroundColor = COLOR_WHITE_ALPHA_40()
        btnRollRec.backgroundColor = COLOR_WHITE_ALPHA_40()
        btnBackCam.backgroundColor = COLOR_APP_THEME()
        
        videoSettingDict["RecordingSource"] = Constants.FrontCamera
        if captureSession.isRunning
        {
            //            captureSession.stopRunning()
        }
        self.captureSession.beginConfiguration()
        //        self.configureVideoSession()
        self.SetCameraView()
        self.captureSession.commitConfiguration()
        selectedCameraSource = 0
        //        self.captureSession.startRunning()
        self.EnableOtherSettings()
        
    }
    @IBAction func btnBackCamClicked(_ sender: Any) {
        
        let fpsValue: String = self.videoSettingDict["FPS"] as! String

        let sessionPreset: String = self.GetPresetValue()
        let isSupports: Bool = self.CheckForCameraSupportsWith(presetValue: sessionPreset, cameraPosition: Constants.BackCamera, FPSValue: fpsValue, forselection: 2)
        if (!isSupports)
        {
            NSLog("Not supports: ", sessionPreset)
            return
        }
        
        var isProductPurchased: Bool = false
        if UserDefaults.standard.value(forKey: Constants.kRecordingsource_PurchaseKey) != nil
        {
            let value: String = UserDefaults.standard.value(forKey: Constants.kRecordingsource_PurchaseKey) as! String
            
            if value == "YES"
            {
                isProductPurchased = true
            }
        }
        //        isProductPurchased = true
        if !isProductPurchased
        {
            APP_DELEGATE.displayMessageAlertWithMessage(alertMessage: "You have to purchase Recording source product to change Recording source. You can purchase it from Home Page.", withTitle: "Alert")
            return
        }
        btnFrontCam.backgroundColor = COLOR_WHITE_ALPHA_40()
        btnURLRec.backgroundColor = COLOR_WHITE_ALPHA_40()
        btnRollRec.backgroundColor = COLOR_WHITE_ALPHA_40()
        btnBackCam.backgroundColor = COLOR_APP_THEME()
        videoSettingDict["RecordingSource"] = Constants.BackCamera
        
        self.captureSession.beginConfiguration()
        self.SetCameraView()
        self.captureSession.commitConfiguration()
        //        self.captureSession.startRunning()
        selectedCameraSource = 1
        self.EnableOtherSettings()
    }
    @IBAction func btnRollClicked(_ sender: Any) {
        
        btnFrontCam.backgroundColor = COLOR_WHITE_ALPHA_40()
        btnURLRec.backgroundColor = COLOR_WHITE_ALPHA_40()
        btnRollRec.backgroundColor = COLOR_APP_THEME()
        btnBackCam.backgroundColor = COLOR_WHITE_ALPHA_40()
        selectedCameraSource = 3
        self.EnableOtherSettings()
    }
    @IBAction func btnURLClicked(_ sender: Any) {
        btnFrontCam.backgroundColor = COLOR_WHITE_ALPHA_40()
        btnURLRec.backgroundColor = COLOR_APP_THEME()
        btnRollRec.backgroundColor = COLOR_WHITE_ALPHA_40()
        btnBackCam.backgroundColor = COLOR_WHITE_ALPHA_40()
        selectedCameraSource = 2
        self.EnableOtherSettings()
        
    }
    func SetCameraView()
    {
        let devices = AVCaptureDevice.devices(for: AVMediaType.video)
        
        // Get Back Camera
        for device in devices
        {
            let recordingSource: String = self.videoSettingDict["RecordingSource"] as! String
            if recordingSource == Constants.FrontCamera
            {
                if device.position == AVCaptureDevice.Position.front
                {
                    self.currentDevice = device
                    break
                }
                
            }
            else if recordingSource == Constants.BackCamera
            {
                if device.position == AVCaptureDevice.Position.back
                {
                    self.currentDevice = device
                    break
                }
            }
        }
        
        for input in self.captureSession.inputs {
            self.captureSession.removeInput(input )
        }
        do
        {
            var deviceInput: AVCaptureDeviceInput!
            do {
                deviceInput = try AVCaptureDeviceInput(device: self.currentDevice!)
            } catch let error {
                print(error.localizedDescription)
                return
            }
            
            // Add Audio Input
            if self.captureSession.canAddInput(deviceInput)
            {
                self.captureSession.addInput(deviceInput)
            }
            else
            {
                NSLog("Can't Add Audio Input")
            }
        }
        catch
        {
            
        }
    }
    
    @IBAction func btnGoProClicked(_ sender: Any) {
        var isProductPurchased: Bool = false
        if UserDefaults.standard.value(forKey: Constants.kRecordingsource_PurchaseKey) != nil
        {
            let value: String = UserDefaults.standard.value(forKey: Constants.kRecordingsource_PurchaseKey) as! String
            
            if value == "YES"
            {
                isProductPurchased = true
            }
        }
        //        isProductPurchased = true
        if !isProductPurchased
        {
            APP_DELEGATE.displayMessageAlertWithMessage(alertMessage: "You have to purchase Recording source product to change Recording source. You can purchase it from Home Page.", withTitle: "Alert")
            return
        }
        btnFrontCam.backgroundColor = COLOR_APP_THEME()
        btnBackCam.backgroundColor = COLOR_WHITE_ALPHA_40()
    }
    
    
    @IBAction func btnHDClicked(_ sender: Any) {
        
        let fpsValue: String = self.videoSettingDict["FPS"] as! String

        let sessionPreset: String = AVCaptureSession.Preset.hd1280x720.rawValue
        let recordingSource: String = self.videoSettingDict["RecordingSource"] as! String
        
        let isSupports: Bool = self.CheckForCameraSupportsWith(presetValue: sessionPreset, cameraPosition: recordingSource, FPSValue: fpsValue, forselection: 1)
        if (!isSupports)
        {
            NSLog("Not supports: ", sessionPreset)
            return
        }
        btnHD.backgroundColor = COLOR_APP_THEME()
        btnFHD.backgroundColor = COLOR_WHITE_ALPHA_40()
        btn4K.backgroundColor = COLOR_WHITE_ALPHA_40()
        
        videoSettingDict["Quality"] = Constants.HDQuality
        
        self.PresetChange()
        
    }
    
    @IBAction func btnFHDClicked(_ sender: Any) {
        
        let fpsValue: String = self.videoSettingDict["FPS"] as! String
        let sessionPreset: String = AVCaptureSession.Preset.hd1920x1080.rawValue
        let recordingSource: String = self.videoSettingDict["RecordingSource"] as! String
        
        let isSupports: Bool = self.CheckForCameraSupportsWith(presetValue: sessionPreset, cameraPosition: recordingSource, FPSValue: fpsValue, forselection: 1)
        if (!isSupports)
        {
            NSLog("Not supports: ", sessionPreset)
            return
        }
        
        btnHD.backgroundColor = COLOR_WHITE_ALPHA_40()
        btnFHD.backgroundColor = COLOR_APP_THEME()
        btn4K.backgroundColor = COLOR_WHITE_ALPHA_40()
        videoSettingDict["Quality"] = Constants.FHDQuality
        self.PresetChange()
    }
    
    @IBAction func btn4KClicked(_ sender: Any) {
        
        let fpsValue: String = self.videoSettingDict["FPS"] as! String

        let sessionPreset: String = AVCaptureSession.Preset.hd4K3840x2160.rawValue
        let recordingSource: String = self.videoSettingDict["RecordingSource"] as! String
        
        let isSupports: Bool = self.CheckForCameraSupportsWith(presetValue: sessionPreset, cameraPosition: recordingSource, FPSValue: fpsValue, forselection: 1)
        if (!isSupports)
        {
            NSLog("Not supports: ", sessionPreset)
            return
        }
//        let videoCodec: String = self.videoSettingDict["Codec"] as! String
//
//        if videoCodec == Constants.CodecH264 || videoCodec == Constants.CodecH265
//        {
//            if self.CheckForCodecSupports(codecvalue: videoCodec) == false
//            {
//                APP_DELEGATE.displayMessageAlertWithMessage(alertMessage: "H264 codec does not supported by this capture quality.", withTitle: "Alert")
//                return
//            }
//        }
//        

        var isProductPurchased: Bool = false
        if UserDefaults.standard.value(forKey: Constants.kRecording_PurchaseKey) != nil
        {
            let value: String = UserDefaults.standard.value(forKey: Constants.kRecording_PurchaseKey) as! String
            
            if value == "YES"
            {
                isProductPurchased = true
            }
        }
        //        isProductPurchased = true
        if !isProductPurchased
        {
            APP_DELEGATE.displayMessageAlertWithMessage(alertMessage: "You have to purchase 4k Recording product to use 4k quality. You can purchase it from Home Page.", withTitle: "Alert")
            return
        }
        
        btnHD.backgroundColor = COLOR_WHITE_ALPHA_40()
        btnFHD.backgroundColor = COLOR_WHITE_ALPHA_40()
        btn4K.backgroundColor = COLOR_APP_THEME()
        videoSettingDict["Quality"] = Constants.UltraQuality
        self.PresetChange()
    }
    func PresetChange()
    {
        let videoQuality: String = self.videoSettingDict["Quality"] as! String
        
        var sessionPreset = AVCaptureSession.Preset.low
        
        if videoQuality == Constants.HDQuality
        {
            sessionPreset = AVCaptureSession.Preset.hd1280x720
        }
        if videoQuality == Constants.FHDQuality
        {
            sessionPreset = AVCaptureSession.Preset.hd1920x1080
        }
        if videoQuality == Constants.UltraQuality
        {
            sessionPreset = AVCaptureSession.Preset.hd4K3840x2160
        }
        
        if self.captureSession.canSetSessionPreset(sessionPreset)
        {
            self.captureSession.beginConfiguration()
            self.captureSession.sessionPreset = sessionPreset
            self.captureSession.commitConfiguration()
        }
        else
        {
            
        }
    }
    
    
    @IBAction func btnFPS30Clicked(_ sender: Any) {
        if !self.FPSValueChanged(frameRate: 30, forDevice: self.currentDevice!)
        {
            APP_DELEGATE.displayMessageAlertWithMessage(alertMessage: "Selected frame rate not supported by this device.", withTitle: "Alert")
            
            return
        }
        btnFPS30.backgroundColor = COLOR_APP_THEME()
        btnFPS60.backgroundColor = COLOR_WHITE_ALPHA_40()
        videoSettingDict["FPS"] = Constants.FPS30
    }
    
    @IBAction func btnFPS60Clicked(_ sender: Any) {
        if !self.FPSValueChanged(frameRate: 60, forDevice: self.currentDevice!)
        {
            APP_DELEGATE.displayMessageAlertWithMessage(alertMessage: "Selected frame rate not supported by this device.", withTitle: "Alert")
            return
        }
        btnFPS30.backgroundColor = COLOR_WHITE_ALPHA_40()
        btnFPS60.backgroundColor = COLOR_APP_THEME()
        videoSettingDict["FPS"] = Constants.FPS60
        
    }
    
    func FPSValueChanged(frameRate: Int, forDevice: AVCaptureDevice) -> Bool
    {
        let isrunning: Bool = self.captureSession.isRunning
        if isrunning
        {
            self.captureSession.stopRunning()
        }
        var isFPSSupported: Bool = false
        var selectedFormat: AVCaptureDevice.Format!
        var maxWidth: Int32 = 0
        
        for vFormat in forDevice.formats
        {
            for ranges in vFormat.videoSupportedFrameRateRanges
            {
//                CMFormatDescriptionRef desc = format.formatDescription;
//                CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions(desc);
//                int32_t width = dimensions.width;
                let desc:CMFormatDescription = vFormat.formatDescription
                let dimensions: CMVideoDimensions = CMVideoFormatDescriptionGetDimensions(desc)
                let width: Int32 = dimensions.width
                if ((Float64(frameRate) <= ranges.maxFrameRate) && (ranges.minFrameRate <= Float64(frameRate)) && width >= maxWidth)
                {
                    selectedFormat = vFormat
                    maxWidth = width;
                }
                
            }
        }
        if (selectedFormat != nil)
        {
            
            do {
//                self.captureSession.beginConfiguration()
                try forDevice.lockForConfiguration()
                forDevice.activeFormat = selectedFormat as AVCaptureDevice.Format
                forDevice.activeVideoMinFrameDuration = CMTimeMake(1, Int32(frameRate))
                forDevice.activeVideoMaxFrameDuration = CMTimeMake(1, Int32(frameRate))
                forDevice.unlockForConfiguration()
//                self.captureSession.commitConfiguration()
            }
            catch {
                print("Error locking configuration")
            }
            
            isFPSSupported = true
        }
        if (isrunning)
        {
            self.captureSession.startRunning()
        }
        return isFPSSupported
    }
    
    @IBAction func btnH264Clicked(_ sender: Any)
    {
        
        if self.CheckForCodecSupports(codecvalue: Constants.CodecH264) == false
        {
            APP_DELEGATE.displayMessageAlertWithMessage(alertMessage: "H264 codec does not supported by this device", withTitle: "Alert")
            return
        }
        
        btnH264.backgroundColor = COLOR_APP_THEME()
        btnH265.backgroundColor = COLOR_WHITE_ALPHA_40()
        videoSettingDict["Codec"] = Constants.CodecH264
        self.configureVideoSession()
    }
    
    @IBAction func btnH265Clicked(_ sender: Any)
    {
        if self.CheckForCodecSupports(codecvalue: Constants.CodecH265) == false
        {
            APP_DELEGATE.displayMessageAlertWithMessage(alertMessage: "H265 codec does not supported by this device", withTitle: "Alert")
            
            return
        }
        
        btnH264.backgroundColor = COLOR_WHITE_ALPHA_40()
        btnH265.backgroundColor = COLOR_APP_THEME()
        videoSettingDict["Codec"] = Constants.CodecH265
        self.configureVideoSession()
    }
    func CheckForCodecSupports(codecvalue: String) -> Bool
    {
        if !UIImagePickerController.isSourceTypeAvailable(.camera)
        {
            return false
        }
//        if #available(iOS 10.0, *) {
        let supportedCodec: NSArray = self.videoFileOutput?.availableVideoCodecTypes as! NSArray
//        } else {
//            // Fallback on earlier versions
//        }
//
        if codecvalue == Constants.CodecH264
        {
            if !supportedCodec.contains(AVVideoCodecH264)
            {
                return false
            }
        }
        if codecvalue == Constants.CodecH265
        {
            if #available(iOS 11.0, *)
            {
                if !supportedCodec.contains(AVVideoCodecHEVC)
                {
                    return false
                }
            }
            else
            {
                return false
            }
        }
        
        return true
    }
    
    @IBAction func btnFBYTClicked(_ sender: Any) { }
    
    @IBAction func SetZoomSpeed(_ sender: UIButton)
    {
        var zoomSpeed: Int = self.videoSettingDict["ZoomSpeed"] as! Int
        
        if sender.tag == 0 //zoom minus clicked
        {
            zoomSpeed = zoomSpeed - 5
        }
        else //zoom plus clicked
        {
            zoomSpeed = zoomSpeed + 5
        }
        self.lblZoomSpeed.text = "\(zoomSpeed)%"
        self.videoSettingDict["ZoomSpeed"] = zoomSpeed
    }
    
    @IBAction func ProgressiveZoomChange(_ sender: UIButton)
    {
        
        let zoomSpeed: Int = self.videoSettingDict["ZoomSpeed"] as! Int
        if sender.tag == 0 // Minus
        {
            zoomScale = zoomScale - (zoomScale * CGFloat(zoomSpeed)/100)
        }
        else // plus
        {
            zoomScale = zoomScale + (zoomScale * CGFloat(zoomSpeed)/100)
        }
        
        guard let device = AVCaptureDevice.devices().first else { return }
        
        do {
            zoomScale = min(min(max(zoomScale, beginZoomScale), device.activeFormat.videoMaxZoomFactor), device.activeFormat.videoMaxZoomFactor)
            try device.lockForConfiguration()
            defer { device.unlockForConfiguration() }
            //            device.videoZoomFactor = zoomScale
            device.ramp(toVideoZoomFactor: CGFloat(zoomScale), withRate: Float(20.0/Double(zoomSpeed) * 1.5))
        } catch {
            print("\(error.localizedDescription)")
        }
    }
    func CheckForCameraSupportsWith(presetValue: String, cameraPosition: String, FPSValue: String, forselection: Int) -> Bool
    {
        var isSupport: Bool = true
        let devices = AVCaptureDevice.devices(for: AVMediaType.video)
        var captureDevice: AVCaptureDevice? = nil
        // Get Back Camera
        for device in devices
        {
            if cameraPosition == Constants.FrontCamera
            {
                if device.position == AVCaptureDevice.Position.front
                {
                    captureDevice = device
                    break
                }
                
            }
            else if cameraPosition == Constants.BackCamera
            {
                if device.position == AVCaptureDevice.Position.back
                {
                    captureDevice = device
                    break
                }
            }
        }
        if captureDevice == nil
        {
            isSupport = false
        }
        
        if (!((captureDevice?.supportsSessionPreset(AVCaptureSession.Preset(rawValue: presetValue)))!))
        {
            
            NSLog("Not supports: ", presetValue)
            var presetStr: String = "HD"
            
            if presetValue == AVCaptureSession.Preset.hd1280x720.rawValue
            {
                presetStr = "HD"
            }
            else if presetValue == AVCaptureSession.Preset.hd1280x720.rawValue
            {
                presetStr = "FHD"
            }
            else if presetValue == AVCaptureSession.Preset.hd1280x720.rawValue
            {
                presetStr = "4K"
            }
            
            var cameraPosition: String = "Back"
            if cameraPosition == Constants.FrontCamera
            {
                cameraPosition = "Front"
            }
            
            isSupport = false
//            APP_DELEGATE.displayMessageAlertWithMessage(alertMessage: alertMessage, withTitle: "Alert")
//            return false
        }
        
        var fpsInt: Int = 30
        
        if FPSValue == Constants.FPS30
        {
            fpsInt = 30
        }
        else
        {
            fpsInt = 60
        }
        
        if !self.FPSValueChanged(frameRate: fpsInt, forDevice: captureDevice!)
        {
            isSupport = false
//            APP_DELEGATE.displayMessageAlertWithMessage(alertMessage: "Selected frame rate not supported by selected Camera.", withTitle: "Alert")
//
//            return false
        }
        if !isSupport
        {
            var alertMessage: String = ""
            if forselection == 1
            {
                alertMessage = "Selected camera quality does not supported by current camera settings."
            }
            else if forselection == 2
            {
                alertMessage = "Selected camera does not supported by current camera settings."
            }
            else if forselection == 3
            {
                alertMessage = "Selected FPS value not does supported by current camera settings."
            }
            APP_DELEGATE.displayMessageAlertWithMessage(alertMessage: "Selected frame rate not supported by selected Camera.", withTitle: "Alert")
        }
        
        return isSupport
    }
    func OpenAlertForSelectVideo(sender: UIButton)
    {
        let actionSheet = UIAlertController(title: "Select Video", message: "Please select video from your device library.", preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let fromgalary = UIAlertAction(title: "Select From Library", style: .default) { (action:UIAlertAction!) in
            
            self.picker.delegate = self
            self.picker.mediaTypes = [kUTTypeMovie as String]
            self.picker.allowsEditing = false
            self.picker.sourceType = .photoLibrary
            if isIpad()
            {
                self.picker.modalPresentationStyle = .popover
                self.picker.popoverPresentationController?.sourceView = sender
            }
            self.present(self.picker, animated: true, completion: nil)
            
        }
        actionSheet.addAction(cancelAction)
       
        actionSheet.addAction(fromgalary)
        
        actionSheet.popoverPresentationController?.sourceView = sender // works for both iPhone & iPad
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        self.dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        self.selectedVideoURL = info[UIImagePickerControllerMediaURL] as? URL
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        print("Finished picking image: \(image.size)")
        self.dismiss(animated: true) {
            
            let videoSize: CGSize = APP_DELEGATE.resolutionForLocalVideo(url: self.selectedVideoURL)!
            
            self.OpenRecordingView()
        }
    }
    func OpenAlertToEnterURL()
    {
        var alertMessage: String = "Enter valid video URL..."
        
        if videoURLType == "facebook"
        {
            alertMessage = "Enter valid Facebook video URL..."
        }
        else if videoURLType == "youtube"
        {
            alertMessage = "Enter valid Youtube video URL..."
        }
        
        let alert = UIAlertController(title: nil, message: alertMessage, preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.placeholder = "Enter video URL..."
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { [weak alert] (_) in
            
        }))
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            
            
            self.CheckForValidationAndStartDownload(videoURL: (textField?.text)!)
//            self.StartDownloadEnteredURL(videoURL: (textField?.text)!)
            
        }))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    func verifyUrl(urlString: String?) -> Bool {
        guard let urlString = urlString,
            let url = URL(string: urlString) else {
                return false
        }
        
        return UIApplication.shared.canOpenURL(url)
    }
    
    
    
    func StartDownloadEnteredURL(videoURL: String)
    {

        let task = self.activate().downloadTask(with: URL(string: videoURL)!)
        task.resume()
    }
    func StartProgress()
    {
        progressHUD = MBProgressHUD.showAdded(to: (self.view)!, animated: true)
        
        progressHUD.label.text = "Downloading (0%)..."
        //        progressHUD.contentColor = UIColor.gray
        progressHUD.mode = .indeterminate
        progressHUD.progress = 0.0
    }
    func HideProgress()
    {
        progressHUD.hide(animated: true)
    }
    func EnableOtherSettings()
    {
        var enable: Bool = false
        var alphaValue: CGFloat = 0.5
        
        if selectedCameraSource == 0 ||  selectedCameraSource == 1
        {
            enable = true
            alphaValue = 1.0
        }
        
        btnH264.isEnabled = enable
        btnH265.isEnabled = enable
        btnFPS30.isEnabled = enable
        btnFPS60.isEnabled = enable
        btnHD.isEnabled = enable
        btnFHD.isEnabled = enable
        btn4K.isEnabled = enable
        
        btnH264.alpha = alphaValue
        btnH265.alpha = alphaValue
        btnFPS30.alpha = alphaValue
        btnFPS60.alpha = alphaValue
        btnHD.alpha = alphaValue
        btnFHD.alpha = alphaValue
        btn4K.alpha = alphaValue
        
    }
    func CheckForValidationAndStartDownload(videoURL: String)
    {
        if !APP_DELEGATE.CheckForInternetConnection()
        {
            APP_DELEGATE.displayMessageAlertWithMessage(alertMessage: NoInternetMessage, withTitle: "Alert")
            
            return
        }
        let liveURL: String = videoURL.trimmingCharacters(in: .whitespacesAndNewlines)
        if liveURL.isEmpty
        {
            APP_DELEGATE.displayMessageAlertWithMessage(alertMessage: "Please enter video url.", withTitle: "Alert")
            return
        }
        else if !self.verifyUrl(urlString: liveURL)
        {
            APP_DELEGATE.displayMessageAlertWithMessage(alertMessage: "Please enter valid video URL.", withTitle: "Alert")
            return
        }
        self.StartProgress()
        
        if videoURLType == "facebook"
        {
            self.GetURLForFacebook(videoURL: liveURL)
        }
        else if videoURLType == "youtube"
        {
            self.GetURLForYoutuber(videoURL: liveURL)
        }
        else
        {
            self.StartDownloadEnteredURL(videoURL: liveURL)
        }
    }
    func GetURLForYoutuber(videoURL: String)
    {
        
        HCYoutubeParser.h264videos(withYoutubeURL: URL(string: videoURL)!, complete: {(_ videoDictionary: [AnyHashable: Any]?, _ error: Error?) -> Void in
            
            DispatchQueue.main.async {
                
                if error == nil // Found Valid URL
                {
                    var qualities = videoDictionary as! Dictionary<NSNumber, Any>
                    
                    var URLString: String? = nil
                    if qualities[NSNumber.init(value: Int8(RMYouTubeExtractorVideoQuality.HD720.rawValue)) ] != nil
                    {
                        URLString = qualities[NSNumber.init(value: Int8(RMYouTubeExtractorVideoQuality.HD720.rawValue)) ] as? String
                    }
                    else if qualities[NSNumber.init(value: Int8(RMYouTubeExtractorVideoQuality.medium360.rawValue)) ] != nil
                    {
                        URLString = qualities[NSNumber.init(value: Int8(RMYouTubeExtractorVideoQuality.medium360.rawValue)) ] as? String
                    }
                    else if qualities[NSNumber.init(value: Int8(RMYouTubeExtractorVideoQuality.small240.rawValue)) ] != nil
                    {
                        URLString = qualities[NSNumber.init(value: Int8(RMYouTubeExtractorVideoQuality.small240.rawValue)) ] as? String
                    }
                        //                    else if qualities["live"] != nil
                        //                    {
                        //                        URLString = qualities["live"] as? String
                        //                    }
                    else
                    {
                        self.HideProgress()
                        APP_DELEGATE.displayMessageAlertWithMessage(alertMessage: "Couldn't find youtube video", withTitle: "Error")
                        
                        return
                    }
                    self.StartDownloadEnteredURL(videoURL: URLString!)
                }
                else
                {
                    self.StartDownloadEnteredURL(videoURL: videoURL)
                }
            }
        })
    }
    func GetURLForFacebook(videoURL: String)
    {
        
        let params: Parameters = [
            "url": videoURL
            ]
        let requestURL: String = "http://www.simpsip.com/main.php"
        Alamofire.request(requestURL, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil)
            .responseJSON { response in
                
                switch response.result
                {
                case .success(_):
                    if response.result.value != nil
                    {
                        let dict = response.result.value as! NSDictionary
                        if dict.value(forKey: "type") != nil
                        {
                            var finalURLStr: String = ""
                            var isVideoAvailable: Bool = false
                            let type: String = dict.value(forKey: "type") as! String
                            if type == "success"
                            {
                                
                                if dict.value(forKey: "hd_download_url") != nil
                                {
                                    isVideoAvailable = true
                                    finalURLStr = dict.value(forKey: "hd_download_url") as! String
                                }
                                else if dict.value(forKey: "sd_download_url") != nil
                                {
                                    isVideoAvailable = true
                                    finalURLStr = dict.value(forKey: "sd_download_url") as! String
                                }
                            }
                            if isVideoAvailable && !finalURLStr.isEmpty
                            {
                                DispatchQueue.main.async {
                                    self.StartDownloadEnteredURL(videoURL: finalURLStr)
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
    func OpenURLTypeOptionSheet()
    {
        let actionSheet = UIAlertController.init(title: "Select type of URL", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        actionSheet.addAction(UIAlertAction.init(title: "Facebook", style: UIAlertActionStyle.default, handler: { (action) in
            
            self.videoURLType = "facebook"
            self.OpenAlertToEnterURL()
        }))
        
        actionSheet.addAction(UIAlertAction.init(title: "Youtube", style: UIAlertActionStyle.default, handler: { (action) in
            
            self.videoURLType = "youtube"
            self.OpenAlertToEnterURL()
        }))
        
        actionSheet.addAction(UIAlertAction.init(title: "Other", style: UIAlertActionStyle.default, handler: { (action) in
            
            self.videoURLType = "other"
            self.OpenAlertToEnterURL()
        }))
        
        actionSheet.addAction(UIAlertAction.init(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action) in
                        
        }))
        actionSheet.popoverPresentationController?.sourceView = self.btnStartRecoding // works for both iPhone & iPad

        self.present(actionSheet, animated: true, completion: nil)
    }
}

extension LiveCameraVC
{
    
    func activate() -> URLSession {
//        let config =  URLSessionConfiguration.background(withIdentifier: "\(Bundle.main.bundleIdentifier!).background")
        
//        let config =  URLSessionConfiguration.background(withIdentifier: "\(Bundle.main.bundleIdentifier!).background")
        let config =   URLSessionConfiguration.default
        // Warning: If an URLSession still exists from a previous download, it doesn't create a new URLSession object but returns the existing one with the old delegate object attached!
        return URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue())
    }
    
    private func calculateProgress(session : URLSession, completionHandler : @escaping (Float) -> ()) {
        session.getTasksWithCompletionHandler { (tasks, uploads, downloads) in
            let progress = downloads.map({ (task) -> Float in
                if task.countOfBytesExpectedToReceive > 0 {
                    return Float(task.countOfBytesReceived) / Float(task.countOfBytesExpectedToReceive)
                } else {
                    return 0.0
                }
            })
            completionHandler(progress.reduce(0.0, +))
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        if totalBytesExpectedToWrite > 0 {
            if let onProgress = onProgress {
                calculateProgress(session: session, completionHandler: onProgress)
            }
            let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
            DispatchQueue.main.async
                {
                self.progressHUD.label.text = "Downloading (\(Int(progress * 100))%)..."
            }
            
//            debugPrint("Progress \(downloadTask) \(progress)")
            
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
//        debugPrint("Download finished: \(location)")
        
        var tempFolderPath: String = APP_DELEGATE.FetchTempVideoFolderPath()
        tempFolderPath = tempFolderPath + "/downloadVideo.mp4"
        if FileManager.default.fileExists(atPath: tempFolderPath as String)
        {
            do
            {
                try FileManager.default.removeItem(atPath: tempFolderPath)
            }
            catch
            {
                return
            }
            
        }
//        let pathextension = location.pathExtension
//
//        let uti = UTTypeCreatePreferredIdentifierForTag(
//            kUTTagClassFilenameExtension,
//            pathextension as CFString,
//        nil)
        
//        if UTTypeConformsTo((uti?.takeRetainedValue())!, kUTTypeMovie) {
//            print("This is not movie file")
//            
//            
//        }
//        else
//        {
//            DispatchQueue.main.async {
//                
//                self.HideProgress()
//                APP_DELEGATE.displayMessageAlertWithMessage(alertMessage: "Downloaded file is not video file, please check video URL entered by you.", withTitle: "Alert")
//            }
//            return
//        }
        
        try? FileManager.default.moveItem(atPath: location.path, toPath: tempFolderPath)
//        try? FileManager.default.removeItem(at: location)
        
        self.selectedVideoURL = URL.init(fileURLWithPath: tempFolderPath)
        DispatchQueue.main.async {
            self.HideProgress()
            self.OpenRecordingView()
        }
        
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
//        debugPrint("Task completed: \(task), error: \(error)")
        if error != nil
        {
            DispatchQueue.main.async {
                self.HideProgress()
                APP_DELEGATE.displayMessageAlertWithMessage(alertMessage: "Error occured while downloading video.", withTitle: "Alert")
            }
            

        }
    }
}


/*
 func FPSValueChanged(frameRate: Int, forDevice: AVCaptureDevice) -> Bool
 {
 var isFPSSupported: Bool = false
 var selectedFormat: AVCaptureDevice.Format!
 var maxWidth: Int32 = 0
 
 for vFormat in forDevice.formats
 {
 for ranges in vFormat.videoSupportedFrameRateRanges
 {
 //            forDevice.activeFormat.videoSupportedFrameRateRanges
 //            var ranges = vFormat.videoSupportedFrameRateRanges as [AVFrameRateRange]
 let frameRates = ranges
 if frameRate == 30
 {
 if frameRates.maxFrameRate == 30
 {
 if ( (Float64(frameRate) <= frameRates.maxFrameRate) && (frameRates.minFrameRate <= Float64(frameRate)))
 {
 isFPSSupported = true
 do {
 
 self.captureSession.beginConfiguration()
 try forDevice.lockForConfiguration()
 self.currentDevice?.activeFormat = vFormat as AVCaptureDevice.Format
 forDevice.activeVideoMinFrameDuration = CMTimeMake(1, 30)
 forDevice.activeVideoMaxFrameDuration = CMTimeMake(1, 30)
 forDevice.unlockForConfiguration()
 
 self.captureSession.commitConfiguration()
 }
 catch {
 print("Error locking configuration")
 }
 }
 
 return isFPSSupported
 }
 }
 else if frameRate == 60
 {
 if frameRates.maxFrameRate == 60
 {
 if ( (Float64(frameRate) <= frameRates.maxFrameRate) && (frameRates.minFrameRate <= Float64(frameRate)))
 {
 isFPSSupported = true
 do {
 self.captureSession.beginConfiguration()
 try forDevice.lockForConfiguration()
 self.currentDevice?.activeFormat = vFormat as AVCaptureDevice.Format
 forDevice.activeVideoMinFrameDuration = CMTimeMake(1, 60)
 forDevice.activeVideoMaxFrameDuration = CMTimeMake(1, 60)
 forDevice.unlockForConfiguration()
 self.captureSession.commitConfiguration()
 }
 catch {
 print("Error locking configuration")
 }
 }
 
 return isFPSSupported
 }
 }
 
 }
 }
 if (selectedFormat != nil)
 {
 self.captureSession.beginConfiguration()
 try forDevice.lockForConfiguration()
 self.currentDevice?.activeFormat = vFormat as AVCaptureDevice.Format
 forDevice.activeVideoMinFrameDuration = CMTimeMake(1, 60)
 forDevice.activeVideoMaxFrameDuration = CMTimeMake(1, 60)
 forDevice.unlockForConfiguration()
 self.captureSession.commitConfiguration()
 
 return true
 }
 
 return false
 }*/


