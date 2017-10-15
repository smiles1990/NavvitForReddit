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
                let type: String?
                let author: String
                let score: Int
            }
        }
    }
}


struct loadedComment {
    let body: String
    let author: String
    let score: Int
}

class SelfPostView: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var myTableView: UITableView!
    
    var url: String = ""
    var commentsArray = [loadedComment]()
    var postBody: String = ""
    var postTitle: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let jsonURL = URL(string: url) else { return }
        URLSession.shared.dataTask(with: jsonURL) { (data, response, error) in
            
            guard let data = data else {return}
            
                do {
                let info = try JSONDecoder().decode([commentLoader].self, from: data)
                
                    for children in info[1].data.children {
                        
                        let comment = loadedComment(body: children.data.body!, author: children.data.author, score: children.data.score)
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func displayShareSheet(shareContent:String) {
        let activityViewController = UIActivityViewController(activityItems: [shareContent as NSString], applicationActivities: nil)
        present(activityViewController, animated: true, completion: {})
    }
    
    @IBAction func shareButton(_ sender: UIButton) {
        let userURL = String(url.characters.dropLast(5))
        displayShareSheet(shareContent: "\(userURL)\n\nSent via the Viewr for reddit app for iOS.")
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
            
        } else if indexPath.row >= 2 {
            oneCell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as! CommentCell
            
            oneCell.authorLabel.text = String("Author: "+commentsArray[indexPath.row - 2].author)
            oneCell.commentLabel.text = commentsArray[indexPath.row - 2].body
            oneCell.scoreLabel.text = String("\(commentsArray[indexPath.row - 2].score)")
            
        }
        
        return oneCell
    }
    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//
//    }
    

    
    
    
}
