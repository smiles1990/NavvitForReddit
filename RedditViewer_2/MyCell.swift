//
//  MyCell.swift
//  RedditViewer_2
//
//  Created by Scott Browne on 03/09/2017.
//  Copyright © 2017 Smiles Dev. All rights reserved.
//

import UIKit

class MyCell: UITableViewCell {

// Definine variables and outlets.
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var cellTitle: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!

    var currentScore = Int()
    var thingFullname = String()
    
// These two buttons use the buttons' states to determine how they want to vote, based on what the user pressed
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
