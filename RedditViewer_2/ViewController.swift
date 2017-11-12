//
//  ViewController.swift
//  RedditViewer_2
//
//  Created by Scott Browne on 03/09/2017.
//  Copyright © 2017 Smiles Dev. All rights reserved.
//

import Foundation
import UIKit

class ViewController: UITableViewController, UIApplicationDelegate, ModalViewControllerDelegate{
    
// Define the structure for a Section item
    struct Section {
        var sectionName: String!
        var sectionItems: Array<String>!
    }
// This function shows the popover view to manually enter a subreddit name for navigation
    func showManualEntryVC() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let secondViewController = storyboard.instantiateViewController(withIdentifier: "ManualEntryVC") as! ManualEntryPopUpVC
        secondViewController.delegate = self
        self.present(secondViewController, animated: true, completion: nil)
        
    }

// This allows the manual subreddit entry view controller to set a variable in this class.
    func sendValue(value: String) {
        selectedView = 1
        selectedSubredditName = value
        performSegue(withIdentifier: "subredditSegue", sender: self)
    }
    
// Variables and referencing outlets.
    @IBOutlet weak var myTableView: UITableView!
    var refresher: UIRefreshControl!
    var sectionsArray = [Section]()
    var selectedView = 0
    var loggedIn = false
    var selectedSubredditName = ""
    var manualName: String = ""
    let myUDSuite: UserDefaults = UserDefaults.init(suiteName: "group.navvitForReddit")!
    var subscribedSubreddits = [String]()
    var generalOptions = ["Manually enter subreddit."]
    var defaultSubreddits: Array = ["Announcements", "Art", "AskReddit", "Askscience", "Aww", "Blog", "Books", "Creepy", "Dataisbeautiful", "DIY", "Documentaries", "EarthPorn", "Explainlikeimfive", "Food", "Funny", "Futurology", "Gadgets", "Gaming", "GetMotivated", "Gifs", "History", "IAmA", "InternetIsBeautiful", "Jokes", "LifeProTips", "Listentothis", "MagicTCG", "Mildlyinteresting", "Movies", "Music", "News", "Nosleep", "Nottheonion", "OldSchoolCool", "Personalfinance", "Philosophy", "Photoshopbattles", "Pics", "Science", "Showerthoughts", "Space", "Sports", "Television", "TIFU", "Todayilearned", "UpliftingNews", "Videos", "Worldnews"]
    
    override func viewDidLoad() {
        
    // This checks the status of the users access token(which subsequently refreshes it if necessary), but only if there is a user currently logged in.
        if myUDSuite.string(forKey: "Username") != nil {
            SuperFunctions().checkTokenStatus()
        }
        
    // This sets the intial standard for the user's browsing type preference.
        if UserDefaults.standard.string(forKey: "BrowsingPref") == nil {
            UserDefaults.standard.set("hot", forKey: "BrowsingPref")
        }
        
    // Creates and controls the pull-down refresher for the table view.
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: #selector(ViewController.refreshTable), for: UIControlEvents.valueChanged)
        tableView.addSubview(refresher)
        
    // Calls functions that aquire/organise the content shown to the user.
        getSubscribedSubreddits()
        arrangeTableSections()
    
    }
    
// Set the number of items in a table section based on the conent available.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionsArray[section].sectionItems.count
    }
    
// Populates the cells with the content from the sections within the sections array array.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> CellOne {
        let cellOne = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CellOne
        cellOne.cellLabel.text = sectionsArray[indexPath.section].sectionItems[indexPath.row]
        return cellOne
    }

// Sets number sections in the table to the number of sections in the array that provides the sections.
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionsArray.count
    }
    
// Sets the names of the sections to display in the table.
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionsArray[section].sectionName
    }
    
// Controls what happens when a tableview cell is pressed.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if sectionsArray[indexPath.section].sectionItems[indexPath.row] == "Manually enter subreddit" {
            showManualEntryVC()
        }else{
            selectedView = 1
            selectedSubredditName = sectionsArray[indexPath.section].sectionItems[indexPath.row]
            performSegue(withIdentifier: "subredditSegue", sender: self)
        }
    }
    
// Controls the appearence of the header of each section.
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        view.tintColor = UIColor(red: 1.0, green: 0.27, blue: 0.0, alpha: 1.0)
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.7)
    }
    
// This performs the segue to the settings view when the settings button is pressed.
    @IBAction func settingsButton(_ sender: Any) {
        selectedView = 2
        performSegue(withIdentifier: "settingsSegue", sender: self)
    }
    

// Prepares the view for a segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if selectedView == 1 {
            let subredditsView = segue.destination as! View2
            subredditsView.subredditName = self.selectedSubredditName
        }
    }
    
// This function controls what happens when the table is refreshed manually.
    @objc func refreshTable() {
        getSubscribedSubreddits()
        refresher.endRefreshing()
    }
    
// This arranges the table based on whether or not the user is logged in to reddit through the app.
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
    
//This will populate the Subscribed section of the table if the user is logged into reddit through the app.
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
