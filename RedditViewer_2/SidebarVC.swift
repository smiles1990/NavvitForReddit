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

    }
}

class SidebarVC: UIViewController{
    
    var url: String = ""

    @IBOutlet weak var subredditLabel: UILabel!
    @IBOutlet weak var subredditHeaderImage: UIImageView!
    @IBOutlet weak var publicDescriptionLabel: UILabel!
    @IBOutlet weak var subscribersLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var popUpView: UIView!
    
    var subredditTitle = ""
    var subscribers = 0
    var publicDescription = ""
    var subredditDescription = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(url)
        
        popUpView.layer.cornerRadius = 10
        
        let jsonURL = NSURL(string: url)
        
        let request = NSMutableURLRequest(url: jsonURL as URL!)
        let session = URLSession.shared
        
//        request.httpMethod = "GET"
//
//        var accessTokenString = "bearer "
//        accessTokenString.append(SuperFunctions().getToken(identifier: "CurrentAccessToken")!)
//
//        request.setValue("\(accessTokenString)", forHTTPHeaderField: "Authorization")
        
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
                
            }catch let jsonErr {
                print ("Error fetching sidebar info", jsonErr)
            }
            
            DispatchQueue.main.async {
                self.subredditLabel.text = self.subredditTitle
                self.publicDescriptionLabel.text = self.publicDescription
                self.subscribersLabel.text = String("\(self.subscribers) subscribers")
                self.descriptionTextView.text = self.subredditDescription
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
