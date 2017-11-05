//
//  SelfPostView.swift
//  RedditViewer_2
//
//  Created by Scott Browne on 08/10/2017.
//  Copyright © 2017 Smiles Dev. All rights reserved.
//

import UIKit

struct commentLoader: Codable {
    let data: data
    struct data: Codable {
        let children: Array<data>
        struct data: Codable {
            let data: loadedComment
            struct loadedComment: Codable {
                let body: String?
                let body_html: String?
                let type: String?
                let author: String?
                let score: Int?
                let name: String
                let likes: Int?
                let saved: Int?
            }
        }
    }
}


struct loadedComment {
    let body: String
    let author: String
    let score: Int
    let likes: Int?
    let fullname: String
}

class SelfPostView: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var myTableView: UITableView!
    
    var url: String = ""
    var commentsArray = [loadedComment]()
    var postScore: Int = 0
    var postBody: String = ""
    var postTitle: String = ""
    var postFullname: String = ""
    var postAuthor: String = ""
    var postVote: Int?
    var postSaved: Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        guard let jsonURL = URL(string: url) else { return }
//        URLSession.shared.dataTask(with: jsonURL) { (data, response, error) in

        if SuperFunctions().getToken(identifier: "CurrentAccessToken") != nil {
            url = String(url.dropFirst(11))
            url = "https://oauth"+url
        }
        
        print(url)
        
        let jsonURL = NSURL(string: url)
        
        let request = NSMutableURLRequest(url: jsonURL as URL!)
        let session = URLSession.shared
        
        request.httpMethod = "GET"
        
        var accessTokenString = "bearer "
        accessTokenString.append(SuperFunctions().getToken(identifier: "CurrentAccessToken")!)
        
        request.setValue("\(accessTokenString)", forHTTPHeaderField: "Authorization")
        
        session.dataTask(with: request as URLRequest) { (data, response, error) in
            guard let data = data else {return}
            
//            let backToString = String(data: data, encoding: String.Encoding.utf8) as String!
//            print("It's me: "+backToString! as String!)
            
                do {
                let info = try JSONDecoder().decode([commentLoader].self, from: data)
                
                    for children in info[0].data.children {
                        self.postFullname = children.data.name
                        self.postAuthor = (children.data.author ?? "")!
                        self.postVote = children.data.likes ?? nil
                        self.postSaved = children.data.saved ?? 0
                    }
                    
                    for children in info[1].data.children {
                        
                        let comment = loadedComment(body: (children.data.body ?? ""), author: (children.data.author ?? "")!, score: (children.data.score ?? 0)!, likes: children.data.likes, fullname: children.data.name)
                        self.commentsArray.append(comment)
                        
                    }
                    
                }catch let jsonErr{
                    print("Error parsing comments JSON:", jsonErr)
                }
            
            DispatchQueue.main.async {
                self.myTableView.reloadData()
            }
            
        }.resume()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let commentPopUp = segue.destination as! CommentPopUpVC
        commentPopUp.fullname = postFullname
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func displayShareSheet(shareContent:String) {
        let activityViewController = UIActivityViewController(activityItems: [shareContent as NSString], applicationActivities: nil)
        present(activityViewController, animated: true, completion: {})
    }
    
    @IBAction func shareButton(_ sender: UIButton) {
        let userURL = String(url.characters.dropLast(5))
        displayShareSheet(shareContent: "\(userURL)\n\nSent via the Navvit for reddit app on iOS.")
    }
    
    
    
    
    
    

    
    
    
    // *** TABLEVIEW STUFF ***
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (2 + commentsArray.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var oneCell = tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath) as! CommentCell
        
        if indexPath.row == 0 {
            oneCell = tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath) as! CommentCell
            oneCell.titleLabel.text = postTitle
            
        } else if indexPath.row == 1 {
            oneCell = tableView.dequeueReusableCell(withIdentifier: "bodyCell", for: indexPath) as! CommentCell
            

            
            oneCell.bodyLabel.text = postBody
            oneCell.authorLabel.text = postAuthor
            oneCell.thingFullname = postFullname
            oneCell.currentScore = postScore
            oneCell.scoreLabel.text = String("\(postScore)")
            
            if postVote == 1{
                oneCell.upvoteButton.setImage(#imageLiteral(resourceName: "Upvoted"), for: .normal)
            }else if postVote == 0{
                oneCell.downvoteButton.setImage(#imageLiteral(resourceName: "Downvoted"), for: .normal)
            }
            
            if postSaved == 1 {
                oneCell.saveButton.setImage(#imageLiteral(resourceName: "SavedIcon"), for: .normal)
            }
            
        } else if indexPath.row >= 2 {
            oneCell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as! CommentCell
            
            oneCell.authorLabel.text = String("Author: "+commentsArray[indexPath.row - 2].author)
            oneCell.commentLabel.text = commentsArray[indexPath.row - 2].body
            oneCell.scoreLabel.text = String("\(commentsArray[indexPath.row - 2].score)")
            oneCell.currentScore = commentsArray[indexPath.row - 2].score
            oneCell.thingFullname = commentsArray[indexPath.row - 2].fullname
            
            if commentsArray[indexPath.row - 2].likes == 1 {
                oneCell.upvoteButton.setImage(#imageLiteral(resourceName: "Upvoted"), for: .normal)
            }else if commentsArray[indexPath.row - 2].likes == 0{
                oneCell.downvoteButton.setImage(#imageLiteral(resourceName: "Downvoted"), for: .normal)
            }
        }
        
        return oneCell
    }
    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//
//    }
    

    
    
    
}
