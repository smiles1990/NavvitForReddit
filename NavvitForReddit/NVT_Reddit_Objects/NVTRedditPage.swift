//
//  RedditPage.swift
//  RedditViewer_2
//
//  Created by Scott Browne on 18/11/2017.
//  Copyright © 2017 Smiles Dev. All rights reserved.
//

import UIKit

struct RedditPageJSON: Codable {
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
                let saved: Int?
                let created: Double
            }
        }
    }
}

class NVTRedditPage{
    
    var subredditName: String
    var contents: [NVTRedditPost]
    var lastFullname: String
    var isSubreddit: Bool
    
    init(subredditName: String){
        self.subredditName = subredditName
        contents = [NVTRedditPost]()
        lastFullname = ""
        isSubreddit = Bool()
        getPage()
    }
    
    func getPage(){
        
        NVTSuperFunctions().checkTokenStatus()
        
        var urlString: String = ""
        let myUDSuite = UserDefaults.init(suiteName: "group.navvitForReddit")
        let browsePref: String? = UserDefaults.standard.string(forKey: "BrowsingPref")
        let postCount = 10

        if subredditName == "Upvoted"{
            urlString = "https://www.reddit.com/user/"+(myUDSuite?.string(forKey: "Username"))!+"/upvoted.json"
        }else if subredditName == "Saved"{
            urlString = "https://www.reddit.com/user/"+(myUDSuite?.string(forKey: "Username"))!+"/saved.json"
        }else if subredditName == "Submitted"{
            urlString = "https://www.reddit.com/user/"+(myUDSuite?.string(forKey: "Username"))!+"/submitted.json"
        }else{
            self.isSubreddit = true
            if lastFullname == "" {
                urlString = "https://www.reddit.com/r/"+subredditName+"/"+browsePref!+".json?count="
                urlString.append(String(postCount))
            } else {
                urlString = "https://www.reddit.com/r/"+subredditName+"/"+browsePref!+".json?count="
                urlString.append(String(postCount)+"&after="+lastFullname)
            }
        }
        
        if NVTSuperFunctions().getToken(identifier: "CurrentAccessToken") != nil {
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
            accessTokenString.append(NVTSuperFunctions().getToken(identifier: "CurrentAccessToken")!)
            request.setValue("\(accessTokenString)", forHTTPHeaderField: "Authorization")
        }
        
        session.dataTask(with: request as URLRequest ) { (data, response, error) in
            guard let data = data else { return }
            //                let backToString = String(data: data, encoding: String.Encoding.utf8) as String!
            //                print(backToString as String!)
            do{
                let info = try JSONDecoder().decode(RedditPageJSON.self, from: data)
                for children in info.data.children {
                    let post = NVTRedditPost(postTitle: children.data.title,
                                          postImageURL: children.data.thumbnail,
                                          postScore: children.data.score,
                                          postURL: children.data.url,
                                          postID: children.data.id,
                                          is_self: children.data.is_self,
                                          selftext: children.data.selftext,
                                          postFullname: children.data.name,
                                          postVote: children.data.likes,
                                          postAuthor: children.data.author,
                                          postSaved: children.data.saved,
                                          postCreated: children.data.created)
                    self.lastFullname = children.data.name
                    self.contents.append(post)
                }
            }catch let jsonErr {
                print ("Error loading parsing RedditPage JSON", jsonErr)
            }
            
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "postsLoaded"), object: nil)
            }
            
        }.resume()
    }
}
