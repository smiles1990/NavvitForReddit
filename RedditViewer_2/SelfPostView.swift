//
//  SelfPostView.swift
//  RedditViewer_2
//
//  Created by Scott Browne on 08/10/2017.
//  Copyright © 2017 Smiles Dev. All rights reserved.
//

import UIKit

//struct commentLoader: Codable {
//    let data: data
//    struct data: Codable {
//        let children: Array<data>
//        struct data: Codable {
//            let data: loadedComment
//            struct loadedComment: Codable {
//                let body: String?
//                let body_html: String?
//                let type: String?
//                let author: String?
//                let score: Int?
//                let name: String
//                let likes: Int?
//                let saved: Int?
//            }
//        }
//    }
//}


//struct loadedComment {
//    let body: String
//    let author: String
//    let score: Int
//    let likes: Int?
//    let fullname: String
//}

class SelfPostView: UIViewController, UITabBarDelegate, UITableViewDataSource {
    
    @IBOutlet weak var myTableView: UITableView!
    
    var redditPost: RedditPost!
    var refresher: UIRefreshControl!
    var postVote: Int?
    
//    var url: String = ""
//    var commentsArray = [RedditComment]()
//    var postScore: Int = 0
//    var postBody: String = ""
//    var postTitle: String = ""
//    var postFullname: String = ""
//    var postAuthor: String = ""
//    var postSaved: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(View2.refreshTable), name: NSNotification.Name(rawValue: "commentsLoaded"), object: nil)
        
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: #selector(View2.refreshTable), for: UIControlEvents.valueChanged)
        myTableView.addSubview(refresher)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let commentPopUp = segue.destination as! CommentPopUpVC
        commentPopUp.fullname = redditPost.postFullname
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func displayShareSheet(shareContent:String) {
        let activityViewController = UIActivityViewController(activityItems: [shareContent as NSString], applicationActivities: nil)
        present(activityViewController, animated: true, completion: {})
    }
    
    @IBAction func shareButton(_ sender: UIButton) {
        let userURL = String(redditPost.postURL.characters.dropLast(5))
        displayShareSheet(shareContent: "\(userURL)\n\nSent via the Navvit for reddit app on iOS.")
    }
    
    @objc func refreshTable() {
        myTableView.reloadData()
        refresher.endRefreshing()
    }
    
    // *** TABLEVIEW STUFF ***
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfCells = 2
        if redditPost.commentsArray != nil {
            numberOfCells += (redditPost.commentsArray?.count)!
        }
        return numberOfCells
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var oneCell = tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath) as! CommentCell
        
        if indexPath.row == 0 {
            oneCell = tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath) as! CommentCell
            oneCell.titleLabel.text = redditPost.postTitle
            
        } else if indexPath.row == 1 {
            oneCell = tableView.dequeueReusableCell(withIdentifier: "bodyCell", for: indexPath) as! CommentCell
            
            oneCell.bodyLabel.text = redditPost.selftext
            oneCell.authorLabel.text = redditPost.postAuthor
            oneCell.thingFullname = redditPost.postFullname
            oneCell.currentScore = redditPost.postScore
            oneCell.scoreLabel.text = String("\(redditPost.postScore)")
            
            if postVote == 1{
                oneCell.upvoteButton.setImage(#imageLiteral(resourceName: "Upvoted"), for: .normal)
            }else if postVote == 0{
                oneCell.downvoteButton.setImage(#imageLiteral(resourceName: "Downvoted"), for: .normal)
            }
            
            if redditPost.postSaved == 1 {
                oneCell.saveButton.setImage(#imageLiteral(resourceName: "SavedIcon"), for: .normal)
            }
            
            
        } else if indexPath.row >= 2 {
            oneCell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as! CommentCell
            
            oneCell.authorLabel.text = String("Author: "+redditPost.commentsArray![indexPath.row - 2].author)
            oneCell.commentLabel.text = redditPost.commentsArray![indexPath.row - 2].body
            oneCell.scoreLabel.text = String("\(redditPost.commentsArray![indexPath.row - 2].score)")
            oneCell.currentScore = redditPost.commentsArray![indexPath.row - 2].score
            oneCell.thingFullname = redditPost.commentsArray![indexPath.row - 2].fullname
            
            if redditPost.commentsArray![indexPath.row - 2].likes == 1 {
                oneCell.upvoteButton.setImage(#imageLiteral(resourceName: "Upvoted"), for: .normal)
            }else if redditPost.commentsArray![indexPath.row - 2].likes == 0{
                oneCell.downvoteButton.setImage(#imageLiteral(resourceName: "Downvoted"), for: .normal)
            }
        }
        
        return oneCell
    }
    
}
