//
//  AllVideosListVC.swift
//  VideoEditor


import UIKit
import Segmentio
import AVFoundation
import AVKit
class AllVideosListVC: BaseVC, UITableViewDelegate, UITableViewDataSource {

    let imageCache = NSCache<NSString, UIImage>()
    @IBOutlet weak var tblAllVideos: UITableView!
    @IBOutlet weak var viewSegmentControl: UIView!
    var segmentioView: Segmentio!
    
    let arrGameNames = ["MILAN VS ROMA", "BRAZIL VS PORT", "BRAZIL VS ROMA", "MILAN VS PORT"]
    var videoRecordingList: NSMutableArray = NSMutableArray.init()

    var screenStatusBarHeight: CGFloat {
        return UIApplication.shared.statusBarFrame.height
    }
    //MARK:- View cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        NSLog("screenStatusBarHeight: %f", self.screenStatusBarHeight)
        self.navigationItem.title = "ALL YOUR VIDEO"
        addTopRightNavigationBarButton(imageName: "search_gray")
        segmentioView = Segmentio()
        segmentioView.selectedSegmentioIndex = 0
        
        tblAllVideos.tableFooterView = UIView()
        tblAllVideos.register(UINib(nibName: "videoListCell", bundle: nil), forCellReuseIdentifier: "videoListCell")
        
        self.view.layoutIfNeeded()
        
        let segmentioViewRect = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width , height: 35)
        segmentioView = Segmentio(frame: segmentioViewRect)
        viewSegmentControl.addSubview(segmentioView)
        
        var contentsArr = [SegmentioItem]()
        contentsArr.append(SegmentioBuilder.setupSegmentItem(stroption: "All", strImage: ""))
        contentsArr.append(SegmentioBuilder.setupSegmentItem(stroption: "Recorded", strImage: ""))
        contentsArr.append(SegmentioBuilder.setupSegmentItem(stroption: "By Studio", strImage: ""))

        SegmentioBuilder.buildSegmentioView(
            segmentioView: segmentioView,
            contents: contentsArr,
            segmentioStyle: .onlyLabel,
            totalSegments: 3
        )
        segmentioView.selectedSegmentioIndex = 0
        
        self.view.layoutIfNeeded()
        
        segmentioView.valueDidChange = { [weak self] _, segmentIndex in
            if segmentIndex == 0
            {
                self?.tblAllVideos.reloadData()
            }
            else if segmentIndex == 1
            {
                self?.tblAllVideos.reloadData()
            }
            else if segmentIndex == 2
            {
                self?.tblAllVideos.reloadData()
            }
            
        }
        
        self.addSwipeGestureOnScrollview()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.FetchVideoInfo()
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addSwipeGestureOnScrollview () {
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(gesture:)))
        swipeRight.delegate = self
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(gesture:)))
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
                if segmentioView.selectedSegmentioIndex < 2 {
                    segmentioView.selectedSegmentioIndex = segmentioView.selectedSegmentioIndex + 1
                }
            case UISwipeGestureRecognizerDirection.up:
                print("Swiped up")
            default:
                break
            }
        }
    }
    
    //MARK:- Button clicks
    override func topRightNavigationBarButtonClicked() {
        let redirectTo = loadVC(strStoryboardId: SB_OTHERS, strVCId: idSearchVC) as! SearchVC
        self.navigationController?.pushViewController(redirectTo, animated: true)
    }
    
//    //MARK:- Segment method
//    func setupSegmentItem(stroption: String, strImage: String) -> SegmentioItem {
//        let tornadoItem = SegmentioItem(
//            title: stroption,
//            image: UIImage(named: strImage)
//        )
//        return tornadoItem
//    }

    func FetchVideoInfo()
    {
        let SubCategoryArray1: NSArray =         CoreDataHelperInstance.sharedInstance.fetchDataFrom(entityName1: "RecEventList", sorting: false, predicate: nil, sortKey: "recordingDate")! as NSArray

        if SubCategoryArray1 != nil
        {
            self.videoRecordingList = NSMutableArray.init(array: SubCategoryArray1)
        }
        
        DispatchQueue.main.async
        {
            self.tblAllVideos.reloadData()
        }
    }
    func generateThumbnail(url: URL) -> UIImage? {
        do {
            let asset = AVURLAsset(url: url)
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true
            
            let time = kCMTimeZero

            imageGenerator.generateCGImagesAsynchronously(forTimes: [NSValue.init(time: time)], completionHandler: { (requestedTime: CMTime, thumbnail: CGImage?, actualTime: CMTime, result: AVAssetImageGeneratorResult, error: NSError?) in
                
                } as! AVAssetImageGeneratorCompletionHandler)
            let cgImage = try imageGenerator.copyCGImage(at: kCMTimeZero, actualTime: nil)
            
            return UIImage(cgImage: cgImage)
        } catch {
            print(error.localizedDescription)
            
            return nil
        }
    }
//    func getThumbnailFrom(path: URL) -> UIImage? {
//
//        do {
//
//            let asset = AVURLAsset(url: path , options: nil)
//            let imgGenerator = AVAssetImageGenerator(asset: asset)
//            imgGenerator.appliesPreferredTrackTransform = true
//            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil)
//            let thumbnail = UIImage(cgImage: cgImage)
//
//            return thumbnail
//
//        } catch let error {
//
//            print("*** Error generating thumbnail: \(error.localizedDescription)")
//            return nil
//
//        }
//
//    }
//
    func sizeForLocalFilePath(filePath:String) -> UInt64 {
        do {
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: filePath)
            if let fileSize = fileAttributes[FileAttributeKey.size]  {
                return (fileSize as! NSNumber).uint64Value
            } else {
                print("Failed to get a size attribute from path: \(filePath)")
            }
        } catch {
            print("Failed to get file attributes for local path: \(filePath) with error: \(error)")
        }
        return 0
    }
    func covertToFileString(with size: UInt64) -> String {
        var convertedValue: Double = Double(size)
        var multiplyFactor = 0
        let tokens = ["bytes", "KB", "MB", "GB", "TB", "PB",  "EB",  "ZB", "YB"]
        while convertedValue > 1024 {
            convertedValue /= 1024
            multiplyFactor += 1
        }
        return String(format: "%4.2f %@", convertedValue, tokens[multiplyFactor])
    }
    func timeFormatted(totalSeconds: Float64) -> String {
        let timeInterval: TimeInterval = totalSeconds
        let seconds: Int = lround(timeInterval)
        var hour: Int = 0
        var minute: Int = Int(seconds/60)
        let second: Int = seconds % 60
        if minute > 59 {
            hour = minute / 60
            minute = minute % 60
            return String(format: "%02d:%02d:%02d", hour, minute, second)
        }
        else {
            return String(format: "%02d:%02d", minute, second)
        }
    }
    //MARK:- Tableview methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if segmentioView != nil
        {
            if segmentioView.selectedSegmentioIndex == 2
            {
                return 0
            }
        }
        
        return self.videoRecordingList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if isIpad()
        {
            return 350
        }
        return 230
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let devicemodel = UIDevice.current.model
        
        //        let cell = tableView.dequeueReusableCell(withIdentifier: "simpleCell", for: indexPath)
        //        cell.selectionStyle = .none
        //        cell.textLabel?.text = "Record your own videos."
        //        return cell
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "videoListCell", for: indexPath) as! videoListCell
        cell.selectionStyle = .none
        
        cell.btnDelete.addTarget(self, action: #selector(DeleteVideoFromDB(_:)), for: .touchUpInside)
        cell.btnDelete.tag = indexPath.row

        let recordedEvent: RecEventList = self.videoRecordingList.object(at: indexPath.row) as! RecEventList
        
        cell.lblGameName.text = "sasas"
        cell.fb_live.isHidden = true
        
        //        if ((indexPath.row%2) == 0 && segmentioView.selectedSegmentioIndex == 0) ||  segmentioView.selectedSegmentioIndex == 1
        //        {
        let myString = "Recorded"
        
        let myAttribute = [ NSAttributedStringKey.foregroundColor: UIColor.red ]
        let myAttrString = NSMutableAttributedString(string: myString, attributes: myAttribute)
        
        let recordedDate: Date = recordedEvent.recordingDate!
        
        let dateFormatter: DateFormatter = DateFormatter.init()
        
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        
        let strDate: String = dateFormatter.string(from: recordedDate)
        
        let strDateAndUser = " \(strDate)"
        let myAttributeDate = [ NSAttributedStringKey.foregroundColor: UIColor.white ]
        let myAttrStringDate = NSAttributedString(string: strDateAndUser, attributes: myAttributeDate)
        myAttrString.append(myAttrStringDate)
        // set attributed text on a UILabel
        cell.lblGameDescription.attributedText = myAttrString
        cell.lblScore.isHidden = false
        
        let documentsPath = recordedEvent.videoFolderID as! String
        
        var outputFilePath = NSTemporaryDirectory() as String
        
        outputFilePath = outputFilePath + "\(documentsPath)" + "/mynew.mov"
        
        let asset = AVURLAsset.init(url: URL.init(fileURLWithPath: outputFilePath)) // AVURLAsset.init(url: outputFileURL as URL) in swift 3
        // get the time in seconds
        let durationInSeconds = asset.duration.seconds
        cell.btnVideoLength.setTitle(self.timeFormatted(totalSeconds: durationInSeconds), for: .normal)
        
        let videoSize = self.sizeForLocalFilePath(filePath: outputFilePath)
        if videoSize > 0
        {
            cell.btnVideoSize.setTitle(self.covertToFileString(with: videoSize), for: .normal)
        }
        else
        {
            cell.btnVideoSize.setTitle("0 MB", for: .normal)
        }
        if recordedEvent.isDayEvent
        {
            cell.lblSeriesName.text = "Day Series"
            cell.lblGameName.text = "Local A VS Local B"
            cell.lblScore.text = ""
            cell.deviceImage.image = UIImage(named: "recorded_by_phone")
            cell.deviceModel.text = devicemodel
            
            
        }
        else
        {
            cell.lblGameName.text = "\(recordedEvent.homeTeamName!) VS \(recordedEvent.awayTeamName!)"
            cell.lblSeriesName.text = recordedEvent.eventName
            
            cell.lblScore.text = "\(recordedEvent.homeTeamScore)" + " - " + "\(recordedEvent.awayTeamScore)"
            cell.deviceImage.image = UIImage(named: "recorded_by_phone")
            cell.deviceModel.text = devicemodel
            if recordedEvent.fbLive == true {
                cell.fb_live.isHidden = false
            }
            
        }
        
        if let cachedImage = imageCache.object(forKey: outputFilePath as NSString)
        {
            cell.imgPhoto.image = cachedImage
//            print("cachedImage")
        }
        else
        {
            cell.generateThumbnail(url: URL.init(fileURLWithPath: outputFilePath), cacheStorage: imageCache as! NSCache<AnyObject, AnyObject>)
//            print("newimage")
        }
//        if let track = AVAsset.init(url: URL.init(fileURLWithPath: outputFilePath)).tracks(withMediaType: .video).first
//        {
//            let size1 = track.naturalSize.applying(track.preferredTransform)
//            print(size1)
//        }
//        else
//        {
//
//        }
        

        var presetValue: String = Constants.HDQuality
        if recordedEvent.videoPreset == Constants.HDQuality
        {
            presetValue = "HD"
        }
        else if recordedEvent.videoPreset == Constants.FHDQuality
        {
            presetValue = "Full HD"
        }
        else if recordedEvent.videoPreset == Constants.UltraQuality
        {
            presetValue = "Ultra HD"
        }
        cell.btnPresetValue.setTitle(presetValue, for: .normal)
//        cell.imgPhoto.image = self.generateThumbnail(url: URL.init(fileURLWithPath: outputFilePath))
        //        }
        //        else
        //        {
        //            let myString = "By Studio"
        //            let myAttribute = [ NSAttributedStringKey.foregroundColor: COLOR_APP_THEME() ]
        //            let myAttrString = NSMutableAttributedString(string: myString, attributes: myAttribute)
        //
        //            let strDateAndUser = " 12 Dec '17 Rome, Via A, Monti 189"
        //            let myAttributeDate = [ NSAttributedStringKey.foregroundColor: UIColor.white ]
        //            let myAttrStringDate = NSAttributedString(string: strDateAndUser, attributes: myAttributeDate)
        //            myAttrString.append(myAttrStringDate)
        //            // set attributed text on a UILabel
        //            cell.lblGameDescription.attributedText = myAttrString
        //            cell.lblScore.isHidden = true
        //        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let redirectTo = loadVC(strStoryboardId: SB_MAIN, strVCId: idVideoDetailsVC) as! VideoDetailsVC
//        if ((indexPath.row%2) == 0 && segmentioView.selectedSegmentioIndex == 0) ||  segmentioView.selectedSegmentioIndex == 1 {
//            redirectTo.strScreenType = "Recorded"
//        } else {
//            redirectTo.strScreenType = "By Studio"
//        }
        redirectTo.videoIndex = indexPath.row + 1
        redirectTo.strScreenType = "Recorded"
        redirectTo.strGameName = "sas"//arrGameNames[indexPath.row]
        redirectTo.recordedEvent = self.videoRecordingList.object(at: indexPath.row) as! RecEventList
        self.navigationController?.pushViewController(redirectTo, animated: true)
    }
    @objc func DeleteVideoFromDB(_ sender: UIButton)
    {
        //delete clicked
        let index = sender.tag
        let myalert = UIAlertController(title: "Alert", message: "Are you sure you want to delete this Video?", preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelAction = UIAlertAction(title: "NO", style: .cancel) { (action:UIAlertAction!) in
            
        }
        let oKAction = UIAlertAction(title: "Yes", style: .default) { (action:UIAlertAction!) in
            
            let recordedEvent: RecEventList = self.videoRecordingList.object(at: index) as! RecEventList

            self.videoRecordingList.remove(recordedEvent)
            
//            self.tblAllVideos.deleteRows(at: [IndexPath.init(row: index, section: 0)], with: .none)
            
            let fullVideoPath: String = APP_DELEGATE.FetchFullVideoPath(videoFolderName: recordedEvent.videoFolderID!)
            
            if FileManager.default.fileExists(atPath: fullVideoPath as String)
            {
                do
                {
                    try FileManager.default.removeItem(atPath: fullVideoPath)
                }
                catch
                {
                    
                }
            }
            CoreDataHelperInstance.sharedInstance.manageObjectContext.delete(recordedEvent)
            CoreDataHelperInstance.sharedInstance.saveContext()
            
            let outputFilePath = fullVideoPath + "/mynew.mov"

            if let cachedImage = self.imageCache.object(forKey: outputFilePath as NSString)
            {
                self.imageCache.removeObject(forKey: outputFilePath as NSString)
            }
            DispatchQueue.main.async {
                self.tblAllVideos.reloadData()
            }
            
        }
        
        myalert.addAction(cancelAction)
        myalert.addAction(oKAction)
        
        self.present(myalert, animated: true)
        
        return
        
    }
}
