//
//  RedditPost.swift
//  RedditViewer_2
//
//  Created by Scott Browne on 18/11/2017.
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


class NVTRedditPost{
    
    let postTitle: String
    let postImageURL: String
    let postScore: Int
    let postURL: String
    let postID: String
    let is_self: Bool
    let selftext: String?
    let postFullname: String
    let postVote: Int?
    let postAuthor: String
    let postSaved: Int?
    let postCreated: Double
    var commentsArray: [NVTRedditComment]?
    
    init(postTitle: String,
        postImageURL: String,
        postScore: Int,
        postURL: String,
        postID: String,
        is_self: Bool,
        selftext: String?,
        postFullname: String,
        postVote: Int?,
        postAuthor: String,
        postSaved: Int?,
        postCreated: Double) {
    
        self.postTitle = postTitle
        self.postImageURL = postImageURL
        self.postScore = postScore
        self.postURL = postURL
        self.postID = postID
        self.is_self = is_self
        self.selftext = selftext
        self.postFullname = postFullname
        self.postVote = postVote
        self.postAuthor = postAuthor
        self.postSaved = postSaved
        self.postCreated = postCreated
        
    }
    
    let myUDSuite: UserDefaults = UserDefaults.init(suiteName: "group.navvitForReddit")!
    
    func getComments() {
        
//        guard let jsonURL = URL(string: url) else { return }
//        URLSession.shared.dataTask(with: jsonURL) { (data, response, error) in
        
        var url = self.postURL
        
        if myUDSuite.string(forKey: "Username") != nil {
            url = String(url.dropFirst(11))
            url = "https://oauth"+url
        }
        
        let jsonURL = NSURL(string: url)
        
        let request = NSMutableURLRequest(url: jsonURL as URL!)
        let session = URLSession.shared
        
        request.httpMethod = "GET"
        
        if UserDefaults.standard.stringArray(forKey: "Username") != nil {
            var accessTokenString = "bearer "
            accessTokenString.append(NVTSuperFunctions().getToken(identifier: "CurrentAccessToken")!)
        
            request.setValue("\(accessTokenString)", forHTTPHeaderField: "Authorization")
        }
        
        session.dataTask(with: request as URLRequest) { (data, response, error) in
            guard let data = data else {return}
            
//            let backToString = String(data: data, encoding: String.Encoding.utf8) as String!
//            print("It's me: "+backToString! as String!)
            
            do {
                let info = try JSONDecoder().decode([commentLoader].self, from: data)
                
//                for children in info[0].data.children {
//                    self.postFullname = children.data.name
//                    self.postAuthor = (children.data.author ?? "")!
//                    self.postVote = children.data.likes ?? nil
//                    self.postSaved = children.data.saved ?? 0
//                }
                
                for children in info[1].data.children {
                    
                    let comment = NVTRedditComment.init(body: (children.data.body ?? ""), author: (children.data.author ?? "")!, score: (children.data.score ?? 0)!, likes: children.data.likes, fullname: children.data.name)
                    
                    if self.commentsArray == nil {
                        self.commentsArray = [comment]
                    } else {
                        self.commentsArray?.append(comment)
                    }
                }
                
            }catch let jsonErr{
                print("Error parsing comments JSON:", jsonErr)
            }
            
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "commentsLoaded"), object: nil)
            }
            
        }.resume()
        
    }
    
}
