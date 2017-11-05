//
//  CommentPopUpVC.swift
//  RedditViewer_2
//
//  Created by Scott Browne on 26/10/2017.
//  Copyright © 2017 Smiles Dev. All rights reserved.
//

import UIKit

class CommentPopUpVC: UIViewController {
    

    
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var commentField: UITextView!
    var fullname: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        popUpView.layer.cornerRadius = 10
        
    }
    
    
    
    @IBAction func postButton(_ sender: Any) {
        
        SuperFunctions().commentOnAThing(fullname: fullname, comment: commentField.text)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func closeButton(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
