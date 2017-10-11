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
                var is_self: Bool
                
            }
        }
    }
}

struct loadedPost {
    var postTitle: String
    var postImageURL: String
    var postScore: Int
    var postURL: String
    var is_self: Bool


}

class View2: UITableViewController {
    
    var postArray = [loadedPost]()
    var refresher: UIRefreshControl!
    var imageForCell = UIImage()
    var myURLString = ""
    var subredditName = ""
    var postCount = 20
    
    var postType: String = ""
    var postURL: String = ""
    
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var navItem: UINavigationItem!
    
    
    override func loadView() {
        super.loadView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SuperFunctions().checkTokenStatus()
        
        let myURLString = "https://www.reddit.com/r/"+subredditName+"/hot.json?count="+String(postCount)
        
        navItem.title = subredditName
        
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: #selector(View2.refreshTable), for: UIControlEvents.valueChanged)
        tableView.addSubview(refresher)
        
        guard let myURL = URL(string: myURLString) else { return }
        
        URLSession.shared.dataTask(with: myURL) { (data, response, error) in
            guard let data = data else { return }
            
//                let backToString = String(data: data, encoding: String.Encoding.utf8) as String!
//                print("It's me: "+backToString! as String!)

            
            do{
                let info = try JSONDecoder().decode(RedditPage.self, from: data)
                
                for children in info.data.children {
                    
//                    let post = loadedPost(postTitle: children.data.title, postImageURL: children.data.thumbnail, postScore: children.data.score, postURL: children.data.url
                    
                    let post = loadedPost(postTitle: children.data.title, postImageURL: children.data.thumbnail, postScore: children.data.score, postURL: children.data.url, is_self: children.data.is_self)
    
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
        
        if postType == "self" {
            let selfPostView = segue.destination as! SelfPostView
            selfPostView.url = postURL
        } else {
            let linkView = segue.destination as! LinkView
            linkView.url = postURL
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        self.postURL = postArray[indexPath.row].postURL
        
        if postArray[indexPath.row].is_self == true {
            self.postType = "self"
            performSegue(withIdentifier: "selfPostSegue", sender: self)
        } else {
            self.postType = "link"
            performSegue(withIdentifier: "nonSelfSegue", sender: self)
        }
        
    }
    
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.postArray.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> MyCell {
        
        var oneCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MyCell
        
        if postArray.count != 0 {
        
            var data = Data()
            let myURL = URL(string: postArray[indexPath.row].postImageURL)
            
            if postArray[indexPath.row].postImageURL != "" {
                do {
                    data = try Data(contentsOf: myURL!)
                    oneCell.cellImage.image = UIImage(data: data)
                }catch{
                    print("Error: data error")
                }
            }else{
                oneCell = tableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath) as! MyCell
                //oneCell.cellImage.isHidden = true
            }
            
            oneCell.cellTitle.text = postArray[indexPath.row].postTitle
            oneCell.cellScore.text = String("\(postArray[indexPath.row].postScore)")
            
        }else{
            print("Post Array:", postArray.count)
        }
        return (oneCell)
    }
    
    @objc func refreshTable() {
        tableView.reloadData()
        refresher.endRefreshing()
        print("Finished refreshing")
    }
    
}

    
    


