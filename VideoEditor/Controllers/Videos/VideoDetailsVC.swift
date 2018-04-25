//
//  VideoDetailsVC.swift
//  VideoEditor


import UIKit
import Segmentio
import MARKRangeSlider
import SwipeCellKit
import CoreData

class VideoDetailsVC: BaseVC, UITableViewDelegate, UITableViewDataSource, HighlightOptionsDelegate, HighlightTagViewDelegate {
    
    var isPlayingMainVideo: Bool = true
    var previousSliderValue: Float = 0.0

    var videoIndex: Int = 0
    
    var selectedSegment: Int = 0
    var isTempStop: Bool = false
    var previousClipsDuration: Float64 = 0.0
    var totalSliderDuration: Float64 = 0.0
    var selectedInfoClip: Int = 0
    var highlightTagsView: HighlightTagsView!
    var clipCaptureSecond: Float64 = 0.0
    var selectedTeamIndex: Int = 0
    @IBOutlet weak var btnHomeTeam: UIButton!
    @IBOutlet weak var btnAwayTeam: UIButton!
    @IBOutlet weak var tagCollectionView: UICollectionView!
    var tagsArray: NSMutableArray = NSMutableArray.init()
    var selectedtagsArray: NSMutableArray = NSMutableArray.init()
    var fullVideoPath: String = ""

    var playerRateBeforeSeek: Float = 0
    var preferedScale: Int32 = 1000
    var timer: Timer!
    var startClipTime: Float64 = 0.0
    var endClipTime: Float64 = 0.0
    
    var selectedVideoClip: RecVideoClips! = nil
    var timeObserver: AnyObject!
    var avPlayerLayer: AVPlayerLayer!
    var avPlayer: AVPlayer!
    var highLightClipsArray: NSMutableArray!
    var recordedEvent: RecEventList!
    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var viewTopContainer: UIView!
    @IBOutlet weak var viewTopContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var viewSegmentControl: UIView!
    var segmentioView: Segmentio!
    
    @IBOutlet weak var clipVideoCount: UILabel!
    
    @IBOutlet weak var sliderVideo: UISlider!
    @IBOutlet weak var lblStartTime: UILabel!
    @IBOutlet weak var lblStartTimeWidth: NSLayoutConstraint!
    @IBOutlet weak var lblEndTime: UILabel!
    @IBOutlet weak var tblAudioEdit: UITableView!
    @IBOutlet weak var tblMusicSelection: UITableView!
    @IBOutlet weak var tblHighlights: UITableView!
    
    @IBOutlet weak var txtSearchMusic: UITextField!
    @IBOutlet weak var viewAudioEditContainer: UIView!
    @IBOutlet weak var viewMusicContainer: UIView!
    @IBOutlet weak var viewHighlightContainer: UIView!
    @IBOutlet weak var viewVideoContainer: UIView!
    
    @IBOutlet weak var imgThumb: UIImageView!
    
    @IBOutlet weak var playPauseButton: UIButton!
    
    @IBOutlet weak var forwardButton: UIButton!

    @IBOutlet weak var btnVideoHighlights: CustomHighLightButton!
    @IBOutlet weak var btnSaveTag: UIButton!
    @IBOutlet weak var btnCancelTag: UIButton!
    @IBOutlet weak var viewHighlightOptions: UIView!
    
    @IBOutlet weak var viewScrollContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var viewAudioEditorHeight: NSLayoutConstraint!
    @IBOutlet weak var viewMusicContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var viewHighlightContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var viewVideoContainerHeight: NSLayoutConstraint!
    
    @IBOutlet weak var btnSoundTrack: UIButton!
    @IBOutlet weak var btnMyMusic: UIButton!
    
    @IBOutlet weak var viewHighlightShareInfoContainer: UIView!
    @IBOutlet weak var viewHighlightShareInfoTop: NSLayoutConstraint!
    @IBOutlet weak var btnAllHLInStudio: UIButton!
    
    var indexSelectedForHighlight = -1
    
    var totalSegments = 3
    
    var strScreenType = ""
    var strGameName = ""
    var indexSelectedMusicTrack = 0
    var isVoiceOverClicked = false
    
    var lpgrOnHighlightTable: UILongPressGestureRecognizer?
    var tapOnHighlightTable: UITapGestureRecognizer?
    
    var swipeRight = UISwipeGestureRecognizer()
    var swipeLeft = UISwipeGestureRecognizer()
    
    //MARK:- View cycle
    override func viewDidLoad()
    {
        super.viewDidLoad()
//        btnVideoHighlights.showsTouchWhenHighlighted = true
        addTopLeftBackButton()
        addTopRightNavigationBarButton(imageName: "share_gray")
        
        lpgrOnHighlightTable = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressOnHighlight(gestureReconizer:)))
        lpgrOnHighlightTable?.minimumPressDuration = 0.5
        lpgrOnHighlightTable?.delaysTouchesBegan = true
        lpgrOnHighlightTable?.delegate = self
        
        self.tblHighlights.addGestureRecognizer(lpgrOnHighlightTable!)
        
        tapOnHighlightTable = UITapGestureRecognizer(target: self, action: #selector(handleTapOnHighlight(gestureReconizer:)))
        tapOnHighlightTable?.numberOfTapsRequired = 1
        tapOnHighlightTable?.delegate = self
        
//        self.tblHighlights.addGestureRecognizer(tapOnHighlightTable!)
        
        let nib = UINib(nibName: "TagCollectionCell", bundle: nil)
        self.tagCollectionView.register(nib, forCellWithReuseIdentifier: "TagCollectionCell")
        
        self.tblAudioEdit.register(UINib(nibName: "VolumeCell", bundle: nil), forCellReuseIdentifier: "VolumeCell")
        self.tblAudioEdit.register(UINib(nibName: "SimpleButtonCell", bundle: nil), forCellReuseIdentifier: "SimpleButtonCell")
        self.tblAudioEdit.register(UINib(nibName: "AudioAdjustCell", bundle: nil), forCellReuseIdentifier: "AudioAdjustCell")
        self.tblAudioEdit.tableFooterView = UIView()
        
        self.tblMusicSelection.register(UINib(nibName: "MusicSelectionCell", bundle: nil), forCellReuseIdentifier: "MusicSelectionCell")
        self.tblMusicSelection.tableFooterView = UIView()
        
        self.tblHighlights.register(UINib(nibName: "HighlightsCell", bundle: nil), forCellReuseIdentifier: "HighlightsCell")
        self.tblHighlights.tableFooterView = UIView()
        
        if isIpad() {
            viewTopContainerHeight.constant = 400
        }
        
        self.view.layoutIfNeeded()
        
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width - 60, height: 44))
        let lblTitle = UILabel(frame: CGRect(x: 0, y: 0, width: titleView.frame.size.width, height: 28))
        lblTitle.font = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight(rawValue: 1))
        if recordedEvent.isDayEvent
        {
            lblTitle.text = "Local A VS Local B"
        }
        else
        {
            lblTitle.text = "\(recordedEvent.homeTeamName!) VS \(recordedEvent.awayTeamName!)"
        }
//        lblTitle.text = strGameName
        lblTitle.textAlignment = .center
        
        let lblSubTitle = UILabel(frame: CGRect(x: 0, y: 25, width: titleView.frame.size.width, height: 15))
        lblSubTitle.font = UIFont.systemFont(ofSize: 10)
//        lblSubTitle.text = "By Studio 11 Dec '17 Rome, Via A. Monti 189"
        var myString = ""
        
        var myAttribute = [ NSAttributedStringKey.foregroundColor: UIColor.red ]
        
        let segmentioViewRect = viewSegmentControl.bounds
        segmentioView = Segmentio(frame: segmentioViewRect)
        viewSegmentControl.addSubview(segmentioView)
        
        var contentsArr = [SegmentioItem]()
        
        
        if strScreenType == "Recorded" {
            myString = "Recorded"
            myAttribute = [NSAttributedStringKey.foregroundColor: UIColor.red]
            contentsArr.append(SegmentioBuilder.setupSegmentItem(stroption: "Video", strImage: ""))
            totalSegments = 4
            self.viewAudioEditContainer.isHidden = true
            self.viewMusicContainer.isHidden = true
            self.viewHighlightContainer.isHidden = true
            self.viewVideoContainer.isHidden = false
        } else {
            myString = "By Studio"
            myAttribute = [NSAttributedStringKey.foregroundColor: COLOR_APP_THEME()]
            self.viewAudioEditContainer.isHidden = true
            self.viewMusicContainer.isHidden = false
            self.viewHighlightContainer.isHidden = true
            self.viewVideoContainer.isHidden = true
        }
        
        self.viewHighlightOptions.isHidden = true
        
        contentsArr.append(SegmentioBuilder.setupSegmentItem(stroption: "Music", strImage: ""))
        contentsArr.append(SegmentioBuilder.setupSegmentItem(stroption: "Voiceover", strImage: ""))
        contentsArr.append(SegmentioBuilder.setupSegmentItem(stroption: "Highlights", strImage: ""))
        
        segmentioView.selectedSegmentioIndex = 0
        
        SegmentioBuilder.buildSegmentioView(
            segmentioView: segmentioView,
            contents: contentsArr,
            segmentioStyle: .onlyLabel,
            totalSegments: totalSegments
        )
        
        let myAttrString = NSMutableAttributedString(string: myString, attributes: myAttribute)
        
//        let strDateAndUser = " 12 Dec '17 Rome, Via A, Monti 189"
//        let strDateAndUser = " 12 Dec '17 Rome, Via A, Monti 189"
        
        let recordedDate: Date = recordedEvent.recordingDate!
        
        let dateFormatter: DateFormatter = DateFormatter.init()
        
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        
        let strDate: String = dateFormatter.string(from: recordedDate)
        
        let strDateAndUser = " \(strDate)"

        let myAttributeDate = [ NSAttributedStringKey.foregroundColor: UIColor.gray ]
        let myAttrStringDate = NSAttributedString(string: strDateAndUser, attributes: myAttributeDate)
        myAttrString.append(myAttrStringDate)
        // set attributed text on a UILabel
        lblSubTitle.attributedText = myAttrString
        lblSubTitle.textAlignment = .center
        
        titleView.addSubview(lblTitle)
        titleView.addSubview(lblSubTitle)
        self.navigationItem.titleView = titleView
        
        sliderVideo.setThumbImage(UIImage(named: "slider_thumb"), for: .normal)
        sliderVideo.setMinimumTrackImage(UIImage(named: "slider_minimum"), for: .normal)
        sliderVideo.setMaximumTrackImage(UIImage(named: "slider_maximum"), for: .normal)
        
        lblStartTime.layer.cornerRadius = lblStartTime.frame.size.height/2
        lblStartTime.layer.masksToBounds = true
        
        self.view.layoutIfNeeded()
        
//        imgThumb.layer.cornerRadius = 3.0
//        imgThumb.layer.masksToBounds = true
        
        addLeftViewInTextField(txtSearchMusic)
        
        viewHighlightContainerHeight.constant = tblHighlights.contentSize.height + 55
        viewAudioEditorHeight.constant = tblAudioEdit.contentSize.height + 50
        viewMusicContainerHeight.constant = tblMusicSelection.contentSize.height + 110
        
        var maxHeight = viewVideoContainerHeight.constant
        
        if viewMusicContainerHeight.constant > maxHeight {
            maxHeight = viewMusicContainerHeight.constant
        }
        
        if viewAudioEditorHeight.constant > maxHeight {
            maxHeight = viewAudioEditorHeight.constant
        }
        
        if viewHighlightContainerHeight.constant > maxHeight {
            maxHeight = viewHighlightContainerHeight.constant
        }
        
        viewScrollContainerHeight.constant = viewTopContainer.frame.maxY + maxHeight
        self.selectedSegment = 0
        segmentioView.valueDidChange = { [weak self] _, segmentIndex in
            if (segmentIndex == 0 && self?.strScreenType == "Recorded") {
                self?.selectedSegment = segmentIndex
                self?.viewAudioEditContainer.isHidden = true
                self?.viewMusicContainer.isHidden = true
                self?.viewHighlightContainer.isHidden = true
                self?.viewVideoContainer.isHidden = false
                
                self?.view.addGestureRecognizer((self?.swipeLeft)!)
                self?.view.addGestureRecognizer((self?.swipeRight)!)
                self?.PlayMainVideo()
                
            } else if segmentIndex == 0 || (segmentIndex == 1 && self?.strScreenType == "Recorded")  {
                self?.selectedSegment = segmentIndex
                self?.viewAudioEditContainer.isHidden = true
                self?.viewMusicContainer.isHidden = false
                self?.viewHighlightContainer.isHidden = true
                self?.viewVideoContainer.isHidden = true
                
                self?.view.addGestureRecognizer((self?.swipeLeft)!)
                self?.view.addGestureRecognizer((self?.swipeRight)!)
                self?.PlayMainVideo()
                
            } else if segmentIndex == 1 || (segmentIndex == 2 && self?.strScreenType == "Recorded"){
                self?.selectedSegment = segmentIndex
                self?.viewAudioEditContainer.isHidden = false
                self?.viewMusicContainer.isHidden = true
                self?.viewHighlightContainer.isHidden = true
                self?.viewVideoContainer.isHidden = true
                
                self?.view.removeGestureRecognizer((self?.swipeLeft)!)
                self?.view.removeGestureRecognizer((self?.swipeRight)!)
                
                self?.viewTopContainer.addGestureRecognizer((self?.swipeRight)!)
                self?.viewTopContainer.addGestureRecognizer((self?.swipeLeft)!)
                self?.PlayMainVideo()
            } else if segmentIndex == 2 || (segmentIndex == 3 && self?.strScreenType == "Recorded") {
                self?.selectedSegment = segmentIndex
                self?.viewAudioEditContainer.isHidden = true
                self?.viewMusicContainer.isHidden = true
                self?.viewHighlightContainer.isHidden = false
                self?.viewVideoContainer.isHidden = true
                
                self?.view.addGestureRecognizer((self?.swipeLeft)!)
                self?.view.addGestureRecognizer((self?.swipeRight)!)
                self?.FetchVideoClipsInfo()
                
                self?.IntitializeForHighlightClips()
                self?.PlayHighLightVideoWithIndex(index: 0, plusDuration: 0)
            }
        }
        
//        btnSaveTag.layer.cornerRadius = btnSaveTag.frame.size.height/2
//        btnSaveTag.layer.masksToBounds = true
//        btnSaveTag.layer.shadowRadius = 1
//        btnSaveTag.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
//        btnSaveTag.layer.shadowOpacity = 0.5
//        btnSaveTag.backgroundColor = COLOR_APP_THEME()
//        
//        btnCancelTag.layer.cornerRadius = btnCancelTag.frame.size.height/2
//        btnCancelTag.layer.masksToBounds = true
//        btnCancelTag.layer.shadowRadius = 1
//        btnCancelTag.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
//        btnCancelTag.layer.shadowOpacity = 0.5
//        btnCancelTag.backgroundColor = UIColor.white
        
        setCornerRadiusAndShadowOnButton(button: btnSaveTag, backColor: COLOR_APP_THEME())
        setCornerRadiusAndShadowOnButton(button: btnCancelTag, backColor: UIColor.white)
        
        sliderVideo.minimumValue = 0
        sliderVideo.maximumValue = 1
        sliderVideo.isContinuous = true
        viewHighlightShareInfoContainer.isHidden = true
        
        viewHighlightShareInfoContainer.layer.shadowRadius = 2
        viewHighlightShareInfoContainer.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        viewHighlightShareInfoContainer.layer.shadowOpacity = 1
        viewHighlightShareInfoContainer.layer.shadowColor = UIColor.lightGray.cgColor
        
        addSwipeGestureOnScrollview()
        
        setCornerRadiusAndShadowOnButton(button: btnVideoHighlights, backColor: COLOR_APP_THEME())
        setCornerRadiusAndShadowOnButton(button: btnSoundTrack, backColor: COLOR_APP_THEME())
        setCornerRadiusAndShadowOnButton(button: btnAllHLInStudio, backColor: COLOR_APP_THEME())
        setCornerRadiusAndShadowOnButton(button: btnMyMusic, backColor: UIColor.white)
        
//        self.sliderVideo.addTarget(self, action: #selector(sliderBeganTracking), for: .touchDown)
//        self.sliderVideo.addTarget(self, action: #selector(sliderEndedTracking), for: [.touchUpInside, .touchUpOutside])
//        self.sliderVideo.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        self.sliderVideo.addTarget(self, action: #selector(onSliderValChanged(slider:event:)), for: .valueChanged)
        self.InitializeVideoPlayer()
        
    }
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.FetchTagInfoFromDB()
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let playerIsPlaying = avPlayer.rate > 0
        if playerIsPlaying
        {
            avPlayer.pause()
            self.playPauseButton.setBackgroundImage(UIImage.init(named: "play_gray"), for: .normal)
        }
    }
    func generateThumbnail(url: URL, atSecond: Int64)
    {
        DispatchQueue.global().async {
            let asset = AVURLAsset(url: url)
            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true
            let actionTime: CMTime = CMTimeMake(atSecond, 1)
            let time = NSValue.init(time: actionTime)
            generator.generateCGImagesAsynchronously(forTimes: [time]) { [weak self] _, image, _, _, _ in
                
                DispatchQueue.main.async(execute: {
                    if let image = image, let _ = UIImagePNGRepresentation(UIImage(cgImage: image))
                    {
                        self?.imgThumb.image = UIImage.init(cgImage: image)
                    }
                })
                
            }
        }
        
    }
    func UpdateHeightForVideoPage()
    {
        var maxHeight: CGFloat = 0.0
        let modulo = self.tagsArray.count % 4
        if modulo == 0
        {
            maxHeight = CGFloat((self.tagsArray.count / 4 * 50))
        }
        else
        {
            maxHeight = CGFloat(((self.tagsArray.count - (self.tagsArray.count % 4)) / 4 + 1) * 50)
        }
        if maxHeight > 150
        {
            maxHeight = 150 + 123
        }
        else
        {
            maxHeight = maxHeight + 123
        }
        viewVideoContainerHeight.constant = maxHeight
        viewScrollContainerHeight.constant = viewTopContainer.frame.maxY + viewVideoContainerHeight.constant
    }
    func UpdateScrollviewHeight()
    {
        viewHighlightContainerHeight.constant = CGFloat(self.highLightClipsArray.count * 55 + 55)
        viewAudioEditorHeight.constant = tblAudioEdit.contentSize.height + 50
        viewMusicContainerHeight.constant = tblMusicSelection.contentSize.height + 110
        
        var maxHeight = viewVideoContainerHeight.constant
        
        if viewMusicContainerHeight.constant > maxHeight {
            maxHeight = viewMusicContainerHeight.constant
        }
        
        if viewAudioEditorHeight.constant > maxHeight {
            maxHeight = viewAudioEditorHeight.constant
        }
        
        if viewHighlightContainerHeight.constant > maxHeight
        {
            maxHeight = viewHighlightContainerHeight.constant
        }
        
        viewScrollContainerHeight.constant = viewTopContainer.frame.maxY + maxHeight
    }
    
    func InitializeVideoPlayer()
    {
        self.avPlayer = AVPlayer.init()
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer.frame = self.playerView.bounds
        self.playerView.layer.addSublayer(avPlayerLayer)
        let outputFileName = self.recordedEvent.videoFolderID
        
        var outputFilePath = NSTemporaryDirectory() as String
        outputFilePath = outputFilePath + outputFileName! + "/mynew.mov"
        self.fullVideoPath = outputFilePath
        let videoURL = URL.init(fileURLWithPath: self.fullVideoPath)
        
        let playerItem = AVPlayerItem.init(url: videoURL)
        self.avPlayer.replaceCurrentItem(with: playerItem)
        self.avPlayerLayer.backgroundColor=UIColor.clear.cgColor
        self.PlayMainVideo()
//        self.generateThumbnail(url: videoURL, atSecond: 0)
    }
    func PlayMainVideo()
    {
        imgThumb.isHidden = true
        playerView.isHidden = false
        self.isPlayingMainVideo = true
        self.forwardButton.isEnabled = true
        self.playPauseButton.isEnabled = true
        sliderVideo.isEnabled = true
        
        let playerIsPlaying = avPlayer.rate > 0
        if playerIsPlaying
        {
            avPlayer.pause()
            self.playPauseButton.setBackgroundImage(UIImage.init(named: "play_gray"), for: .normal)
        }
        if (timeObserver != nil)
        {
            avPlayer.removeTimeObserver(timeObserver)
            timeObserver = nil
        }
        
        let timeInterval: CMTime = CMTimeMakeWithSeconds(0.05, preferedScale)
        timeObserver = avPlayer.addPeriodicTimeObserver(forInterval: timeInterval,
                                                        queue: DispatchQueue.main) { (elapsedTime: CMTime) -> Void in
                                                            
//                                                             print("elapsedTime now:", CMTimeGetSeconds(elapsedTime))
                                                            self.observeTime(elapsedTime: elapsedTime)
            } as AnyObject
        

        let duration : CMTime = avPlayer.currentItem!.asset.duration
        self.sliderVideo.isContinuous = true
        let seconds : Float64 = CMTimeGetSeconds(duration)
        self.lblEndTime.text = String(format: "%02d:%02d", ((lround(seconds) / 60) % 60), lround(seconds) % 60)
        self.startClipTime = 0.01
        self.endClipTime = seconds
        self.previousClipsDuration = 0.0
        self.sliderVideo.minimumValue = Float(self.startClipTime)
        self.sliderVideo.maximumValue = Float(seconds)
        self.sliderVideo.value = Float(self.startClipTime)
        self.totalSliderDuration = self.endClipTime - self.startClipTime
        
        avPlayer.seek(to: CMTimeMakeWithSeconds(self.startClipTime, preferedScale), toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero, completionHandler: { (completed: Bool) in


        })
    }
    func IntitializeForHighlightClips()
    {
        if self.highLightClipsArray.count == 0
        {
//            self.isPlayingMainVideo = true
//            self.PlayMainVideo()
            imgThumb.isHidden = false
            playerView.isHidden = true
            sliderVideo.isEnabled = false
            self.forwardButton.isEnabled = false
            self.lblEndTime.text = "00:00"
            self.playPauseButton.isEnabled = false
            self.sliderVideo.value = 0.0
            return
        }
        imgThumb.isHidden = true
        playerView.isHidden = false
        sliderVideo.isEnabled = true
        self.forwardButton.isEnabled = true
        self.playPauseButton.isEnabled = true
        
        isPlayingMainVideo = false
        indexSelectedForHighlight = 0
        self.selectedVideoClip = self.highLightClipsArray.object(at: indexSelectedForHighlight) as! RecVideoClips
        let playerIsPlaying = avPlayer.rate > 0
        if playerIsPlaying
        {
            avPlayer.pause()
            self.playPauseButton.setBackgroundImage(UIImage.init(named: "play_gray"), for: .normal)
        }
        if (timeObserver != nil)
        {
            avPlayer.removeTimeObserver(timeObserver)
            timeObserver = nil
        }
        let maxTagSecond: Int64 = self.highLightClipsArray.value(forKeyPath: "@sum.clipDuration") as! Int64

        var elapsedTime: Float64 = Float64(self.selectedVideoClip.clipStartTime)
        if elapsedTime <= 0
        {
            elapsedTime = 0.01
        }
        self.startClipTime = elapsedTime
        elapsedTime = 0.01
        self.sliderVideo.minimumValue = Float(elapsedTime)
        self.sliderVideo.maximumValue = Float(maxTagSecond)
        self.sliderVideo.value = Float(elapsedTime)
        
        self.previousClipsDuration = 0.0
        self.totalSliderDuration = Float64(maxTagSecond)
        self.lblEndTime.text = String(format: "%02d:%02d", ((lround(self.totalSliderDuration) / 60) % 60), lround(self.totalSliderDuration) % 60)

        let timeInterval: CMTime = CMTimeMakeWithSeconds(0.05, preferedScale)
        timeObserver = avPlayer.addPeriodicTimeObserver(forInterval: timeInterval,
                                                        queue: DispatchQueue.main) { (elapsedTime: CMTime) -> Void in
                                                            //                                                            print("elapsedTime now:", CMTimeGetSeconds(elapsedTime))
                                                            self.observeTime(elapsedTime: elapsedTime)
            } as AnyObject
        
        avPlayer.seek(to: CMTimeMakeWithSeconds(self.startClipTime, preferedScale), toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero, completionHandler: { (completed: Bool) in
            
        })
    }
    func PlayHighLightVideoWithIndex(index: Int, plusDuration: Float64)
    {
        if self.highLightClipsArray.count == 0
        {
            isPlayingMainVideo = true
            return
        }
        isPlayingMainVideo = false
//        print("indexSelectedForHighlight", index)

        let playerIsPlaying = avPlayer.rate > 0
        if playerIsPlaying
        {
            self.isTempStop = true
//            avPlayer.pause()
        }
        if indexSelectedForHighlight >= 0
        {
            let cell: HighlightsCell = self.tblHighlights.cellForRow(at: IndexPath.init(row: indexSelectedForHighlight, section: 0)) as! HighlightsCell
            cell.contentView.backgroundColor = UIColor.white

        }
        if index >= 0
        {
            let cell: HighlightsCell = self.tblHighlights.cellForRow(at: IndexPath.init(row: index, section: 0)) as! HighlightsCell
            cell.contentView.backgroundColor = COLOR_APP_THEME()
            
        }
        
        indexSelectedForHighlight = index
        if index == 0
        {
            self.previousClipsDuration = 0.0
        }
        else
        {
            let fromRange = IndexSet(0...index - 1)

            let newArray: NSArray = self.highLightClipsArray.objects(at: fromRange) as NSArray
            let maxTagSecond: Int64 = newArray.value(forKeyPath: "@sum.clipDuration") as! Int64
            self.previousClipsDuration = Float64(maxTagSecond)

        }
//
        self.selectedVideoClip = self.highLightClipsArray.object(at: indexSelectedForHighlight) as! RecVideoClips
        
        let duration : CMTime = avPlayer.currentItem!.asset.duration
        let seconds : Float64 = CMTimeGetSeconds(duration)
        var elapsedTime: Float64 = Float64(self.selectedVideoClip.clipStartTime)
        if elapsedTime <= 0
        {
            elapsedTime = 0.01
        }
        
        self.startClipTime = elapsedTime
        elapsedTime = elapsedTime + plusDuration
//        self.sliderVideo.value = Float(self.previousClipsDuration + plusDuration)
        self.endClipTime = Float64(self.selectedVideoClip.clipEndTime)
        if self.endClipTime > seconds
        {
            self.endClipTime = seconds
        }
        self.lblEndTime.text = String(format: "%02d:%02d", ((lround(self.totalSliderDuration - self.previousClipsDuration - plusDuration) / 60) % 60), lround(self.totalSliderDuration - self.previousClipsDuration - plusDuration) % 60)
//        avPlayer.seek(to: CMTimeMakeWithSeconds(self.startClipTime, preferedScale))
        avPlayer.seek(to: CMTimeMakeWithSeconds(elapsedTime, preferedScale), toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero, completionHandler: { (completed: Bool) in

            self.isTempStop = false
            
        })
        
        
        
    }
    func runTimer()
    {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(VideoDetailsVC.updateTimer)), userInfo: nil, repeats: true)
    }
    @objc func updateTimer()
    {
        
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
    func sliderBeganTracking(slider: UISlider) {
//        playerRateBeforeSeek = avPlayer.rate
        avPlayer.pause()
        self.playPauseButton.setBackgroundImage(UIImage.init(named: "play_gray"), for: .normal)
        previousSliderValue = slider.value
    }
    
    func sliderEndedTracking(slider: UISlider) {
//        let videoDuration = CMTimeGetSeconds(avPlayer.currentItem!.duration)
//        let elapsedTime: Float64 = Float64(self.sliderVideo.value)
//        updateTimeLabel(elapsedTime: elapsedTime, duration: 0)
//
//        avPlayer.seek(to: CMTimeMakeWithSeconds(elapsedTime, preferedScale), toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero, completionHandler: { (completed: Bool) in
//
////            if self.playerRateBeforeSeek > 0 {
////                self.avPlayer.play()
////            }
//        })
        
    }
    
    func sliderValueChanged(slider: UISlider) {
//        let videoDuration = CMTimeGetSeconds(avPlayer.currentItem!.duration)
        var elapsedTime: Float64 = Float64(self.sliderVideo.value)
        if elapsedTime <= 0.01
        {
            elapsedTime = 0.01
            self.sliderVideo.value = Float(elapsedTime)
//            return
        }
//        if self.previousClipsDuration == 0
//        {
//            self.previousClipsDuration = 0.0
//        }
//        else
//        {
//            let fromRange = IndexSet(0...(self.indexSelectedForHighlight - 1))
//
//            let newArray: NSArray = self.highLightClipsArray.objects(at: fromRange) as NSArray
//            let maxTagSecond: Int64 = newArray.value(forKeyPath: "@sum.clipDuration") as! Int64
//            self.previousClipsDuration = Float64(maxTagSecond)
//        }
        let currentPlayerTimer = self.startClipTime + (elapsedTime - self.previousClipsDuration)
        
//        var currentSeconds : Float64 = 0 //CMTimeGetSeconds((self.avPlayer.currentTime()))
//        currentSeconds = elapsedTime - self.startClipTime + self.previousClipsDuration
        updateTimeLabel(currentSeconds: elapsedTime)
//        print("currentPlayerTimer:", currentPlayerTimer)
        var isIncrease: Bool = true
        if previousSliderValue < slider.value
        {
            isIncrease = true
        }
        else
        {
            isIncrease = false
        }
        previousSliderValue = slider.value
        if elapsedTime >= self.totalSliderDuration
        {
            self.avPlayer.pause()
            self.playPauseButton.setBackgroundImage(UIImage.init(named: "play_gray"), for: .normal)
            return
        }
        if self.isPlayingMainVideo
        {
            avPlayer.seek(to: CMTimeMakeWithSeconds(elapsedTime, preferedScale))
            return
        }
        var compareCount: Int  = 0
        
        var isNeedChange: Bool = false
        if isIncrease
        {
            if currentPlayerTimer >= Float64(self.selectedVideoClip.clipEndTime)
            {
                isNeedChange = true
            }
            compareCount = self.highLightClipsArray.count - 1
        }
        else
        {
            if currentPlayerTimer <= Float64(self.selectedVideoClip.clipStartTime)
            {
                isNeedChange = true
            }
            compareCount = 0
        }
        
        if isNeedChange
        {
            if self.indexSelectedForHighlight == compareCount
            {
                self.avPlayer.pause()
                self.playPauseButton.setBackgroundImage(UIImage.init(named: "play_gray"), for: .normal)
                return
            }
            else
            {
                //                self.avPlayer.pause()
                isTempStop = true
                if isIncrease
                {
                    self.PlayHighLightVideoWithIndex(index: self.indexSelectedForHighlight + 1, plusDuration: 0)
                }
                else
                {
                    self.PlayHighLightVideoWithIndex(index: self.indexSelectedForHighlight - 1, plusDuration: 0)
                }
            }
        }
        else
        {
            avPlayer.seek(to: CMTimeMakeWithSeconds(currentPlayerTimer, preferedScale))
        }
    }
    func observeTime(elapsedTime: CMTime)
    {
        if isTempStop
        {
            return
        }
        let playerIsPlaying = avPlayer.rate > 0
        if playerIsPlaying
        {
//            let duration = CMTimeGetSeconds(avPlayer.currentItem!.duration)
            let elapsedTime = CMTimeGetSeconds(elapsedTime)
            
            var currentSeconds : Float64 = 0 //CMTimeGetSeconds((self.avPlayer.currentTime()))
            currentSeconds = elapsedTime - self.startClipTime + self.previousClipsDuration
            updateTimeLabel(currentSeconds: currentSeconds)
            
//            print("elapsedTime now:", currentSeconds)
            self.sliderVideo.setValue(Float ( currentSeconds ), animated: true)
            
            if currentSeconds >= self.totalSliderDuration && isPlayingMainVideo
            {
                self.avPlayer.pause()
                self.playPauseButton.setBackgroundImage(UIImage.init(named: "play_gray"), for: .normal)
                
                self.PlayMainVideo()
                return
            }
//            if self.selectedSegment != 3
            if self.isPlayingMainVideo
            {
                return
            }
            if elapsedTime >= Float64(self.selectedVideoClip.clipEndTime)
            {
                if self.indexSelectedForHighlight == (self.highLightClipsArray.count - 1)
                {
                    self.avPlayer.pause()
                    self.playPauseButton.setBackgroundImage(UIImage.init(named: "play_gray"), for: .normal)
                    isTempStop = true
                    self.sliderVideo.setValue(Float ( 0.0 ), animated: true)
                    self.PlayHighLightVideoWithIndex(index: 0, plusDuration: 0)
                    return
                }
                else
                {
                    //                self.avPlayer.pause()
                    isTempStop = true
                    self.PlayHighLightVideoWithIndex(index: self.indexSelectedForHighlight + 1, plusDuration: 0)
                }
            }
        }
    }
    func updateTimeLabel(currentSeconds: Float64)
    {
        let timeRemaining: Float64 = self.totalSliderDuration - currentSeconds
        if self.avPlayer.currentItem?.status == .readyToPlay
        {
            self.lblEndTime.text = String(format: "%02d:%02d", ((lround(timeRemaining) / 60) % 60), lround(timeRemaining) % 60)
        }
        
    }
    @IBAction func BtnForwardClicked(_ sender: UIButton)
    {
        var elapsedTime: Float64 = Float64(self.sliderVideo.value) + 10.0
        if self.isPlayingMainVideo
        {
            if elapsedTime > self.endClipTime
            {
                elapsedTime = self.endClipTime
            }
            avPlayer.seek(to: CMTimeMakeWithSeconds(elapsedTime, preferedScale), toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero, completionHandler: { (completed: Bool) in
                
                let currentSeconds : Float64 = CMTimeGetSeconds((self.avPlayer.currentTime()))
                self.sliderVideo.setValue(Float ( currentSeconds  ), animated: true)
                self.updateTimeLabel(currentSeconds: currentSeconds)
            })
            return
        }
        else
        {
            if elapsedTime > self.totalSliderDuration
            {
                elapsedTime = self.totalSliderDuration
            }
            var clipNumber: Int = 0
            var totalDuration: Float64 = 0.0
            var plusDuration1: Float64 = 0.0
            for i in 0..<self.highLightClipsArray.count
            {
                let videoClips: RecVideoClips = self.highLightClipsArray.object(at: i) as! RecVideoClips
                
                if elapsedTime >= (totalDuration) && elapsedTime <= (totalDuration + Float64(videoClips.clipDuration))
                {
                    clipNumber = i
                    plusDuration1 = elapsedTime - totalDuration
                    break
                }
                totalDuration = totalDuration + Float64(videoClips.clipDuration)
            }
            self.PlayHighLightVideoWithIndex(index: clipNumber, plusDuration: plusDuration1)
        }
        
        self.sliderVideo.value = Float(elapsedTime)
        
        
        
    }
    
    @IBAction func BtnPlayVideoStart(_ sender: UIButton)
    {
//        let currentSeconds : Float64 = CMTimeGetSeconds((avPlayer.currentItem?.currentTime())!)
        let duration : CMTime = avPlayer.currentItem!.asset.duration
        let elapsedTime: Float64 = Float64(self.sliderVideo.value)
        if elapsedTime >= self.totalSliderDuration
        {
            if !self.isPlayingMainVideo
            {
                self.PlayHighLightVideoWithIndex(index: 0, plusDuration: 0)
            }
            else
            {
                self.PlayMainVideo()
            }
            
        }
        let playerIsPlaying = avPlayer.rate > 0
        if playerIsPlaying {
            avPlayer.pause()
            self.playPauseButton.setBackgroundImage(UIImage.init(named: "play_gray"), for: .normal)
        } else {
            avPlayer.play()
            self.playPauseButton.setBackgroundImage(UIImage.init(named: "pause_gray"), for: .normal)
            
        }

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // Layout subviews manually
        if avPlayerLayer != nil
        {
            avPlayerLayer.frame = self.playerView.bounds
        }
        
    }
    fileprivate func goToControllerAtIndex(_ index: Int) {
        segmentioView.selectedSegmentioIndex = index
    }
    
    
    func addSwipeGestureOnScrollview() {
        swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(gesture:)))
        swipeRight.delegate = self
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
        
        swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(gesture:)))
        swipeLeft.delegate = self
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipeLeft)
    }

    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                if segmentioView.selectedSegmentioIndex > 0 {
                    segmentioView.selectedSegmentioIndex = segmentioView.selectedSegmentioIndex - 1
                }
            case UISwipeGestureRecognizerDirection.down:
                print("Swiped down")
            case UISwipeGestureRecognizerDirection.left:
                if segmentioView.selectedSegmentioIndex < totalSegments - 1 {
                    segmentioView.selectedSegmentioIndex = segmentioView.selectedSegmentioIndex + 1
                }
            case UISwipeGestureRecognizerDirection.up:
                print("Swiped up")
            default:
                break
            }
        }
    }
    func FetchVideoClipsInfo()
    {
        let filterPredicate = NSPredicate(format: "videoFolderID = %@",self.recordedEvent.videoFolderID!)

        let SubCategoryArray1: NSArray =         CoreDataHelperInstance.sharedInstance.fetchDataFrom(entityName1: "RecVideoClips", sorting: true, predicate: filterPredicate, sortKey: "clipDate")! as NSArray
        
        if SubCategoryArray1 != nil
        {
//            self.highLightClipsArray.addObjects(from: SubCategoryArray1 as! [Any])
            self.highLightClipsArray = NSMutableArray.init(array: SubCategoryArray1)
        }
        
        if SubCategoryArray1.count > 1
        {
            self.clipVideoCount.text = "\(SubCategoryArray1.count) Highlights"
        }
        else
        {
            self.clipVideoCount.text = "\(SubCategoryArray1.count) Highlight"
        }
        self.tblHighlights.reloadData()
        self.UpdateScrollviewHeight()
    }
    func FetchTagInfoFromDB()
    {
//        var filterPredicate = NSPredicate(format: "isRecordingPageTag = true")
        
        let filterPredicate = NSPredicate(format: "isRecordingPageTag = true")

        let SubCategoryArray1: NSArray = CoreDataHelperInstance.sharedInstance.fetchDataFrom(entityName1: "TagInfo", sorting: true, predicate: filterPredicate)! as NSArray
        if SubCategoryArray1 != nil
        {
            self.tagsArray = NSMutableArray.init(array: SubCategoryArray1)
        }
      
    }
    //MARK:- Button clicks
    override func topRightNavigationBarButtonClicked() {
        let redirectTo = loadVC(strStoryboardId: SB_OTHERS, strVCId: idSocialShareVC) as! SocialShareVC
        self.navigationController?.pushViewController(redirectTo, animated: true)
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
    @IBAction func btnSaveTagClicked(_ sender: UIButton)
    {
        let recVideoClips: RecVideoClips = (NSEntityDescription.insertNewObject(forEntityName: "RecVideoClips", into: CoreDataHelperInstance.sharedInstance.manageObjectContext) as? RecVideoClips)!
        
        recVideoClips.isPostClip = true
        recVideoClips.clipDate = Date.init()
        recVideoClips.clipNumber = 10
        recVideoClips.clipSecond = Int64(clipCaptureSecond)
        recVideoClips.videoFolderID = self.recordedEvent.videoFolderID
        var clipName: String = ""
        var teamName: String = ""
        if self.selectedTeamIndex == 1
        {
            teamName = self.recordedEvent.homeTeamName!
        }
        else if self.selectedTeamIndex == 2
        {
            teamName = self.recordedEvent.awayTeamName!
        }
        if self.selectedtagsArray.count > 0
        {
            recVideoClips.isHighlightClip = false
            let tagItem: TagInfo = self.selectedtagsArray[0] as! TagInfo
            recVideoClips.clipTagSecond = tagItem.tagSecondValue
            clipName = tagItem.tagName!
            recVideoClips.recordingToTagList = NSSet.init(array: self.selectedtagsArray as! [Any])

        }
        else
        {
            recVideoClips.recordingToTagList = nil
            recVideoClips.isHighlightClip = true
            clipName = "Highlight"
            recVideoClips.clipTagSecond = 30
        }
//        if teamName.count > 0
//        {
//            clipName = clipName + " (\(teamName))"
//        }
        var clipStartTime: Int64 = recVideoClips.clipSecond - recVideoClips.clipTagSecond
        let clipEndTime: Int64 = recVideoClips.clipTagSecond + clipStartTime
        
        if clipStartTime < 0
        {
            clipStartTime = 0
        }
        recVideoClips.clipName = clipName
        if teamName.count > 0
        {
            recVideoClips.teamName = teamName
        }
        else
        {
            recVideoClips.teamName = ""
        }
        recVideoClips.clipStartTime = clipStartTime
        recVideoClips.clipEndTime = clipEndTime
        recVideoClips.clipDuration = clipEndTime - clipStartTime
        CoreDataHelperInstance.sharedInstance.saveContext()
        self.viewHighlightOptions.isHidden = true
        self.btnVideoHighlights.isHidden = false
    }
    @IBAction func btnCancelTagClicked(_ sender: UIButton)
    {
        self.viewHighlightOptions.isHidden = true
        self.btnVideoHighlights.isHidden = false
    }
    @IBAction func btnBottomVideoContinerClicked(_ sender: Any) {
        let button = sender as! UIButton
        
        if button.currentTitle == "GO" {
//            openHighlightButtonOptionsWindow()
        } else {
            btnSaveTag.setTitle("GO", for: .normal)
            viewHighlightOptions.isHidden = false
        }
    }
    
    @objc func handleLongPressOnHighlight(gestureReconizer: UISwipeGestureRecognizer)
    {
        if gestureReconizer.state != UIGestureRecognizerState.ended {
            return
        }
        
//        let point = gestureReconizer.location(in: self.tblHighlights)
//        let indexPath = self.tblHighlights.indexPathForRow(at: point)
//
//        if let index = indexPath {
//            viewHighlightShareInfoTop.constant = CGFloat((index.row + 1) * 55)
//
//            if viewHighlightShareInfoContainer.isHidden == true {
//                viewHighlightShareInfoContainer.isHidden = false
//            } else {
//                viewHighlightShareInfoContainer.isHidden = true
//            }
//        } else {
//            print("Could not find index path")
//        }
    }
    
    @objc func handleTapOnHighlight(gestureReconizer: UISwipeGestureRecognizer)
    {
        viewHighlightShareInfoContainer.isHidden = true
    }
    
    //MARK:- Button Click
    @objc func btnBestClicked(_ sender: Any) {
        let button = sender as! UIButton
        
        if button.image(for: .normal) == UIImage(named: "thunder_blue_filled") {
            button.setImage(UIImage(named: "thunder_gray"), for: .normal)
        } else {
            button.setImage(UIImage(named: "thunder_blue_filled"), for: .normal)
        }
    }
    
    @objc func btnVoiceOverClicked(_ sender: Any) {
        
        isVoiceOverClicked = true
        tblAudioEdit.reloadData()
        
        let deadlineTime = DispatchTime.now() + .seconds(3)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            self.isVoiceOverClicked = false
            self.tblAudioEdit.reloadData()
        }
    }
    
    @IBAction func btnSoundTrackClicked(_ sender: Any) {
//        btnSoundTrack.setBackgroundImage(UIImage(named: "button_bg_blue_mx"), for: .normal)
        btnSoundTrack.setTitleColor(UIColor.white, for: .normal)

        setCornerRadiusAndShadowOnButton(button: btnSoundTrack, backColor: COLOR_APP_THEME())
        setCornerRadiusAndShadowOnButton(button: btnMyMusic, backColor: UIColor.white)
//        btnMyMusic.setBackgroundImage(UIImage(named: "button_bg_white"), for: .normal)
        btnMyMusic.setTitleColor(COLOR_APP_THEME(), for: .normal)
    }
    
    @IBAction func btnMyMusicClicked(_ sender: Any) {
//        btnMyMusic.setBackgroundImage(UIImage(named: "button_bg_blue_mx"), for: .normal)
        btnMyMusic.setTitleColor(UIColor.white, for: .normal)

        setCornerRadiusAndShadowOnButton(button: btnMyMusic, backColor: COLOR_APP_THEME())
        setCornerRadiusAndShadowOnButton(button: btnSoundTrack, backColor: UIColor.white)
//        btnSoundTrack.setBackgroundImage(UIImage(named: "button_bg_white"), for: .normal)
        btnSoundTrack.setTitleColor(COLOR_APP_THEME(), for: .normal)
    }
    
    @IBAction func btnVideoHighlightClicked(_ sender: Any) {
//        openHighlightButtonOptionsWindow()
        
        let currentSeconds : Float64 = CMTimeGetSeconds((avPlayer.currentItem?.currentTime())!)
        var isAllowToHighLight: Bool = true
        if currentSeconds == self.endClipTime || currentSeconds == self.startClipTime
        {
            isAllowToHighLight = false
        }
        if !isAllowToHighLight
        {
            APP_DELEGATE.displayMessageAlertWithMessage(alertMessage: "You can not add highlight at 0 second.", withTitle: "Alert")
            return
        }
        if recordedEvent.isDayEvent
        {
            let recVideoClips: RecVideoClips = (NSEntityDescription.insertNewObject(forEntityName: "RecVideoClips", into: CoreDataHelperInstance.sharedInstance.manageObjectContext) as? RecVideoClips)!
            
            recVideoClips.isPostClip = true
            recVideoClips.clipDate = Date.init()
            recVideoClips.clipName = "Hightlight"
            recVideoClips.teamName = ""
            recVideoClips.clipNumber = 5
            recVideoClips.clipSecond = Int64(currentSeconds)
            recVideoClips.clipTagSecond = 30
            recVideoClips.videoFolderID = self.recordedEvent.videoFolderID
            
            recVideoClips.isHighlightClip = true
            var clipStartTime: Int64 = recVideoClips.clipSecond - recVideoClips.clipTagSecond
            let clipEndTime: Int64 = recVideoClips.clipTagSecond + clipStartTime
            
            if clipStartTime < 0
            {
                clipStartTime = 0
            }
            recVideoClips.clipStartTime = clipStartTime
            recVideoClips.clipEndTime = clipEndTime
            recVideoClips.clipDuration = clipEndTime - clipStartTime
            recVideoClips.recordingToTagList = nil
            
            CoreDataHelperInstance.sharedInstance.saveContext()
        }
        else
        {
            clipCaptureSecond = currentSeconds
            self.viewHighlightOptions.isHidden = false
            self.btnVideoHighlights.isHidden = true
            
            setCornerRadiusAndShadowOnButton(button: btnHomeTeam, backColor: UIColor.white)
            btnHomeTeam.setTitleColor(COLOR_APP_THEME(), for: .normal)
            
            setCornerRadiusAndShadowOnButton(button: btnAwayTeam, backColor: UIColor.white)
            btnAwayTeam.setTitleColor(COLOR_APP_THEME(), for: .normal)
            
            self.btnHomeTeam.setTitle(self.recordedEvent.homeTeamName, for: .normal)
            self.btnAwayTeam.setTitle(self.recordedEvent.awayTeamName, for: .normal)
            if self.selectedtagsArray.count > 0
            {
                self.selectedtagsArray.removeAllObjects()
            }
            
            self.tagCollectionView.reloadData()
            self.SetStateOfTagSaveButton()
            self.UpdateHeightForVideoPage()
        }
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
            setCornerRadiusAndShadowOnButton(button: btnSaveTag, backColor: COLOR_APP_THEME())
            btnSaveTag.setTitleColor(UIColor.white, for: .normal)
        }
        else
        {
            setCornerRadiusAndShadowOnButton(button: btnSaveTag, backColor: UIColor.white)
            btnSaveTag.setTitleColor(COLOR_APP_THEME(), for: .normal)
        }
        btnSaveTag.isEnabled = isEnable
    }
    @IBAction func btnShareHighlightClicked(_ sender: Any) {
        topRightNavigationBarButtonClicked()
    }
    
    @IBAction func btnInfoHighlightClicked(_ sender: Any) {
        openHighlightButtonOptionsWindow()
    }
    
    @objc func btnDeleteOnAudioCellClicked()
    {
        showDeleteAlertMessage(viewConstroller: self)
    }
    
    
    //MARK:- Tableview methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tblAudioEdit == tableView
        {
            if isVoiceOverClicked == true
            {
                return 8
            }
            return 7
        }
        else if tblMusicSelection == tableView
        {
            return 5
        }
        else
        {
//            return 2
            if self.highLightClipsArray != nil
            {
                return self.highLightClipsArray.count
            }
            else
            {
                return 1
            }
        }
    }
    
    @objc func btnStudioClicked() {
//        openHighlightButtonOptionsWindow()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if tblAudioEdit == tableView {
            return 50
        } else if tblMusicSelection == tableView{
            if indexPath.row == 0 {
                return 35
            } else {
                return 50
            }
        } else {
            return 55
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tblAudioEdit == tableView {
            if indexPath.row == 7 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "simpleCell", for: indexPath)
                cell.selectionStyle = .none
                
                let button = cell.viewWithTag(1001) as! UIButton
                
                var deadlineTime = DispatchTime.now() + .seconds(1)
                DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                    button.setTitle("2", for: .normal)
                }
                
                deadlineTime = DispatchTime.now() + .seconds(2)
                DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                    button.setTitle("1", for: .normal)
                }
                
                return cell
            } else if indexPath.row == 6 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SimpleButtonCell", for: indexPath) as! SimpleButtonCell
                cell.selectionStyle = .none
                cell.btnSubmit.addTarget(self, action: #selector(btnVoiceOverClicked(_:)), for: .touchUpInside)
                setCornerRadiusAndShadowOnButton(button: cell.btnSubmit, backColor: COLOR_APP_THEME())
                return cell
            } else if indexPath.row == 5 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "VolumeCell", for: indexPath) as! VolumeCell
                cell.selectionStyle = .none
                return cell
            } else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "AudioAdjustCell", for: indexPath) as! AudioAdjustCell
                cell.layoutIfNeeded()
                self.view.layoutIfNeeded()
                cell.sliderAudioChange.frame = CGRect(x: cell.imgPhoto.frame.maxX, y: 10, width: self.view.frame.size.width - cell.imgPhoto.frame.maxX - cell.btnDelete.frame.size.width - 16, height: cell.viewContainer.frame.size.height - 20)
                cell.sliderAudioChange.leftThumbImage = UIImage(named: "forward_border_arrow")
                cell.sliderAudioChange.rightThumbImage = UIImage(named: "back_border_arrow")
                cell.sliderAudioChange.trackImage = UIImage(named: "slider_left_empty_image")
                cell.sliderAudioChange.rangeImage = UIImage(named: "red_audio_wave")
                
                cell.btnDelete.addTarget(self, action: #selector(btnDeleteOnAudioCellClicked), for: .touchUpInside)
                
                cell.selectionStyle = .none
                cell.layoutIfNeeded()
                return cell
            }
        } else if tblMusicSelection == tableView {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "noMusicCell", for: indexPath)
                cell.selectionStyle = .none
                
                let button = cell.viewWithTag(1002) as! UIButton
                
                if (indexSelectedMusicTrack == indexPath.row) {
                    button.isHidden = false
                } else {
                    button.isHidden = true
                }
                
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "MusicSelectionCell", for: indexPath) as! MusicSelectionCell
                cell.selectionStyle = .none
                
                if (indexSelectedMusicTrack == indexPath.row) {
                    cell.btnCheck.isHidden = false
                } else {
                    cell.btnCheck.isHidden = true
                }
                return cell
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HighlightsCell", for: indexPath) as! HighlightsCell
            cell.selectionStyle = .none
            cell.btnStudio.addTarget(self, action: #selector(btnStudioClicked), for: .touchUpInside)
            cell.btnBest.addTarget(self, action: #selector(btnBestClicked(_:)), for: .touchUpInside)
            cell.delegate = self
            
            if self.highLightClipsArray != nil && self.highLightClipsArray.count > 0
            {
                let recVideoClips: RecVideoClips = self.highLightClipsArray.object(at: indexPath.row) as! RecVideoClips
                
                let teamName = recVideoClips.teamName
                if (teamName?.isEmpty)!
                {
                    cell.lblName.text = recVideoClips.clipName
                    
                }
                else
                {
                    cell.lblName.text = recVideoClips.clipName! + " (" + teamName! + ")"
                }
                cell.lblTime.text = "\(recVideoClips.clipDuration) seconds"
                
                if recVideoClips.isPostClip
                {
                    cell.lblThumbTitle.text = "\(videoIndex).\(indexPath.row + 1) Post"
                }
                else
                {
                    cell.lblThumbTitle.text = "\(videoIndex).\(indexPath.row + 1)"
                }

                let videoURL = URL.init(fileURLWithPath: self.fullVideoPath)
                
                var elapsedTime: Int64 = recVideoClips.clipSecond - recVideoClips.clipTagSecond
                if elapsedTime < 0
                {
                    elapsedTime = 0
                }
                cell.generateThumbnail(url: videoURL, atSecond: elapsedTime)
            }
            
            if indexSelectedForHighlight == indexPath.row {
                cell.contentView.backgroundColor = COLOR_APP_THEME()
            } else {
                cell.contentView.backgroundColor = UIColor.white
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tblMusicSelection == tableView
        {
            indexSelectedMusicTrack = indexPath.row
            tblMusicSelection.reloadData()
            sliderVideo.setValue(Float(indexPath.row)/Float(tableView.numberOfRows(inSection: 0)), animated: true)

            return
        } else if tblHighlights == tableView
        {
           // indexSelectedForHighlight = indexPath.row
            
//            sliderVideo.setValue(Float(indexPath.row)/Float(tableView.numberOfRows(inSection: 0)), animated: true)
            viewHighlightShareInfoContainer.isHidden = true
            
            if indexPath.row == 0
            {
                self.previousClipsDuration = 0.0
            }
            else
            {
                let fromRange = IndexSet(0...indexPath.row - 1)
                let newArray: NSArray = self.highLightClipsArray.objects(at: fromRange) as NSArray
                let maxTagSecond: Int64 = newArray.value(forKeyPath: "@sum.clipDuration") as! Int64
                self.previousClipsDuration = Float64(maxTagSecond)
            }
            sliderVideo.value = Float(self.previousClipsDuration)
            self.PlayHighLightVideoWithIndex(index: indexPath.row, plusDuration: 0)
           // tblHighlights.reloadData()
        }
        
    }
    
    //MARK:- Highlight button options
    func openHighlightButtonOptionsWindow() {
//        let redirectTo = HighlightOptionsVC(nibName: "HighlightOptionsVC", bundle: nil)
//        redirectTo.delegate = self
//        self.presentPopupViewController(redirectTo, animationType: MJPopupViewAnimationSlideTopBottom)
        
        let xibView: HighlightTagsView = Bundle.main.loadNibNamed("HighlightTagsView", owner: nil, options: nil)![0] as! HighlightTagsView
        xibView.SetDefaultSetting()
        xibView.tagsArray = self.tagsArray
        xibView.delegate = self
        self.view.window?.addSubview(xibView)
        
    }
    func OpenTagForClips(index: Int)
    {
        let recVideoClips: RecVideoClips = self.highLightClipsArray.object(at: index) as! RecVideoClips
        self.selectedInfoClip = index
        highlightTagsView = Bundle.main.loadNibNamed("HighlightTagsView", owner: nil, options: nil)![0] as! HighlightTagsView
        
        highlightTagsView.tagsArray = self.tagsArray
        if recVideoClips.recordingToTagList != nil
        {
            let count: Int = (recVideoClips.recordingToTagList?.allObjects.count)!
            if count > 0
            {
                highlightTagsView.selectedtagsArray = NSMutableArray.init(array: (recVideoClips.recordingToTagList?.allObjects)!)
            }
        }
        highlightTagsView.frame = UIScreen.main.bounds
        highlightTagsView.recVideoClips = recVideoClips
        highlightTagsView.recordedEvent = self.recordedEvent
        highlightTagsView.delegate = self
        highlightTagsView.SetDefaultSetting()
        
        self.view.window?.addSubview(highlightTagsView)
    }
    func cancelButtonClicked(controller: HighlightTagsView)
    {
        self.highlightTagsView.removeFromSuperview()
    }
    func saveButtonClicked(controller: HighlightTagsView)
    {
        var clipName: String = ""
        var teamName: String = ""
        if controller.selectedTeamIndex == 1
        {
            teamName = self.recordedEvent.homeTeamName!
        }
        else if controller.selectedTeamIndex == 2
        {
            teamName = self.recordedEvent.awayTeamName!
        }
        
        if controller.selectedtagsArray.count > 0
        {
            controller.recVideoClips.recordingToTagList = NSSet.init(array: controller.selectedtagsArray as! [Any])

            controller.recVideoClips.isHighlightClip = false
            let tagItem: TagInfo = controller.selectedtagsArray[0] as! TagInfo
            clipName = tagItem.tagName!
        }
        else
        {
            controller.recVideoClips.recordingToTagList = nil
            controller.recVideoClips.isHighlightClip = true
            clipName = "Highlight"
        }
//        if teamName.count > 0
//        {
//            clipName = clipName + " (\(teamName))"
//        }
        controller.recVideoClips.clipName = clipName
        controller.recVideoClips.teamName = teamName
        
        CoreDataHelperInstance.sharedInstance.saveContext()
        
        self.cancelButtonClicked(controller: controller)
        
        self.highLightClipsArray.replaceObject(at: self.selectedInfoClip, with: controller.recVideoClips)
        
        self.UpdateTableleData()
    }
    func cancelButtonClicked(controller: HighlightOptionsVC) {
       dismissPopupViewControllerWithanimationType(MJPopupViewAnimationSlideTopBottom)
    }
}

extension VideoDetailsVC: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        if orientation == .left {
            
            let btnShare = SwipeAction(style: .default, title: "Share") { action, indexPath in
                self.redirectToShareScreen()
            }
            
            btnShare.hidesWhenSelected = true
            configure(action: btnShare, with: "Share", with: "share_blue")
            if self.recordedEvent.isDayEvent
            {
                return [btnShare]
            }
            
            let btnInfo = SwipeAction(style: .default, title: "Info") { action, indexPath in
//                self.openHighlightButtonOptionsWindow()
                self.OpenTagForClips(index: indexPath.row)
            }
            btnInfo.hidesWhenSelected = true
            configure(action: btnInfo, with: "Info", with: "info_blue")
            
            return [btnShare, btnInfo]
        } else {
            
            let btnDelete = SwipeAction(style: .default, title: nil) { action, indexPath in
                
                let ac = UIAlertController(title: "Fanner Cam", message: "Are you sure you want to delete?", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (alert) in
                    
                    self.DeleteClipFromDB(index: indexPath.row)
                    
                }))
                ac.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
                self.present(ac, animated: true)
                
            }
            configure(action: btnDelete, with: "Delete", with: "trash_blue")
            return [btnDelete]
        }
    }
    func DeleteClipFromDB(index: Int)
    {
        let recVideoClips: RecVideoClips = self.highLightClipsArray.object(at: index) as! RecVideoClips
        self.highLightClipsArray.remove(recVideoClips)
        CoreDataHelperInstance.sharedInstance.manageObjectContext.delete(recVideoClips)
        CoreDataHelperInstance.sharedInstance.saveContext()
        
        self.UpdateTableleData()
        
        self.IntitializeForHighlightClips()
    }
    func UpdateTableleData()
    {
        if self.highLightClipsArray.count > 1
        {
            self.clipVideoCount.text = "\(self.highLightClipsArray.count) Highlights"
        }
        else
        {
            self.clipVideoCount.text = "\(self.highLightClipsArray.count) Highlight"
        }
        self.tblHighlights.reloadData()
    }
    func configure(action: SwipeAction, with title: String, with imgName: String)
    {
        action.title = title
        action.image = UIImage(named: imgName)
        action.backgroundColor = UIColor.white
        action.textColor = COLOR_FONT_GRAY()
        action.backgroundColor = UIColor(red: 235.0/255.0, green: 235.0/255.0, blue: 235.0/255.0, alpha: 1)
        action.font = UIFont.FontWithSize(FONT_MONTSERRAT_Medium, 12)
        action.transitionDelegate = ScaleTransition.default
    }
}
//MARK:- Collectionview methods
extension VideoDetailsVC :UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let numberOfColumns: CGFloat = 4.0
        let itemWidth = CGFloat((((collectionView.frame.width - 24) - (numberOfColumns - 1)) / numberOfColumns))
        
        return CGSize(width: itemWidth, height: itemWidth * 0.4625)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return self.tagsArray.count
    }
   
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCollectionCell", for: indexPath) as! TagCollectionCell
        
        let numberOfColumns: CGFloat = 4.0
        let itemWidth = CGFloat((((collectionView.frame.width - 24) - (numberOfColumns - 1)) / numberOfColumns) - 4)
        
        cell.hightLightButton.setBackgroundImage(UIImage(named: ""), for: .normal)
        cell.hightLightButton.layer.cornerRadius = itemWidth * 0.4625 / 2
        
        cell.hightLightButton.layer.shadowRadius = 1
        cell.hightLightButton.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        cell.hightLightButton.layer.shadowOpacity = 0.4
        
        let tagItem: TagInfo = self.tagsArray[indexPath.item] as! TagInfo
        
        cell.hightLightButton.setTitle(tagItem.tagName, for: .normal)
        cell.hightLightButton.backgroundColor = UIColor.white
        cell.hightLightButton.addTarget(self, action: #selector(TagButtonClicked(_:)), for: .touchUpInside)
        cell.hightLightButton.tag = indexPath.item
        
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
        let tagItem: TagInfo = self.tagsArray[indexPath.item] as! TagInfo
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
        let tagItem: TagInfo = self.tagsArray[sender.tag] as! TagInfo
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
}
// Trim Videos: https://gist.github.com/acj/b8c5f8eafe0605a38692
