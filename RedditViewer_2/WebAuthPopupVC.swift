//
//  WebAuthPopupVC.swift
//  RedditViewer_2
//
//  Created by Scott Browne on 20/09/2017.
//  Copyright © 2017 Smiles Dev. All rights reserved.
//

import UIKit

class webAuthPopupVC: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var myWebView: UIWebView!
    @IBOutlet weak var guideText: UILabel!
    @IBOutlet weak var snooImage: UIImageView!
    
    func webViewDidFinishLoad(_ webView: UIWebView){
        
        if guideText.text == "" {
                guideText.text = "Login to reddit"
        } else {
            if guideText.text == "Login to reddit"{
                guideText.text = "Scroll down and click Allow or Deny"
            }else if guideText.text == "Scroll down and click Allow or Deny"{
                guideText.text = "Click Done"
                myDoneButton.isHidden = false
                snooImage.isHidden = false
                myWebView.isHidden = true
            }else{
                print("No more instructions left to give")
            }
        }
    }
    
    @IBOutlet weak var myDoneButton: UIButton!
    
    @IBAction func doneButton(_ sender: Any) {
        
        let currentURL = myWebView.request?.url?.absoluteString
        print("I'M MR MEESEEKS \(String(describing: currentURL)) LOOK AT ME!")
        SuperFunctions().parseAuthCode(returnedString: currentURL!)
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func backButton(_ sender: Any) {
           dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UserDefaults.standard.string(forKey: "ClientID") == nil {
            UserDefaults.standard.set("DYOwn2H7ENR2pg", forKey: "ClientID")
        }else{
            print("ClientID already specified")
        }
        
        let stateString = SuperFunctions().randomString(length: 10)
        print (stateString)
        UserDefaults.standard.set(stateString, forKey: "currentStateString")
        
        var URLString = "https://www.reddit.com/api/v1/authorize.compact?client_id=DYOwn2H7ENR2pg&response_type=code&state="
        URLString.append(UserDefaults.standard.string(forKey: "currentStateString")!)
        URLString.append("&redirect_uri=http://www.reddit.com&duration=permanent&scope=mysubreddits,read,save,account,submit,privatemessages")
        
        let myURL = URL(string: URLString)
        
        myWebView.loadRequest(URLRequest(url: myURL!))
        
    }
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
