//
//  ManualEntryPopUpVC.swift
//  RedditViewer_2
//
//  Created by Scott Browne on 05/11/2017.
//  Copyright © 2017 Smiles Dev. All rights reserved.
//

import Foundation
import UIKit

protocol ModalViewControllerDelegate
{
    func sendValue(value: String)
}

class NVTManualPopUpVC: UIViewController{
    
    var browsePref: String? = UserDefaults.standard.string(forKey: "BrowsingPref")
    var delegate: ModalViewControllerDelegate!
    
    @IBOutlet weak var subredditTextfield: UITextField!
    @IBOutlet weak var popUpView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popUpView.layer.cornerRadius = 10
    }
    
    @IBAction func dissmissViewController(_ sender: Any) {
        delegate?.sendValue(value: subredditTextfield.text!)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func closeButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
