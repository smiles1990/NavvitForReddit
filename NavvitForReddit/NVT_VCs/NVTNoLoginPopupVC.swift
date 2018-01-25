//
//  NVTNoLoginPopupVC.swift
//  NavvitForReddit
//
//  Created by Scott Browne on 24/01/2018.
//  Copyright © 2018 Smiles Dev. All rights reserved.
//

import Foundation
import UIKit

protocol ModalViewControllerDelegate
{
    func showNoLoginVC()
}

class NVTNoLoginPopUpVC: UIViewController{
    
    var browsePref: String? = UserDefaults.standard.string(forKey: "BrowsingPref")
    var delegate: ModalViewControllerDelegate!
    

    @IBOutlet weak var popUpView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popUpView.layer.cornerRadius = 10
    }
    
    @IBAction func logInButton(_ sender: Any) {
        performSegue(withIdentifier: "PopOverToAuth", sender: self)
    }
    
    
    @IBAction func closeButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
