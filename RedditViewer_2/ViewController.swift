//
//  ViewController.swift
//  RedditViewer_2
//
//  Created by Scott Browne on 03/09/2017.
//  Copyright © 2017 Smiles Dev. All rights reserved.
//

import UIKit

class ViewController: UITableViewController, UIApplicationDelegate {
    
    struct Section {
        var sectionName: String!
        var sectionItems: Array<String>!
    }
    
    @IBOutlet weak var myTableView: UITableView!
    
    var refresher: UIRefreshControl!
    var myURLString1 = String()
    var sectionsArray = [Section]()
    var selectedView = 0
    var loggedIn = false
    var selectedSubredditName = ""
    
    let myUDSuite: UserDefaults = UserDefaults.init(suiteName: "group.navvitForReddit")!
    var subscribedSubreddits = [String]()
    var generalOptions = ["Manually enter subreddit."]
    var defaultSubreddits: Array = ["Announcements", "Art", "AskReddit", "Askscience", "Aww", "Blog", "Books", "Creepy", "Dataisbeautiful", "DIY", "Documentaries", "EarthPorn", "Explainlikeimfive", "Food", "Funny", "Futurology", "Gadgets", "Gaming", "GetMotivated", "Gifs", "History", "IAmA", "InternetIsBeautiful", "Jokes", "LifeProTips", "Listentothis", "MagicTCG", "Mildlyinteresting", "Movies", "Music", "News", "Nosleep", "Nottheonion", "OldSchoolCool", "Personalfinance", "Philosophy", "Photoshopbattles", "Pics", "Science", "Showerthoughts", "Space", "Sports", "Television", "TIFU", "Todayilearned", "UpliftingNews", "Videos", "Worldnews"]
    
    // VIEW CONTROLLER
    
    override func viewDidLoad() {
        
        if myUDSuite.string(forKey: "Username") != nil {
            SuperFunctions().checkTokenStatus()
        }
        
        if UserDefaults.standard.string(forKey: "BrowsingPref") == nil {
            UserDefaults.standard.set("hot", forKey: "BrowsingPref")
        }
        
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: #selector(ViewController.refreshTable), for: UIControlEvents.valueChanged)
        tableView.addSubview(refresher)
        
        getSubscribedSubreddits()
        arrangeTableSections()
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // TABLEVIEW
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionsArray[section].sectionItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> CellOne {
        
        let cellOne = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CellOne
        
        cellOne.cellLabel.text = sectionsArray[indexPath.section].sectionItems[indexPath.row]
    
        return cellOne
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionsArray.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionsArray[section].sectionName
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedView = 1
        selectedSubredditName = sectionsArray[indexPath.section].sectionItems[indexPath.row]
        performSegue(withIdentifier: "subredditSegue", sender: self)
        
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        view.tintColor = UIColor(red: 1.0, green: 0.27, blue: 0.0, alpha: 1.0)
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.darkGray
    }
    
    //ACTIONS
    
    @IBAction func settingsButton(_ sender: Any) {
    
        selectedView = 2
        performSegue(withIdentifier: "settingsSegue", sender: self)

    }
    

    // SEGUES
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        
        if selectedView == 1 {
            let subredditsView = segue.destination as! View2
            subredditsView.url = myURLString1
            subredditsView.subredditName = self.selectedSubredditName
        }
        
    }
    
    @objc func refreshTable() {
        
        getSubscribedSubreddits()
        refresher.endRefreshing()
        print("Finished refreshing")
        
    }
    
    func arrangeTableSections() {
        
        if myUDSuite.string(forKey: "Username") != nil {
            
            let generalPages = ["Saved", "Submitted", "Upvoted", "Manually enter subreddit"]
            let generalSection = Section(sectionName: "General", sectionItems: generalPages)
            
            let subredditsSection = Section(sectionName: "Subscribed", sectionItems: subscribedSubreddits)
            
            sectionsArray = [generalSection, subredditsSection]
            
        } else if myUDSuite.string(forKey: "Username") == nil {
            
            let generalPages = ["Manually enter subreddit"]
            let generalSection = Section(sectionName: "General", sectionItems: generalPages)
            
            let defaultSection = Section(sectionName: "Default", sectionItems: defaultSubreddits)
            
            sectionsArray = [generalSection, defaultSection]
            
        }
    }
    
    
    func getSubscribedSubreddits(){
        
        if myUDSuite.string(forKey: "Username") != nil {

            SuperFunctions().checkTokenStatus()
            
            self.subscribedSubreddits = [String]()
            
            let subscriberURL = NSURL(string: "https://oauth.reddit.com/subreddits/mine/subscriber.json")
            let request = NSMutableURLRequest(url: subscriberURL as URL!)
            let session = URLSession.shared
            
            request.httpMethod = "GET"

            var accessTokenString = "bearer "
            accessTokenString.append(SuperFunctions().getToken(identifier: "CurrentAccessToken")!)

            request.setValue("\(accessTokenString)", forHTTPHeaderField: "Authorization")
            
            session.dataTask(with: request as URLRequest){ (data,response,error) in
                guard let data = data else { return }
                
//                let backToString = String(data: data, encoding: String.Encoding.utf8) as String!
//                print("It's me: "+backToString! as String!)
                
                do{
                    let info = try JSONDecoder().decode(subscribedSubredditsRetrieval.self, from: data)
                    
                    for children in info.data.children {
                        self.subscribedSubreddits.append(children.data.display_name)
                    }
                }catch let jsonErr {
                    print ("Error parsing subscribed subreddits.", jsonErr)
                }
                
                DispatchQueue.main.async{
                    self.arrangeTableSections()
                    self.myTableView.reloadData()
                }
                print("Subscribed subreddits loaded")
                
            }.resume()
        }
    }
}
