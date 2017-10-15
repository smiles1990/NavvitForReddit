//
//  View2.swift
//  RedditViewer_2
//
//  Created by Scott Browne on 03/09/2017.
//  Copyright © 2017 Smiles Dev. All rights reserved.
//

import UIKit

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
                let selftext: String
                let name: String
                
            }
        }
    }
}

struct loadedPost {
    let postTitle: String
    let postImageURL: String
    let postScore: Int
    let postURL: String
    let postID: String
    let is_self: Bool
    let selftext: String
    let postFullname: String
}

class View2: UITableViewController {
    
    var postArray = [loadedPost]()
    var refresher: UIRefreshControl!
    var imageForCell = UIImage()
    var myURLString = ""
    var subredditName = ""
    var postCount = 10
    var postID: String = ""
    var postType: String = ""
    var postURL: String = ""
    var postBody: String = ""
    var postTitle: String = ""
    var lastFullname: String = ""
    
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var navItem: UINavigationItem!
    
    
    override func loadView() {
        super.loadView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SuperFunctions().checkTokenStatus()
        
        navItem.title = subredditName
        
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: #selector(View2.refreshTable), for: UIControlEvents.valueChanged)
        tableView.addSubview(refresher)
        
        let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(View2.handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 1.0
        longPressGesture.delegate = self as? UIGestureRecognizerDelegate
        self.tableView.addGestureRecognizer(longPressGesture)
    
        getPosts()
    }
    
    func getPosts(){
        
        var myURLString: String = ""
        
        if lastFullname == "" {
            myURLString = "https://www.reddit.com/r/"+subredditName+"/hot.json?count="+String(postCount)
        } else {
            myURLString = "https://www.reddit.com/r/"+subredditName+"/hot.json?count="+String(postCount)+"&after="+lastFullname
        }
        
        guard let myURL = URL(string: myURLString) else { return }
        
        let session = URLSession.shared
        
        //        let request = NSMutableURLRequest(url: myURL as URL!)
        //        request.httpMethod = "GET"
        
        session.dataTask(with: myURL) { (data, response, error) in
            guard let data = data else { return }
            
            //            let backToString = String(data: data, encoding: String.Encoding.utf8) as String!
            //            print(backToString as String!)
            
            do{
                let info = try JSONDecoder().decode(RedditPage.self, from: data)
                
                for children in info.data.children {
                    
                    let post = loadedPost(postTitle: children.data.title, postImageURL: children.data.thumbnail, postScore: children.data.score, postURL: children.data.url, postID: children.data.id, is_self: children.data.is_self, selftext: children.data.selftext, postFullname: children.data.name)
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if self.postType == "self" {
            
            let postURLString = "https://www.reddit.com/r/"+subredditName+"/comments/"+postID+".json"
            
            let selfPostView = segue.destination as! SelfPostView
            selfPostView.url = postURLString
            selfPostView.postTitle = self.postTitle
            selfPostView.postBody = self.postBody
            
        } else {
            let linkView = segue.destination as! LinkView
            linkView.url = postURL
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == (postArray.count) {
            getPosts()
        }else{
            self.postURL = postArray[indexPath.row].postURL
            self.postID = postArray[indexPath.row].postID
            
            if postArray[indexPath.row].is_self == true {
                self.postType = "self"
                self.postTitle = postArray[indexPath.row].postTitle
                self.postBody = postArray[indexPath.row].selftext
                performSegue(withIdentifier: "selfPostSegue", sender: self)
            } else {
                self.postType = "link"
                performSegue(withIdentifier: "nonSelfSegue", sender: self)
            }
        }
        
    }
    
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (postArray.count+1)
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> MyCell {
        
        var oneCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MyCell
        
        if (postArray.count) == indexPath.row {
            oneCell = tableView.dequeueReusableCell(withIdentifier: "cell3", for: indexPath) as! MyCell
        }else{
                var data = Data()
                let myURL = URL(string: postArray[indexPath.row].postImageURL)
                    
                if postArray[indexPath.row].postImageURL != "" {
                    do {
                        data = try Data(contentsOf: myURL!)
                        oneCell.cellImage.image = UIImage(data: data)
                    }catch{
                        print("Error: data error fetching image")
                    }
                }else{
                    oneCell = tableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath) as! MyCell
                }
                    
            oneCell.cellTitle.text = postArray[indexPath.row].postTitle
            oneCell.cellScore.text = String("\(postArray[indexPath.row].postScore)")
            oneCell.initialScore = postArray[indexPath.row].postScore
            oneCell.cellFullname = postArray[indexPath.row].postFullname
            
       }
        return (oneCell)
    }
    
    @objc func refreshTable() {
        tableView.reloadData()
        refresher.endRefreshing()
        print("Finished refreshing")
    }
    
    @objc func handleLongPress(_ longPressGestureRecognizer: UILongPressGestureRecognizer) {
        
        if longPressGestureRecognizer.state == UIGestureRecognizerState.began {
            
            let touchPoint = longPressGestureRecognizer.location(in: self.view)
            if let indexPath = myTableView.indexPathForRow(at: touchPoint) {
                
                displayShareSheet(shareContent: "\(postArray[indexPath.row].postURL)\n\nSent via the Viewr for redditapp for iOS.")
            }
        }
    }
    
    func displayShareSheet(shareContent:String) {
        let activityViewController = UIActivityViewController(activityItems: [shareContent as NSString], applicationActivities: nil)
        present(activityViewController, animated: true, completion: {})
    }
}

