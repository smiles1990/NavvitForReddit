//
//  SelfPostView.swift
//  RedditViewer_2
//
//  Created by Scott Browne on 08/10/2017.
//  Copyright © 2017 Smiles Dev. All rights reserved.
//

import UIKit

class NVTSelfPostVC: UIViewController, UITabBarDelegate, UITableViewDataSource {
    
    @IBOutlet weak var myTableView: UITableView!
    
    var redditPost: NVTRedditPost!
    var refresher: UIRefreshControl!
    var postVote: Int?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // This creates a notification observer, this will be triggered by the function the loads the comments, it will then refresh the table, to include the newly loaded comments.
        NotificationCenter.default.addObserver(self, selector: #selector(NVTPageVC.refreshTable), name: NSNotification.Name(rawValue: "commentsLoaded"), object: nil)
        
        // This sets the refresh controller.
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: #selector(NVTPageVC.refreshTable), for: UIControlEvents.valueChanged)
        myTableView.addSubview(refresher)
        
    }
    
// Prepare for Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let commentPopUp = segue.destination as! NVTCommentPopUpVC
        commentPopUp.fullname = redditPost.postFullname
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
// These functions presents the user with the share sheet.
    func displayShareSheet(shareContent:String) {
        let activityViewController = UIActivityViewController(activityItems: [shareContent as NSString], applicationActivities: nil)
        present(activityViewController, animated: true, completion: {})
    }
    
    @IBAction func shareButton(_ sender: UIButton) {
        let userURL = String(redditPost.postURL)
        
        displayShareSheet(shareContent: "\(userURL)\n\nSent via the Navvit for reddit app on iOS.")
    }
    
// *** TABLEVIEW STUFF ***
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfCells = 2
        if redditPost.commentsArray != nil {
            numberOfCells += (redditPost.commentsArray?.count)!
        }
        return numberOfCells
    }
    
    @objc func refreshTable() {
        myTableView.reloadData()
        refresher.endRefreshing()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var oneCell = tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath) as! NVTCommentCell
        
    //This if statement returns the first cell(Title), second cell(Body), and all further cells(Comment) with the appropriate cell identifier and content.
        if indexPath.row == 0 {
            oneCell = tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath) as! NVTCommentCell
            oneCell.titleLabel.text = redditPost.postTitle
        
        
        } else if indexPath.row == 1 {
            oneCell = tableView.dequeueReusableCell(withIdentifier: "bodyCell", for: indexPath) as! NVTCommentCell
            
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
            oneCell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as! NVTCommentCell
            
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
