//
//  View2.swift
//  RedditViewer_2
//
//  Created by Scott Browne on 03/09/2017.
//  Copyright © 2017 Smiles Dev. All rights reserved.
//

import UIKit

class View2: UITableViewController {
    
    //Defines or intialises necessary variables and outlets.
    
    var refresher: UIRefreshControl!
    var url = ""
    var subredditName = ""
    var redditPage: RedditPage!
    
//    let myUDSuite = UserDefaults.init(suiteName: "group.navvitForReddit")
//    let browsePref: String? = UserDefaults.standard.string(forKey: "BrowsingPref")
    
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var navItem: UINavigationItem!
//    var postID: String = ""
    var segueType: String = ""
    var selectedPost: RedditPost!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(View2.refreshTable), name: NSNotification.Name(rawValue: "postsLoaded"), object: nil)
        
    // This sets the navigation bar view title
        navItem.title = redditPage.subredditName
        
    // Creates and controls the pull-down refresher for the table view.
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: #selector(View2.refreshTable), for: UIControlEvents.valueChanged)
        tableView.addSubview(refresher)
    
    // This allows the table to
        let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(View2.handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 1.0
        longPressGesture.delegate = self as? UIGestureRecognizerDelegate
        self.tableView.addGestureRecognizer(longPressGesture)
    
    }

// This button shows the sidebar popover view when pressed, provding info about the subreddit displayed.
    @IBAction func sidebarButton(_ sender: Any) {
        if redditPage.isSubreddit == true {
        self.segueType = "sidebar"
        performSegue(withIdentifier: "sidebarSegue", sender: self)
        }
    }
    
// Prepares the view to segue to a selected post, this does different things depending on the type of post selected.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if self.segueType == "sidebar" {
            let sidebarView = segue.destination as! SidebarVC
            
            if UserDefaults.standard.string(forKey: "Username") == nil{
                sidebarView.url = "https://www.reddit.com/r/"+redditPage.subredditName+"/about.json"
            } else {
                sidebarView.url = "https://oauth.reddit.com/r/"+redditPage.subredditName+"/about.json"
            }
        } else if self.segueType == "self" {
            let selfPostView = segue.destination as! SelfPostView
            selfPostView.redditPost = self.selectedPost
            selfPostView.redditPost.getComments()
            
        } else {
            let linkView = segue.destination as! LinkView
            linkView.url = self.selectedPost.postURL
        }
    }
    
// This defines what should happen when the user selects a cell in the table.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if indexPath.row == (redditPage.contents.count) {
//            redditPage.getPage()
//            tableView.reloadData()
//        }else{
        
              self.selectedPost = redditPage.contents[indexPath.row]
              print(selectedPost)
       
            if redditPage.contents[indexPath.row].is_self == true {
                self.segueType = "self"
                performSegue(withIdentifier: "selfPostSegue", sender: self)
            } else {
                self.segueType = "link"
                performSegue(withIdentifier: "nonSelfSegue", sender: self)
            }
//        }
    }

// This defines how many posts need to be displayed in the table.
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (redditPage.contents.count)
    }
    
    public override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == redditPage.contents.count-1 {
            redditPage.getPage()
        }
    }

// This populates the cells in the table with the data fetched from the .json.
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> MyCell {
        
        var oneCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MyCell
        
        if (redditPage.contents.count) >= indexPath.row {
                var data = Data()
                let myURL = URL(string: redditPage.contents[indexPath.row].postImageURL)
            if redditPage.contents[indexPath.row].postImageURL == "self" {
                oneCell = tableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath) as! MyCell
            }else if redditPage.contents[indexPath.row].postImageURL == "default" {
                oneCell = tableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath) as! MyCell
            }else if redditPage.contents[indexPath.row].postImageURL == "" {
                oneCell = tableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath) as! MyCell
            }else{
                    do {
                        data = try Data(contentsOf: myURL!)
                        oneCell.cellImage.image = UIImage(data: data)
                    }catch{
                        print("Error: data error fetching image")
                        print(redditPage.contents[indexPath.row].postImageURL)
                    }
            }
            oneCell.cellTitle.text = redditPage.contents[indexPath.row].postTitle
            oneCell.scoreLabel.text = String("\(redditPage.contents[indexPath.row].postScore)")
            oneCell.currentScore = redditPage.contents[indexPath.row].postScore
            oneCell.thingFullname = redditPage.contents[indexPath.row].postFullname
            oneCell.authorLabel.text = redditPage.contents[indexPath.row].postAuthor
            
            if redditPage.contents[indexPath.row].postVote != nil {
                if redditPage.contents[indexPath.row].postVote == 1 {
                    oneCell.upvoteButton.setImage(#imageLiteral(resourceName: "Upvoted"), for: .normal)
                }else if redditPage.contents[indexPath.row].postVote == 0 {
                    oneCell.downvoteButton.setImage(#imageLiteral(resourceName: "Downvoted"), for: .normal)
                }
            }
        }
        return oneCell
    }
    
// This function controls what happens when the table is refreshed manually.
    @objc func refreshTable() {
        tableView.reloadData()
        refresher.endRefreshing()
        print("Finished refreshing")
    }
    
// This is called when the user completes a long press on the screen.
    @objc func handleLongPress(_ longPressGestureRecognizer: UILongPressGestureRecognizer) {
        if longPressGestureRecognizer.state == UIGestureRecognizerState.began {
            let touchPoint = longPressGestureRecognizer.location(in: self.view)
            if let indexPath = myTableView.indexPathForRow(at: touchPoint) {
                displayShareSheet(shareContent: "\(redditPage.contents[indexPath.row].postURL)\n\nSent via the Navvit for reddit app for iOS.")
            }
        }
    }
    
// Allows the view to display the share sheet.
    func displayShareSheet(shareContent:String) {
        let activityViewController = UIActivityViewController(activityItems: [shareContent as NSString], applicationActivities: nil)
        present(activityViewController, animated: true, completion: {})
    }
    
}

