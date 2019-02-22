//
//  FaceBookLiveVideoVc.swift
//  VideoEditor
//
//  Created by CZ Ltd on 5/14/18.
//  Copyright © 2018 Ark Inc. All rights reserved.
//

import UIKit
import HaishinKit
import CoreData
import Photos
import MobileCoreServices

class ExampleRecorderDelegate : DefaultAVMixerRecorderDelegate {
    
    
    override func didFinishWriting(_ recorder: AVMixerRecorder) {
        guard let writer: AVAssetWriter = recorder.writer else { return }
        
        print(writer.outputURL)
        
        let imageDataDict:[String: Any] = ["url": writer.outputURL]
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "FacebookLiveVideo"), object: nil, userInfo: imageDataDict)
        
       
        
    }
}


class FaceBookLiveVideoVc: BaseVC, UITextFieldDelegate, UIImagePickerControllerDelegate {
    
    var blurOverlay: UIVisualEffectView!
    
    var sessionURL: NSURL!
    
    var loader: UIActivityIndicatorView!
    
    var loginButton: FBSDKLoginButton!
    
    var liveVideo: FBSDKLiveVideo!
   
    
    let recorderDelegate = ExampleRecorderDelegate()
    
    @IBOutlet weak var recordButton : UIButton!
    
    let nc = NotificationCenter.default
    
    var lastPanY: CGFloat = 0
    var latestDirection: Int = 0
    var preferedScale: Int32 = 1000
    var focusSquare: CameraFocusSquare!
    var selectedVideoURL: URL!
    var selectedCameraSource: Int = 1
    var timeObserver: AnyObject!
    var avPlayerLayer: AVPlayerLayer!
    var avPlayer: AVPlayer!
    typealias TrimCompletion = (Error?) -> ()
    typealias TrimPoints = [(CMTime, CMTime)]
    var lblTimeString: String?
    
    var isVideoPlay: Bool = false
    var trimPositionArray: NSMutableArray = NSMutableArray.init()
    var trimStart: CMTime!
    var trimEnd: CMTime!
    
    var currentTime: CMTime!
    var playerItem: AVPlayerItem!
    var player: AVPlayer!
    var movieFile: GPUImageMovie!
    var filter: GPUImageFilter!
    var isTimeLabelHide: Bool = false
    var lastSliderValue: Float = 0.0
    
    var lastRecordedSecond: Float = 0.0
    var totalRecordedSecond: Float = 0.0
    var videoSize: CGSize?
    var selectedTeamIndex: Int = 0
    let picker = UIImagePickerController()
    var totalVideoSecond: Float = 0.0
    var timer: Timer!
    var cameraPreview: GPUImageView! = nil
    
    var videoPainter: AVCameraPainter! = nil
   
    var frameDrawer: AVFrameDrawer! = nil
    var isScorebaordOn: Bool = true
    var isPeriodOn: Bool = true
    var isTimerOn: Bool = true
    
    var isTimerPeriodOn: Bool = true
    var tagsRecordingList: NSMutableArray = NSMutableArray.init()
    var isRecordingInProgress: Bool = false
    var recordEventInfo: RecordingInfo!
    var videoSettingDict: Dictionary<String, Any>!
    var photoTagImage = Data()
    var overlayScoreBoardImage:UIImage?
    
    var recordedVideoIndex: Int = 0
    fileprivate let sessionQueue                 = DispatchQueue(label: "session queue", attributes: [])
    fileprivate var backgroundRecordingID        : UIBackgroundTaskIdentifier? = nil
    
    let captureSession = AVCaptureSession()
    var currentDevice: AVCaptureDevice?
    var videoFileOutput: AVCaptureMovieFileOutput?
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    
    var swipeRightOnScorecard = UISwipeGestureRecognizer()
    var swipeLeftOnVideoRecording = UISwipeGestureRecognizer()
    var swipeRightOnVideoRecording = UISwipeGestureRecognizer()
    var swipeLeftOnOverlay = UISwipeGestureRecognizer()
    var videoClipsArray: NSMutableArray = NSMutableArray.init()
    var matchEventvideoClipsArray: NSMutableArray = NSMutableArray.init()
    var selectedtagsArray: NSMutableArray = NSMutableArray.init()
    var totalNumberOfButtons = 11
    let arrButtonTitles = ["1","2","3","4","5","6","7","8","9","0","-","+"]
    
   
    
    fileprivate var zoomScale                    = CGFloat(1.0)
    /// Variable for storing initial zoom scale before Pinch to Zoom begins
    fileprivate var beginZoomScale               = CGFloat(1.0)
    public var maxZoomScale                         = CGFloat.greatestFiniteMagnitude
    
    var screenStatusBarHeight: CGFloat {
        return UIApplication.shared.statusBarFrame.height
    }
    
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var sliderView: UIView!
    @IBOutlet weak var sliderVideo: UISlider!
    @IBOutlet weak var lblEndTime: UILabel!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var home_ScoreButton1: UIButton!
    @IBOutlet weak var home_ScoreButton2: UIButton!
    @IBOutlet weak var home_ScoreButton3: UIButton!
    @IBOutlet weak var home_ScoreView: UIView!
    @IBOutlet weak var away_ScoreView: UIView!
    @IBOutlet weak var away_ScoreButton1: UIButton!
    @IBOutlet weak var away_ScoreButton2: UIButton!
    @IBOutlet weak var away_ScoreButton3: UIButton!
    @IBOutlet weak var imageAndScoreBoardView: UIView!
    @IBOutlet weak var topSpace: NSLayoutConstraint!
    @IBOutlet weak var bottomSpace: NSLayoutConstraint!
    @IBOutlet weak var rightSpace: NSLayoutConstraint!
    @IBOutlet weak var leftSpace: NSLayoutConstraint!
    
    @IBOutlet weak var tagCollectionView: UICollectionView!
    @IBOutlet weak var highLightView: UIView!
    @IBOutlet weak var imageUploadButton: UIButton!
    @IBOutlet weak var overlayImageView: UIImageView!
    @IBOutlet weak var overlayAllView: UIView!
    @IBOutlet weak var recordingOverlayView: UIView!
    @IBOutlet weak var overlayNameScoreView: UIView!
    @IBOutlet weak var overlayHomeTeamView: UIView!
    @IBOutlet weak var overlayAwayTeamView: UIView!
    @IBOutlet weak var overlayScoreView: UIView!
    @IBOutlet weak var overlayPeriodView: UIView!
    @IBOutlet weak var overlayTimerView: UIView!
    @IBOutlet weak var overlayHomeNameBtn: UIButton!
    @IBOutlet weak var overlayAwayNameBtn: UIButton!
    @IBOutlet weak var overlayScoreBtn: UIButton!
    @IBOutlet weak var overlayPeriodBtn: UIButton!
    @IBOutlet weak var overlayTimerBtn: UIButton!
    @IBOutlet weak var playerVideoView1: UIView!
    @IBOutlet weak var playerVideoView: UIView!
    @IBOutlet weak var viewVideoRecordingOptionContainer: UIView!
    @IBOutlet weak var viewHomeContainer: UIView!
    @IBOutlet weak var viewAwayContainer: UIView!
    @IBOutlet weak var viewScoreAndMinuteContainer: UIView!
    @IBOutlet weak var viewActionButtonsContainer: UIView!
    @IBOutlet weak var viewProgressiveZoomContainer: UIView!
    @IBOutlet weak var viewZoomOptionsContainer: UIView!
    @IBOutlet weak var viewBottomRightContainer: UIView!
    
    @IBOutlet weak var imgHomeLogo: UIImageView!
    @IBOutlet weak var imgAwayLogo: UIImageView!
    @IBOutlet weak var settingHomeLogo: UIImageView!
    @IBOutlet weak var settingAwayLogo: UIImageView!
    @IBOutlet weak var btnMinusZoom : UIButton!
    @IBOutlet weak var btnPlusZoom: UIButton!
    @IBOutlet weak var btnMinusZoomSpeed: UIButton!
    @IBOutlet weak var btnPlusZoomSpeed: UIButton!
    @IBOutlet weak var highLightButton: CustomHighLightButton!
    @IBOutlet weak var btnMinutesSwitch: UIButton!
    @IBOutlet weak var btnPeriodSwitch: UIButton!
    @IBOutlet weak var btnTeamScoreSwitch: UIButton!
    @IBOutlet weak var viewBottomButtonsContainer: UIView!
    @IBOutlet weak var lblZoomSpeed: UILabel!
    @IBOutlet weak var lblScoreField: UITextField!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblPeriod: UILabel!
    @IBOutlet weak var txtPeriod: UITextField!
    @IBOutlet weak var txtMinutes: UITextField!
    @IBOutlet weak var txtHomeTeamName: UITextField!
    @IBOutlet weak var txtHomeTeamScore: UITextField!
    @IBOutlet weak var txtAwayTeamName: UITextField!
    @IBOutlet weak var txtAwayTeamScore: UITextField!
    
    @IBOutlet weak var btnZoom: UIButton!
    @IBOutlet weak var btnSmoothZoomSwitch: UIButton!
    @IBOutlet weak var btnPauseState: UIButton!
    @IBOutlet weak var btnBackToRecording: UIButton!
    @IBOutlet weak var btnFinishRecording: UIButton!
    
    @IBOutlet weak var btnPause: UIButton!
    @IBOutlet weak var btnRedDot: UIButton!
    
    @IBOutlet weak var viewScorecardContainer: UIView!
    
    @IBOutlet weak var viewTagsContainer: UIView!
    @IBOutlet weak var viewTagsParent: UIView!
    @IBOutlet weak var btnHomeTeam: UIButton!
    @IBOutlet weak var btnAwayTeam: UIButton!
    @IBOutlet weak var btnSaveRecording: UIButton!
    
    @IBOutlet weak var btnSaveScoreBoard: UIButton!
    
    @IBOutlet weak var viewOverlayContainer: UIView!
    
    @IBOutlet weak var lblHomeTeam: UILabel!
    @IBOutlet weak var lblAwayTeam: UILabel!
    
    
    @IBAction func recordButtonTapped(_ sender: UIButton) {
        
        if !self.liveVideo.isStreaming {
            
            startStreaming()
            
        } else {
            
            stopStreamingAlert()
            
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
      
        forcelandscapeRight()
        
        self.navigationController?.navigationBar.isHidden = true
        self.view.layoutIfNeeded()
        
        print("Record Camera Video VC View did Load")
        
        self.isVideoPlay = true
        sliderVideo.tag = 0
        
        print("1.RCVC isVideoPlay: \(isVideoPlay)")
        print(" RCVC selectedCameraSource: \(selectedCameraSource)")
        
        if selectedCameraSource == 2 || selectedCameraSource == 3
        {
            self.isVideoPlay = true
            
        }
        else
        {
            self.isVideoPlay = false
        }
        
        print("2.RCVC isVideoPlay: \(isVideoPlay)")
        print("2.isRecordingInProgress: \(isRecordingInProgress)")
        print("2.recordedVideoIndex: \(recordedVideoIndex)")
        
        self.isRecordingInProgress = true
        self.recordedVideoIndex = 0
        
        
        print("2.1. isRecordingInProgress: \(isRecordingInProgress)")
        print("2.1. recordedVideoIndex: \(recordedVideoIndex)")
        
        //        self.tagCollectionView.collectionViewLayout = CustomFlowLayout() as UICollectionViewLayout
        
        //        NSLog("screenStatusBarHeight: %f", screenStatusBarHeight)
        let nib = UINib(nibName: "TagCollectionCell", bundle: nil)
        self.tagCollectionView.register(nib, forCellWithReuseIdentifier: "TagCollectionCell")
        //        self.tagCollectionView.register(UINib(nibName: "TagCollectionCell", bundle: nil), forCellReuseIdentifier: "TagCollectionCell")
        self.navigationController?.navigationBar.isHidden = true
        self.view.layoutIfNeeded()
        
        btnFinishRecording.layer.cornerRadius = btnFinishRecording.frame.size.height/2
        btnFinishRecording.layer.masksToBounds = true
        
        btnRedDot.layer.cornerRadius = btnRedDot.frame.size.height/2
        btnRedDot.layer.masksToBounds = true
        
        viewVideoRecordingOptionContainer.isHidden = true
        viewZoomOptionsContainer.isHidden   = true
        viewActionButtonsContainer.isHidden = true
        viewScorecardContainer.isHidden     = true
        viewTagsContainer.isHidden          = true
        viewOverlayContainer.isHidden       = true
        
        sliderVideo.setThumbImage(UIImage(named: "slider_thumb"), for: .normal)
        sliderVideo.setMinimumTrackImage(UIImage(named: "slider_minimum"), for: .normal)
        sliderVideo.setMaximumTrackImage(UIImage(named: "slider_maximum"), for: .normal)
        
        //        for view in self.viewTagsParent.subviews as [UIView]
        //        {
        //            if let btn = view as? UIButton
        //            {
        //                setCornerRadiusAndShadowOnButton(button: btn, backColor: UIColor.white)
        //                btn.setTitleColor(COLOR_FONT_GRAY(), for: .normal)
        //            }
        //        }
        
        self.view.layoutIfNeeded()
        //        self.highLightButton.setBackgroundColor(UIColor.black, forState: UIControlState.Highlighted)
        self.home_ScoreButton1.setTitle("1", for: .normal)
        self.home_ScoreButton2.setTitle("2", for: .normal)
        self.home_ScoreButton3.setTitle("3", for: .normal)
        setCornerRadiusAndBorderButton(button: self.home_ScoreButton1, borderWidth: 3.0)
        setCornerRadiusAndBorderButton(button: self.home_ScoreButton2, borderWidth: 3.0)
        setCornerRadiusAndBorderButton(button: self.home_ScoreButton3, borderWidth: 3.0)
        
        self.away_ScoreButton1.setTitle("1", for: .normal)
        self.away_ScoreButton2.setTitle("2", for: .normal)
        self.away_ScoreButton3.setTitle("3", for: .normal)
        setCornerRadiusAndBorderButton(button: self.away_ScoreButton1, borderWidth: 3.0)
        setCornerRadiusAndBorderButton(button: self.away_ScoreButton2, borderWidth: 3.0)
        setCornerRadiusAndBorderButton(button: self.away_ScoreButton3, borderWidth: 3.0)
        
        
        setCornerRadiusAndShadowOnButton(button: self.highLightButton, backColor: COLOR_APP_THEME())
        setCornerRadiusAndShadowOnButton(button: btnSaveScoreBoard, backColor: COLOR_APP_THEME())
        
        setCornerRadiusAndShadowOnButton(button: btnHomeTeam, backColor: COLOR_APP_THEME())
        btnHomeTeam.setTitleColor(UIColor.white, for: .normal)
        btnSaveRecording.setTitleColor(UIColor.white, for: .normal)
        
        setCornerRadiusAndShadowOnButton(button: btnAwayTeam, backColor: UIColor.white)
        btnAwayTeam.setTitleColor(COLOR_APP_THEME(), for: .normal)
        
        btnPeriodSwitch.setImage(UIImage(named: "switch_off"), for: .normal)
        btnMinutesSwitch.setImage(UIImage(named: "switch_off"), for: .normal)
        btnTeamScoreSwitch.setImage(UIImage(named: "switch_off"), for: .normal)
        
        txtHomeTeamName.isEnabled = true
        txtHomeTeamScore.isEnabled = true
        txtAwayTeamName.isEnabled = true
        txtAwayTeamScore.isEnabled = true
        txtPeriod.isEnabled = true
        txtMinutes.isEnabled = true
        
        self.viewBottomRightContainer.isHidden = true
        
        addSwipeGestureOnScrollview()
        
        self.addPanGesture()
        //        addTapGesture(view: imgHomeLogo)
        //        addTapGesture(view: imgAwayLogo)
        //        addTapGesture(view: lblTime)
        //        addTapGesture(view: lblPeriod)
        //        addTapGesture(view: lblHomeTeam)
        //        addTapGesture(view: lblAwayTeam)
        //        addButtonInBottomBar()
        self.addTapGestureForFocus()
        setCornerRadiusAndShadowOnButton(button: self.highLightButton, backColor: COLOR_APP_THEME())
        self.highLightButton.setTitleColor(UIColor.white, for: .normal)
        
        print("1.isTimerOn: \(isTimerOn)")
        print("1.isPeriodOn: \(isPeriodOn)")
        print("1.isScorebaordOn: \(isScorebaordOn)")
        
        
        
        if self.isVideoPlay
        {
            //            self.playerVideoView.backgroundColor = UIColor.black
            self.playerVideoView.isHidden = false
            self.isScorebaordOn = false
            self.isTimerOn = false
            self.isPeriodOn = false
            self.highLightView.isHidden = false
            self.viewVideoRecordingOptionContainer.isHidden = false
            self.viewScorecardContainer.isHidden = true
            
            self.viewAwayContainer.isHidden = true
            self.viewScoreAndMinuteContainer.isHidden = true
            self.imageAndScoreBoardView.isHidden = true
            self.home_ScoreView.isHidden = true
            self.away_ScoreView.isHidden = true
            self.viewProgressiveZoomContainer.isHidden = true
            self.viewZoomOptionsContainer.isHidden = true
        }
        else if self.recordEventInfo.isDayEvent
        {
            self.playerVideoView.isHidden = true
            self.isScorebaordOn = false
            self.isTimerOn = false
            self.isPeriodOn = false
            self.highLightView.isHidden = false
            self.viewVideoRecordingOptionContainer.isHidden = false
            self.viewScorecardContainer.isHidden = true
            
            //            self.viewHomeContainer.isHidden = true
            self.viewAwayContainer.isHidden = true
            self.viewScoreAndMinuteContainer.isHidden = true
            self.imageAndScoreBoardView.isHidden = true
            self.home_ScoreView.isHidden = true
            self.away_ScoreView.isHidden = true
        }
        else
        {
            self.playerVideoView.isHidden = true
            self.isScorebaordOn = true
            self.isTimerOn = true
            self.isPeriodOn = true
            //            self.highLightView.isHidden = true
            self.lblHomeTeam.text = self.recordEventInfo.homeTeamName
            self.lblAwayTeam.text = self.recordEventInfo.awayTeamName
            
            self.overlayHomeNameBtn.setTitle(self.recordEventInfo.homeTeamName, for: .normal)
            self.overlayAwayNameBtn.setTitle(self.recordEventInfo.awayTeamName, for: .normal)
            self.overlayScoreBtn.setTitle("0 - 0", for: .normal)
            
            self.imgHomeLogo.image = self.recordEventInfo.homeTeamLogo
            self.imgAwayLogo.image = self.recordEventInfo.awayTeamLogo
            
            self.txtHomeTeamName.text = self.recordEventInfo.homeTeamName
            self.txtAwayTeamName.text = self.recordEventInfo.awayTeamName
            
            self.settingHomeLogo.image = self.imgHomeLogo.image
            self.settingAwayLogo.image = self.imgAwayLogo.image
            
            self.lblScoreField.text = "0 - 0"
            
            btnMinutesSwitch.setImage(UIImage(named: "switch_on"), for: .normal)
            btnPeriodSwitch.setImage(UIImage(named: "switch_on"), for: .normal)
            btnTeamScoreSwitch.setImage(UIImage(named: "switch_on"), for: .normal)
            self.imageAndScoreBoardView.isHidden = false
            self.home_ScoreView.isHidden = false
            self.away_ScoreView.isHidden = false
            self.txtPeriod.text = "1T"
            
            print("IsScoreboardPurchase: \(IsScoreboardPurchase)")
            
            if !IsScoreboardPurchase()
            {
                self.viewVideoRecordingOptionContainer.isHidden = false
                self.viewScorecardContainer.isHidden = true
            }
            else
            {
                self.viewVideoRecordingOptionContainer.isHidden = true
                self.viewScorecardContainer.isHidden = false
            }
            
        }
        
        print("2.isTimerOn: \(isTimerOn)")
        print("2.isPeriodOn: \(isPeriodOn)")
        print("2.isScorebaordOn: \(isScorebaordOn)")
        
        self.recordEventInfo.homeTeamScore = 0
        self.recordEventInfo.awayTeamScore = 0
        
        self.txtHomeTeamScore.text = "\(self.recordEventInfo.homeTeamScore)"
        self.txtAwayTeamScore.text = "\(self.recordEventInfo.awayTeamScore)"
        
        addGestureRecognizers()
        //        overlayImageView.AddGestureForOverlayImage()
        //        self.configureVideoSession()
        self.AddGestureForOverlayImage()
        
        print("0: TimerBtn set Title")
        self.overlayTimerBtn.setTitle("00:00", for: .normal)
        
        self.FetchTagInfoFromDB()
        
        //        let outputFileName = APP_DELEGATE.FetchTempVideoFolderPath()
        //        if self.recordEventInfo.videoFolderName.isEmpty
        //        {
        //            self.recordEventInfo.videoFolderName = outputFileName
        //        }
        self.recordEventInfo.videoFolderName = "MyTemp"
        //        outputFileName = self.recordEventInfo.videoFolderName
        //
        //        var outputFilePath = NSTemporaryDirectory() as String
        //
        //        outputFilePath = outputFilePath + "\(outputFileName)"
        //
        //        if !FileManager.default.fileExists(atPath: outputFilePath as String)
        //        {
        //            do
        //            {
        //                try FileManager.default.createDirectory(atPath: outputFilePath, withIntermediateDirectories: true, attributes: nil)
        //            }
        //            catch
        //            {
        //
        //            }
        //        }
        
        self.viewHomeContainer.isHidden = true
        self.viewAwayContainer.isHidden = true
        self.viewScoreAndMinuteContainer.isHidden = true
     
        
        print("2. isVideoPlay: \(isVideoPlay)")
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.navigationController?.navigationBar.isHidden = true
        UIDevice.current.setValue(APP_DELEGATE.landscaperSide.rawValue, forKey: "orientation")
        
        
        nc.addObserver(self, selector: #selector(videoNotiction(notification:)), name: NSNotification.Name(rawValue: "FacebookLiveVideo"), object: nil)
        
        print(self.view.bounds)
        
        let outputFileName = UUID().uuidString
        var outputFilePath = NSTemporaryDirectory() as String
        outputFilePath = outputFilePath + "\(outputFileName)/mynew.mov"
        
        let screenRect: CGRect =  self.topView.bounds// self.view.bounds
        
        let screenSize: CGSize = screenRect.size
        
        var videoTempSize: CGSize = CGSize.zero
        let videoQuality: String = self.videoSettingDict["Quality"] as! String
        
        if videoQuality == Constants.HDQuality
        {
            videoTempSize = CGSize.init(width: 1280.0, height: 720.0)
        }
        else if videoQuality == Constants.FHDQuality
        {
            videoTempSize = CGSize.init(width: 1920.0, height: 1080.0)
        }
        else if videoQuality == Constants.UltraQuality
        {
            videoTempSize = CGSize.init(width: 3840.0, height: 2160.0)
        }
        
        let widthFactor = videoTempSize.width / screenSize.width
        let heightFactor = videoTempSize.height / screenSize.height
        
        var resizeFactor = widthFactor
        if videoTempSize.height > videoTempSize.width {
            resizeFactor = heightFactor
        }
        
        let newSize = CGSize.init(width: videoTempSize.width/resizeFactor, height: videoTempSize.height/resizeFactor)
        var scaledImageRect = CGRect.zero
        
        scaledImageRect.size.width  = newSize.width
        scaledImageRect.size.height = newSize.height
        scaledImageRect.origin.x    = (screenSize.width - scaledImageRect.size.width) / 2.0
        scaledImageRect.origin.y    = (screenSize.height - scaledImageRect.size.height) / 2.0
        
         print(self.topView.frame)
        
//        self.topSpace.constant    = scaledImageRect.origin.y
//        self.leftSpace.constant   = scaledImageRect.origin.x
//        self.rightSpace.constant  = -scaledImageRect.origin.x
//        self.bottomSpace.constant = -scaledImageRect.origin.y
        
        print(self.topView.frame)
        
        let rect: CGRect = CGRect.init(x: 0, y: 0, width: scaledImageRect.width, height: scaledImageRect.height)
        
        self.liveVideo = FBSDKLiveVideo(
            delegate: self,
            previewSize: self.topView.frame,
            videoSize: CGSize(width: rect.size.width, height: rect.size.height), path: outputFilePath, fbvideoDelegate: recorderDelegate, videoSettingDict: self.videoSettingDict
        )
        
        let myOverlay = UIView(frame: CGRect(x: 5, y: 5, width: self.view.bounds.size.width - 10, height: 30))
        myOverlay.backgroundColor = UIColor.black
        myOverlay.alpha = 0.5
        
        print(fbid)
        
        self.liveVideo.privacy  = .allFriends
        self.liveVideo.audience = fbid // or your user-id, page-id, event-id, group-id, ...
        
        // Comment in to show a green overlay bar (configure with your own one)
        // self.liveVideo.overlay = myOverlay
        
        initializeUserInterface()
        
        self.imageUploadButton.isHidden = false
        
        self.MakeProgressiveZoomOnOff()
        //        APP_DELEGATE.myOrientation = .landscape
        self.navigationController?.navigationBar.isHidden = true
        UIDevice.current.setValue(APP_DELEGATE.landscaperSide.rawValue, forKey: "orientation")
        //APP_DELEGATE.tabbarController?.tabBar.isHidden = true
        //APP_DELEGATE.tabbarController?.tabBar.layer.zPosition = -1
        
        //        setCornerRadiusAndShadowOnButton(button: btnZoom, backColor: COLOR_APP_THEME())
        setCornerRadiusAndShadowOnButton(button: btnBackToRecording, backColor: COLOR_APP_THEME())
        setCornerRadiusAndShadowOnButton(button: btnSaveRecording, backColor: COLOR_APP_THEME())
        
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: Notification.Name.UIApplicationWillResignActive, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(appBecomeActive), name: Notification.Name.UIApplicationDidBecomeActive, object: nil)
        
    }
    
    public enum ImageFormat {
        case png
        case jpeg(CGFloat)
    }
    
    func convertImageTobase64(format: ImageFormat, image:UIImage) -> String? {
        var imageData: Data?
        switch format {
        case .png: imageData = UIImagePNGRepresentation(image)
        case .jpeg(let compression): imageData = UIImageJPEGRepresentation(image, compression)
        }
        return imageData?.base64EncodedString()
    }
    
    @objc func forcelandscapeRight() {
        let value = UIInterfaceOrientation.landscapeLeft.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        self.view.layoutIfNeeded()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.navigationBar.isHidden = false
        
        nc.removeObserver(self, name: NSNotification.Name(rawValue: "FacebookLiveVideo"), object: nil)
        nc.removeObserver(self, name: Notification.Name.UIDeviceOrientationDidChange, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIApplicationWillResignActive, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    func initializeUserInterface() {
        self.loader = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        self.loader.frame = CGRect(x: 15, y: 15, width: 40, height: 40)
        
        self.blurOverlay = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        self.blurOverlay.frame = self.view.bounds
        
        
        self.topView.insertSubview(self.liveVideo.preview, belowSubview: viewVideoRecordingOptionContainer)
        
        self.loginButton = FBSDKLoginButton()
        self.loginButton.publishPermissions = ["publish_actions"]
        self.loginButton.loginBehavior = .native
        self.loginButton.center = CGPoint(x: self.view.bounds.size.width / 2, y: 60)
        self.loginButton.delegate = self
        self.view.addSubview(self.loginButton)
        self.loginButton.isHidden = true
        
        if FBSDKAccessToken.current() == nil {
            self.view.insertSubview(self.blurOverlay, at: 1)
        } else {
            self.recordButton.isHidden = false
        }
    }
    
    func startStreaming() {
        
        
        
        self.liveVideo.start()
        self.loader.startAnimating()
        self.recordButton.addSubview(self.loader)
        self.recordButton.isEnabled = false
        
        self.runTimer()
    }
    
    func stopStreaming() {
        self.liveVideo.stop()
        
        if (timer != nil)
        {
            timer.invalidate()
            timer = nil
        }
        
    }
    
    func stopStreamingAlert() {
        
        let alertController = UIAlertController(title: "Hey!", message: "Do you need to stop facebook live streaming.", preferredStyle: .alert)
        
        let action1 = UIAlertAction(title: "Ok", style: .default) { (action:UIAlertAction) in
           
            self.stopStreaming()
        }
        
        let action2 = UIAlertAction(title: "Cancel", style: .default) { (action:UIAlertAction) in
            print("You've pressed cancel");
        }
        
        
        alertController.addAction(action1)
        alertController.addAction(action2)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    @objc func videoNotiction(notification:Notification) -> Void {
        
        if let url = notification.userInfo?["url"] as? URL {
            
            do {
                
                APP_DELEGATE.showHUDWithText(textMessage: "Saving...")
                let videoData = try Data(contentsOf: url)
                
                print("There were \(videoData.count) bytes")
                let bcf = ByteCountFormatter()
                bcf.allowedUnits = [.useMB] // optional: restricts the units to MB only
                bcf.countStyle = .file
                let string = bcf.string(fromByteCount: Int64(videoData.count))
                print("formatted result: \(string)")
                
                saveVideo(videoData: videoData)
                
            } catch {
                
                  print("Unable to load data: \(error)")
            }
            
            
        }
        
    }
    
    func saveVideo(videoData : Data) {
        
        let outputFileName = UUID().uuidString
        var outputFilePath = NSTemporaryDirectory() as String
        outputFilePath = outputFilePath + "\(outputFileName)"
        self.recordEventInfo.videoFolderName = outputFileName
       
        if !FileManager.default.fileExists(atPath: outputFilePath as String)
        {
            do
            {
                try FileManager.default.createDirectory(atPath: outputFilePath, withIntermediateDirectories: true, attributes: nil)
            }
            catch
            {
                
            }
        }
        
        let completeMoviePath = URL(fileURLWithPath: outputFilePath).appendingPathComponent("mynew.mov")
        
        do {
            
            try videoData.write(to: completeMoviePath)
            
            fbid        = "me"
            fbAvailable = false
            SaveVideoRcordedInfoToDB()
            
        } catch {
            print("Could not write file", error.localizedDescription)
        }
       
    }
   
    
    func OpenHightLightView(selectedIndex: Int)
    {
        
        viewTagsContainer.isHidden = false
        viewZoomOptionsContainer.isHidden = true
        viewVideoRecordingOptionContainer.isHidden = true
        viewProgressiveZoomContainer.isHidden = true
        
        if self.recordEventInfo.isDayEvent
        {
            self.btnHomeTeam.isHidden = true
            self.btnAwayTeam.isHidden = true
        }
        else
        {
            self.btnHomeTeam.isHidden = false
            self.btnAwayTeam.isHidden = false
            self.btnHomeTeam.setTitle(self.recordEventInfo.homeTeamName, for: .normal)
            self.btnAwayTeam.setTitle(self.recordEventInfo.awayTeamName, for: .normal)
        }
        self.selectedTeamIndex = 0
        //        if selectedIndex == 0
        //        {
        //            setCornerRadiusAndShadowOnButton(button: btnHomeTeam, backColor: COLOR_APP_THEME())
        //            btnHomeTeam.setTitleColor(UIColor.white, for: .normal)
        //            setCornerRadiusAndShadowOnButton(button: btnAwayTeam, backColor: UIColor.white)
        //            btnAwayTeam.setTitleColor(COLOR_APP_THEME(), for: .normal)
        //        }
        //        else
        //        {
        //            setCornerRadiusAndShadowOnButton(button: btnHomeTeam, backColor: UIColor.white)
        //            btnHomeTeam.setTitleColor(COLOR_APP_THEME(), for: .normal)
        //            setCornerRadiusAndShadowOnButton(button: btnAwayTeam, backColor: COLOR_APP_THEME())
        //            btnAwayTeam.setTitleColor(UIColor.white, for: .normal)
        //        }
        
        setCornerRadiusAndShadowOnButton(button: btnHomeTeam, backColor: UIColor.white)
        btnHomeTeam.setTitleColor(COLOR_APP_THEME(), for: .normal)
        
        setCornerRadiusAndShadowOnButton(button: btnAwayTeam, backColor: UIColor.white)
        btnAwayTeam.setTitleColor(COLOR_APP_THEME(), for: .normal)
        
        self.tagCollectionView.reloadData()
        self.SetStateOfTagSaveButton()
    }
    
    func SetStateOfTagSaveButton()
    {
        var isEnable: Bool = true
        if self.selectedTeamIndex == 0 && self.selectedtagsArray.count > 0
        {
            isEnable = false
        }
        if isEnable
        {
            setCornerRadiusAndShadowOnButton(button: btnSaveRecording, backColor: COLOR_APP_THEME())
            btnSaveRecording.setTitleColor(UIColor.white, for: .normal)
        }
        else
        {
            setCornerRadiusAndShadowOnButton(button: btnSaveRecording, backColor: UIColor.white)
            btnSaveRecording.setTitleColor(COLOR_APP_THEME(), for: .normal)
        }
        btnSaveRecording.isEnabled = isEnable
    }
    
    
    
    /*************************copy code *********************************/
    
    @IBAction func btnPauseClicked(_ sender: Any) {
        
        if fbAvailable == true {
            
            if !self.liveVideo.isStreaming {
                startStreaming()
            } else {
                stopStreaming()
            }
            
        }
        
        if (timer != nil)
        {
            timer.invalidate()
            timer = nil
        }
        if self.isVideoPlay
        {
            let playerIsPlaying = avPlayer.rate > 0
            if playerIsPlaying
            {
                self.trimEnd = self.currentTime
                self.lastRecordedSecond = self.totalRecordedSecond
                
                let trimDict: NSMutableDictionary = NSMutableDictionary.init()
                trimDict.setValue(self.trimStart, forKey: "trimstart")
                trimDict.setValue(self.trimEnd, forKey: "trimend")
                self.trimPositionArray.add(trimDict)
            }
        }
        else
        {
            
        }
        if self.isVideoPlay
        {
            self.viewProgressiveZoomContainer.isHidden = true
            self.viewZoomOptionsContainer.isHidden = true
        }
        else
        {
            self.viewProgressiveZoomContainer.isHidden = false
            self.viewZoomOptionsContainer.isHidden = false
        }
        
        self.isRecordingInProgress = false
        viewActionButtonsContainer.isHidden = false
        
        btnPause.isHidden = true
        //        viewHomeContainer.isHidden = true
        //        viewAwayContainer.isHidden = true
        
        self.highLightView.isHidden = true
        
        if !self.recordEventInfo.isDayEvent
        {
            self.home_ScoreView.isUserInteractionEnabled = false
            self.overlayNameScoreView.isUserInteractionEnabled = false
            self.away_ScoreView.isUserInteractionEnabled = false
        }
        
        
    }
    
    func addTapGesture(view:UIView)
    {
        
        if self.isVideoPlay
        {
            return
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(respondToTapGesture(gesture:)))
        tapGesture.delegate = self
        tapGesture.numberOfTapsRequired = 1
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tapGesture)
    }
    
    func addTapGestureForFocus() {
        
        if isVideoPlay
        {
            return
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cameraViewTapAction(gesture:)))
        tapGesture.delegate = self
        tapGesture.numberOfTapsRequired = 1
        self.viewVideoRecordingOptionContainer.isUserInteractionEnabled = true
        self.viewVideoRecordingOptionContainer.addGestureRecognizer(tapGesture)
    }
    
    
    @objc func cameraViewTapAction(gesture: UIGestureRecognizer) {
        
//        if !self.isRecordingInProgress
//        {
//            return
//        }
//
//        var location: CGPoint = gesture.location(in: self.viewVideoRecordingOptionContainer)
//
//        let squareWidth: CGFloat = 100
//        let focusFrame: CGRect = CGRect(x: location.x - squareWidth / 2, y: location.y - squareWidth / 2, width: squareWidth, height: squareWidth)
//
//        //        let excludeTopFrame: CGRect = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 100)
//        //
//        //        let excludeLeftFrame: CGRect = CGRect(x: 0, y: 0, width: 200, height: self.view.frame.size.height)
//        //
//        //        let excludBottomeFrame: CGRect = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 70)
//        //
//        //        let excludeRightFrame: CGRect = CGRect(x: 0, y: self.view.frame.size.height - 50, width: self.view.frame.size.width, height: 70)
//
//        let focusAllowedFrame: CGRect = CGRect(x: 150, y: 60, width: self.view.frame.size.width - 215, height: self.view.frame.size.height - 100)
//
//        if !focusAllowedFrame.contains(focusFrame)
//        {
//            return
//        }
//
//        //        if gesture.state = UIGestureRecognizer
//        //        {
//        //        gesture.location(ofTouch: 0, in: <#T##UIView?#>)
//
//        //            let device: AVCaptureDevice = self.painter.camera.inputCamera
//        var pointOfInterest: CGPoint = CGPoint.init(x: 0.5, y: 0.5)
//        let frameSize: CGSize = self.viewVideoRecordingOptionContainer.frame.size
//
//        if let fsquare = self.focusSquare
//        {
//            fsquare.updatePoint(location)
//        }
//        else
//        {
//            self.focusSquare = CameraFocusSquare(touchPoint: location)
//            self.viewVideoRecordingOptionContainer.addSubview(self.focusSquare!)
//
//            //                self.focusSquare.exposureSlider.minimumValue = self.painter.camera.inputCamera.activeFormat.minISO
//            //                self.focusSquare.exposureSlider.maximumValue = self.painter.camera.inputCamera.activeFormat.maxISO
//            //
//            //                self.focusSquare.exposureSlider.tag = 1
//            //                self.focusSquare.exposureSlider.addTarget(self, action: #selector(onSliderValChanged(slider:event:)), for: .valueChanged)
//
//            self.focusSquare?.setNeedsDisplay()
//        }
//
//        self.focusSquare?.animateFocusingAction()
//        if self.painter.camera.cameraPosition() == AVCaptureDevice.Position.front
//        {
//            location.x = frameSize.width - location.x
//        }
//        let x = location.y / frameSize.height
//        let y = 1.0 - location.x / frameSize.width
//        pointOfInterest = CGPoint(x: x, y: y)
//
//        //            pointOfInterest = CGPoint.init(x: location.x / frameSize.width, y: location.y / frameSize.height)
//
//        if self.painter.camera.inputCamera.isFocusPointOfInterestSupported &&  self.painter.camera.inputCamera.isFocusModeSupported(.autoFocus)
//        {
//            //                var error: NSError!
//
//            do {
//                try self.painter.camera.inputCamera.lockForConfiguration()
//
//                self.painter.camera.inputCamera.focusPointOfInterest = pointOfInterest
//                self.painter.camera.inputCamera.focusMode = .autoFocus
//
//                if self.painter.camera.inputCamera.isExposurePointOfInterestSupported && self.painter.camera.inputCamera.isExposureModeSupported(.autoExpose)
//                {
//                    self.painter.camera.inputCamera.exposurePointOfInterest = pointOfInterest
//                    self.painter.camera.inputCamera.exposureMode = .autoExpose
//                }
//
//                self.painter.camera.inputCamera.unlockForConfiguration()
//                NSLog("FOCUS OK", "");
//            }
//            catch {
//                print("Error locking configuration")
//            }
//        }
//        //            NSLog("iso value: %f", self.painter.camera.inputCamera.iso)
//        //            self.focusSquare.exposureSlider.value = self.painter.camera.inputCamera.iso
        
        //        }
    }
    // click on team logo
    @objc func respondToTapGesture(gesture: UIGestureRecognizer) {
        
        self.OpenHightLightView(selectedIndex: (gesture.view?.tag)!)
        
    }
    
    @IBAction func TeamButtonCliicked(_ sender: UIButton)
    {
        self.OpenScroreBaordSettingView()
        //        self.OpenHightLightView(selectedIndex: sender.tag)
    }
    
    @IBAction func HightLightButtonClicked(_ sender: UIButton)
    {
        //        return
        
        self.selectedtagsArray = NSMutableArray.init()
        
        if self.recordEventInfo.isDayEvent
        {
            let clipSecond: Int64 = 30
            let clipName: String = "Hightlight"
            let dict: Dictionary <String, Any> = [
                "clipcapturesecond" : Int64(self.totalRecordedSecond),
                "cliptagsecond" : clipSecond,
                "clipname" : clipName,
                "teamname" : "",
                "tagsArray": self.selectedtagsArray,
                "clipDate": Date.init()
            ]
            
            self.videoClipsArray.add(dict)
        }
            
        else
        {
            
            //            picker.sourceType = .camera
            //            picker.delegate =  self
            //            self.present(picker, animated: true, completion: nil)
            
            highLightView.isHidden = true
            home_ScoreView.isHidden = true
            away_ScoreView.isHidden = true
            viewProgressiveZoomContainer.isHidden = true
            btnPause.isHidden = true
            highLightView.isHidden = true
            
            overlayNameScoreView.isHidden = true
            overlayHomeTeamView.isHidden = true
            overlayAwayTeamView.isHidden = true
            overlayScoreView.isHidden = true
            overlayPeriodView.isHidden = true
            overlayTimerView.isHidden = true
            
            overlayNameScoreView.isHidden = true
            overlayHomeNameBtn.isHidden = true
            overlayAwayNameBtn.isHidden = true
            overlayScoreBtn.isHidden = true
            overlayPeriodBtn.isHidden = true
            overlayTimerBtn.isHidden = true
            
            UIGraphicsBeginImageContextWithOptions(CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height), false, 0.0)
            self.view.drawHierarchy(in: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height), afterScreenUpdates: true)
            if let image = UIGraphicsGetImageFromCurrentImageContext() {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                
            }
            UIGraphicsEndImageContext();
            
            let clipSecond: Int64 = 30
            let clipName: String = "Hightlight"
            let dict: Dictionary <String, Any> = [
                "clipcapturesecond" : Int64(self.totalRecordedSecond),
                "cliptagsecond" : clipSecond,
                "clipname" : clipName,
                "teamname" : "",
                "tagsArray": self.selectedtagsArray,
                "clipDate": Date.init(),
                "clipImage": photoTagImage,
                "fbLive": fbAvailable
            ]
            highLightView.isHidden = false
            home_ScoreView.isHidden = false
            away_ScoreView.isHidden = false
            viewProgressiveZoomContainer.isHidden = false
            btnPause.isHidden = false
            highLightView.isHidden = false
            
            overlayNameScoreView.isHidden = false
            overlayHomeTeamView.isHidden = false
            overlayAwayTeamView.isHidden = false
            overlayScoreView.isHidden = false
            overlayPeriodView.isHidden = false
            overlayTimerView.isHidden = false
            
            overlayNameScoreView.isHidden = false
            overlayHomeNameBtn.isHidden = false
            overlayAwayNameBtn.isHidden = false
            overlayScoreBtn.isHidden = false
            overlayPeriodBtn.isHidden = false
            overlayTimerBtn.isHidden = false
            self.matchEventvideoClipsArray.add(dict)
            self.OpenHightLightView(selectedIndex: sender.tag)
        }
        
    }
    
    
    
   
    //MARK:- Gesture
    func addPanGesture()
    {
        //        return
        if !self.isVideoPlay
        {
            return
        }
        let panGesture: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(respondToPanGesture(gesture:)))
        self.viewVideoRecordingOptionContainer.isUserInteractionEnabled = true
        if !self.recordEventInfo.isDayEvent
        {
            
            panGesture.require(toFail: swipeRightOnVideoRecording)
            panGesture.require(toFail: swipeLeftOnVideoRecording)
            
        }
        
        
        self.viewVideoRecordingOptionContainer.addGestureRecognizer(panGesture)
        
        
    }
    
    func addSwipeGestureOnScrollview() {
        
        if self.recordEventInfo.isDayEvent || self.isVideoPlay
        {
            return
        }
        
        swipeRightOnScorecard = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(gesture:)))
        swipeRightOnScorecard.delegate = self
        swipeRightOnScorecard.direction = UISwipeGestureRecognizerDirection.right
        self.viewScorecardContainer.addGestureRecognizer(swipeRightOnScorecard)
        
        swipeLeftOnVideoRecording = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(gesture:)))
        swipeLeftOnVideoRecording.delegate = self
        swipeLeftOnVideoRecording.direction = UISwipeGestureRecognizerDirection.left
        viewVideoRecordingOptionContainer.addGestureRecognizer (swipeLeftOnVideoRecording)
        
        swipeRightOnVideoRecording = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(gesture:)))
        swipeRightOnVideoRecording.delegate = self
        swipeRightOnVideoRecording.direction = UISwipeGestureRecognizerDirection.right
        self.viewVideoRecordingOptionContainer.addGestureRecognizer (swipeRightOnVideoRecording)
        
        swipeLeftOnOverlay = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(gesture:)))
        swipeLeftOnOverlay.delegate = self
        swipeLeftOnOverlay.direction = UISwipeGestureRecognizerDirection.left
        viewOverlayContainer.addGestureRecognizer (swipeLeftOnOverlay)
        
        
    }
    @objc func respondToPanGesture(gesture: UIPanGestureRecognizer)
    {
//        //        return
//        if self.focusSquare == nil
//        {
//            return
//        }
//        if self.focusSquare.isHidden
//        {
//            return
//        }
//        let location: CGPoint = gesture.location(in: self.viewVideoRecordingOptionContainer)
//
//        if gesture.state == .began
//        {
//            lastPanY = location.y
//            print("panning began")
//        }
//        if gesture.state == .changed
//        {
//            print("panning moved")
//
//            let velocity = gesture.velocity(in: self.viewVideoRecordingOptionContainer)
//            var currentDirection: Int = 0
//            print(velocity)
//            if velocity.x > 0
//            {
//                //            print("panning right")
//                currentDirection = 1
//            }
//            else
//            {
//                //            print("panning left")
//                currentDirection = 2
//            }
//
//            // check if direction was changed
//            if currentDirection != latestDirection
//            {
//                //            print("direction was changed")
//
//            }
//            var difference = lastPanY - location.y
//            difference = difference * 0.1
//            if velocity.y > 0
//            {
//                //            print("panning down")
//
//            }
//            else
//            {
//                //            print("panning up")
//
//            }
//            var newSliderValue = self.focusSquare.exposureSlider.value + Float(difference)
//            if newSliderValue < self.focusSquare.exposureSlider.minimumValue
//            {
//                newSliderValue = self.focusSquare.exposureSlider.minimumValue
//            }
//            else if newSliderValue > self.focusSquare.exposureSlider.maximumValue
//            {
//                newSliderValue = self.focusSquare.exposureSlider.maximumValue
//            }
//            else
//            {
//                self.focusSquare.exposureSlider.value = newSliderValue
//                do {
//                    try self.painter.camera.inputCamera.lockForConfiguration()
//                    self.painter.camera.inputCamera.setExposureModeCustom(duration: AVCaptureDevice.currentExposureDuration, iso: newSliderValue, completionHandler: nil)
//                    self.painter.camera.inputCamera.unlockForConfiguration()
//                } catch let error {
//                    NSLog("Could not lock device for configuration: \(error)")
//                }
//                self.focusSquare.isSliderChanging()
//            }
//
//            latestDirection = currentDirection
//        }
//        if gesture.state == .ended
//        {
//            print("panning ended")
//        }
        
        
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            let view = gesture.view
            
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                if view == viewVideoRecordingOptionContainer
                {
                    if IsOverlayImagePurchase()
                    {
                        self.OpenOverlayView()
                    }
                }
                else
                {
                    self.viewVideoRecordingOptionContainer.isHidden = false
                    self.viewScorecardContainer.isHidden = true
                }
                
            case UISwipeGestureRecognizerDirection.down:
                print("Swiped down")
            case UISwipeGestureRecognizerDirection.left:
                
                if view == viewVideoRecordingOptionContainer
                {
                    if IsScoreboardPurchase()
                    {
                        self.OpenScroreBaordSettingView()
                    }
                    
                }
                else
                {
                    self.OpenRecordingView()
                    
                }
                
            case UISwipeGestureRecognizerDirection.up:
                print("Swiped up")
            default:
                break
            }
        }
    }
    func OpenRecordingView()
    {
        self.viewVideoRecordingOptionContainer.isHidden = false
        self.viewOverlayContainer.isHidden = true
        //        if overlayImageView.image != nil
        //        {
        //            self.overlayRecordingImageView.image = overlayImageView.image
        //            self.overlayRecordingImageView.isHidden = false
        //        }
        //        else
        //        {
        //            self.overlayRecordingImageView.image = nil
        //            self.overlayRecordingImageView.isHidden = true
        //        }
        var arrayImageView: Array = self.recordingOverlayView.subviews
        
        for i in 0..<arrayImageView.count
        {
            let subview: UIImageView = arrayImageView[i] as! UIImageView
            subview.removeFromSuperview()
            //            subview = nil
        }
        
        arrayImageView = overlayAllView.subviews
        
        for view in arrayImageView
        {
            let imageView: DrageImageView = view as! DrageImageView
            
            let newImageView: UIImageView = UIImageView.init(frame: imageView.frame)
            newImageView.image = imageView.image
            
            self.recordingOverlayView.addSubview(newImageView)
        }
        //        self.overlayRecordingImageView.frame = overlayImageView.frame
        self.GetScoreBoardImage()
        
    }
    
    func GetScoreBoardImage()
    {
        if self.recordEventInfo.isDayEvent
        {
            return
        }
        UIGraphicsBeginImageContextWithOptions(imageAndScoreBoardView.frame.size, false, 0)
        
        //        UIGraphicsBeginImageContextWithOptions((self.videoSize)!, false, 0)
        
        
        let context = UIGraphicsGetCurrentContext()!
        self.imageAndScoreBoardView.layer.render(in: context)
        self.overlayScoreBoardImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    
    func OpenOverlayView()
    {
        self.viewVideoRecordingOptionContainer.isHidden = true
        self.viewOverlayContainer.isHidden = false
        
        //        self.recordEventInfo.homeTeamScore = Int64(homeScroe)!
        //        self.recordEventInfo.awayTeamScore = Int64(awayScore)!
        //
        //        self.lblScoreField.text = "\(self.recordEventInfo.homeTeamScore )" + " - " + "\(self.recordEventInfo.awayTeamScore )"
        
        
        
    }
    //MARK:- Add buttons in bottom bar
    func addButtonInBottomBar() {
        self.view.layoutIfNeeded()
        
        for i in 0...totalNumberOfButtons {
            let button = UIButton()
            let y = 2.0
            let height = 36.0
            let width = (viewBottomButtonsContainer.frame.size.width - CGFloat((totalNumberOfButtons+1) * 2))/CGFloat(totalNumberOfButtons+1)
            let x = (CGFloat(i) * width) + CGFloat((i+1) * 2)
            button.frame = CGRect(x: x, y: CGFloat(y), width: width, height: CGFloat(height))
            
            button.backgroundColor = COLOR_BLACK_ALPHA_60()
            button.setTitle(arrButtonTitles[i], for: .normal)
            button.setTitleColor(UIColor.white, for: .normal)
            button.titleLabel?.font = UIFont.FontWithSize(FONT_MONTSERRAT_Bold, 12)
            
            button.layer.cornerRadius = 5.0
            button.layer.masksToBounds = true
            viewBottomButtonsContainer.addSubview(button)
        }
        
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        self.OpenScroreBaordSettingView()
        return false
    }
    func OpenScroreBaordSettingView()
    {
        if IsScoreboardPurchase()
        {
            self.viewVideoRecordingOptionContainer.isHidden = true
            self.viewScorecardContainer.isHidden = false
            
            //            let watch = StopWatch(totalSeconds: totalVideoSecond)
            
            self.txtHomeTeamName.text = self.recordEventInfo.homeTeamName
            self.txtAwayTeamName.text = self.recordEventInfo.awayTeamName
            
            self.txtHomeTeamScore.text = "\(self.recordEventInfo.homeTeamScore)"
            self.txtAwayTeamScore.text = "\(self.recordEventInfo.awayTeamScore)"
            //            self.settingHomeLogo.image = self.imgHomeLogo.image
            //            self.settingAwayLogo.image = self.imgAwayLogo.image
            
            if self.isScorebaordOn
            {
                btnTeamScoreSwitch.setImage(UIImage(named: "switch_on"), for: .normal)
            }
            else
            {
                btnTeamScoreSwitch.setImage(UIImage(named: "switch_off"), for: .normal)
            }
            if self.isTimerOn
            {
                btnMinutesSwitch.setImage(UIImage(named: "switch_on"), for: .normal)
            }
            else
            {
                btnMinutesSwitch.setImage(UIImage(named: "switch_off"), for: .normal)
            }
            
            if self.isPeriodOn
            {
                btnPeriodSwitch.setImage(UIImage(named: "switch_on"), for: .normal)
            }
            else
            {
                btnPeriodSwitch.setImage(UIImage(named: "switch_off"), for: .normal)
            }
            
            let watch = StopWatch(totalSeconds: Int(self.totalRecordedSecond))
            
            if watch.minutes < 99 {
                
                self.txtMinutes.text = String(format: "%02i", watch.minutes)
                
            } else  {
                self.txtMinutes.text = String(format: "%03i", watch.minutes)
                
            }
        }
    }
    
    //MARK:- Buttons click
    fileprivate func addGestureRecognizers() {
        
        let pinchGesture: UIPinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(zoomGesture(pinch:)))
        pinchGesture.delegate = self
        viewVideoRecordingOptionContainer.addGestureRecognizer(pinchGesture)
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
            device.ramp(toVideoZoomFactor: CGFloat(zoomScale), withRate: Float(20.0/Double(zoomSpeed) * 1.5))
            
        } catch {
            print("\(error.localizedDescription)")
        }
    }
    @IBAction func btnSmoothZoomSwitchClicked(_ sender: Any)
    {
        if btnSmoothZoomSwitch.image(for: .normal) == UIImage(named: "switch_off")
        {
            btnSmoothZoomSwitch.setImage(UIImage(named: "switch_on"), for: .normal)
            videoSettingDict["IsZoomOn"] = true
            
            self.btnPlusZoom.isEnabled = true
            self.btnMinusZoom.isEnabled = true
            self.btnPlusZoomSpeed.isEnabled = true
            self.btnMinusZoomSpeed.isEnabled = true
        }
        else
        {
            btnSmoothZoomSwitch.setImage(UIImage(named: "switch_off"), for: .normal)
            videoSettingDict["IsZoomOn"] = false
            
            self.btnPlusZoom.isEnabled = false
            self.btnMinusZoom.isEnabled = false
            self.btnPlusZoomSpeed.isEnabled = false
            self.btnMinusZoomSpeed.isEnabled = false
        }
    }
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
    
    /***************Main djshdshj************************/
    
    
    @IBAction func btnPauseStateClicked(_ sender: Any) {
        
    }
    
    @IBAction func btnBackToRecordingClicked(_ sender: Any) {
        
        recording()
        
    }
    
    func recording() {
        
        print("btnBackToRecordingClicked")
        
        viewActionButtonsContainer.isHidden = true
        viewZoomOptionsContainer.isHidden = true
        
        
        print("1.isVideoPlay: \(isVideoPlay)")
        
        if isVideoPlay
        {
            viewProgressiveZoomContainer.isHidden = true
        }
        else
        {
            
            viewProgressiveZoomContainer.isHidden = false
        }
        btnPause.isHidden = false
        
        //        if self.recordEventInfo.isDayEvent
        //        {
        //            viewAwayContainer.isHidden = true
        //        }
        //        else
        //        {
        //            viewAwayContainer.isHidden = false
        //        }
        self.highLightView.isHidden = false
        self.MakeProgressiveZoomOnOff()
        if self.isVideoPlay
        {
            print("2.StartPlaying Recording")
           
        }
        else
        {
            print("3.Start Camera capture")
            
           
        }
        
        if !self.recordEventInfo.isDayEvent
        {
            self.home_ScoreView.isUserInteractionEnabled = true
            self.overlayNameScoreView.isUserInteractionEnabled = true
            self.away_ScoreView.isUserInteractionEnabled = true
        }
        self.isRecordingInProgress = true
        
        
    }
    
    @IBAction func btnFinishRecordingClicked(_ sender: Any) {
        
        //        self.trimEnd = self.currentTime
        //
        //        let trimDict: NSMutableDictionary = NSMutableDictionary.init()
        //        trimDict.setValue(self.trimStart, forKey: "trimstart")
        //        trimDict.setValue(self.trimEnd, forKey: "trimend")
        //
        //        self.trimPositionArray.add(trimDict)
        
        //  painter.stopCameraRecording(competionHandler: nil)
        //        self.SaveVideoRcordedInfoToDB()
        
        if self.isVideoPlay
        {
            
            if self.avPlayer.rate > 0
            {
                //                painter.stopCameraRecording(competionHandler: nil)
                //                self.lastRecordedSecond = self.totalRecordedSecond
                stopStreaming()
                
                self.avPlayer.pause()
                
            }
            
            APP_DELEGATE.showHUDWithText(textMessage: "Saving...")
           
        }
        else
        {
            APP_DELEGATE.showHUDWithText(textMessage: "Saving...")
            
        }
        //        self.Merge1()
        //        viewTagsContainer.isHidden = false
        //        viewZoomOptionsContainer.isHidden = true
        //        viewVideoRecordingOptionContainer.isHidden = true
        //        viewProgressiveZoomContainer.isHidden = true
    }
    
    
    @IBAction func btnTeamScoreSwitchCicked(_ sender: Any) {
        
        if btnTeamScoreSwitch.image(for: .normal) == UIImage(named: "switch_off")
        {
            btnTeamScoreSwitch.setImage(UIImage(named: "switch_on"), for: .normal)
            
            txtHomeTeamName.isEnabled = true
            txtAwayTeamName.isEnabled = true
            txtHomeTeamScore.isEnabled = true
            txtAwayTeamScore.isEnabled = true
        }
        else
        {
            btnTeamScoreSwitch.setImage(UIImage(named: "switch_off"), for: .normal)
            btnMinutesSwitch.setImage(UIImage(named: "switch_off"), for: .normal)
            btnPeriodSwitch.setImage(UIImage(named: "switch_off"), for: .normal)
            
            txtHomeTeamName.isEnabled = false
            txtAwayTeamName.isEnabled = false
            txtHomeTeamScore.isEnabled = false
            txtAwayTeamScore.isEnabled = false
            
            txtMinutes.isEnabled = false
            txtPeriod.isEnabled = false
        }
    }
    
    @IBAction func btnMinutesSwitchClicked(_ sender: Any)
    {
        if btnTeamScoreSwitch.image(for: .normal) == UIImage(named: "switch_off")
        {
            return
        }
        if btnMinutesSwitch.image(for: .normal) == UIImage(named: "switch_off")
        {
            btnMinutesSwitch.setImage(UIImage(named: "switch_on"), for: .normal)
            
            txtMinutes.isEnabled = true
        }
        else
        {
            btnMinutesSwitch.setImage(UIImage(named: "switch_off"), for: .normal)
            btnPeriodSwitch.setImage(UIImage(named: "switch_off"), for: .normal)
            
            txtMinutes.isEnabled = false
            txtPeriod.isEnabled = false
        }
    }
    
    @IBAction func btnPeriodSwitchClicked(_ sender: Any) {
        if btnTeamScoreSwitch.image(for: .normal) == UIImage(named: "switch_off")
        {
            return
        }
        if btnMinutesSwitch.image(for: .normal) == UIImage(named: "switch_off")
        {
            return
        }
        if btnPeriodSwitch.image(for: .normal) == UIImage(named: "switch_off")
        {
            btnPeriodSwitch.setImage(UIImage(named: "switch_on"), for: .normal)
            txtPeriod.isEnabled = true
            
        }
        else
        {
            btnPeriodSwitch.setImage(UIImage(named: "switch_off"), for: .normal)
            txtPeriod.isEnabled = false
        }
    }
    
    @IBAction func btnTagsClicked(_ sender: Any) {
        
        let button = sender as! UIButton
        
        if button.backgroundColor == COLOR_APP_THEME() {
            setCornerRadiusAndShadowOnButton(button: button, backColor: UIColor.white)
            button.setTitleColor(COLOR_FONT_GRAY(), for: .normal)
        } else {
            setCornerRadiusAndShadowOnButton(button: button, backColor: COLOR_APP_THEME())
            button.setTitleColor(UIColor.white, for: .normal)
        }
        
    }
    
    
    @IBAction func btnSaveRecordingClicked(_ sender: Any) {
        //        APP_DELEGATE.myOrientation = .portrait
        //        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        //        self.view.layoutIfNeeded()
        //        self.navigationController?.popToRootViewController(animated: true)
        
        if self.selectedtagsArray.count > 0
        {
            if self.selectedTeamIndex == 0
            {
                return
            }
        }
        
        viewTagsContainer.isHidden = true
        if isVideoPlay
        {
            viewProgressiveZoomContainer.isHidden = true
        }
        else
        {
            viewProgressiveZoomContainer.isHidden = false
        }
        
        //        viewZoomOptionsContainer.isHidden = true
        viewVideoRecordingOptionContainer.isHidden = false
        
        var clipSecond: Int64 = 0
        var clipName: String = ""
        var teamName: String = ""
        
        if self.recordEventInfo.isDayEvent
        {
            teamName = ""
        }
        else
        {
            if self.selectedTeamIndex == 1
            {
                teamName = self.lblHomeTeam.text!
            }
            else if self.selectedTeamIndex == 2
            {
                teamName = self.lblAwayTeam.text!
            }
        }
        if self.selectedtagsArray.count > 0
        {
            let tagItem: TagInfo = self.selectedtagsArray.object(at: 0) as! TagInfo
            
            let maxTagSecond: Int64 = self.selectedtagsArray.value(forKeyPath: "@max.tagSecondValue") as! Int64
            
            clipSecond = maxTagSecond
            clipName = tagItem.tagName!
        }
        else
        {
            clipSecond = 30
            clipName = "Hightlight"
        }
        //        if teamName.count > 0
        //        {
        //            clipName = clipName + " (\(teamName))"
        //        }
        let dict: Dictionary <String, Any> = [
            "clipcapturesecond" : Int64(self.totalRecordedSecond),
            "cliptagsecond" : clipSecond,
            "clipname" : clipName,
            "teamname" : teamName,
            "tagsArray": self.selectedtagsArray,
            "clipDate": Date.init(),
            "fbLive": fbAvailable
        ]
        
        self.videoClipsArray.add(dict)
        
    }
    @IBAction func btnHomeScoreClicked(_ sender: UIButton)
    {
        self.recordEventInfo.homeTeamScore = self.recordEventInfo.homeTeamScore + Int64((sender.titleLabel?.text)!)!
        //        self.recordEventInfo.homeTeamScore = Int64((sender.titleLabel?.text)!)!
        let scoreStr: String = "\(self.recordEventInfo.homeTeamScore )" + " - " + "\(self.recordEventInfo.awayTeamScore )"
        self.overlayScoreBtn.setTitle(scoreStr, for: .normal)
        self.GetScoreBoardImage()
    }
    @IBAction func btnAwayScoreClicked(_ sender: UIButton)
    {
        self.recordEventInfo.awayTeamScore = self.recordEventInfo.awayTeamScore + Int64((sender.titleLabel?.text)!)!
        let scoreStr: String = "\(self.recordEventInfo.homeTeamScore)" + " - " + "\(self.recordEventInfo.awayTeamScore )"
        self.overlayScoreBtn.setTitle(scoreStr, for: .normal)
        self.GetScoreBoardImage()
    }
    
    
    @IBAction func btnSaveScoreBoardClicked(_ sender: Any) {
        
        
        let homeTeamName: String = self.txtHomeTeamName.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let awayTeamName: String = self.txtAwayTeamName.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let homeScroe: String = self.txtHomeTeamScore.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let awayScore: String = self.txtAwayTeamScore.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let timerValue: String = self.txtMinutes.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let periodValue: String = self.txtPeriod.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        
        if homeTeamName.isEmpty
        {
            APP_DELEGATE.displayMessageAlertWithMessage(alertMessage: "Please enter Home team name.", withTitle: "Alert")
            return
        }
        if awayTeamName.isEmpty
        {
            APP_DELEGATE.displayMessageAlertWithMessage(alertMessage: "Please enter Away team name.", withTitle: "Alert")
            return
        }
        if homeScroe.isEmpty
        {
            APP_DELEGATE.displayMessageAlertWithMessage(alertMessage: "Please add Home team score.", withTitle: "Alert")
            return
        }
        if awayScore.isEmpty
        {
            APP_DELEGATE.displayMessageAlertWithMessage(alertMessage: "Please add Away team score.", withTitle: "Alert")
            return
        }
        if timerValue.isEmpty
        {
            APP_DELEGATE.displayMessageAlertWithMessage(alertMessage: "Please add time value.", withTitle: "Alert")
            return
        }
        if periodValue.isEmpty
        {
            APP_DELEGATE.displayMessageAlertWithMessage(alertMessage: "Please add period value.", withTitle: "Alert")
            return
        }
        
        self.recordEventInfo.homeTeamName = homeTeamName
        self.recordEventInfo.awayTeamName = awayTeamName
        
        self.recordEventInfo.homeTeamScore = Int64(homeScroe)!
        self.recordEventInfo.awayTeamScore = Int64(awayScore)!
        
        let scoreStr: String = "\(self.recordEventInfo.homeTeamScore )" + " - " + "\(self.recordEventInfo.awayTeamScore )"
        //        totalVideoSecond = Int(timerValue)!
        //        self.lblTime.text = timerValue
        //        self.totalRecordedSecond =
        
        self.lblPeriod.text = periodValue
        self.lblHomeTeam.text = homeTeamName
        self.lblAwayTeam.text = awayTeamName
        
        self.overlayHomeNameBtn.setTitle(self.recordEventInfo.homeTeamName, for: .normal)
        self.overlayAwayNameBtn.setTitle(self.recordEventInfo.awayTeamName, for: .normal)
        self.overlayScoreBtn.setTitle(scoreStr, for: .normal)
        self.overlayPeriodBtn.setTitle(periodValue, for: .normal)
        
        self.viewVideoRecordingOptionContainer.isHidden = false
        self.viewScorecardContainer.isHidden = true
        
        if btnTeamScoreSwitch.image(for: .normal) == UIImage(named: "switch_off")
        {
            self.isScorebaordOn = false
            
            //            self.overlayHomeTeamView.isHidden = true
            //            self.overlayAwayTeamView.isHidden = true
            //            self.overlayScoreView.isHidden = true
            
            self.overlayNameScoreView.isHidden = true
            
            self.away_ScoreView.isHidden = true
            self.home_ScoreView.isHidden = true
        }
        else
        {
            self.isScorebaordOn = true
            
            //            self.overlayHomeTeamView.isHidden = false
            //            self.overlayAwayTeamView.isHidden = false
            //            self.overlayScoreView.isHidden = false
            
            self.overlayNameScoreView.isHidden = false
            self.away_ScoreView.isHidden = false
            self.home_ScoreView.isHidden = false
        }
        
        if btnPeriodSwitch.image(for: .normal) == UIImage(named: "switch_off")
        {
            self.isPeriodOn = false
            self.overlayPeriodView.isHidden = true
        }
        else
        {
            self.isPeriodOn = true
            self.overlayPeriodView.isHidden = false
        }
        
        if btnMinutesSwitch.image(for: .normal) == UIImage(named: "switch_off")
        {
            self.isTimerOn = false
            self.isTimeLabelHide = true
            self.overlayTimerView.isHidden = true
        }
        else
        {
            self.isTimerOn = true
            self.isTimeLabelHide = false
            self.overlayTimerView.isHidden = false
        }
        
        self.GetScoreBoardImage()
      
        
    }
    
    
    @IBAction func btnHomeTeamClicked(_ sender: UIButton)
    {
        if btnHomeTeam.backgroundColor == COLOR_APP_THEME()
        {
            setCornerRadiusAndShadowOnButton(button: btnHomeTeam, backColor:  UIColor.white)
            btnHomeTeam.setTitleColor(COLOR_APP_THEME(), for: .normal)
            self.selectedTeamIndex = 0
        }
        else
        {
            setCornerRadiusAndShadowOnButton(button: btnHomeTeam, backColor: COLOR_APP_THEME())
            btnHomeTeam.setTitleColor(UIColor.white, for: .normal)
            
            setCornerRadiusAndShadowOnButton(button: btnAwayTeam, backColor:  UIColor.white)
            btnAwayTeam.setTitleColor(COLOR_APP_THEME(), for: .normal)
            self.selectedTeamIndex = 1
        }
        self.SetStateOfTagSaveButton()
    }
    
    @IBAction func btnAwayTeamClicked(_ sender: UIButton)
    {
        if btnAwayTeam.backgroundColor == COLOR_APP_THEME()
        {
            setCornerRadiusAndShadowOnButton(button: btnAwayTeam, backColor:  UIColor.white)
            btnAwayTeam.setTitleColor(COLOR_APP_THEME(), for: .normal)
            self.selectedTeamIndex = 0
        }
        else
        {
            setCornerRadiusAndShadowOnButton(button: btnAwayTeam, backColor: COLOR_APP_THEME())
            btnAwayTeam.setTitleColor(UIColor.white, for: .normal)
            
            setCornerRadiusAndShadowOnButton(button: btnHomeTeam, backColor:  UIColor.white)
            btnHomeTeam.setTitleColor(COLOR_APP_THEME(), for: .normal)
            self.selectedTeamIndex = 2
        }
        self.SetStateOfTagSaveButton()
    }
    
    //MARK:- Display Alert for In App Purchase
    func IsOverlayImagePurchase() -> Bool
    {
        var isProductPurchased: Bool = false
        if UserDefaults.standard.value(forKey: Constants.kImageOverlay_PurchaseKey) != nil
        {
            let value: String = UserDefaults.standard.value(forKey: Constants.kImageOverlay_PurchaseKey) as! String
            
            if value == "YES"
            {
                isProductPurchased = true
            }
        }
        //        isProductPurchased = true
        if !isProductPurchased
        {
            APP_DELEGATE.displayMessageAlertWithMessage(alertMessage: "You have to purchase Image in overlay product for overlay screen. You can purchase it from Home Page.", withTitle: "Alert")
            return false
        }
        return true
    }
    func IsScoreboardPurchase() -> Bool
    {
        var isProductPurchased: Bool = false
        if UserDefaults.standard.value(forKey: Constants.kScoreboard_PurchaseKey) != nil
        {
            let value: String = UserDefaults.standard.value(forKey: Constants.kScoreboard_PurchaseKey) as! String
            
            if value == "YES"
            {
                isProductPurchased = true
            }
        }
        //        isProductPurchased = true
        if !isProductPurchased
        {
            APP_DELEGATE.displayMessageAlertWithMessage(alertMessage: "You have to purchase Scoreboard product to set Scoreboard setting. You can purchase it from Home Page.", withTitle: "Alert")
            return false
        }
        return true
    }
    
    func AddImageOverVideo(outputFileURL: String)
    {
        
    }
    
    
    private func getImageLayer(height: CGFloat) -> CALayer {
        let imglogo = UIImage(named: "button_bg_blue_video")
        
        let imglayer = CALayer()
        imglayer.contents = imglogo?.cgImage
        imglayer.frame = CGRect(
            x: 8, y: 8,
            width: 100, height: 45)
        imglayer.opacity = 1.0
        
        return imglayer
    }
    
    private func getFramesAnimation(frames: [UIImage], duration: CFTimeInterval) -> CAAnimation {
        let animation = CAKeyframeAnimation(keyPath:#keyPath(CALayer.contents))
        animation.calculationMode = kCAAnimationDiscrete
        animation.duration = duration
        animation.values = frames.map {$0.cgImage!}
        animation.repeatCount = Float(frames.count)
        animation.isRemovedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        animation.beginTime = AVCoreAnimationBeginTimeAtZero
        
        return animation
    }
    
    private func addAudioTrack(composition: AVMutableComposition, videoAsset: AVURLAsset) {
        let compositionAudioTrack:AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: CMPersistentTrackID())!
        let audioTracks = videoAsset.tracks(withMediaType: AVMediaType.audio)
        for audioTrack in audioTracks {
            try! compositionAudioTrack.insertTimeRange(audioTrack.timeRange, of: audioTrack, at: kCMTimeZero)
        }
    }
    func FetchTagInfoFromDB()
    {
        var filterPredicate = NSPredicate(format: "isRecordingPageTag = true")
        
        let SubCategoryArray1: NSArray = CoreDataHelperInstance.sharedInstance.fetchDataFrom(entityName1: "TagInfo", sorting: true, predicate: filterPredicate)! as NSArray
        if SubCategoryArray1 != nil
        {
            self.tagsRecordingList = NSMutableArray.init(array: SubCategoryArray1)
        }
        
        //        DispatchQueue.main.async {
        //
        //        }
    }
    
    func SetHighLightButtons()
    {
        
    }
    
    func runTimer()
    {
        print("run Timer")
        //        return
        
        if self.recordEventInfo.isDayEvent
        {
            return
        }
        if (timer != nil)
        {
            timer.invalidate()
            timer = nil
        }
        
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(RecordCameraVideoVC.updateTimer)), userInfo: nil, repeats: true)
        
    }
    
    @objc func updateTimer()
    {
        print("updateTimer")
        
        totalVideoSecond = totalVideoSecond + 1
        
        self.totalRecordedSecond = totalVideoSecond + 1
        
        let watch = StopWatch(totalSeconds: Int(totalVideoSecond))
        
        if watch.minutes < 100 {
            
            self.lblTime.text = String(format: "%02i:%02i", watch.minutes, watch.seconds)
            self.lblTimeString = self.lblTime.text
            self.txtMinutes.text = String(format: "%02i", watch.minutes)
            
        } else {
            
            self.lblTime.text = String(format: "%03i:%02i", watch.minutes, watch.seconds)
            self.lblTimeString = self.lblTime.text
            self.txtMinutes.text = String(format: "%03i", watch.minutes)
            
        }
        self.overlayTimerBtn.setTitle(self.lblTimeString!, for: .normal)
        self.GetScoreBoardImage()
        
    }
    
    
    func verifyPresetForAsset(preset: String, asset: AVAsset) -> Bool {
        let compatiblePresets = AVAssetExportSession.exportPresets(compatibleWith: asset)
        let filteredPresets = compatiblePresets.filter { $0 == preset }
        return filteredPresets.count > 0 || preset == AVAssetExportPresetPassthrough
    }
    
    func removeFileAtURLIfExists(url: URL) {
        
        let fileManager = FileManager.default
        
        guard fileManager.fileExists(atPath: url.path) else { return }
        
        do {
            try fileManager.removeItem(at: url)
        }
        catch let error {
            print("TrimVideo - Couldn't remove existing destination file: \(String(describing: error))")
        }
    }
    
   
    
    
}

extension FaceBookLiveVideoVc : FBSDKLiveVideoDelegate {
    func liveVideo(_ liveVideo: FBSDKLiveVideo, VideoUrl url: URL) {
        
    }
    
    func liveVideo(_ liveVideo: FBSDKLiveVideo, didStartWith session: RTMPConnection) {
        self.loader.stopAnimating()
        self.loader.removeFromSuperview()
        self.recordButton.isEnabled = true
        
        self.recordButton.imageView?.image = UIImage(named: "stop-button")
    }
    
    func liveVideo(_ liveVideo: FBSDKLiveVideo, didChange sessionState: FBSDKLiveVideoSessionState) {
        print("Session state changed to: \(sessionState)")
    }
    
    func liveVideo(_ liveVideo: FBSDKLiveVideo, didStopWith session: RTMPConnection) {
        self.recordButton.imageView?.image = UIImage(named: "record-button")
        
    }
    
    func liveVideo(_ liveVideo: FBSDKLiveVideo, didErrorWith error: Error) {
        self.recordButton.imageView?.image = UIImage(named: "record-button")
        
        
    }
}

extension FaceBookLiveVideoVc : FBSDKLoginButtonDelegate {
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        self.recordButton.isHidden = true
        self.view.insertSubview(self.blurOverlay, at: 1)
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            print("Error logging in: \(error.localizedDescription)")
            return
        }
        
        self.recordButton.isHidden = false
        self.blurOverlay.removeFromSuperview()
    }
    
    func SaveVideoRcordedInfoToDB()
    {
        let recEventObj: RecEventList = (NSEntityDescription.insertNewObject(forEntityName: "RecEventList", into: CoreDataHelperInstance.sharedInstance.manageObjectContext) as? RecEventList)!
        
        if self.recordEventInfo.awayTeamLogo != nil
        {
            let imageData: NSData = UIImageJPEGRepresentation(self.recordEventInfo.awayTeamLogo!, 0.5)! as NSData
            recEventObj.awayTeamLogo = imageData as Data
            
        }
        else
        {
            recEventObj.awayTeamLogo = nil
        }
        if self.recordEventInfo.homeTeamLogo != nil
        {
            let imageData: NSData = UIImageJPEGRepresentation(self.recordEventInfo.homeTeamLogo!, 0.5)! as NSData
            recEventObj.homeTeamLogo = imageData as Data
            
        }
        else
        {
            recEventObj.homeTeamLogo = nil
        }
        recEventObj.awayTeamName = self.recordEventInfo.awayTeamName
        recEventObj.homeTeamName = self.recordEventInfo.homeTeamName
        recEventObj.sportName = self.recordEventInfo.sportName
        recEventObj.eventName = self.recordEventInfo.eventName
        recEventObj.videoFolderID = self.recordEventInfo.videoFolderName
        recEventObj.isDayEvent = self.recordEventInfo.isDayEvent
        recEventObj.homeTeamScore = self.recordEventInfo.homeTeamScore
        recEventObj.awayTeamScore = self.recordEventInfo.awayTeamScore
        recEventObj.recordingDate = Date.init()
        recEventObj.videoPreset = (self.videoSettingDict["Quality"] as! String)
        
        recEventObj.fbLive = true
        
        for i in 0..<self.videoClipsArray.count
        {
            let recVideoClips: RecVideoClips = (NSEntityDescription.insertNewObject(forEntityName: "RecVideoClips", into: CoreDataHelperInstance.sharedInstance.manageObjectContext) as? RecVideoClips)!
            
            let dict: Dictionary<String, Any> = self.videoClipsArray.object(at: i) as! Dictionary<String, Any>
            
            recVideoClips.isPostClip = false
            recVideoClips.clipDate = (dict["clipDate"] as! Date)
            recVideoClips.clipName = dict["clipname"] as? String
            recVideoClips.teamName = dict["teamname"] as? String
            recVideoClips.clipNumber = Int64(i)
            recVideoClips.clipSecond = dict["clipcapturesecond"] as! Int64
            recVideoClips.clipTagSecond = dict["cliptagsecond"] as! Int64
            recVideoClips.videoFolderID = self.recordEventInfo.videoFolderName
            recVideoClips.fbLive = true
            
            
            if self.selectedtagsArray.count > 0
            {
                recVideoClips.isHighlightClip = false
            }
            else
            {
                recVideoClips.isHighlightClip = true
            }
            var clipStartTime: Int64 = recVideoClips.clipSecond - recVideoClips.clipTagSecond
            let clipEndTime: Int64 = recVideoClips.clipTagSecond + clipStartTime
            
            if clipStartTime < 0
            {
                clipStartTime = 0
            }
            recVideoClips.clipStartTime = clipStartTime
            recVideoClips.clipEndTime = clipEndTime
            recVideoClips.clipDuration = clipEndTime - clipStartTime
            
            if dict["tagsArray"] != nil
            {
                let array: NSArray = dict["tagsArray"] as! NSArray
                if array.count > 0
                {
                    recVideoClips.recordingToTagList = NSSet.init(array: dict["tagsArray"] as! [Any])
                }
                else
                {
                    recVideoClips.recordingToTagList = nil
                }
            }
            else
            {
                recVideoClips.recordingToTagList = nil
            }
            
        }
        
        CoreDataHelperInstance.sharedInstance.saveContext()
        
        self.RedirectToBackAfterMerderVideo()
    }
    
    func RedirectToBackAfterMerderVideo()
    {
        
        DispatchQueue.main.async {
            
            APP_DELEGATE.hideHUD()
            APP_DELEGATE.myOrientation = .portrait
            APP_DELEGATE.landscaperSide = UIInterfaceOrientation.portrait
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            self.view.layoutIfNeeded()
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    private func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        
        return UIInterfaceOrientationMask.landscapeLeft
    }
    private func shouldAutorotate() -> Bool {
        
        return true
        
    }
}

extension FaceBookLiveVideoVc {
    
    func observeTime(elapsedTime: CMTime)
    {
        let playerIsPlaying = avPlayer.rate > 0
        if playerIsPlaying
        {
            if self.trimStart == nil
            {
                self.trimStart = elapsedTime
            }
            self.currentTime = elapsedTime;
            var secondsf: Float = Float(elapsedTime.value) / Float(elapsedTime.timescale)
            if !secondsf.isNaN
            {
                let lastStartSecond: Float = Float(self.trimStart.value) / Float(self.trimStart.timescale)
                
                secondsf = self.lastRecordedSecond + secondsf - lastStartSecond
                self.totalRecordedSecond = secondsf
            }
            let elapsedSecond = CMTimeGetSeconds(elapsedTime)
            let totalVideoDuration = CMTimeGetSeconds(self.playerItem.duration)
            
            self.sliderVideo.setValue(Float ( elapsedSecond ), animated: true)
            
            let timeRemaining: Float64 = totalVideoDuration - elapsedSecond
            
            if (lround(timeRemaining) / 60) % 60 < 100 {
                
                self.lblEndTime.text = String(format: "%02d:%02d", ((lround(timeRemaining) / 60) % 60), lround(timeRemaining) % 60)
                
            } else {
                
                self.lblEndTime.text = String(format: "%03d:%02d", ((lround(timeRemaining) / 60) % 60), lround(timeRemaining) % 60)
                
            }
            
            if elapsedSecond >= Float64(totalVideoDuration)
            {
                self.avPlayer.pause()
                self.playPauseButton.setBackgroundImage(UIImage.init(named: "play_gray"), for: .normal)
                
                self.trimEnd = self.playerItem.duration
                let trimDict: NSMutableDictionary = NSMutableDictionary.init()
                trimDict.setValue(self.trimStart, forKey: "trimstart")
                trimDict.setValue(self.trimEnd, forKey: "trimend")
                
                self.trimPositionArray.add(trimDict)
                self.btnFinishRecordingClicked(UIButton.init())
            }
            
            
        }
        
    }
    @objc func onSliderValChanged(slider: UISlider, event: UIEvent) {
        
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
            case .began:
                // handle drag began
                self.sliderBeganTracking(slider: slider)
            case .moved:
                // handle drag moved
                self.sliderValueChanged(slider: slider)
            case .ended:
                // handle drag ended
                self.sliderEndedTracking(slider: slider)
            default:
                break
            }
        }
    }
    func sliderBeganTracking(slider: UISlider)
    {
        
        if isVideoPlay
        {
            let playerIsPlaying = avPlayer.rate > 0
            if playerIsPlaying
            {
                avPlayer.pause()
                
                self.trimEnd = avPlayer.currentTime()
                self.lastRecordedSecond = self.totalRecordedSecond
                let trimDict: NSMutableDictionary = NSMutableDictionary.init()
                trimDict.setValue(self.trimStart, forKey: "trimstart")
                trimDict.setValue(self.trimEnd, forKey: "trimend")
                
                self.trimPositionArray.add(trimDict)
                
                self.playPauseButton.setBackgroundImage(UIImage.init(named: "play_gray"), for: .normal)
            }
            self.lastSliderValue = self.sliderVideo.value
        }
        else
        {
            
        }
    }
    func sliderEndedTracking(slider: UISlider)
    {
        
        if !isVideoPlay
        {
            self.focusSquare.isSliderEnded()
            return
        }
        //        let elapsedTime: Float64 = Float64(self.sliderVideo.value)
        //
        //        avPlayer.seek(to: CMTimeMakeWithSeconds(elapsedTime, preferedScale), toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero, completionHandler: { (completed: Bool) in
        //
        //            self.avPlayer.play()
        //
        //        })
        //        self.lblEndTime.text = String(format: "%02d:%02d", ((lround(elapsedTime) / 60) % 60), lround(elapsedTime) % 60)
        
    }
    func sliderValueChanged(slider: UISlider)
    {
        
//        if !isVideoPlay
//        {
//            do {
//                try self.painter.camera.inputCamera.lockForConfiguration()
//                self.painter.camera.inputCamera.setExposureModeCustom(duration: AVCaptureDevice.currentExposureDuration, iso: slider.value, completionHandler: nil)
//                self.painter.camera.inputCamera.unlockForConfiguration()
//            } catch let error {
//                NSLog("Could not lock device for configuration: \(error)")
//            }
//            self.focusSquare.isSliderChanging()
//            return
//        }
//        var elapsedTime: Float64 = Float64(self.sliderVideo.value)
//
//        if self.isRecordingInProgress
//        {
//            //            if elapsedTime < Float64(self.lastSliderValue)
//            //            {
//            //                elapsedTime = Float64(self.lastSliderValue)
//            //                self.sliderVideo.value = Float(elapsedTime)
//            //            }
//        }
//
//        if elapsedTime >= Float64(self.totalVideoSecond)
//        {
//            elapsedTime = Float64(self.totalVideoSecond)
//        }
//
//        if (lround(elapsedTime) / 60) % 60 < 100 {
//
//            self.lblEndTime.text = String(format: "%02d:%02d", ((lround(elapsedTime) / 60) % 60), lround(elapsedTime) % 60)
//        } else {
//
//            self.lblEndTime.text = String(format: "%03d:%02d", ((lround(elapsedTime) / 60) % 60), lround(elapsedTime) % 60)
//
//
//        }
//
//
//
//        self.lastSliderValue = Float(elapsedTime)
//        avPlayer.seek(to: CMTimeMakeWithSeconds(elapsedTime, preferedScale))
        
    }
    
    
    @objc func appMovedToBackground()
    {
        
        //        print("App moved to background!")
        
//        if self.isVideoPlay
//        {
//            if self.avPlayer.rate > 0
//            {
//                self.avPlayer.pause()
//                self.playPauseButton.setBackgroundImage(UIImage.init(named: "play_gray"), for: .normal)
//            }
//
//        }
//        else
//        {
//            self.btnPauseClicked(UIButton.init())
//
//            self.painter.pauseCameraCapture()
//            self.painter.stopCameraCapture()
//
//            runSynchronouslyOnVideoProcessingQueue {
//                glFinish()
//            }
//        }
    }
    @objc func appBecomeActive()
    {
        
        //        print("App Become Active")
        //        NSLog("self.painter: %@", self.painter)
        
//        if self.isVideoPlay
//        {
//            //            self.player.play()
//        }
//        else
//        {
//            self.painter.resumeCameraCapture()
//            self.painter.startCameraCapture()
//        }
        
    }
    
    
    func changesInViewWhenStopRecording()
    {
        
//        if painter.isRecording
//        {
//            self.lastRecordedSecond = self.totalRecordedSecond
//        }
        
        self.isRecordingInProgress = false
        viewActionButtonsContainer.isHidden = false
        viewZoomOptionsContainer.isHidden = false
      
        
        viewProgressiveZoomContainer.isHidden = false
        btnPause.isHidden = true
        //        viewHomeContainer.isHidden = true
        //        viewAwayContainer.isHidden = true
        
        self.highLightView.isHidden = true
        
        if !self.recordEventInfo.isDayEvent
        {
            self.home_ScoreView.isUserInteractionEnabled = false
            self.overlayNameScoreView.isUserInteractionEnabled = false
            self.away_ScoreView.isUserInteractionEnabled = false
        }
    }
    func MakeProgressiveZoomOnOff()
    {
        
        let zoomSpeed: Int = self.videoSettingDict["ZoomSpeed"] as! Int
        
        self.lblZoomSpeed.text = "\(zoomSpeed)%"
        
        let isZoomON = self.videoSettingDict["IsZoomOn"] as! Bool
        
        if isZoomON
        {
            self.viewProgressiveZoomContainer.isHidden = false
        }
        else
        {
            self.viewProgressiveZoomContainer.isHidden = true
        }
        if isVideoPlay
        {
            self.viewProgressiveZoomContainer.isHidden = true
        }
    }
    
   
    
}


extension FaceBookLiveVideoVc :UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    //MARK:- Collectionview methods
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let numberOfColumns: CGFloat = 5.0
        let itemWidth = CGFloat((((collectionView.frame.width - 32) - (numberOfColumns - 1)) / numberOfColumns))
        return CGSize(width: itemWidth, height: itemWidth * 0.4625)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return self.tagsRecordingList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCollectionCell", for: indexPath) as! TagCollectionCell
        
        let numberOfColumns: CGFloat = 5.0
        let itemWidth = CGFloat((((collectionView.frame.width - 32) - (numberOfColumns - 1)) / numberOfColumns) - 4)
        
        cell.hightLightButton.setBackgroundImage(UIImage(named: ""), for: .normal)
        cell.hightLightButton.layer.cornerRadius = itemWidth * 0.4625 / 2
        
        cell.hightLightButton.layer.shadowRadius = 1
        cell.hightLightButton.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        cell.hightLightButton.layer.shadowOpacity = 0.4
        
        let tagItem: TagInfo = self.tagsRecordingList[indexPath.item] as! TagInfo
        
        cell.hightLightButton.setTitle(tagItem.tagName, for: .normal)
        cell.hightLightButton.backgroundColor = UIColor.white
        cell.hightLightButton.addTarget(self, action: #selector(TagButtonClicked(_:)), for: .touchUpInside)
        cell.hightLightButton.tag = indexPath.item
        
        cell.hightLightButton.setTitleColor(COLOR_FONT_GRAY(), for: .normal)
        
        if self.selectedtagsArray.contains(tagItem)
        {
            cell.hightLightButton.backgroundColor = COLOR_APP_THEME()
            cell.hightLightButton.setTitleColor(UIColor.white, for: .normal)
        }
        else
        {
            cell.hightLightButton.backgroundColor =  UIColor.white
            cell.hightLightButton.setTitleColor(COLOR_FONT_GRAY(), for: .normal)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let tagItem: TagInfo = self.tagsRecordingList[indexPath.item] as! TagInfo
        let cell = collectionView.cellForItem(at: indexPath) as! TagCollectionCell
        if cell.hightLightButton.backgroundColor == COLOR_APP_THEME()
        {
            setCornerRadiusAndShadowOnButton(button: cell.hightLightButton, backColor: UIColor.white)
            cell.hightLightButton.setTitleColor(COLOR_FONT_GRAY(), for: .normal)
            self.selectedtagsArray.remove(tagItem)
        }
        else
        {
            setCornerRadiusAndShadowOnButton(button: cell.hightLightButton, backColor: COLOR_APP_THEME())
            cell.hightLightButton.setTitleColor(UIColor.white, for: .normal)
            self.selectedtagsArray.add(tagItem)
        }
        self.SetStateOfTagSaveButton()
    }
    @objc func TagButtonClicked(_ sender: UIButton)
    {
        let tagItem: TagInfo = self.tagsRecordingList[sender.tag] as! TagInfo
        if sender.backgroundColor == COLOR_APP_THEME() // deselct
        {
            setCornerRadiusAndShadowOnButton(button: sender, backColor: UIColor.white)
            sender.setTitleColor(COLOR_FONT_GRAY(), for: .normal)
            self.selectedtagsArray.remove(tagItem)
        }
        else  // select
        {
            setCornerRadiusAndShadowOnButton(button: sender, backColor: COLOR_APP_THEME())
            sender.setTitleColor(UIColor.white, for: .normal)
            self.selectedtagsArray.add(tagItem)
        }
        self.SetStateOfTagSaveButton()
    }
    @IBAction func btnAddOverlayClicked(_ sender: UIButton)
    {
        //        print("btnAddOverlayClicked: ", self.picker)
        self.picker.delegate = self
        
        self.picker.allowsEditing = false
        self.picker.sourceType = .photoLibrary
        //            self.picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        self.picker.mediaTypes = [kUTTypeImage as String]
        
        if isIpad()
        {
            self.picker.modalPresentationStyle = .popover
            self.picker.popoverPresentationController?.sourceView = sender
        }
        
        self.present(self.picker, animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        self.dismiss(animated: true, completion: nil)
        self.viewOverlayContainer.bringSubview(toFront: self.imageUploadButton)
    }
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        let docDir = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        let imageUniqueName : Int64 = Int64(NSDate().timeIntervalSince1970 * 1000);
        
        let filePath = docDir.appendingPathComponent("\(imageUniqueName).png");
        
        do{
            if let pngimage = UIImagePNGRepresentation((info[UIImagePickerControllerOriginalImage] as? UIImage)!){
                
                photoTagImage = pngimage
                
                print("photoImage::::::\(photoTagImage)")
                
                try pngimage.write(to : filePath , options : .atomic)
                
                /*FETCH DATA:
                 public static func fetchData(nameImage : String) -> UIImage{
                 
                 let docDir = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                 let filePath = docDir.appendingPathComponent(nameImage);
                 
                 if FileManager.default.fileExists(atPath: filePath.path){
                 
                 if let containOfFilePath = UIImage(contentsOfFile : filePath.path){
                 
                 return containOfFilePath;
                 
                 }
                 
                 }
                 
                 return UIImage();
                 }
                 */
            }
            
        } catch {
            
            print("couldn't write image")
            
        }
        
        
        
        self.dismiss(animated: true) {
            let draggableView: DrageImageView = DrageImageView()
            
            let newImage = image.scaled(to: CGSize.init(width: self.overlayAllView.frame.size.width - 20.0, height: self.overlayAllView.frame.size.height/2), scalingMode: .aspectFit)
            
            draggableView.frame = CGRect.init(x: self.view.frame.size.width/2 - newImage.size.width/2, y: 0, width: newImage.size.width, height: newImage.size.height)
            draggableView.image = newImage
            
            //        draggableView.sizeToFit()
            //        draggableView.frame = CGRect.init(x: 50, y: 50, width: draggableView.frame.size.width, height: draggableView.frame.size.height)
            //        self.overlayImageView.image = image
            //        self.view.bringSubview(toFront: self.overlayImageView)
            
            let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.longPress(_:)))
            longGesture.minimumPressDuration = 0.5
            
            draggableView.AddGestureForOverlayImage()
            draggableView.addGestureRecognizer(longGesture)
            
            self.overlayAllView.addSubview(draggableView)
            self.viewOverlayContainer.bringSubview(toFront: self.imageUploadButton)
        }
        
    }
    
    func AddGestureForOverlayImage()
    {
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(DrageImageView.longPress(_:)))
        longGesture.minimumPressDuration = 0.5
        self.overlayImageView.addGestureRecognizer(longGesture)
    }
    @objc func longPress(_ sender: UILongPressGestureRecognizer)
    {
        if sender.view == nil
        {
            return
        }
        let actionSheet = UIAlertController.init(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        actionSheet.addAction(UIAlertAction.init(title: "Delete", style: UIAlertActionStyle.default, handler: { (action) in
            
            sender.view?.removeFromSuperview()
            
            
        }))
        actionSheet.addAction(UIAlertAction.init(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action) in
            
        }))
        actionSheet.popoverPresentationController?.sourceView = sender.view // works for both iPhone & iPad
        
        //Present the controller
        //        self.window?.rootViewController?.present(actionSheet, animated: true, completion: nil)
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    
}



