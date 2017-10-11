//
//  LinkView.swift
//  RedditViewer_2
//
//  Created by Scott Browne on 08/10/2017.
//  Copyright © 2017 Smiles Dev. All rights reserved.
//

import UIKit
import WebKit

class LinkView: UIViewController, WKNavigationDelegate {
    
    
    @IBOutlet internal var containerView: UIView? = nil
    var webView: WKWebView?
    var url: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let myURL = URL(string: self.url)
        let myRequest = URLRequest(url: myURL!)
        _ = webView?.load(myRequest)
        
    }
    
    override func loadView() {
        super.loadView()
        self.webView = WKWebView()
        self.view = self.webView
    }
}
