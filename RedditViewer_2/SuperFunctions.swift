//
//  SuperFunctions.swift
//  RedditViewer_2
//
//  Created by Scott Browne on 23/09/2017.
//  Copyright © 2017 Smiles Dev. All rights reserved.
//

import Foundation
import UIKit
import os.log
import Security

//Structures for JSON Decoding

struct AccessTokenRetrieval: Codable{
    let access_token: String
    let refresh_token: String
}

struct RefreshUserToken: Codable {
    let access_token: String
    let expires_in: Double
}

struct GetUserInfo: Codable{
    let name: String
    let link_karma: Int
    let comment_karma: Int
}

struct subscribedSubredditsRetrieval: Codable{
    var data: data
    struct data: Codable{
        var children: Array<data>
        struct data: Codable{
            let data: subscribedSubreddit
            struct subscribedSubreddit: Codable{
            let display_name: String
            }
        }
    }
}


class SuperFunctions{
    
    var subscribedSubreddits = [String]()
    let myUDSuite: UserDefaults = UserDefaults.init(suiteName: "group.navvitForReddit")!
    
// Defining variables required by Keychain.
    let kSecClassGenericPasswordValue = String(format: kSecClassGenericPassword as String)
    let kSecClassValue = String(format: kSecClass as String)
    let kSecAttrServiceValue = String(format: kSecAttrService as String)
    let kSecValueDataValue = String(format: kSecValueData as String)
    let kSecMatchLimitValue = String(format: kSecMatchLimit as String)
    let kSecReturnDataValue = String(format: kSecReturnData as String)
    let kSecMatchLimitOneValue = String(format: kSecMatchLimitOne as String)
    let kSecAttrAccountValue = String(format: kSecAttrAccount as String)

// *** TOKEN FUNCTIONS ***
// Aqcuiring and maintaining the current user's Access and Refresh tokens, these are required to access account specific data and posting content from the user's account.
    
//Get the initial Access token and Refresh token for the current user.
    func getAccessToken(){
        
        if UserDefaults.standard.string(forKey: "UserAuthCode") != nil {
            
            let authCode = UserDefaults.standard.string(forKey: "UserAuthCode")
            
            let accessTokenURL = NSURL(string: "https://www.reddit.com/api/v1/access_token")
            let request = NSMutableURLRequest(url: accessTokenURL as URL!)
            let session = URLSession.shared
            request.httpMethod = "POST"
            var postString = "grant_type=authorization_code&code="
            postString.append(authCode!)
            postString.append("&redirect_uri=http://www.reddit.com")
            print(postString)
            var loginString = ""
            loginString.append(UserDefaults.standard.string(forKey: "ClientID")!)
            loginString.append(": ")
            let loginData = loginString.data(using: String.Encoding.utf8)!
            let base64EncodedString = loginData.base64EncodedString()
            request.setValue("Basic \(base64EncodedString)", forHTTPHeaderField: "Authorization")
            request.httpBody = postString.data(using: String.Encoding.utf8)
            
            session.dataTask(with: request as URLRequest){ (data,response,error) in
                guard let data = data else { return }
                    let backToString = String(data: data, encoding: String.Encoding.utf8) as String!
                    print(backToString as String!)
                do{
                    let info = try JSONDecoder().decode(AccessTokenRetrieval.self, from: data)
                    self.setToken(identifier: "CurrentAccessToken", token: info.access_token)
                    self.setToken(identifier: "CurrentRefreshToken", token: info.refresh_token)
                    
                }catch let jsonErr {
                    print ("Error parsing Access/Refresh tokens", jsonErr)
                }

                self.getUserInfo()

            }.resume()
        }
    }
    
//Refresh the current Access token.
    func refreshToken(){
        
        if myUDSuite.string(forKey: "Username") != nil {
            
            let accessTokenURL = NSURL(string: "https://www.reddit.com/api/v1/access_token")
            let request = NSMutableURLRequest(url: accessTokenURL as URL!)
            let session = URLSession.shared
            request.httpMethod = "POST"
            
            let postString = "grant_type=refresh_token&refresh_token="+getToken(identifier: "CurrentRefreshToken")!

            print(postString)
            print("I tried to post the string")
            
            var loginString = ""
            loginString.append(UserDefaults.standard.string(forKey: "ClientID")!)
            loginString.append(": ")
            let loginData = loginString.data(using: String.Encoding.utf8)!
            let base64EncodedString = loginData.base64EncodedString()
            
            request.setValue("Basic \(base64EncodedString)", forHTTPHeaderField: "Authorization")
            request.httpBody = postString.data(using: String.Encoding.utf8)
            
            var tokenExpiry = (Date().timeIntervalSince1970 * 1000)
            
            session.dataTask(with: request as URLRequest){ (data,response,error) in
                guard let data = data else { return }
//                let backToString = String(data: data, encoding: String.Encoding.utf8) as String!
//                print(backToString as String!)
                do{
                    let info = try JSONDecoder().decode(RefreshUserToken.self, from: data)
                    self.setToken(identifier: "CurrentAccessToken", token: info.access_token)
                    tokenExpiry = tokenExpiry + info.expires_in
                    UserDefaults.standard.set(tokenExpiry, forKey: "expiryTime")
                }catch let jsonErr {
                    print ("Error parsing Access token and/or Expiry time", jsonErr)
                }
                }.resume()
        }else{
            if UserDefaults.standard.string(forKey: "currentAuthCode") != nil {
                getAccessToken()
            }
        }
    }
//Check to see if the current Access token has expired, if so, refresh the Access token.
    func checkTokenStatus() {
        
        if (Date().timeIntervalSince1970 * 1000) >= UserDefaults.standard.double(forKey: "expiryTime") {
            refreshToken()
            print("Access token refreshed")
        }else{
            print("Token is still valid")
        }
    }
    
//Fetch the current user's Username, Comment Karma and Post Karma.
    func getUserInfo() {
        
        let myURL = NSURL(string: "https://oauth.reddit.com/api/v1/me.json")
        let request = NSMutableURLRequest(url: myURL as URL!)
        let session = URLSession.shared
        
        request.httpMethod = "GET"
        
        if SuperFunctions().getToken(identifier: "CurrentAccessToken") != nil {
            
            var accessTokenString = "bearer "
            accessTokenString.append(SuperFunctions().getToken(identifier: "CurrentAccessToken")!)
            request.setValue("\(accessTokenString)", forHTTPHeaderField: "Authorization")
            
        }
        
        session.dataTask(with: request as URLRequest) { (data, response, error) in
            guard let data = data else { return }
            
            do{
                let info = try JSONDecoder().decode(GetUserInfo.self, from: data)
                self.myUDSuite.set(info.name, forKey: "Username")
                self.myUDSuite.set(info.comment_karma, forKey: "CommentKarma")
                self.myUDSuite.set(info.link_karma, forKey: "PostKarma")
            } catch let jsonErr {
                print("Error parsing user info", jsonErr)
            }
        }.resume()
        
    }
    
    func getSubscribedSubreddits(){
        if myUDSuite.string(forKey: "Username") != nil {
            self.checkTokenStatus()
            self.subscribedSubreddits = [String]()
            let subscriberURL = NSURL(string: "https://oauth.reddit.com/subreddits/mine/subscriber.json")
            let request = NSMutableURLRequest(url: subscriberURL as URL!)
            let session = URLSession.shared
            request.httpMethod = "GET"
            var accessTokenString = "bearer "
            accessTokenString.append(SuperFunctions().getToken(identifier: "CurrentAccessToken")!)
            request.setValue("\(accessTokenString)", forHTTPHeaderField: "Authorization")
            session.dataTask(with: request as URLRequest){ (data,response,error) in
                guard let data = data else { return }
                //                let backToString = String(data: data, encoding: String.Encoding.utf8) as String!
                //                print("It's me: "+backToString! as String!)
                do{
                    let info = try JSONDecoder().decode(subscribedSubredditsRetrieval.self, from: data)
                    for children in info.data.children {
                        self.subscribedSubreddits.append(children.data.display_name)
                    }
                }catch let jsonErr {
                    print ("Error parsing subscribed subreddits.", jsonErr)
                }
                DispatchQueue.main.async{
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "subs"), object: nil)
                }
            }.resume()
        }
    }
    
    
    
    
    
    
// *** PERFORMING ACTIONS ON REDDIT ***
// functions for posting/voting/saving posts and comments.
    
        //Add a post to your reddit account's Saved list.
    func saveThing(fullname: String){
        
        let voteURLString = "https://oauth.reddit.com/api/save"
        let voteURL = URL(string: voteURLString)
        
        let request = NSMutableURLRequest(url: voteURL as URL!)
        let session = URLSession.shared
        request.httpMethod = "POST"
        
        let postString = "id="+fullname
        
        var accessTokenString = "bearer "
        accessTokenString.append(SuperFunctions().getToken(identifier: "CurrentAccessToken")!)
        
        request.setValue("\(accessTokenString)", forHTTPHeaderField: "Authorization")
        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        session.dataTask(with: request as URLRequest){ (data,response,error) in
            //guard let data = data else { return }
            //let backToString = String(data: data, encoding: String.Encoding.utf8) as String!
            //print(backToString as String!)
        }.resume()
    }
    
//Remove a post to your reddit account's Saved list.
    func unsaveThing(fullname: String){

        let voteURLString = "https://oauth.reddit.com/api/unsave"
        let voteURL = URL(string: voteURLString)
        
        let request = NSMutableURLRequest(url: voteURL as URL!)
        let session = URLSession.shared
        request.httpMethod = "POST"
        
        let postString = "id="+fullname
        
        var accessTokenString = "bearer "
        accessTokenString.append(SuperFunctions().getToken(identifier: "CurrentAccessToken")!)
        
        request.setValue("\(accessTokenString)", forHTTPHeaderField: "Authorization")
        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        session.dataTask(with: request as URLRequest){ (data,response,error) in
            //guard let data = data else { return }
            //let backToString = String(data: data, encoding: String.Encoding.utf8) as String!
            //print(backToString as String!)
        }.resume()
    }
    
//Comment on a post, or even another comment on reddit from the current user account.
    func commentOnAThing(fullname: String, comment: String){
        
        let commentURLString = "https://oauth.reddit.com/api/comment"
        let commentURL = URL(string: commentURLString)
        
        let rawMDComment = comment
        
        let request = NSMutableURLRequest(url: commentURL as URL!)
        let session = URLSession.shared
        request.httpMethod = "POST"
        
        let postString = "api_type=json&thing_id="+fullname+"&text="+rawMDComment
        
        var accessTokenString = "bearer "
        accessTokenString.append(SuperFunctions().getToken(identifier: "CurrentAccessToken")!)
        
        request.setValue("\(accessTokenString)", forHTTPHeaderField: "Authorization")
        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        session.dataTask(with: request as URLRequest){ (data,response,error) in
            //guard let data = data else { return }
            //let backToString = String(data: data, encoding: String.Encoding.utf8) as String!
            //print(backToString as String!)
            }.resume()
    }
    
//Upvote, downvote or un-vote a post or a comment from the current user account.
    func vote(fullname: String, direction: Int ){
        
        let voteURLString = "https://oauth.reddit.com/api/vote"
        let voteURL = URL(string: voteURLString)
        
        let request = NSMutableURLRequest(url: voteURL as URL!)
        let session = URLSession.shared
        request.httpMethod = "POST"
        
        let postString = "id="+fullname+"&dir="+String("\(direction)")
        //print(postString)
        
        var accessTokenString = "bearer "
        accessTokenString.append(SuperFunctions().getToken(identifier: "CurrentAccessToken")!)
        
        request.setValue("\(accessTokenString)", forHTTPHeaderField: "Authorization")
        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        session.dataTask(with: request as URLRequest){ (data,response,error) in
            //guard let data = data else { return }
            //let backToString = String(data: data, encoding: String.Encoding.utf8) as String!
            //print(backToString as String!)
            
        }.resume()
    }
//Subscribe or unsubscribe to a subreddit on the current user's account.
    func subscribe(subreddit: String, mode: String){
        
        let subURLString = "https://oauth.reddit.com/api/subscribe"
        let subURL = URL(string: subURLString)
        
        let request = NSMutableURLRequest(url: subURL as URL!)
        let session = URLSession.shared
        request.httpMethod = "POST"
        
        let postString = "sr="+subreddit+"&action="+mode
        print(postString)
        
        var accessTokenString = "bearer "
        accessTokenString.append(SuperFunctions().getToken(identifier: "CurrentAccessToken")!)
        
        request.setValue("\(accessTokenString)", forHTTPHeaderField: "Authorization")
        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        session.dataTask(with: request as URLRequest){ (data,response,error) in
            guard let data = data else { return }
            let backToString = String(data: data, encoding: String.Encoding.utf8) as String!
            print(backToString as String!)
            
            }.resume()
    }
    
    
    
    
    
    
    
    
    
    
    
    
// *** KEYCHAIN FUNCTIONS ***
// These functions read and write data encrypted and stored securely in the device's user Keychain.

// Set the value for the current Access/Refresh token.
    func setToken(identifier: String, token: String) {
        if let dataFromString = token.data(using: String.Encoding.utf8) {
            let keychainQuery = [
                kSecClassValue: kSecClassGenericPasswordValue,
                kSecAttrServiceValue: identifier,
                kSecValueDataValue: dataFromString
                ] as CFDictionary
            SecItemDelete(keychainQuery)
            print(SecItemAdd(keychainQuery, nil))
        }
    }
    
// Get the value for the current Access/Refresh token.
    func getToken(identifier: String) -> String? {
        let keychainQuery = [
            kSecClassValue: kSecClassGenericPasswordValue,
            kSecAttrServiceValue: identifier,
            kSecReturnDataValue: kCFBooleanTrue,
            kSecMatchLimitValue: kSecMatchLimitOneValue
            ] as  CFDictionary

        var dataTypeRef: AnyObject?
        let status: OSStatus = SecItemCopyMatching(keychainQuery, &dataTypeRef)
        var passcode: String?
        if (status == errSecSuccess) {
            if let retrievedData = dataTypeRef as? Data,
                let result = String(data: retrievedData, encoding: String.Encoding.utf8) {
                passcode = result as String
            }
        }else{
            print("Nothing was retrieved from the keychain. Status code \(status)")
        }
        return passcode
    }
    
    
    
    
// *** OTHER ***
    
    func randomString(length: Int) -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        return randomString
    }
    
}

