//
//  FaceBookPageVc.swift
//  VideoEditor
//
//  Created by CZ Ltd on 5/16/18.
//  Copyright © 2018 Ark Inc. All rights reserved.
//

import UIKit

protocol FaceBookPageVcDelegate {
    
    func sendPageDetails(name : String,id : String)
}

class FaceBookPageVc: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var facebookPageTable: UITableView!
    
    var pagename    = [String]()
    var pageid      = [String]()
    var pagetoken   = [String]()
    var imagearray  = [String]()
    
    var delegate : FaceBookPageVcDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        facebookPageTable.delegate = self
        facebookPageTable.dataSource = self
        
        facebookmessage()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func ButtonClose(_ sender: UIBarButtonItem) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.pagename.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "facebookpagecell", for: indexPath) as! FacebookPageTableViewCell
        
        let row = indexPath.row
        
        cell.labelName.text = self.pagename[row]
        
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        delegate.sendPageDetails(name: self.pagename[indexPath.row], id: self.pageid[indexPath.row])
        
        self.dismiss(animated: true, completion: nil)
       
    }
    
    // facebook page retriving
    
    func facebookmessage() {
        
        FBSDKGraphRequest.init(graphPath: "me/accounts", parameters: nil, httpMethod: "GET").start(completionHandler: { (connection, result, error) -> Void in
            if let error = error {
                
                print("Error: \(error)")
                
            } else {
                
                if ((error) != nil)
                {
                    // Process error
                    print("Error: \(error)")
                    
                    
                } else {
                    
                    let resultdict = result as? NSDictionary
                    
                    guard let datalist = resultdict?["data"] as? [[String: Any]] else {
                        
                        return
                    }
                    
                    
                    for data in datalist {
                        
                        if let name = data["name"] as? String {
                            
                            self.pagename.append("\(name)")
                        }
                        
                        if let token = data["access_token"] as? String {
                            
                            self.pagetoken.append(token)
                            
                            
                        }
                        
                        if let id = data["id"] as? String {
                            
                            self.pageid.append(id)
                            let urlimage = "http://graph.facebook.com/\(id)/picture?type=large"
                            self.imagearray.append(urlimage)
                            
                        }
                        
                        
                        
                    }
                    
                    DispatchQueue.main.async {
                        
                        self.facebookPageTable.reloadData()
                        
                    }
                    
                    
                    
                    
                }
                
                
                
                
            }
            
        })
        
    }
}
