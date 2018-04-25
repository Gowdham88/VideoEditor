//
//  TagManagementVC.swift
//  VideoEditor
//
//  Copyright © 2018 Ark Inc. All rights reserved.
//

import Foundation
import CoreData
import MobileCoreServices

class TagManagementVC: BaseVC, UITableViewDelegate, UITableViewDataSource,DragableTableDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate
{
    @IBOutlet weak var settingTable: UITableView!
    var dateDropDown: DropDown!
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var newTagView: UIView!
    
    @IBOutlet weak var nameTagView: UIView!
    @IBOutlet weak var secondTagView: UIView!
    
    var selectedIndexPath: IndexPath!
    var editTagInfo: TagInfo!
    
    var indexSelectedForEdit = -1
    let customTagsList = ["Dribbling", "Goal", "Off side", "Penalty", "Red card", "Saved", "Shoot","Stake","Yellow card"]
    
    let tagNotRecordingNames = ["Start/End game", "Yellow card"]
    
    let allCustomTagList = ["Dribbling", "Goal", "Off side", "Penalty", "Red card", "Saved", "Shoot","Stake","Yellow card"]

    var customTagImageList = ["dribbling_image","goalTag","offsidetag","penaltytag","red-cardtag","savedtag","shoottag","staketag","yellow-cardtag"]
    
    let tagNotRecordingImages = ["start-end-gametag","yellow-cardtag"]
    
    var tagsRecordingList: NSMutableArray = NSMutableArray.init()
    
    var tagsNotRecordingList: NSMutableArray = NSMutableArray.init()

    @IBOutlet weak var tagEditTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var tagEditView: UIView!
    
    @IBOutlet weak var customTagEditTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var customTagEditView: UIView!
    
    @IBOutlet weak var tagNameField: UITextField!
    @IBOutlet weak var tagSecondField: UITextField!
    @IBOutlet weak var addTagButton: UIButton!
    @IBOutlet weak var tagViewLabel: UILabel!
    
    @IBOutlet weak var secondBtn1: UIButton!
    @IBOutlet weak var secondBtn2: UIButton!
    @IBOutlet weak var secondBtn3: UIButton!
    @IBOutlet weak var secondBtn4: UIButton!
    @IBOutlet weak var secondBtn5: UIButton!
    @IBOutlet weak var secondBtn6: UIButton!
    
    @IBOutlet weak var newTagImageView: UIImageView!
    @IBOutlet weak var newTagImageButton: UIButton!
    let picker = UIImagePickerController()
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.navigationItem.title = "SETTING TAGS"
        addTopLeftBackButton()
        self.picker.delegate = self
//        addTopRightNavigationBarButton(imageName: "add-new-tag")
        
        let image = UIImage(named: "add-new-tag")?.withRenderingMode(.alwaysOriginal)
        let item1 = UIBarButtonItem.init(image: image, style: .plain, target: self, action: #selector(RightButtonClicked))
//        let item1 = UIBarButtonItem.init(barButtonSystemItem: .add, target: self, action: #selector(RightButtonClicke))
        
        self.navigationItem.setRightBarButtonItems([item1], animated: true)

        self.settingTable.register(UINib(nibName: "TagManagementCell", bundle: nil), forCellReuseIdentifier: "TagManagementCell")
        
//        self.settingTable.register(UINib(nibName: "TagManageHeaderCell", bundle: nil), forCellReuseIdentifier: "TagManageHeaderCell")
        
        self.settingTable.register(UINib(nibName: "TagManageHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "TagManageHeaderView")
        self.settingTable.tableFooterView = UIView()
        
        self.settingTable.separatorStyle = .none
        self.settingTable.dragable = true
        self.settingTable.dragableDelegate = self
        
        tagEditView.isHidden = true
        customTagEditView.isHidden = true
        
        tagEditView.layer.shadowRadius = 2
        tagEditView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        tagEditView.layer.shadowOpacity = 1
        tagEditView.layer.shadowColor = UIColor.lightGray.cgColor
        
        customTagEditView.layer.shadowRadius = 2
        customTagEditView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        customTagEditView.layer.shadowOpacity = 1
        customTagEditView.layer.shadowColor = UIColor.lightGray.cgColor
        
        newTagView.layer.shadowRadius = 2
        newTagView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        newTagView.layer.shadowOpacity = 1
        newTagView.layer.shadowColor = UIColor.lightGray.cgColor
        newTagView.layer.cornerRadius = 10.0
        newTagView.layer.masksToBounds = true
        
        nameTagView.layer.cornerRadius = 10.0
        nameTagView.layer.masksToBounds = true
        nameTagView.layer.borderWidth = 1.0
        nameTagView.layer.borderColor = UIColor.lightGray.cgColor
        
        secondTagView.layer.cornerRadius = 10.0
        secondTagView.layer.masksToBounds = true
        secondTagView.layer.borderWidth = 1.0
        secondTagView.layer.borderColor = UIColor.lightGray.cgColor
        
        self.dateDropDown = DropDown.init()
        self.dateDropDown.separatorColor = UIColor.lightGray
        self.mainView.isHidden = true
    }
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        self.FetchTagInfoFromDB()
    }
    override func topRightNavigationBarButtonClicked()
    {
        self.RightButtonClicked()
    }
    @objc func RightButtonClicked() // Add New Tag
    {
        var isProductPurchased: Bool = false
        if UserDefaults.standard.value(forKey: Constants.kCustomTag_PurchaseKey) != nil
        {
            let value: String = UserDefaults.standard.value(forKey: Constants.kCustomTag_PurchaseKey) as! String
            
            if value == "YES"
            {
                isProductPurchased = true
            }
        }
//        isProductPurchased = true
        if !isProductPurchased
        {
            APP_DELEGATE.displayMessageAlertWithMessage(alertMessage: "You have to purchase Custom Tag product to add Custom Tag. You can purchase it from Home Page.", withTitle: "Alert")
            return
        }
        editTagInfo = nil
        self.newTagImageView.image = UIImage.init(named: "placeHolderTag")
        self.newTagImageButton.isEnabled = true
        self.tagNameField.text = ""
        self.tagSecondField.text = ""
        self.addTagButton.setTitle("Add", for: .normal)
        self.tagViewLabel.text = "Add Custom Tag"
        UIView.transition(with: self.mainView, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.mainView.isHidden = false
        })
    }
    func OpenNewTagViewInEditMode() // When Edit Any Tag
    {
        if customTagsList.contains(editTagInfo.tagName!)
        {
            self.newTagImageView.image = UIImage.init(named: "placeHolderTag")
            self.newTagImageButton.isEnabled = false
        }
        else if editTagInfo.tagImageData != nil
        {
            self.newTagImageView.image = UIImage.init(data: editTagInfo.tagImageData!)
            self.newTagImageButton.isEnabled = true
        }
        
        self.tagNameField.text = editTagInfo.tagName
        self.tagSecondField.text = "\(editTagInfo.tagSecondValue)"
        self.addTagButton.setTitle("Update", for: .normal)
        self.tagViewLabel.text = "Edit Custom Tag"
        UIView.transition(with: self.mainView, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.mainView.isHidden = false
        })
    }
    @IBAction func CancelFromDropdown(_ sender: UIButton)
    {
        
        UIView.transition(with: self.mainView, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.mainView.isHidden = true
        })
    }
    @IBAction func AddNewTag(_ sender: UIButton)
    {
        if (editTagInfo != nil) // Edit Mode
        {
            let arrayIndex = selectedIndexPath.row - 1
            editTagInfo.tagName = self.tagNameField.text
            
            if customTagsList.contains(self.tagNameField.text!)
            {
                editTagInfo.tagImageName = customTagImageList[customTagsList.index(of: self.tagNameField.text!)!]
                editTagInfo.tagImageData = nil
            }
            else
            {
                if self.newTagImageView.image != UIImage.init(named: "placeHolderTag")
                {
                    let imageData: NSData = UIImageJPEGRepresentation(self.newTagImageView.image!, 0.5)! as NSData
                    editTagInfo.tagImageData = imageData as Data
                }
                else
                {
                    editTagInfo.tagImageData = nil
                    editTagInfo.tagImageName = nil
                }
                
            }
            let strValue: NSString = self.tagSecondField.text! as NSString
            
            editTagInfo.tagSecondValue = Int64(strValue.intValue)
//            editTagInfo.isPersonalTag = true
            
            CoreDataHelperInstance.sharedInstance.saveContext()
            
            self.CancelFromDropdown(sender)
            
            if editTagInfo.isRecordingPageTag
            {
                self.tagsRecordingList.replaceObject(at: arrayIndex, with: editTagInfo)
            }
            else
            {
                self.tagsNotRecordingList.replaceObject(at: arrayIndex, with: editTagInfo)
            }
            settingTable.reloadRows(at: [selectedIndexPath], with: .none)
        }
        else
        {
            if self.tagNameField.text == ""
            {
                APP_DELEGATE.displayMessageAlertWithMessage(alertMessage: "Please select tag name.", withTitle: "Alert")
                return
            }
            else if self.tagSecondField.text == ""
            {
                APP_DELEGATE.displayMessageAlertWithMessage(alertMessage: "Please select tag seconds.", withTitle: "Alert")
                return
            }
            
            let tagObj: TagInfo = (NSEntityDescription.insertNewObject(forEntityName: "TagInfo", into: CoreDataHelperInstance.sharedInstance.manageObjectContext) as? TagInfo)!
            
            tagObj.tagName = self.tagNameField.text
            if customTagsList.contains(self.tagNameField.text!)
            {
                tagObj.tagImageName = customTagImageList[customTagsList.index(of: self.tagNameField.text!)!]
                tagObj.tagImageData = nil
            }
            else
            {
                if self.newTagImageView.image != UIImage.init(named: "placeHolderTag")
                {
                    let imageData: NSData = UIImageJPEGRepresentation(self.newTagImageView.image!, 0.5)! as NSData
                    tagObj.tagImageData = imageData as Data
                }
                else
                {
                    tagObj.tagImageData = nil
                    tagObj.tagImageName = nil
                }
            }

            let strValue: NSString = self.tagSecondField.text! as NSString
            
            tagObj.tagSecondValue = Int64(strValue.intValue)
            
            tagObj.tagIndex = Int64(self.tagsNotRecordingList.count)
            
            tagObj.isPersonalTag = true
            tagObj.isRecordingPageTag = false
            
            CoreDataHelperInstance.sharedInstance.saveContext()
            
            self.CancelFromDropdown(sender)
            
            self.tagsNotRecordingList.add(tagObj)
            
            settingTable.insertRows(at: [IndexPath.init(row: self.tagsNotRecordingList.count, section: 1)], with: .none)
        }
    }
    @IBAction func ButtonClickedFromEditView(_ sender: UIButton)
    {
        var category: TagInfo!
        let arrayIndex = selectedIndexPath.row - 1
        if selectedIndexPath.section == 0
        {
            category = self.tagsRecordingList[arrayIndex] as! TagInfo
        }
        else
        {
            category = self.tagsNotRecordingList[arrayIndex] as! TagInfo
        }
        var selectedSeconds: Int64 = 0
        if sender.tag == 0
        {
            selectedSeconds = 30
        }
        else if sender.tag == 1
        {
            selectedSeconds = 15
        }
        else if sender.tag == 2
        {
            selectedSeconds = 10
        }
        else if sender.tag == 3
        {
            //edit clicked
            tagEditView.isHidden = true
            customTagEditView.isHidden = true
            editTagInfo = category
            self.OpenNewTagViewInEditMode()
            
            return
        }
        else if sender.tag == 4
        {
            //delete clicked
            
            if category.tagToRecording != nil
            {
                let array = NSArray.init(array: (category.tagToRecording?.allObjects)!)
                if array.count > 0
                {
                    APP_DELEGATE.displayMessageAlertWithMessage(alertMessage: "This tag is already in use, you can not delete it.", withTitle: "Alert")
                    return
                }
            }
            
            let myalert = UIAlertController(title: "Alert", message: "Are you sure you want to delete this custom tag?", preferredStyle: UIAlertControllerStyle.alert)
            
            let cancelAction = UIAlertAction(title: "NO", style: .cancel) { (action:UIAlertAction!) in
                
            }
            let oKAction = UIAlertAction(title: "Yes", style: .default) { (action:UIAlertAction!) in
                
                if self.selectedIndexPath.section == 0
                {
                    self.tagsRecordingList.remove(category)
                }
                else
                {
                    self.tagsNotRecordingList.remove(category)
                }
                CoreDataHelperInstance.sharedInstance.manageObjectContext.delete(category)
                CoreDataHelperInstance.sharedInstance.saveContext()
                
                self.tagEditView.isHidden = true
                self.customTagEditView.isHidden = true
                self.settingTable.deleteRows(at: [self.selectedIndexPath], with: .none)
            }
            
            myalert.addAction(cancelAction)
            myalert.addAction(oKAction)
            
            self.present(myalert, animated: true)
            
            return
            
        }
        
        category.tagSecondValue = selectedSeconds
        if selectedIndexPath.section == 0
        {
            self.tagsRecordingList.replaceObject(at: arrayIndex, with: category)
        }
        else
        {
            self.tagsNotRecordingList.replaceObject(at: arrayIndex, with: category)
        }
        
        CoreDataHelperInstance.sharedInstance.saveContext()
        
        tagEditView.isHidden = true
        customTagEditView.isHidden = true
        settingTable.reloadRows(at: [selectedIndexPath], with: .none)
    }
    
    @objc func tagEditMoreButtonClicked(_ sender: CustomButton)
    {
        let buttonPosition = sender.convert(CGPoint.init(x: 0, y: 0), to: settingTable)
        let indexPath = settingTable.indexPathForRow(at:buttonPosition)
        selectedIndexPath = IndexPath.init(row: (indexPath?.row)!, section: (indexPath?.section)!)
        
        let cellRect = settingTable.rectForRow(at: selectedIndexPath)
        
      //  let button = sender
        indexSelectedForEdit = selectedIndexPath.row
        
        let arrayIndex = selectedIndexPath.row - 1
        if tagEditView.isHidden == false
        {
            tagEditView.isHidden = true
            return
        }
        if customTagEditView.isHidden == false
        {
            customTagEditView.isHidden = true
            return
        }
        var yPosition: CGFloat = 0
        if selectedIndexPath.section == 1 && arrayIndex == self.tagsNotRecordingList.count - 1
        {
            yPosition = (cellRect.origin.y - settingTable.contentOffset.y) + 15
        }
        else
        {
            yPosition = (cellRect.origin.y - settingTable.contentOffset.y) + 45
        }
        var category: TagInfo!
        
        if selectedIndexPath.section == 0
        {
            category = self.tagsRecordingList[arrayIndex] as! TagInfo
        }
        else
        {
            category = self.tagsNotRecordingList[arrayIndex] as! TagInfo
        }
        if category.isPersonalTag
        {
            if customTagEditView.isHidden == true
            {
                customTagEditView.isHidden = false
            }
            else
            {
                customTagEditView.isHidden = true
            }
            self.secondBtn4.setTitleColor(UIColor.darkGray, for: .normal)
            self.secondBtn5.setTitleColor(UIColor.darkGray, for: .normal)
            self.secondBtn6.setTitleColor(UIColor.darkGray, for: .normal)
            if category.tagSecondValue == 30
            {
                self.secondBtn4.setTitleColor(UIColor.init(hex: "00A5FB"), for: .normal)
            }
            if category.tagSecondValue == 15
            {
                self.secondBtn5.setTitleColor(UIColor.init(hex: "00A5FB"), for: .normal)
            }
            if category.tagSecondValue == 10
            {
                self.secondBtn6.setTitleColor(UIColor.init(hex: "00A5FB"), for: .normal)
            }
            customTagEditTopConstraint.constant = yPosition
        }
        else
        {
            if tagEditView.isHidden == true
            {
                tagEditView.isHidden = false
            }
            else
            {
                tagEditView.isHidden = true
            }
            self.secondBtn1.setTitleColor(UIColor.darkGray, for: .normal)
            self.secondBtn2.setTitleColor(UIColor.darkGray, for: .normal)
            self.secondBtn3.setTitleColor(UIColor.darkGray, for: .normal)
            self.secondBtn1.titleLabel?.tintColor = UIColor.red
//            self.secondBtn1.setTitleColor(UIColor.red, for: .normal)
            
            if category.tagSecondValue == 30
            {
                self.secondBtn1.setTitleColor(UIColor.init(hex: "00A5FB"), for: .normal)
            }
            if category.tagSecondValue == 15
            {
                self.secondBtn2.setTitleColor(UIColor.init(hex: "00A5FB"), for: .normal)
            }
            if category.tagSecondValue == 10
            {
                self.secondBtn3.setTitleColor(UIColor.init(hex: "00A5FB"), for: .normal)
            }
            tagEditTopConstraint.constant = yPosition

        }
        
        //        settingTable.reloadData()
    }
    
    func FetchTagInfoFromDB()
    {
        var filterPredicate = NSPredicate(format: "isRecordingPageTag = true")
        
        let SubCategoryArray1: NSArray = CoreDataHelperInstance.sharedInstance.fetchDataFrom(entityName1: "TagInfo", sorting: true, predicate: filterPredicate)! as NSArray
        if SubCategoryArray1 != nil
        {
            self.tagsRecordingList = NSMutableArray.init(array: SubCategoryArray1)
        }
        
        filterPredicate = NSPredicate(format: "isRecordingPageTag = false")
        
        let SubCategoryArray2: NSArray = CoreDataHelperInstance.sharedInstance.fetchDataFrom(entityName1: "TagInfo", sorting: true, predicate: filterPredicate)! as NSArray
        if SubCategoryArray2 != nil
        {
            self.tagsNotRecordingList = NSMutableArray.init(array: SubCategoryArray2)
        }

        DispatchQueue.main.async {
            self.settingTable.reloadData()
        }
    }
    
    @IBAction func DropdownClicked(_ sender: UIButton)
    {
        self.dateDropDown.backgroundColor = UIColor.white
        self.view.endEditing(true)
        if sender.tag == 1
        {
            let tagNameArray: NSMutableArray = NSMutableArray.init()
            if self.tagsRecordingList.count > 0
            {
                tagNameArray.addObjects(from: self.tagsRecordingList.value(forKeyPath: "tagName") as! [Any])
            }
            if self.tagsNotRecordingList.count > 0
            {
                tagNameArray.addObjects(from: self.tagsNotRecordingList.value(forKeyPath: "tagName") as! [Any])
            }
            
            if (editTagInfo != nil)
            {
                if tagNameArray.contains(editTagInfo.tagName as Any)
                {
                    tagNameArray.remove(editTagInfo.tagName as Any)
                }
            }
            let array1 = Array(Set(allCustomTagList).subtracting(tagNameArray as! Array))
            
            self.dateDropDown.dataSource = array1
        }
        else
        {
            self.dateDropDown.dataSource = ["10", "15","30"]
        }
        
        self.dateDropDown.selectedStr = sender.titleLabel?.text
        if sender.tag == 1
        {
            self.dateDropDown.anchorView = self.nameTagView
        }
        else
        {
            self.dateDropDown.anchorView = self.secondTagView
        }
        
        self.dateDropDown.show()
        self.dateDropDown.selectionAction = { [weak self] (index, item) in
            
            if sender.tag == 1
            {
                self?.tagNameField.text = item
                
                self?.newTagImageView.image = UIImage.init(named: "placeHolderTag")
                self?.newTagImageButton.isEnabled = false
            }
            else
            {
                self?.tagSecondField.text = item
            }
        }
    }
    @IBAction func TagImageSelection(_ sender: UIButton)
    {
        self.picker.mediaTypes = [kUTTypeImage as String]
        let actionSheet = UIAlertController(title: "Select Tag Image", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let fromCamera = UIAlertAction(title: "Camera", style: .default) { (action:UIAlertAction!) in
            
            self.picker.delegate = self
            self.picker.allowsEditing = false
            self.picker.sourceType = .camera
//            self.picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .camera)!
            self.present(self.picker, animated: true, completion: nil)
        }
        
        let fromgalary = UIAlertAction(title: "Photo Library", style: .default) { (action:UIAlertAction!) in
            self.picker.delegate = self
            self.picker.allowsEditing = false
            self.picker.sourceType = .photoLibrary
            self.present(self.picker, animated: true, completion: nil)
        }
        
        let savedAlbum = UIAlertAction(title: "Saved Photo Album", style: .default) { (action:UIAlertAction!) in
            self.picker.delegate = self
            self.picker.allowsEditing = false
            self.picker.sourceType = .savedPhotosAlbum
            self.present(self.picker, animated: true, completion: nil)
        }
        
        actionSheet.addAction(cancelAction)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera)
        {
            actionSheet.addAction(fromCamera)
        }
        actionSheet.addAction(fromgalary)
        actionSheet.addAction(savedAlbum)
        
        if self.newTagImageView.image != UIImage.init(named: "placeHolderTag")
        {
            let removePhoto = UIAlertAction(title: "Remove Photo", style: .default) { (action:UIAlertAction!) in
                self.newTagImageView.image = UIImage.init(named: "placeHolderTag")
            }
            actionSheet.addAction(removePhoto)
        }
        actionSheet.popoverPresentationController?.sourceView = sender // works for both iPhone & iPad
        self.present(actionSheet, animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        dismiss(animated: true, completion: nil)
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])

    {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage //2
        self.newTagImageView.image = image
        dismiss(animated:true, completion: nil) //5
        
        DispatchQueue.main.async {
            
            
        }
    }
    //MARK:- TextField methods
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        if textField.tag == 0
        {
            if customTagsList.contains(self.tagNameField.text!)
            {
                self.newTagImageView.image = UIImage.init(named: "placeHolderTag")
                self.newTagImageButton.isEnabled = false
            }
            else
            {
                self.newTagImageButton.isEnabled = true
            }
        }
        else if textField.tag == 1
        {
            if textField.text == ""
            {
                return
            }
            let testString = textField.text
            let badCharacters = CharacterSet.init(charactersIn: "0123456789").inverted
            var isProperValue: Bool = false
            if testString?.rangeOfCharacter(from: badCharacters) == nil
            {
              //  print("Test string was a number")
                
                let myInt: Int! = Int(textField.text!)
                if myInt >= 5 && myInt <= 30
                {
                    isProperValue = true
                }
            }
            else
            {
                isProperValue = false
                //print("Test string contained non-digit characters.")
            }
            if !isProperValue
            {
                let myalert = UIAlertController(title: "Alert", message: "Tag Second value must be between 5 to 30 and should not contain decimal value.", preferredStyle: UIAlertControllerStyle.alert)
                
                let oKAction = UIAlertAction(title: "OK", style: .cancel) { (action:UIAlertAction!) in
                    
                    textField.becomeFirstResponder()
                    
                }
                
                myalert.addAction(oKAction)
                self.present(myalert, animated: true)
            }
        }
        
    }
    

    //MARK:- Tableview methods
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
//        return nil
        let tagHeaderView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "TagManageHeaderView") as! TagManageHeaderView
        
        if section == 0
        {
            tagHeaderView.leftLabel.text = "Tags in recording page"
            tagHeaderView.rightLabel.text = "Note more than 15 tags"
        }
        else
        {
            tagHeaderView.leftLabel.text = "Not in recording page"
            tagHeaderView.rightLabel.text = ""
        }
        
        return tagHeaderView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 30
    }
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0
        {
            return self.tagsRecordingList.count + 1
        }
        else
        {
            return self.tagsNotRecordingList.count + 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if indexPath.row == 0
        {
            if self.tagsRecordingList.count == 0 && indexPath.section == 0
            {
                return 10
            }
            else if self.tagsNotRecordingList.count == 0 && indexPath.section == 1
            {
                return 10
            }
            return 1
        }
        return 45
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if indexPath.row == 0
        {
            var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
            
            if !(cell != nil) {
                cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "Cell")
            }

            cell?.backgroundColor = UIColor.clear
            
            return cell!
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TagManagementCell", for: indexPath) as! TagManagementCell
        cell.layoutIfNeeded()
        
        cell.btnMore.addTarget(self, action: #selector(tagEditMoreButtonClicked(_:)), for: .touchUpInside)
        cell.btnMore.tag = indexPath.row
        cell.btnMore.sectionNumber = indexPath.section
        cell.contentView.backgroundColor = UIColor.white
        let arrayIndex = indexPath.row - 1
        var category: TagInfo!
        if indexPath.section == 0
        {
            category = self.tagsRecordingList[arrayIndex] as! TagInfo
        }
        else
        {
            category = self.tagsNotRecordingList[arrayIndex] as! TagInfo
        }
        cell.tagLabel.text = category.tagName
        
        if category.tagImageData != nil
        {
            cell.tagImageView.image = UIImage.init(data: category.tagImageData!)
        }
        else if category.tagImageName == nil
        {
            cell.tagImageView.image = UIImage.init(named: "personalTagImage")
        }
        else
        {
            cell.tagImageView.image = UIImage.init(named: category.tagImageName!)
        }
        
        cell.secondLabel.text = "<<\(category.tagSecondValue)"
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//            indexSelectedForEdit = indexPath.row
        tagEditView.isHidden = true
//            settingTable.reloadData()
        customTagEditView.isHidden = true
    }
    
    // MARK: - DragableTableDelegate
    func tableView(_ tableView: UITableView, canDragCellTo indexPath: IndexPath) -> Bool {
        if indexPath.section == 0
        {
            if self.tagsRecordingList.count >= 15
            {
                return false
            }
        }
        if indexPath.row - 1 < 0
        {
            if indexPath.section == 1
            {
                if self.tagsNotRecordingList.count == 0
                {
                    return true
                }
            }
            else
            {
                if self.tagsRecordingList.count == 0
                {
                    return true
                }
            }
            return false
        }
        return true
    }
    func tableView(_ tableView: UITableView, canDragCellFrom indexPath: IndexPath, withTouchPoint point:CGPoint) -> Bool
    {
        if tagEditView.isHidden && customTagEditView.isHidden
        {
            print(true)
            return true
        }
        print(false)
        return false
    }
    
    func tableView(_ tableView: UITableView, dragCellFrom fromIndexPath: IndexPath, toIndexPath: IndexPath) {
        
//        print(dragCellFrom)
        var toPathRow = toIndexPath.row - 1
        var fromPathRow = fromIndexPath.row - 1
        if toPathRow < 0
        {
            toPathRow = 0
            //return
        }
        if fromPathRow < 0
        {
            fromPathRow = 0
            //return
        }
        
        if fromIndexPath.section != toIndexPath.section
        {
//            if self.tagsNotRecordingList.count == 0
//            if self.tagsRecordingList.count == 0
            if fromIndexPath.section == 0
            {
                self.tagsNotRecordingList.insert(self.tagsRecordingList.object(at: fromPathRow), at: toPathRow)
                
                self.tagsRecordingList.removeObject(at: fromPathRow)
               
            }
            else
            {
                
                self.tagsRecordingList.insert(self.tagsNotRecordingList.object(at: fromPathRow), at: toPathRow)
                self.tagsNotRecordingList.removeObject(at: fromPathRow)
                
            }
        }
        else if fromIndexPath.section == 0
        {
            if (fromPathRow < self.tagsRecordingList.count) || (toPathRow < self.tagsRecordingList.count)
            {
                self.tagsRecordingList.exchangeObject(at: fromPathRow, withObjectAt: toPathRow)
            }
        }
        else
        {
            self.tagsNotRecordingList.exchangeObject(at: fromPathRow, withObjectAt: toPathRow)
        }
    }
    func tableView(_ tableView: UITableView, dragCellFrom fromIndexPath: IndexPath, overIndexPath: IndexPath) {
        //        dataArray.removeObject(at: fromIndexPath.row)
    }
    
    func tableView(_ tableView: UITableView, endDragCellTo indexPath: IndexPath)
    {
        
        var draggedToRow = indexPath.row
        if draggedToRow == 0
        {
            draggedToRow = 1
        }

        indexSelectedForEdit = indexPath.row

        var draggedTagInfo: TagInfo!
        if indexPath.section == 0
        {
            if self.tagsRecordingList.count == 1 && draggedToRow == 1
            {
//                settingTable.reloadRows(at: [IndexPath.init(row: 0, section: 0),IndexPath.init(row: 1, section: 0)], with: .none)
            }
            if self.tagsRecordingList.count > (draggedToRow - 1)
            {
                draggedTagInfo = self.tagsRecordingList.object(at: draggedToRow - 1) as! TagInfo
            }
        }
        else
        {
            if self.tagsNotRecordingList.count == 1 && draggedToRow == 1
            {
//                settingTable.reloadRows(at: [IndexPath.init(row: 0, section: 1),IndexPath.init(row: 1, section: 1)], with: .none)
            }
            if self.tagsNotRecordingList.count > (draggedToRow - 1)
            {
                draggedTagInfo = self.tagsNotRecordingList.object(at: draggedToRow - 1) as! TagInfo
            }
        }
        if draggedTagInfo != nil
        {
            if draggedTagInfo.isRecordingPageTag && indexPath.section == 1
            {
                //            draggedTagInfo.isRecordingPageTag = false
                //            CoreDataHelperInstance.sharedInstance.saveContext()
                self.tagsNotRecordingList.replaceObject(at: draggedToRow - 1, with: draggedTagInfo)
            }
            else if !draggedTagInfo.isRecordingPageTag && indexPath.section == 0
            {
                //            draggedTagInfo.isRecordingPageTag = true
                //            CoreDataHelperInstance.sharedInstance.saveContext()
                self.tagsRecordingList.replaceObject(at: draggedToRow - 1, with: draggedTagInfo)
            }
        }
        
        self.performSelector(onMainThread: #selector(TagManagementVC.UpdateTagOrderInDBAfterDrag), with: nil, waitUntilDone: true)

//        DispatchQueue.main.async {
//            self.UpdateTagOrderInDBAfterDrag()
//        }
//        print("endDragCellTo")
        self.settingTable.reloadData()
        
    }
    // MARK: - Update order in DB after Drag
    @objc func UpdateTagOrderInDBAfterDrag()
    {
        for i in 0..<self.tagsRecordingList.count
        {
            let category: TagInfo = self.tagsRecordingList[i] as! TagInfo
            category.isRecordingPageTag = true
            category.tagIndex = Int64(i)
        }
        CoreDataHelperInstance.sharedInstance.saveContext()
        for i in 0..<self.tagsNotRecordingList.count
        {
            let category1: TagInfo = self.tagsNotRecordingList[i] as! TagInfo
            category1.isRecordingPageTag = false
            category1.tagIndex = Int64(i)
        }
        
        
        CoreDataHelperInstance.sharedInstance.saveContext()
//        print("core data save")

    }
    
}
class TagManagementCell: UITableViewCell
{
    @IBOutlet weak var btnMore: CustomButton!
    @IBOutlet weak var tagImageView: UIImageView!
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel!
    
}
class CustomButton: UIButton
{
    var sectionNumber: Int!
}
