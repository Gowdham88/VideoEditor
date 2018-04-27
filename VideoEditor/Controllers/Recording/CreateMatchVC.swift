//
//  CreateMatchVC.swift
//  FannerCam

import UIKit
import MobileCoreServices

class CreateMatchVC: BaseVC, UIImagePickerControllerDelegate {

    //MARK: - OUTLETS
    @IBOutlet weak var txtSportName: UITextField!
    @IBOutlet weak var txtEventName: UITextField!
    @IBOutlet weak var txtHomeNameParticipant: UITextField!
    @IBOutlet weak var txtAwayNameParticipant: UITextField!
    @IBOutlet weak var btnLogoHomeNameParticipant: UIButton!
    @IBOutlet weak var btnLogoAwayNameParticipant: UIButton!
    
    @IBOutlet weak var btnCreateandStartRecording: UIButton!
    @IBOutlet weak var btnVS: UIButton!
    
    var homeTeamLogo: UIImage?
    var awayTeamLogo: UIImage?
    let picker = UIImagePickerController()
    
    var currentLogoSelection: Int!

    override func viewDidLoad() {
        super.viewDidLoad()
        currentLogoSelection = 1
        self.navigationItem.title = "CREATE A MATCH"
        self.picker.delegate = self
        addTopLeftBackButton()
//        addTopRightNavigationBarButton(imageName: "share_gray")
        
        self.txtSportName.text = "A"
        self.txtEventName.text = "B"
        self.txtHomeNameParticipant.text = "C"
        self.txtAwayNameParticipant.text = "D"
        
        btnLogoHomeNameParticipant.layer.borderWidth = 0.7
        btnLogoHomeNameParticipant.layer.borderColor = UIColor(red: 215.0/255.0, green: 215.0/255.0, blue: 215.0/255.0, alpha: 1).cgColor
        btnLogoHomeNameParticipant.layer.cornerRadius = 5.0
        
        btnLogoAwayNameParticipant.layer.borderWidth = 0.7
        btnLogoAwayNameParticipant.layer.borderColor = UIColor(red: 215.0/255.0, green: 215.0/255.0, blue: 215.0/255.0, alpha: 1).cgColor
        btnLogoAwayNameParticipant.layer.cornerRadius = 5.0
        
        setCornerRadiusAndShadowOnButton(button: btnCreateandStartRecording, backColor: COLOR_APP_THEME())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.view.layoutIfNeeded()
        self.navigationController?.navigationBar.isHidden = false
        //APP_DELEGATE.tabbarController?.tabBar.isHidden = false
        //APP_DELEGATE.tabbarController?.tabBar.layer.zPosition = 0
        DispatchQueue.main.async {
            APP_DELEGATE.myOrientation = .portrait
            APP_DELEGATE.landscaperSide = UIInterfaceOrientation.portrait
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            self.view.layoutIfNeeded()
        }
        
    }
    
    override func topRightNavigationBarButtonClicked() {
        let redirectTo = loadVC(strStoryboardId: SB_OTHERS, strVCId: idSocialShareVC) as! SocialShareVC
        self.navigationController?.pushViewController(redirectTo, animated: true)
    }

    @IBAction func btnCreateAndStartRecordingClicked(_ sender: Any) {
        APP_DELEGATE.myOrientation = .all
//        APP_DELEGATE.currentRecordingEvent = Constants.RecordMatchEvent
//        let redirectTo = loadVC(strStoryboardId: SB_LANDSCAPE, strVCId: idLiveCameraVC) as! LiveCameraVC
//        self.navigationController?.pushViewController(redirectTo, animated: true)
//        return
        
        let sportName: String = self.txtSportName.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let eventName: String = self.txtEventName.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let homeTeamName: String = self.txtHomeNameParticipant.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let awayTeamName: String = self.txtAwayNameParticipant.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if sportName.isEmpty
        {
            APP_DELEGATE.displayMessageAlertWithMessage(alertMessage: "Please enter sport name.", withTitle: "Alert")
            return
        }
        if homeTeamName.isEmpty
        {
            APP_DELEGATE.displayMessageAlertWithMessage(alertMessage: "Please enter home team name.", withTitle: "Alert")
            return
        }
        if awayTeamName.isEmpty
        {
            APP_DELEGATE.displayMessageAlertWithMessage(alertMessage: "Please enter away team name.", withTitle: "Alert")
            return
        }
//        if homeTeamLogo == nil
//        {
//            APP_DELEGATE.displayMessageAlertWithMessage(alertMessage: "Please add Home Team Logo", withTitle: "Alert")
//            return
//        }
//        if awayTeamLogo == nil
//        {
//            APP_DELEGATE.displayMessageAlertWithMessage(alertMessage: "Please add Away Team Logo", withTitle: "Alert")
//            return
//        }
        let recordEventInfo: RecordingInfo = RecordingInfo()
        recordEventInfo.awayTeamLogo = awayTeamLogo
        recordEventInfo.homeTeamLogo = homeTeamLogo
        
        recordEventInfo.homeTeamName = homeTeamName
        recordEventInfo.awayTeamName = awayTeamName
        
        recordEventInfo.eventName = eventName
        recordEventInfo.sportName = sportName
        recordEventInfo.createEvent = true
        recordEventInfo.recADay = false
        recordEventInfo.isDayEvent = false
        let redirectTo = loadVC(strStoryboardId: SB_LANDSCAPE, strVCId: idLiveCameraVC) as! LiveCameraVC
        redirectTo.recordEventInfo = recordEventInfo

        self.navigationController?.pushViewController(redirectTo, animated: true)
    }
   
    @IBAction func TeamLogoClicked(_ sender: UIButton)
    {
        self.picker.mediaTypes = [kUTTypeImage as String]

        currentLogoSelection = sender.tag
        let actionSheet = UIAlertController(title: "Select Tag Image", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let fromCamera = UIAlertAction(title: "Camera", style: .default) { (action:UIAlertAction!) in
            
            self.picker.delegate = self
            self.picker.allowsEditing = false
            self.picker.sourceType = .camera
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
        
        actionSheet.popoverPresentationController?.sourceView = sender // works for both iPhone & iPad
        self.present(actionSheet, animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
        
    {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage //2

        if currentLogoSelection == 0
        {
            homeTeamLogo = image
            btnLogoHomeNameParticipant.setTitle("", for: .normal)
            btnLogoHomeNameParticipant.setBackgroundImage(image, for: .normal)
        }
        else
        {
            awayTeamLogo = image
            btnLogoAwayNameParticipant.setTitle("", for: .normal)
            btnLogoAwayNameParticipant.setBackgroundImage(image, for: .normal)
        }
        self.dismiss(animated:true, completion: nil)
        
        DispatchQueue.main.async {
            
            
        }
    }
    
}
