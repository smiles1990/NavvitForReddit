//
//  WebAuthPopupVC.swift
//  RedditViewer_2
//
//  Created by Scott Browne on 20/09/2017.
//  Copyright © 2017 Smiles Dev. All rights reserved.
//

import UIKit
import WebKit

class NVTWebAuthPopUpVC: UIViewController, WKUIDelegate, WKNavigationDelegate {

    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var guideText: UILabel!
    @IBOutlet weak var myDoneButton: UIButton!
    
    func webView(_ webView: WKWebView, didFinish: WKNavigation!) {
        if guideText.text == "" {
            guideText.text = "Login to reddit"
        } else {
            if guideText.text == "Login to reddit"{
                guideText.text = "Scroll down and click Allow or Deny"
            }else if guideText.text == "Scroll down and click Allow or Deny"{
                guideText.text = "Click Done"
                myDoneButton.isHidden = false
                webView.isHidden = true
            }else{
                print("No more instructions left to give")
            }
        }
    }
    
    @IBAction func doneButton(_ sender: Any) {
        
        let currentURL = webView.url?.absoluteString
        let authCode = currentURL?.dropFirst(46)
        UserDefaults.standard.set(authCode, forKey: "UserAuthCode")
        print(UserDefaults.standard.string(forKey: "UserAuthCode")!)
        NVTSuperFunctions().getAccessToken()
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func backButton(_ sender: Any) {
           dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.uiDelegate = self
        
        if UserDefaults.standard.string(forKey: "ClientID") == nil {
            UserDefaults.standard.set("DYOwn2H7ENR2pg", forKey: "ClientID")
        }else{
            print("ClientID already specified")
        }
        
        let stateString = NVTSuperFunctions().randomString(length: 10)
        print(stateString)
        UserDefaults.standard.set(stateString, forKey: "currentStateString")
        
        var URLString = "https://www.reddit.com/api/v1/authorize.compact?client_id=DYOwn2H7ENR2pg&response_type=code&state="
        URLString.append(UserDefaults.standard.string(forKey: "currentStateString")!)
        URLString.append("&redirect_uri=http://www.reddit.com&duration=permanent&scope=mysubreddits,read,save,account,submit,privatemessages,vote,history,identity,subscribe")
        

        let myURL = URL(string: URLString)
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
        
    }
    
    override func loadView() {
        super.loadView()
        webView.navigationDelegate = self

    }
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
