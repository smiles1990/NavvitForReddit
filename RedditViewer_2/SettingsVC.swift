//
//  SettingsVC.swift
//  RedditViewer_2
//
//  Created by Scott Browne on 17/09/2017.
//  Copyright © 2017 Smiles Dev. All rights reserved.
//

import UIKit

class SettingsVC: UIViewController {
    
    let myUDSuite: UserDefaults = UserDefaults.init(suiteName: "group.navvitForReddit")!
    
    @IBOutlet weak var currentUser: UILabel!
    @IBOutlet weak var postKarmaLabel: UILabel!
    @IBOutlet weak var commentKarmaLabel: UILabel!

    @IBOutlet weak var browsingPreference: UISegmentedControl!
    @IBAction func browsingPrefChanged(_ sender: UISegmentedControl) {
        switch browsingPreference.selectedSegmentIndex {
        case 0:
            UserDefaults.standard.set("hot", forKey: "BrowsingPref")
        case 1:
            UserDefaults.standard.set("new", forKey: "BrowsingPref")
        case 2:
            UserDefaults.standard.set("top", forKey: "BrowsingPref")
        case 3:
            UserDefaults.standard.set("controversial", forKey: "BrowsingPref")
        default:
            break
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
            //If user info is available, update it.
        if SuperFunctions().getToken(identifier: "CurrentAccessToken") != nil {
            SuperFunctions().checkTokenStatus()
            SuperFunctions().getUserInfo()
        }
            //If user info is available, update view to display it.
        if myUDSuite.string(forKey: "Username") != nil {
            currentUser.text = myUDSuite.string(forKey: "Username")
            postKarmaLabel.text = myUDSuite.string(forKey: "PostKarma")
            commentKarmaLabel.text = myUDSuite.string(forKey: "CommentKarma")
        }
        
        if UserDefaults.standard.string(forKey: "BrowsingPref") == "hot" {
            self.browsingPreference.selectedSegmentIndex = 0
        }else if UserDefaults.standard.string(forKey: "BrowsingPref") == "new" {
            self.browsingPreference.selectedSegmentIndex = 1
        }else if UserDefaults.standard.string(forKey: "BrowsingPref") == "top" {
            self.browsingPreference.selectedSegmentIndex = 2
        }else if UserDefaults.standard.string(forKey: "BrowsingPref") == "controversial" {
            self.browsingPreference.selectedSegmentIndex = 3
        } else {
            self.browsingPreference.selectedSegmentIndex = 0
        }
        
    }
    

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}





// Code for implementation and debugging assistence.

//    @IBAction func logMeInButton(_ sender: Any) {
//
//        let myURL = NSURL(string: "https://oauth.reddit.com/message/inbox.json?count=20")
//        let request = NSMutableURLRequest(url: myURL as URL!)
//        let session = URLSession.shared
//
//        request.httpMethod = "GET"
//
//        var accessTokenString = "bearer "
//        accessTokenString.append(SuperFunctions().getToken(identifier: "CurrentAccessToken")!)
//
//        request.setValue("\(accessTokenString)", forHTTPHeaderField: "Authorization")
//
//        session.dataTask(with: request as URLRequest) { (data, response, error) in
//            guard let data = data else { return }
//
//            let backToString = String(data: data, encoding: String.Encoding.utf8) as String!
//            print("It's me: "+backToString! as String!)
//
//        }.resume()
//
//    }


//    @IBAction func showCodes(_ sender: Any) {
//        print("Current Auth Code: "+UserDefaults.standard.string(forKey: "currentAuthCode")!)
//        print("ClientID: "+UserDefaults.standard.string(forKey: "ClientID")!)
//    }





// Userdefault keys used.

// Default:
// Expiry time - (Time stamp for time at which the user's access token expires and requires refreshing)

// In Suite "group.navvitForReddit":
// CommentKarma - (Current user's Comment Karma value, used by Today Widget)
// PostKarma - (Current user's Post Karma value, used by Today Widget)
// Username - (Curren user's account Username, used by the Today Widget)

//




