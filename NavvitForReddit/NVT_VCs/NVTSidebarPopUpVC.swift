//
//  SidebarVC.swift
//  RedditViewer_2
//
//  Created by Scott Browne on 30/10/2017.
//  Copyright © 2017 Smiles Dev. All rights reserved.
//

import UIKit

struct Sidebar: Codable {
    
    let data: data
    let kind: String
    
    struct data: Codable {
        
        let description: String
        let header_img: String?
        let public_description: String
        let title: String
        let subscribers: Int
        let user_is_subscriber: Bool
        let name: String
        
    }
}

class NVTSidebarPopUpVC: UIViewController{
    
    var url: String = ""

    @IBOutlet weak var subredditLabel: UILabel!
    @IBOutlet weak var subredditHeaderImage: UIImageView!
    @IBOutlet weak var publicDescriptionLabel: UILabel!
    @IBOutlet weak var subscribersLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var subButton: UIButton!
    
    var subredditTitle = ""
    var subscribers = 0
    var publicDescription = ""
    var subredditDescription = ""
    var userIsSubscribed = false
    var subName = ""
    
    @IBAction func subButton(_ sender: Any) {
        if self.subButton.currentTitle == "Subscribe" {
            self.subButton.setTitle("Unsubscribe", for: .normal)
            self.subButton.setTitleColor(UIColor.red, for: .normal)
            NVTSuperFunctions().subscribe(subreddit: self.subName, mode: "sub")
            
        } else if self.subButton.currentTitle == "Unsubscribe" {
            self.subButton.setTitle("Subscribe", for: .normal)
            self.subButton.setTitleColor(UIColor.green, for: .normal)
            NVTSuperFunctions().subscribe(subreddit: self.subName, mode: "unsub")
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        popUpView.layer.cornerRadius = 10
        
        if NVTSuperFunctions().getToken(identifier: "CurrentAccessToken") != nil {
            url = String(url.dropFirst(11))
            url = "https://oauth"+url
        }
        
        let jsonURL = NSURL(string: url)
        
        let request = NSMutableURLRequest(url: jsonURL as URL!)
        let session = URLSession.shared
        
        if NVTSuperFunctions().getToken(identifier: "CurrentAccessToken") != nil {
            var accessTokenString = "bearer "
            accessTokenString.append(NVTSuperFunctions().getToken(identifier: "CurrentAccessToken")!)
            request.setValue("\(accessTokenString)", forHTTPHeaderField: "Authorization")
        }
        
        session.dataTask(with: request as URLRequest) { (data, response, error) in
            guard let data = data else { return }
            
//            let backToString = String(data: data, encoding: String.Encoding.utf8) as String!
//            print(backToString as String!)
            
            do{
                let info = try JSONDecoder().decode(Sidebar.self, from: data)
                
                if info.data.header_img != nil {
            
                    let imageURL = URL(string: info.data.header_img!)
                
                        DispatchQueue.main.async {
                            do {
                                let imageData = try Data(contentsOf: imageURL!)
                                self.subredditHeaderImage.image = UIImage(data: imageData)
                            }catch{
                                print("Error: data error fetching image")
                            }
                        }
                
                }else{
                    DispatchQueue.main.async {
                        self.subredditHeaderImage.backgroundColor = UIColor.white
                        self.subredditHeaderImage.image = #imageLiteral(resourceName: "Redditlogo.png")
                    }
                    
                }
                
                self.subredditTitle = info.data.title
                self.subscribers = info.data.subscribers
                self.publicDescription = info.data.public_description
                self.subredditDescription = info.data.description
                self.userIsSubscribed = info.data.user_is_subscriber
                self.subName = info.data.name
                
            }catch let jsonErr {
                print ("Error fetching sidebar info", jsonErr)
            }
            
            DispatchQueue.main.async {
                self.subredditLabel.text = self.subredditTitle
                self.publicDescriptionLabel.text = self.publicDescription
                self.subscribersLabel.text = String("Subscribers:\(self.subscribers)")
                self.descriptionTextView.text = self.subredditDescription
        
                if self.userIsSubscribed == true {
                    self.subButton.setTitle("Unsubscribe", for: .normal)
                    self.subButton.setTitleColor(UIColor.red, for: .normal)
                    self.subButton.isHidden = false
                } else if self.userIsSubscribed == false{
                    self.subButton.isHidden = false
                }
            }
            
            }.resume()
    }
    
    override func didReceiveMemoryWarning() {
        super.viewDidLoad()
    }

    @IBAction func closeButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
