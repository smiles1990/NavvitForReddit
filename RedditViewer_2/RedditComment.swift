//
//  RedditComment.swift
//  RedditViewer_2
//
//  Created by Scott Browne on 20/11/2017.
//  Copyright © 2017 Smiles Dev. All rights reserved.
//

import Foundation

class RedditComment {
    
    let body: String
    let author: String
    let score: Int
    let likes: Int?
    let fullname: String
    
    init(body: String,
         author: String,
         score: Int,
         likes: Int?,
         fullname: String){
        
        self.body = body
        self.author = author
        self.score = score
        self.likes = likes
        self.fullname = fullname
    
    }
    
}
