//
//  FBSDKLiveVideo.swift
//  facebook-live-ios-sample
//
//  Created by Hans Knoechel on 09.03.17.
//  Copyright © 2017 Hans Knoechel. All rights reserved.
//

import UIKit
import HaishinKit




// MARK: FBSDKLiveVideoDelegate




public protocol FBSDKLiveVideoDelegate {
    func liveVideo(_ liveVideo: FBSDKLiveVideo, didStartWith session: RTMPConnection);
    
    func liveVideo(_ liveVideo: FBSDKLiveVideo, didStopWith session: RTMPConnection);
    
    func liveVideo(_ liveVideo: FBSDKLiveVideo, VideoUrl url: URL);
}

public extension FBSDKLiveVideoDelegate {
    func liveVideo(_ liveVideo: FBSDKLiveVideo, didErrorWith error: Error) {}
    
    func liveVideo(_ liveVideo: FBSDKLiveVideo, didChange sessionState: FBSDKLiveVideoSessionState) {}
    
    func liveVideo(_ liveVideo: FBSDKLiveVideo, didAdd cameraSource: RTMPConnection) {}
    
    func liveVideo(_ liveVideo: FBSDKLiveVideo, didUpdate session: RTMPConnection) {}
    
    func liveVideo(_ liveVideo: FBSDKLiveVideo, didDelete session: RTMPConnection) {}
}

// MARK: Enumerations

enum FBSDKLiveVideoPrivacy : StringLiteralType {
    case me = "SELF"
    
    case friends = "FRIENDS"
    
    case friendsOfFriends = "FRIENDS_OF_FRIENDS"
    
    case allFriends = "ALL_FRIENDS"
    
    case custom = "CUSTOM"
}

enum FBSDKLiveVideoStatus: StringLiteralType {
    case unpublished = "UNPUBLISHED"
    
    case liveNow = "LIVE_NOW"
    
    case scheduledUnpublished = "SCHEDULED_UNPUBLISHED"
    
    case scheduledLive = "SCHEDULED_LIVE"
    
    case scheduledCanceled = "SCHEDULED_CANCELED"
}

enum FBSDKLiveVideoType: StringLiteralType {
    case regular = "REGULAR"
    
    case ambient = "AMBIENT"
}

public enum FBSDKLiveVideoSessionState : IntegerLiteralType {
    case none = 0
    
    case previewStarted
    
    case starting
    
    case started
    
    case ended
    
    case error
}

struct FBSDKLiveVideoParameter {
    var key: String!
    
    var value: String!
}

let sampleRate: Double = 44_100

open class FBSDKLiveVideo: NSObject {
    
    // MARK: - Live Video Parameters
    // MARK: Create
    
    var overlay: UIView! {
        didSet {
            if overlay.isDescendant(of: self.preview) {
                overlay.removeFromSuperview()
            } else {
                self.preview.addSubview(overlay)
            }
        }
    }
    
    var videoDescription: String! {
        didSet {
            self.createParameters["description"] = videoDescription
        }
    }
    
    var contentTags: [String]! {
        didSet {
            self.createParameters["content_tags"] = contentTags
        }
    }
    
    var privacy: FBSDKLiveVideoPrivacy = .me {
        didSet {
            self.createParameters["privacy"] = "{\"value\":\"\(privacy.rawValue)\"}"
        }
    }
    
    var plannedStartTime: Date! {
        didSet {
            self.createParameters["planned_start_time"] = String(plannedStartTime.timeIntervalSince1970 * 1000)
        }
    }
    
    var status: FBSDKLiveVideoStatus! {
        didSet {
            self.createParameters["status"] = status.rawValue
        }
    }
    
    var type: FBSDKLiveVideoType = .regular {
        didSet {
            self.createParameters["stream_type"] = type.rawValue
        }
    }
    
    var title: String! {
        didSet {
            self.createParameters["title"] = title
        }
    }
    
    var videoOnDemandEnabled: String! {
        didSet {
            self.createParameters["save_vod"] = videoOnDemandEnabled
        }
    }
    
    // MARK: Update
    
    var adBreakStartNow: Bool! {
        didSet {
            self.updateParameters["ad_break_start_now"] = adBreakStartNow
        }
    }
    
    var adBreakTimeOffset: Float! {
        didSet {
            self.updateParameters["ad_break_time_offset"] = adBreakTimeOffset
        }
    }
    
    var disturbing: Bool! {
        didSet {
            self.updateParameters["disturbing"] = disturbing
        }
    }
    
    var embeddable: Bool! {
        didSet {
            self.updateParameters["embeddable"] = embeddable
        }
    }
    
    var sponsorId: String! {
        didSet {
            self.createParameters["sponsor_id"] = sponsorId
        }
    }
    
  
    
    // MARK: - Utility API's
    
    var delegate: FBSDKLiveVideoDelegate!
    
    var url: URL!
    
    var id: String!
    
    var audience: String = "me"
    
    var frameRate: Int = 30
    
    var bitRate: Int = 1000000
    
    var preview: UIView!
    
    var lfView : LFView!
    
    var videoPath : String = ""
     
    var isStreaming: Bool = false
    
    // MARK: - Internal API's
    
    var rtmpConnection: RTMPConnection = RTMPConnection()
    var rtmpStream: RTMPStream!
    
    private var createParameters: [String : Any] = [:]
    
    private var updateParameters: [String : Any] = [:]
    
    var currentPosition: AVCaptureDevice.Position = .back
    
     var videoSize: CGSize?
    
  

    
    required public init(delegate: FBSDKLiveVideoDelegate, previewSize: CGRect, videoSize: CGSize,path : String,fbvideoDelegate : AVMixerRecorderDelegate,videoSettingDict: Dictionary<String, Any>) {
        super.init()
        
        self.delegate = delegate
        
        var sessionPreset: String = AVCaptureSession.Preset.hd1280x720.rawValue
        let videoQuality: String = videoSettingDict["Quality"] as! String
        
        if videoQuality == Constants.HDQuality
        {
            sessionPreset = AVCaptureSession.Preset.hd1280x720.rawValue
            self.videoSize = CGSize.init(width: 1280.0, height: 720.0)
        }
        else if videoQuality == Constants.FHDQuality
        {
            sessionPreset = AVCaptureSession.Preset.hd1920x1080.rawValue
            self.videoSize = CGSize.init(width: 1920.0, height: 1080.0)
        }
        else if videoQuality == Constants.UltraQuality
        {
            sessionPreset = AVCaptureSession.Preset.hd4K3840x2160.rawValue
            self.videoSize = CGSize.init(width: 3840.0, height: 2160.0)
        }
//        var frameSecondRate: Int32 = 30
//        let FPSValue: String = self.videoSettingDict["FPS"] as! String
//        if FPSValue == Constants.FPS30
//        {
//            frameSecondRate = 30
//        }
//        else
//        {
//            frameSecondRate = 60
//        }
        
        let recordingSource: String = videoSettingDict["RecordingSource"] as! String
        if recordingSource == Constants.FrontCamera
        {
            currentPosition = AVCaptureDevice.Position(rawValue: AVCaptureDevice.Position.front.rawValue)!
        }
        else
        {
            currentPosition = AVCaptureDevice.Position(rawValue: AVCaptureDevice.Position.back.rawValue)!
        }
        
        
        rtmpStream = RTMPStream(connection: rtmpConnection)
        rtmpStream.syncOrientation = true
       
        rtmpStream.captureSettings = [
            "sessionPreset": sessionPreset,
            "continuousAutofocus": true,
            "continuousExposure": true
        ]
        rtmpStream.videoSettings = [
            "width": previewSize.width,
            "height": previewSize.height
        ]
        rtmpStream.audioSettings = [
            "sampleRate": sampleRate
        ]
        
        rtmpStream.mixer.recorder.delegate = fbvideoDelegate
        
       
        
        print(rtmpStream.mixer.recorder.delegate)
        
        lfView  = LFView(frame: CGRect(x: 0, y: 0, width: previewSize.width, height: previewSize.height))
        
        rtmpStream.attachAudio(AVCaptureDevice.default(for: .audio)) { error in
            
        }
        rtmpStream.attachCamera(DeviceUtil.device(withPosition: currentPosition)) { error in
            
        }
        
        lfView.image = UIImage(named: "app_logo")
        
        videoPath = path
       
        lfView.attachStream(rtmpStream)
        preview = UIView(frame: previewSize)
        preview.addSubview(lfView)
        
     
        
    }
    
    deinit {
       
        isStreaming = false
        rtmpStream.close()
        rtmpStream.dispose()
        
        self.delegate = nil
        self.preview  = nil
    }
    
    // MARK: - Public API's
    
    func start() {
        
        print(self.audience)
        
        guard FBSDKAccessToken.current().hasGranted("publish_actions") else {
            return self.delegate.liveVideo(self, didErrorWith: FBSDKLiveVideo.errorFromDescription(description: "The \"publish_actions\" permission has not been granted"))
        }
        
        let graphRequest = FBSDKGraphRequest(graphPath: "/\(self.audience)/live_videos", parameters: self.createParameters, httpMethod: "POST")
        
        DispatchQueue.main.async {
            _ = graphRequest?.start { (_, result, error) in
                guard error == nil, let dict = (result as? NSDictionary) else {
                    return self.delegate.liveVideo(self, didErrorWith: FBSDKLiveVideo.errorFromDescription(description: "Error initializing the live video session: \(String(describing: error?.localizedDescription))"))
                }
                
                self.url = URL(string:(dict.value(forKey: "stream_url") as? String)!)
                self.id = dict.value(forKey: "id") as? String
                
                guard let _ = self.url?.lastPathComponent, let _ = self.url?.query else {
                    return self.delegate.liveVideo(self, didErrorWith: FBSDKLiveVideo.errorFromDescription(description: "The stream path is invalid"))
                }
                
                self.rtmpConnection.addEventListener(Event.RTMP_STATUS, selector: #selector(self.rtmpStatusHandler), observer: self)
                self.rtmpConnection.connect("rtmp://rtmp-api.facebook.com:80/rtmp")
               
                
            }
        }
    }
    
    func stop() {
        
        guard FBSDKAccessToken.current().hasGranted("publish_actions") else {
            
            return self.delegate.liveVideo(self, didErrorWith: FBSDKLiveVideo.errorFromDescription(description: "The \"publish_actions\" permission has not been granted"))
        }
        
        let graphRequest = FBSDKGraphRequest(graphPath: "/\(self.audience)/live_videos", parameters: ["end_live_video":  true], httpMethod: "POST")
        
        DispatchQueue.main.async {
            
            _ = graphRequest?.start { (_, _, error) in
                guard error == nil else {
                    
                    return self.delegate.liveVideo(self, didErrorWith: FBSDKLiveVideo.errorFromDescription(description: "Error stopping the live video session: \(String(describing: error?.localizedDescription))"))
                    
                }
                
                self.rtmpConnection.close()
                self.rtmpConnection.removeEventListener(Event.RTMP_STATUS, selector: #selector(self.rtmpStatusHandler), observer: self)
                self.isStreaming = false
                self.delegate.liveVideo(self, didStopWith:self.rtmpConnection)
                
            }
        }
    }
    
    func update() {
        guard FBSDKAccessToken.current().hasGranted("publish_actions") else {
            return self.delegate.liveVideo(self, didErrorWith: FBSDKLiveVideo.errorFromDescription(description: "The \"publish_actions\" permission has not been granted"))
        }
        
        let graphRequest = FBSDKGraphRequest(graphPath: "/\(self.id)", parameters: self.createParameters, httpMethod: "POST")
        
        DispatchQueue.main.async {
            _ = graphRequest?.start { (_, result, error) in
                guard error == nil else {
                    return self.delegate.liveVideo(self, didErrorWith: FBSDKLiveVideo.errorFromDescription(description: "Error initializing the live video session: \(String(describing: error?.localizedDescription))"))
                }
                
                self.delegate.liveVideo(self, didUpdate: self.rtmpConnection)
            }
        }
    }
    
    func delete() {
        guard FBSDKAccessToken.current().hasGranted("publish_actions") else {
            return self.delegate.liveVideo(self, didErrorWith: FBSDKLiveVideo.errorFromDescription(description: "The \"publish_actions\" permission has not been granted"))
        }
        
        let graphRequest = FBSDKGraphRequest(graphPath: "/\(self.id)", parameters: ["end_live_video":  true], httpMethod: "DELEGTE")
        
        DispatchQueue.main.async {
            _ = graphRequest?.start { (_, _, error) in
                guard error == nil else {
                    return self.delegate.liveVideo(self, didErrorWith: FBSDKLiveVideo.errorFromDescription(description: "Error deleting the live video session: \(String(describing: error?.localizedDescription))"))
                }
                
                self.delegate.liveVideo(self, didDelete: self.rtmpConnection)
            }
        }
    }
    
    @objc func rtmpStatusHandler(_ notification: Notification) {
        let e: Event = Event.from(notification)
        if let data: ASObject = e.data as? ASObject, let code: String = data["code"] as? String {
            switch code {
            case RTMPConnection.Code.connectSuccess.rawValue:
                
                guard let streamPath = self.url?.lastPathComponent, let query = self.url?.query else {
                    return self.delegate.liveVideo(self, didErrorWith: FBSDKLiveVideo.errorFromDescription(description: "The stream path is invalid"))
                }
                
                
                
                 rtmpStream!.publish("/\(streamPath)?\(query)", type: .localRecord, path: videoPath)
                self.isStreaming = true
               
               
                self.delegate.liveVideo(self, didStartWith:self.rtmpConnection)
            
            case RTMPConnection.Code.connectNetworkChange.rawValue :
                
                break;
                
            case RTMPConnection.Code.connectClosed.rawValue :
                
                break;
                
            default:
                break
            }
        }
    }
    
    
    // MARK: Utilities
    
    internal class func errorFromDescription(description: String) -> Error {
        return NSError(domain: FBSDKErrorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey : description])
    }
    
    internal func updateLiveStreamParameters(with parameter: FBSDKLiveVideoParameter) {
        self.createParameters[parameter.key] = parameter.value
    }
    
   
}



//extension FBSDKLiveVideo : VCSessionDelegate {
//    public func connectionStatusChanged(_ sessionState: VCSessionState) {
//        if sessionState == .started {
//            self.isStreaming = true
//        } else if sessionState == .ended || sessionState == .error {
//            self.isStreaming = false
//        }
//
//        self.delegate.liveVideo(self, didChange: FBSDKLiveVideoSessionState(rawValue: sessionState.rawValue)!)
//    }
//
//    public func didAddCameraSource(_ session: VCSimpleSession!) {
//
//        self.delegate.liveVideo(self, didAdd: session as! FBSDKLiveVideoSession)
//    }
//}
