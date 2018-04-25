//
//  HighlightTagsView.swift
//  VideoEditor
//
//  Copyright © 2018 Ark Inc. All rights reserved.
//

import Foundation
import UIKit
import CoreData

protocol HighlightTagViewDelegate: class {
    func cancelButtonClicked(controller: HighlightTagsView)
    func saveButtonClicked(controller: HighlightTagsView)
}


class HighlightTagsView: UIView {
    
    var recVideoClips: RecVideoClips!
    var recordedEvent: RecEventList!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var tagCollectionView: UICollectionView!
    var selectedTeamIndex: Int = 0
    var tagsArray: NSMutableArray = NSMutableArray.init()
    var selectedtagsArray: NSMutableArray = NSMutableArray.init()
    open weak var delegate: HighlightTagViewDelegate?
    
    @IBOutlet weak var viewMainContainer: UIView!
    @IBOutlet weak var lblGameName: UILabel!
    @IBOutlet weak var lblGameDescription: UILabel!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var txtScore: UITextField!
    @IBOutlet weak var btnCancel: UIButton!
    
    @IBOutlet weak var btnHomeTeam: UIButton!
    @IBOutlet weak var btnAwayTeam: UIButton!
    
    func SetDefaultSetting()
    {
        let nib = UINib(nibName: "TagCollectionCell", bundle: nil)
        self.tagCollectionView.register(nib, forCellWithReuseIdentifier: "TagCollectionCell")
        self.btnHomeTeam.setTitle(self.recordedEvent.homeTeamName, for: .normal)
        self.btnAwayTeam.setTitle(self.recordedEvent.awayTeamName, for: .normal)
        
        self.txtScore.text = "\(self.recordedEvent.homeTeamScore)" + " - " + "\(self.recordedEvent.awayTeamScore)"
        
        self.mainView.layer.masksToBounds = true
        self.mainView.layer.cornerRadius = 10.0
        
        viewMainContainer.layer.shadowColor = UIColor.black.cgColor
        viewMainContainer.layer.shadowOpacity = 1
        viewMainContainer.layer.shadowOffset = CGSize.zero
        viewMainContainer.layer.shadowRadius = 10
        viewMainContainer.layer.shadowPath = UIBezierPath(rect: viewMainContainer.bounds).cgPath
//        viewMainContainer.layer.shouldRasterize = true

        if recordedEvent.isDayEvent
        {
            lblGameName.text = "Local A VS Local B"
        }
        else
        {
            lblGameName.text = "\(recordedEvent.homeTeamName!) VS \(recordedEvent.awayTeamName!)"
        }
        
        let myString = "Recorded"
        let myAttribute = [ NSAttributedStringKey.foregroundColor: UIColor.red ]
        let myAttrString = NSMutableAttributedString(string: myString, attributes: myAttribute)
        let recordedDate: Date = recordedEvent.recordingDate!
        
        let dateFormatter: DateFormatter = DateFormatter.init()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        
        let strDate: String = dateFormatter.string(from: recordedDate)
        let strDateAndUser = " \(strDate)"
        
        let myAttributeDate = [ NSAttributedStringKey.foregroundColor: UIColor.gray ]
        let myAttrStringDate = NSAttributedString(string: strDateAndUser, attributes: myAttributeDate)
        myAttrString.append(myAttrStringDate)
        lblGameDescription.attributedText = myAttrString
        
        if recVideoClips.teamName == self.recordedEvent.homeTeamName
        {
            self.selectedTeamIndex = 1
            
            setCornerRadiusAndShadowOnButton(button: btnHomeTeam, backColor: COLOR_APP_THEME())
            btnHomeTeam.setTitleColor(UIColor.white, for: .normal)
            
            setCornerRadiusAndShadowOnButton(button: btnAwayTeam, backColor:  UIColor.white)
            btnAwayTeam.setTitleColor(COLOR_APP_THEME(), for: .normal)
        }
        else if recVideoClips.teamName == self.recordedEvent.awayTeamName
        {
            self.selectedTeamIndex = 1
            
            setCornerRadiusAndShadowOnButton(button: btnAwayTeam, backColor: COLOR_APP_THEME())
            btnAwayTeam.setTitleColor(UIColor.white, for: .normal)
            
            setCornerRadiusAndShadowOnButton(button: btnHomeTeam, backColor:  UIColor.white)
            btnHomeTeam.setTitleColor(COLOR_APP_THEME(), for: .normal)
        }
        else
        {
            setCornerRadiusAndShadowOnButton(button: btnHomeTeam, backColor:  UIColor.white)
            btnHomeTeam.setTitleColor(COLOR_APP_THEME(), for: .normal)
            
            setCornerRadiusAndShadowOnButton(button: btnAwayTeam, backColor:  UIColor.white)
            btnAwayTeam.setTitleColor(COLOR_APP_THEME(), for: .normal)
        }
        
        setCornerRadiusAndShadowOnButton(button: btnCancel, backColor: UIColor.white)
        setCornerRadiusAndShadowOnButton(button: btnSave, backColor: COLOR_APP_THEME())
        self.tagCollectionView.reloadData()
    }
    @IBAction func btnBackClicked(_ sender: Any) {
        if (delegate != nil)
        {
            self.delegate?.cancelButtonClicked(controller: self)
        }
    }
    
    @IBAction func btnSaveClicked(_ sender: Any)
    {
        if (delegate != nil)
        {
            self.delegate?.saveButtonClicked(controller: self)
        }
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
    func SetStateOfTagSaveButton()
    {
        var isEnable: Bool = true
        if self.selectedTeamIndex == 0 && self.selectedtagsArray.count > 0
        {
            isEnable = false
        }
        if isEnable
        {
            setCornerRadiusAndShadowOnButton(button: btnSave, backColor: COLOR_APP_THEME())
            btnSave.setTitleColor(UIColor.white, for: .normal)
        }
        else
        {
            setCornerRadiusAndShadowOnButton(button: btnSave, backColor: UIColor.white)
            btnSave.setTitleColor(COLOR_APP_THEME(), for: .normal)
        }
        btnSave.isEnabled = isEnable
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
}
//MARK:- Collectionview methods
extension HighlightTagsView :UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
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
