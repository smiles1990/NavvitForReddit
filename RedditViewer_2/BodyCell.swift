//
//  BodyCell.swift
//  RedditViewer_2
//
//  Created by Scott Browne on 08/10/2017.
//  Copyright © 2017 Smiles Dev. All rights reserved.
//

import UIKit

class BodyCell: UITableViewCell {
    
    @IBOutlet weak var bodyLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
