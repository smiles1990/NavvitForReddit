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

struct AccessTokenRetrieval: Codable{
    
    let access_token: String
//    let token_type: String
//    let scope: String
    let refresh_token: String
    
}

struct RefreshUserToken: Codable {
    
    let access_token: String
    let expires_in: Double
    
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
    
    func getAccessToken(){
        
        let accessTokenURL = NSURL(string: "https://www.reddit.com/api/v1/access_token")
        let request = NSMutableURLRequest(url: accessTokenURL as URL!)
        let session = URLSession.shared
        request.httpMethod = "POST"
        var postString = "grant_type=authorization_code&code="
        postString.append(UserDefaults.standard.string(forKey: "currentAuthCode")!)
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
                UserDefaults.standard.set(info.access_token, forKey: "currentAccessToken")
                UserDefaults.standard.set(info.refresh_token, forKey: "currentRefreshToken")
            }catch let jsonErr {
                print ("I failed my liege, forgive me, please!", jsonErr)
            }
            
            }.resume()
    }
    
    
    
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
    
    func parseAuthCode(returnedString: String) {
        
        let authCode = String(returnedString.dropFirst(46))
        print(authCode)
        UserDefaults.standard.set(authCode, forKey: "currentAuthCode")
        
    }
    
    func refreshToken(){
        
        if UserDefaults.standard.string(forKey: "currentAccessToken") != nil {
            
            let accessTokenURL = NSURL(string: "https://www.reddit.com/api/v1/access_token")
            let request = NSMutableURLRequest(url: accessTokenURL as URL!)
            let session = URLSession.shared
            request.httpMethod = "POST"
            
            let postString = "grant_type=refresh_token&refresh_token="+UserDefaults.standard.string(forKey: "currentRefreshToken")!
            
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
    //            let backToString = String(data: data, encoding: String.Encoding.utf8) as String!
    //            print(backToString as String!)
                do{
                    let info = try JSONDecoder().decode(RefreshUserToken.self, from: data)
                    UserDefaults.standard.set(info.access_token, forKey: "currentAccessToken")
                    tokenExpiry = tokenExpiry + info.expires_in
                    UserDefaults.standard.set(tokenExpiry, forKey: "expiryTime")
                }catch let jsonErr {
                    print ("I failed Sire, forgive me, please!", jsonErr)
                }
            }.resume()
        }
    }

    func checkTokenStatus() {
        
        if (Date().timeIntervalSince1970 * 1000) >= UserDefaults.standard.double(forKey: "expiryTime") {
            refreshToken()
        }else{
            print("Token is still valid")
        }
        
        
    }
    
    func vote(fullname: String, direction: Int ){
        
        let voteURLString = "https://oauth.reddit.com/api/vote"
        let voteURL = URL(string: voteURLString)
        
        let request = NSMutableURLRequest(url: voteURL as URL!)
        let session = URLSession.shared
        request.httpMethod = "POST"
        
        let postString = "id="+fullname+"&dir="+String("\(direction)")
        //print(postString)
        
        var accessTokenString = "bearer "
        accessTokenString.append(UserDefaults.standard.string(forKey: "currentAccessToken")!)
        
        request.setValue("\(accessTokenString)", forHTTPHeaderField: "Authorization")
        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        session.dataTask(with: request as URLRequest){ (data,response,error) in
            //guard let data = data else { return }
            //let backToString = String(data: data, encoding: String.Encoding.utf8) as String!
            //print(backToString as String!)
            
        }.resume()
    }
    
}






















//        ####UserDefaults Keys####

//          currentStateString
//          currentAuthCode
//          currentAccessToken
//          ClientID

