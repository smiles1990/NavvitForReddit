//
//  CommentCell.swift
//  RedditViewer_2
//
//  Created by Scott Browne on 08/10/2017.
//  Copyright © 2017 Smiles Dev. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {
    
    var thingFullname: String = ""
    var currentScore: Int = 0
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    
    
    @IBOutlet weak var saveButton: UIButton!
    @IBAction func saveButton(_ sender: Any) {
        
        if saveButton.currentImage == #imageLiteral(resourceName: "SaveIcon") {
            SuperFunctions().saveThing(fullname: thingFullname)
            saveButton.setImage(#imageLiteral(resourceName: "SavedIcon"), for: .normal)
        } else if saveButton.currentImage == #imageLiteral(resourceName: "SavedIcon") {
            SuperFunctions().unsaveThing(fullname: thingFullname)
            saveButton.setImage(#imageLiteral(resourceName: "SaveIcon"), for: .normal)
        }
        
        
    }
    
    // Multiple
    
    @IBOutlet weak var upvoteButton: UIButton!
    @IBAction func upvoteButton(_ sender: Any) {
        
        if upvoteButton.currentImage == #imageLiteral(resourceName: "Upvote") && downvoteButton.currentImage == #imageLiteral(resourceName: "Downvoted") {
            SuperFunctions().vote(fullname: thingFullname, direction: 1)
            upvoteButton.setImage(#imageLiteral(resourceName: "Upvoted"), for: .normal)
            downvoteButton.setImage(#imageLiteral(resourceName: "Downvote"), for: .normal)
            currentScore = (currentScore + 2)
            scoreLabel.text = "\(currentScore)"
        }else if upvoteButton.currentImage == #imageLiteral(resourceName: "Upvote") {
            SuperFunctions().vote(fullname: thingFullname, direction: 1)
            upvoteButton.setImage(#imageLiteral(resourceName: "Upvoted"), for: .normal)
            currentScore = (currentScore + 1)
            scoreLabel.text = "\(currentScore)"
        }else if upvoteButton.currentImage == #imageLiteral(resourceName: "Upvoted"){
            SuperFunctions().vote(fullname: thingFullname, direction: 0)
            upvoteButton.setImage(#imageLiteral(resourceName: "Upvote"), for: .normal)
            currentScore = (currentScore - 1)
            scoreLabel.text = "\(currentScore)"
            
        }
    }
    
    @IBOutlet weak var downvoteButton: UIButton!
    @IBAction func downvoteButton(_ sender: Any) {
     
        if downvoteButton.currentImage == #imageLiteral(resourceName: "Downvote") && upvoteButton.currentImage == #imageLiteral(resourceName: "Upvoted") {
            SuperFunctions().vote(fullname: thingFullname, direction: -1)
            downvoteButton.setImage(#imageLiteral(resourceName: "Downvoted"), for: .normal)
            upvoteButton.setImage(#imageLiteral(resourceName: "Upvote"), for: .normal)
            currentScore = (currentScore - 2)
            scoreLabel.text = "\(currentScore)"
        }else if downvoteButton.currentImage == #imageLiteral(resourceName: "Downvote") {
            SuperFunctions().vote(fullname: thingFullname, direction: -1)
            downvoteButton.setImage(#imageLiteral(resourceName: "Downvoted"), for: .normal)
            currentScore = (currentScore - 1)
            scoreLabel.text = "\(currentScore)"
        }else if downvoteButton.currentImage == #imageLiteral(resourceName: "Downvoted"){
            SuperFunctions().vote(fullname: thingFullname, direction: 0)
            downvoteButton.setImage(#imageLiteral(resourceName: "Downvote"), for: .normal)
            currentScore = (currentScore + 1)
            scoreLabel.text = "\(currentScore)"
        }
    }
    
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
