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
    var whichView = 0
    var loggedIn = false
    var selectedSubredditName = ""
    var subsLoadedTrigger = 0
    
    var subscribedSubreddits = [String]()
    var defaultSubreddits: Array = ["Announcements", "Art", "AskReddit", "Askscience", "Aww", "Blog", "Books", "Creepy", "Dataisbeautiful", "DIY", "Documentaries", "EarthPorn", "Explainlikeimfive", "Food", "Funny", "Futurology", "Gadgets", "Gaming", "GetMotivated", "Gifs", "History", "IAmA", "InternetIsBeautiful", "Jokes", "LifeProTips", "Listentothis", "MagicTCG", "Mildlyinteresting", "Movies", "Music", "News", "Nosleep", "Nottheonion", "OldSchoolCool", "Personalfinance", "Philosophy", "Photoshopbattles", "Pics", "Science", "Showerthoughts", "Space", "Sports", "Television", "TIFU", "Todayilearned", "UpliftingNews", "Videos", "Worldnews"]
    
    // VIEW CONTROLLER
    
    override func viewDidLoad() {
        
        SuperFunctions().checkTokenStatus()
        
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: #selector(ViewController.refreshTable), for: UIControlEvents.valueChanged)
        tableView.addSubview(refresher)
        
        let defaultSubredditsSetion = Section(sectionName: "Default", sectionItems: defaultSubreddits)
        self.sectionsArray.append(defaultSubredditsSetion)
        
        if subsLoadedTrigger == 0 {
            getSubscribedSubreddits()
        }else{
            print("Subs already loaded.")
        }
        

 
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
        
        whichView = 1
        selectedSubredditName = sectionsArray[indexPath.section].sectionItems[indexPath.row]
        performSegue(withIdentifier: "subredditSegue", sender: self)
        
    }
    
    
    //ACTIONS
    
    @IBAction func settingsButton(_ sender: Any) {
    
        whichView = 2
        performSegue(withIdentifier: "settingsSegue", sender: self)

    }
    

    // SEGUES
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        
        if whichView == 1 {
            let subredditsView = segue.destination as! View2
            subredditsView.myURLString = myURLString1
            subredditsView.subredditName = self.selectedSubredditName
        }
        
    }
    
    @objc func refreshTable() {
        
//        if self.sectionsArray.count == 2 {
//        }else{
//            let subscribedSubredditsSection = Section(sectionName: "Subscribed", sectionItems: subscribedSubreddits)
//            self.sectionsArray.insert(subscribedSubredditsSection, at: 0)
//        }
        
        getSubscribedSubreddits()
        self.myTableView.reloadData()
        
        refresher.endRefreshing()
        print("Finished refreshing")
    }
    
    
    func getSubscribedSubreddits(){
        
        print ("I'm being called")
        if UserDefaults.standard.string(forKey: "currentAccessToken") != nil {
            SuperFunctions().checkTokenStatus()
            
            let subscriberURL = NSURL(string: "https://oauth.reddit.com/subreddits/mine/subscriber.json")
            let request = NSMutableURLRequest(url: subscriberURL as URL!)
            let session = URLSession.shared
            
            request.httpMethod = "GET"
            
            var accessTokenString = "bearer "
            accessTokenString.append(UserDefaults.standard.string(forKey: "currentAccessToken")!)
            
            request.setValue("\(accessTokenString)", forHTTPHeaderField: "Authorization")
            
            session.dataTask(with: request as URLRequest){ (data,response,error) in
                guard let data = data else { return }
                
    //            let backToString = String(data: data, encoding: String.Encoding.utf8) as String!
    //            print("It's me: "+backToString! as String!)
                
                do{
                    let info = try JSONDecoder().decode(subscribedSubredditsRetrieval.self, from: data)
                    
                    for children in info.data.children {
                        self.subscribedSubreddits.append(children.data.display_name)
                    }
                }catch let jsonErr {
                    print ("I failed Sire, forgive me, please!", jsonErr)
                }
                
                if self.sectionsArray.count == 2 {
                }else{
                    let subscribedSubredditsSection = Section(sectionName: "Subscribed", sectionItems: self.subscribedSubreddits)
                    self.sectionsArray.insert(subscribedSubredditsSection, at: 0)
                }
                
                DispatchQueue.main.async{
                    self.myTableView.reloadData()
                }
                print("Subscribed subreddits loaded")
                
            }.resume()
            subsLoadedTrigger += 1
        }else{
            print("But something is wrong")
        }
        
    }
    
}
