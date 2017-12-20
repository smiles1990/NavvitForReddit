//
//  TodayViewController.swift
//  NavvitWidget
//
//  Created by Scott Browne on 22/10/2017.
//  Copyright © 2017 Smiles Dev. All rights reserved.
//

import UIKit
import NotificationCenter
import Security

class NVTTodayVC: UIViewController, NCWidgetProviding {
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var linkKarmaLabel: UILabel!
    @IBOutlet weak var commentKarmaLabel: UILabel!
    
    let myUDSuite = UserDefaults.init(suiteName: "group.navvitForReddit")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if myUDSuite!.string(forKey: "Username") == nil {
            usernameLabel.text = "Please login to Navvit for reddit"
        }else{
            usernameLabel.text = myUDSuite?.string(forKey: "Username")
        }
        
        linkKarmaLabel.text = "--"
        commentKarmaLabel.text = "--"
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {

        if myUDSuite!.string(forKey: "Username") == nil {
            usernameLabel.text = "Please login to Navvit for reddit"
        }else{
            usernameLabel.text = myUDSuite?.string(forKey: "Username")
        }
        
        if myUDSuite?.string(forKey: "PostKarma") != nil {
            linkKarmaLabel.text = myUDSuite?.string(forKey: "LinkKarma")
        }else{
            linkKarmaLabel.text = "--"
        }
        
        if myUDSuite?.string(forKey: "CommentKarma") != nil {
            commentKarmaLabel.text = myUDSuite?.string(forKey: "CommentKarma")
        }else{
            commentKarmaLabel.text = "--"
        }
        
        
        

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
}
