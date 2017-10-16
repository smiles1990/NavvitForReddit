//
//  MyCell.swift
//  RedditViewer_2
//
//  Created by Scott Browne on 03/09/2017.
//  Copyright © 2017 Smiles Dev. All rights reserved.
//

import UIKit

class MyCell: UITableViewCell {

    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var cellTitle: UILabel!
    @IBOutlet weak var cellScore: UILabel!
    var initialScore = Int()
    var cellFullname = String()
    

    @IBAction func upvoteButton(_ sender: Any) {
        SuperFunctions().vote(fullname: cellFullname, direction: 1)
        self.cellScore.text = String("\(initialScore+1)")
        self.cellScore.textColor = UIColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0)
    }
    
    @IBAction func downvoteButton(_ sender: Any) {
        SuperFunctions().vote(fullname: cellFullname, direction: -1)
        self.cellScore.text = String("\(initialScore-1)")
        self.cellScore.textColor = UIColor(red: 0.0, green: 0.5, blue: 1.0, alpha: 1.0)
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
