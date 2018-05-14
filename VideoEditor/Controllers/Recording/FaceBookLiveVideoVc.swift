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

class ExampleRecorderDelegate : DefaultAVMixerRecorderDelegate {
    
    
    override func didFinishWriting(_ recorder: AVMixerRecorder) {
        guard let writer: AVAssetWriter = recorder.writer else { return }
        
        print(writer.outputURL)
        
        let imageDataDict:[String: Any] = ["url": writer.outputURL]
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "FacebookLiveVideo"), object: nil, userInfo: imageDataDict)
        
       
        
    }
}


class FaceBookLiveVideoVc: UIViewController {
    
    var blurOverlay: UIVisualEffectView!
    
    var sessionURL: NSURL!
    
    var loader: UIActivityIndicatorView!
    
    var loginButton: FBSDKLoginButton!
    
    var liveVideo: FBSDKLiveVideo!
    
    var recordEventInfo   : RecordingInfo!
    var videoSettingDict  : Dictionary<String, Any>!
    var videoClipsArray   : NSMutableArray = NSMutableArray.init()
    var selectedtagsArray : NSMutableArray = NSMutableArray.init()
    
   let recorderDelegate = ExampleRecorderDelegate()
    
    @IBOutlet weak var recordButton : UIButton!
    
    let nc = NotificationCenter.default
    
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var sliderView: UIView!
    @IBOutlet weak var sliderVideo: UISlider!
    @IBOutlet weak var lblEndTime: UILabel!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var topSpace: NSLayoutConstraint!
    @IBOutlet weak var bottomSpace: NSLayoutConstraint!
    @IBOutlet weak var rightSpace: NSLayoutConstraint!
    @IBOutlet weak var leftSpace: NSLayoutConstraint!
    @IBOutlet weak var topImageView: UIImageView!
    @IBOutlet weak var home_ScoreButton1: UIButton!
    @IBOutlet weak var home_ScoreButton2: UIButton!
    @IBOutlet weak var home_ScoreButton3: UIButton!
    @IBOutlet weak var home_ScoreView: UIView!
    @IBOutlet weak var away_ScoreView: UIView!
    @IBOutlet weak var away_ScoreButton1: UIButton!
    @IBOutlet weak var away_ScoreButton2: UIButton!
    @IBOutlet weak var away_ScoreButton3: UIButton!
    @IBOutlet weak var imageAndScoreBoardView: UIView!
    @IBOutlet weak var viewCameraContainer: UIView!
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
    @IBOutlet weak var viewBlackPlaceHolder: UIView!
    @IBOutlet weak var imgHomeLogo: UIImageView!
    @IBOutlet weak var imgAwayLogo: UIImageView!
    @IBOutlet weak var settingHomeLogo: UIImageView!
    @IBOutlet weak var settingAwayLogo: UIImageView!
    @IBOutlet weak var btnMinusZoom: UIButton!
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
    
    var isScorebaordOn: Bool = true
    var isPeriodOn: Bool = true
    var isTimerOn: Bool = true
    
    
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
        
      
        
        self.liveVideo = FBSDKLiveVideo(
            delegate: self,
            previewSize: self.view.bounds,
            videoSize: CGSize(width: 1280, height: 720), path: outputFilePath, fbvideoDelegate: recorderDelegate
        )
        
        let myOverlay = UIView(frame: CGRect(x: 5, y: 5, width: self.view.bounds.size.width - 10, height: 30))
        myOverlay.backgroundColor = UIColor.black
        myOverlay.alpha = 0.5
        
       
        self.liveVideo.privacy = .me
        self.liveVideo.audience = "me" // or your user-id, page-id, event-id, group-id, ...
        
        // Comment in to show a green overlay bar (configure with your own one)
        // self.liveVideo.overlay = myOverlay
        
        initializeUserInterface()
        
    }
    
    @objc func forcelandscapeRight() {
        let value = UIInterfaceOrientation.landscapeRight.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.navigationBar.isHidden = false
        
        nc.removeObserver(self, name: NSNotification.Name(rawValue: "FacebookLiveVideo"), object: nil)
        nc.removeObserver(self, name: Notification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    func initializeUserInterface() {
        self.loader = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        self.loader.frame = CGRect(x: 15, y: 15, width: 40, height: 40)
        
        self.blurOverlay = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        self.blurOverlay.frame = self.view.bounds
        
        self.view.insertSubview(self.liveVideo.preview, at: 0)
        
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
    }
    
    func stopStreaming() {
        self.liveVideo.stop()
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
            
            fbAvailable = false
            SaveVideoRcordedInfoToDB()
            
        } catch {
            print("Could not write file", error.localizedDescription)
        }
       
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
    
    @IBAction func btnHomeScoreClicked(_ sender: UIButton)
    {
        self.recordEventInfo.homeTeamScore = self.recordEventInfo.homeTeamScore + Int64((sender.titleLabel?.text)!)!
        //        self.recordEventInfo.homeTeamScore = Int64((sender.titleLabel?.text)!)!
        let scoreStr: String = "\(self.recordEventInfo.homeTeamScore )" + " - " + "\(self.recordEventInfo.awayTeamScore )"
        self.overlayScoreBtn.setTitle(scoreStr, for: .normal)
//        self.GetScoreBoardImage()
    }
    @IBAction func btnAwayScoreClicked(_ sender: UIButton)
    {
        self.recordEventInfo.awayTeamScore = self.recordEventInfo.awayTeamScore + Int64((sender.titleLabel?.text)!)!
        let scoreStr: String = "\(self.recordEventInfo.homeTeamScore)" + " - " + "\(self.recordEventInfo.awayTeamScore )"
        self.overlayScoreBtn.setTitle(scoreStr, for: .normal)
//        self.GetScoreBoardImage()
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
//            self.isTimeLabelHide = true
            self.overlayTimerView.isHidden = true
        }
        else
        {
            self.isTimerOn = true
//            self.isTimeLabelHide = false
            self.overlayTimerView.isHidden = false
        }
        
//        self.GetScoreBoardImage()
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
        
        recEventObj.fbLive = self.recordEventInfo.fbLive
        
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
}
