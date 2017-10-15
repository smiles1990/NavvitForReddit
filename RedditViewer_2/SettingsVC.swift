//
//  SettingsVC.swift
//  RedditViewer_2
//
//  Created by Scott Browne on 17/09/2017.
//  Copyright © 2017 Smiles Dev. All rights reserved.
//

import UIKit

class SettingsVC: UIViewController {
    
    var subScribedSubredditsArray = ["Hello"]
    
    @IBAction func logMeInButton(_ sender: Any) {
        
        
        
    }
    
    @IBAction func refreshToken(_ sender: Any) {
        SuperFunctions().checkTokenStatus()
    }
    
    @IBAction func showCodes(_ sender: Any) {
        print("Current Access Token: "+UserDefaults.standard.string(forKey: "currentAccessToken")!)
        print("Current Auth Code: "+UserDefaults.standard.string(forKey: "currentAuthCode")!)
        print("Current Refresh Token: "+UserDefaults.standard.string(forKey: "currentRefreshToken")!)
        print("ClientID: "+UserDefaults.standard.string(forKey: "ClientID")!)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

