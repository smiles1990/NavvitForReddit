//
//  View2.swift
//  RedditViewer_2
//
//  Created by Scott Browne on 03/09/2017.
//  Copyright © 2017 Smiles Dev. All rights reserved.
//

import UIKit

// This defines the structure of a .json file we want to decode, leaving out the unnecesary data.
struct RedditPage: Codable {
    let data: data
    let kind: String
    struct data: Codable {
        let children: Array<data>
        struct data: Codable {
            let data: redditPost
            struct redditPost: Codable {
                let url: String
                let title: String
                let author:String
                let thumbnail: String
                let id: String
                let score: Int
                let is_self: Bool
                let selftext: String?
                let name: String
                let likes: Int?
            }
        }
    }
}

//This defines the structure of a post loaded from the .json file.
struct loadedPost {
    let postTitle: String
    let postImageURL: String
    let postScore: Int
    let postURL: String
    let postID: String
    let is_self: Bool
    let selftext: String?
    let postFullname: String
    let postVote: Int?
}

class View2: UITableViewController {
    
    //Defines or intiaises necessary variables and outlets.
    var postArray = [loadedPost]()
    var refresher: UIRefreshControl!
    var imageForCell = UIImage()
    var url = ""
    var subredditName = ""
    var lastFullname: String = ""
    var isSubreddit: Bool = false
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var navItem: UINavigationItem!
    let myUDSuite = UserDefaults.init(suiteName: "group.navvitForReddit")
    let browsePref: String? = UserDefaults.standard.string(forKey: "BrowsingPref")
    var postCount = 10
    var postID: String = ""
    var segueType: String = ""
    var postURL: String = ""
    var postBody: String = ""
    var postTitle: String = ""
    var postScore: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    // This checks the status of the users access token(which subsequently refreshes it if necessary), but only if there is a user currently logged in.
        SuperFunctions().checkTokenStatus()
        
    // This sets the navigation bar view title
        navItem.title = subredditName
        
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
    
    // This populates the table with posts from the subreddit the user navigated to.
        getPosts()
    }
    
    func getPosts(){
        var urlString: String = ""
        if subredditName == "Upvoted"{
            urlString = "https://www.reddit.com/user/"+(myUDSuite?.string(forKey: "Username"))!+"/upvoted.json"
        }else if subredditName == "Saved"{
            urlString = "https://www.reddit.com/user/"+(myUDSuite?.string(forKey: "Username"))!+"/saved.json"
        }else if subredditName == "Submitted"{
            urlString = "https://www.reddit.com/user/"+(myUDSuite?.string(forKey: "Username"))!+"/submitted.json"
        }else{
            isSubreddit = true
            if lastFullname == "" {
                urlString = "https://www.reddit.com/r/"+subredditName+"/"+browsePref!+".json?count="
                urlString.append(String(postCount))
            } else {
                urlString = "https://www.reddit.com/r/"+subredditName+"/"+browsePref!+".json?count="
                urlString.append(String(postCount)+"&after="+lastFullname)
            }
        }
        if SuperFunctions().getToken(identifier: "CurrentAccessToken") != nil {
            urlString = String(urlString.dropFirst(11))
            urlString = "https://oauth"+urlString
        }
        print(urlString)
        let jsonURL = NSURL(string: urlString)
        let request = NSMutableURLRequest(url: jsonURL as URL!)
        let session = URLSession.shared
        request.httpMethod = "GET"
        if myUDSuite?.string(forKey: "Username") != nil {
            var accessTokenString = "bearer "
            accessTokenString.append(SuperFunctions().getToken(identifier: "CurrentAccessToken")!)
            request.setValue("\(accessTokenString)", forHTTPHeaderField: "Authorization")
        }
        session.dataTask(with: request as URLRequest) { (data, response, error) in
            guard let data = data else { return }
//                let backToString = String(data: data, encoding: String.Encoding.utf8) as String!
//                print(backToString as String!)
            do{
                let info = try JSONDecoder().decode(RedditPage.self, from: data)
                for children in info.data.children {
                    let post = loadedPost(postTitle: children.data.title,
                                          postImageURL: children.data.thumbnail,
                                          postScore: children.data.score,
                                          postURL: children.data.url,
                                          postID: children.data.id,
                                          is_self: children.data.is_self,
                                          selftext: children.data.selftext,
                                          postFullname: children.data.name,
                                          postVote: children.data.likes)
                    self.lastFullname = children.data.name
                    self.postArray.append(post)
                }
            }catch let jsonErr {
                print ("I failed Master, forgive me, please!", jsonErr)
            }
            DispatchQueue.main.async {
                self.myTableView.reloadData()
            }
        }.resume()
    }

// This button shows the sidebar popover view when pressed, provding info about the subreddit displayed.
    @IBAction func sidebarButton(_ sender: Any) {
        if isSubreddit == true {
        self.segueType = "sidebar"
        performSegue(withIdentifier: "sidebarSegue", sender: self)
        }
    }
    
// Prepares the view to segue to a selected post, this does different things depending on the type of post selected.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if self.segueType == "sidebar" {
            let sidebarView = segue.destination as! SidebarVC
            if UserDefaults.standard.string(forKey: "Username") == nil{
                sidebarView.url = "https://www.reddit.com/r/"+subredditName+"/about.json"
            } else {
                sidebarView.url = "https://oauth.reddit.com/r/"+subredditName+"/about.json"
            }
        } else if self.segueType == "self" {
            let postURLString = "https://www.reddit.com/r/"+subredditName+"/comments/"+postID+".json"
            let selfPostView = segue.destination as! SelfPostView
            selfPostView.url = postURLString
            selfPostView.postTitle = self.postTitle
            selfPostView.postBody = self.postBody
            selfPostView.postScore = self.postScore
        } else {
            let linkView = segue.destination as! LinkView
            linkView.url = postURL
        }
    }
    
// This defines what should happen when the user selects a cell in the table.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == (postArray.count) {
            getPosts()
        }else{
            self.postURL = postArray[indexPath.row].postURL
            self.postID = postArray[indexPath.row].postID
            if postArray[indexPath.row].is_self == true {
                self.segueType = "self"
                self.postTitle = postArray[indexPath.row].postTitle
                self.postBody = postArray[indexPath.row].selftext ?? ""
                self.postScore = postArray[indexPath.row].postScore
                performSegue(withIdentifier: "selfPostSegue", sender: self)
            } else {
                self.segueType = "link"
                performSegue(withIdentifier: "nonSelfSegue", sender: self)
            }
        }
    }

// This defines how many posts need to be displayed in the table.
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (postArray.count+1)
    }

// This populates the cells in the table with the data fetched from the .json.
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> MyCell {
        var oneCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MyCell
        if (postArray.count) == indexPath.row {
            oneCell = tableView.dequeueReusableCell(withIdentifier: "cell3", for: indexPath) as! MyCell
        }else{
                var data = Data()
                let myURL = URL(string: postArray[indexPath.row].postImageURL)
            if postArray[indexPath.row].postImageURL == "self" {
                oneCell = tableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath) as! MyCell
            }else if postArray[indexPath.row].postImageURL == "default" {
                oneCell = tableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath) as! MyCell
            }else if postArray[indexPath.row].postImageURL == "" {
                oneCell = tableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath) as! MyCell
            }else{
                    do {
                        data = try Data(contentsOf: myURL!)
                        oneCell.cellImage.image = UIImage(data: data)
                    }catch{
                        print("Error: data error fetching image")
                        print(postArray[indexPath.row].postImageURL)
                    }
            }
            oneCell.cellTitle.text = postArray[indexPath.row].postTitle
            oneCell.scoreLabel.text = String("\(postArray[indexPath.row].postScore)")
            oneCell.currentScore = postArray[indexPath.row].postScore
            oneCell.thingFullname = postArray[indexPath.row].postFullname
            if postArray[indexPath.row].postVote != nil {
                if postArray[indexPath.row].postVote == 1 {
                    oneCell.upvoteButton.setImage(#imageLiteral(resourceName: "Upvoted"), for: .normal)
                }else if postArray[indexPath.row].postVote == 0 {
                    oneCell.downvoteButton.setImage(#imageLiteral(resourceName: "Downvoted"), for: .normal)
                }
            }
       }
        return (oneCell)
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
                displayShareSheet(shareContent: "\(postArray[indexPath.row].postURL)\n\nSent via the Navvit for reddit app for iOS.")
            }
        }
    }
    
// Allows the view to display the share sheet.
    func displayShareSheet(shareContent:String) {
        let activityViewController = UIActivityViewController(activityItems: [shareContent as NSString], applicationActivities: nil)
        present(activityViewController, animated: true, completion: {})
    }
}

