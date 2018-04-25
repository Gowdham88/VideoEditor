//
//  WebviewVC.swift
//  VideoEditor
//
//  Copyright © 2018 Ark Inc. All rights reserved.
//

import Foundation
class WebviewVC: BaseVC
{
    @IBOutlet weak var webView: UIWebView!
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.navigationItem.title = "Account Webpage"

        addTopLeftBackButton()
        self.webView.isOpaque = false
        self.webView.backgroundColor = UIColor.clear
    }
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        let url = NSURL (string: Constants.ACCOUNT_FANNER_URL)
        let requestObj = NSURLRequest(url: url! as URL);
        self.webView.loadRequest(requestObj as URLRequest)
    }
}
