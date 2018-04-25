//
//  AudioEditorVC.swift
//  VideoEditor


import UIKit
import Segmentio
import MARKRangeSlider

class AudioEditorVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var viewSegmentControl: UIView!
    var segmentioView: Segmentio!
    @IBOutlet weak var sliderVideo: UISlider!
    @IBOutlet weak var lblStartTime: UILabel!
    @IBOutlet weak var lblEndTime: UILabel!
    @IBOutlet weak var tblAudioEdit: UITableView!
    
    @IBOutlet weak var viewAudioEditContainer: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tblAudioEdit.register(UINib(nibName: "AudioAdjustCell", bundle: nil), forCellReuseIdentifier: "AudioAdjustCell")
        self.tblAudioEdit.register(UINib(nibName: "VolumeCell", bundle: nil), forCellReuseIdentifier: "VolumeCell")
        self.tblAudioEdit.register(UINib(nibName: "SimpleButtonCell", bundle: nil), forCellReuseIdentifier: "SimpleButtonCell")
        self.tblAudioEdit.tableFooterView = UIView()
        self.view.layoutIfNeeded()
        
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width - 60, height: 44))
        let lblTitle = UILabel(frame: CGRect(x: 0, y: 0, width: titleView.frame.size.width, height: 28))
        lblTitle.font = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight(rawValue: 1))
        lblTitle.text = "MILAN VS LAZIO"
        lblTitle.textAlignment = .center
        
        let lblSubTitle = UILabel(frame: CGRect(x: 0, y: 25, width: titleView.frame.size.width, height: 15))
        lblSubTitle.font = UIFont.systemFont(ofSize: 10)
        lblSubTitle.text = "By Studio 11 Dec '17 Rome, Via A. Monti 189"
        lblSubTitle.textAlignment = .center
        lblSubTitle.textColor = UIColor.gray
        
        titleView.addSubview(lblTitle)
        titleView.addSubview(lblSubTitle)
        self.navigationItem.titleView = titleView
        
        
        let segmentioViewRect = viewSegmentControl.bounds
        segmentioView = Segmentio(frame: segmentioViewRect)
        viewSegmentControl.addSubview(segmentioView)

        var contentsArr = [SegmentioItem]()
        
        contentsArr.append(SegmentioBuilder.setupSegmentItem(stroption: "Music", strImage: ""))
        contentsArr.append(SegmentioBuilder.setupSegmentItem(stroption: "Voiceover", strImage: ""))
        contentsArr.append(SegmentioBuilder.setupSegmentItem(stroption: "Highlights", strImage: ""))
        
//        segmentioView.setup(
//            content: contentsArr,
//            style: .onlyLabel,
//            options:nil
//        )
        SegmentioBuilder.buildSegmentioView(
            segmentioView: segmentioView,
            contents: contentsArr,
            segmentioStyle: .onlyLabel,
            totalSegments: 3
        )
        
        sliderVideo.setThumbImage(UIImage(named: "slider_thumb"), for: .normal)
        sliderVideo.setMinimumTrackImage(UIImage(named: "slider_minimum"), for: .normal)
        sliderVideo.setMaximumTrackImage(UIImage(named: "slider_maximum"), for: .normal)
        
        lblStartTime.layer.cornerRadius = lblStartTime.frame.size.height/2
        lblStartTime.layer.masksToBounds = true
        
        self.view.layoutIfNeeded()
    }
    
//    func segmentioOptions(segmentioStyle: SegmentioStyle) -> SegmentioOptions
//    {
//        return SegmentioOptions(
//            indicatorOptions: self.segmentioIndicatorOptions(),
//            horizontalSeparatorOptions: self.segmentioHorizontalSeparatorOptions(),
//            verticalSeparatorOptions: self.segmentioVerticalSeparatorOptions(),
//            labelTextAlignment: .center,
//            labelTextNumberOfLines: 1,
//            segmentStates: self.segmentioStates()
//        )
//    }
//
//    func segmentioIndicatorOptions() -> SegmentioIndicatorOptions {
//        return SegmentioIndicatorOptions(
//            type: .bottom,
//            ratio: 1,
//            height: 5,
//            color: UIColor.blue
//        )
//    }
//
//     func segmentioHorizontalSeparatorOptions() -> SegmentioHorizontalSeparatorOptions {
//        return SegmentioHorizontalSeparatorOptions(
//            type: .topAndBottom,
//            height: 1,
//            color: .clear
//        )
//    }
//
//     func segmentioVerticalSeparatorOptions() -> SegmentioVerticalSeparatorOptions {
//        return SegmentioVerticalSeparatorOptions(
//            ratio: 1,
//            color: UIColor.clear
//        )
//    }
//
//     func segmentioStates() -> SegmentioStates {
//        let font = UIFont.systemFont(ofSize: 13)
//        return SegmentioStates(
//                    defaultState: SegmentioState(
//                        backgroundColor: .clear,
//                        titleFont: font,
//                        titleTextColor: UIColor.lightGray
//                    ),
//                    selectedState: SegmentioState(
//                        backgroundColor: .clear,
//                        titleFont: font,
//                        titleTextColor: UIColor.black
//                    ),
//                    highlightedState: SegmentioState(
//                        backgroundColor: .clear,
//                        titleFont: font,
//                        titleTextColor: UIColor.lightGray
//                    )
//
//        )
//    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//
//
//    func setupSegmentItem(stroption: String, strImage: String) -> SegmentioItem {
//        let tornadoItem = SegmentioItem(
//            title: stroption,
//            image: UIImage(named: strImage)
//        )
//        return tornadoItem
//    }
    
    //MARK:- Tableview methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 7 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "simpleCell", for: indexPath)
            cell.selectionStyle = .none
            return cell
        } else if indexPath.row == 6 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SimpleButtonCell", for: indexPath) as! SimpleButtonCell
            cell.selectionStyle = .none
            return cell
        } else if indexPath.row == 5 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "VolumeCell", for: indexPath) as! VolumeCell
            cell.selectionStyle = .none
            return cell
        } else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "AudioAdjustCell", for: indexPath) as! AudioAdjustCell
            cell.layoutIfNeeded()
            cell.sliderAudioChange.frame = CGRect(x: cell.imgPhoto.frame.maxX, y: 10, width: self.view.frame.size.width - cell.imgPhoto.frame.maxX - cell.btnDelete.frame.size.width - 16, height: cell.viewContainer.frame.size.height - 20)
            cell.sliderAudioChange.leftThumbImage = UIImage(named: "forward_border_arrow")
            cell.sliderAudioChange.rightThumbImage = UIImage(named: "back_border_arrow")
            cell.sliderAudioChange.trackImage = UIImage(named: "slider_left_empty_image")
            cell.sliderAudioChange.rangeImage = UIImage(named: "red_audio_wave")
            
            cell.selectionStyle = .none
            
            return cell
        }
    }

}
