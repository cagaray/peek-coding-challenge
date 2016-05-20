//
//  ViewController.swift
//  PeekCodingChallenge
//
//  Created by Cristián Garay on 5/13/16.
//  Copyright © 2016 Cristian Garay. All rights reserved.
//

import UIKit

/*
MARK: View controller with UITableView to load twitter mentions of @Peek
*/

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //Table view to display twitter mentions of @Peek.
    @IBOutlet weak var twitterMentionsTableView: UITableView!
    //Activity indicator to wait for tweets to load into the tableview.
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    //Refresh control for pull to refresh functionality.
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(ViewController.handleRefresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        return refreshControl
    }()
    
    
    //Twitter request objects to interact with Twitter API (search for Tweets and Retweet) and array to save requested tweets.
    //TwitterRequest objects save parameters from query to query (max_id, etc.), so I use 2 objects one for querys and one for retweets so not to affect those parameters for future queries.
    //TODO: Query from this call to the API returns different results from query on web. Check if differences only due to advertising and such, or there is a missing parameter (query on the web is constructed the same way as here). Is including account such as @Peek-a-boo, and retweets (web don't).
    var twitterRequest: TwitterRequest? = TwitterRequest(search: "%40peek", count: 7, .Mixed, nil)
    var retweetRequest: TwitterRequest? = TwitterRequest("statuses/retweet/")
    var peekMentionsArray = [Tweet]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        twitterMentionsTableView.delegate = self
        twitterMentionsTableView.dataSource = self
        
        //Start animation of activity indicator when loading tweets.
        //TODO: Center animation on vertical axis with regard of entire screen.
        activityIndicatorView.center = self.twitterMentionsTableView.center
        activityIndicatorView.startAnimating()
        
        //First fetch of tweets that mentioned account @peek
        //TODO: Improve speed of this first query. A LOT.
        twitterRequest!.fetchTweets{
            (tweetArray: [Tweet]) in
            for tweet in tweetArray {
                self.peekMentionsArray.append(tweet)
            }
            self.twitterMentionsTableView.reloadData()
            self.activityIndicatorView.stopAnimating()
            self.twitterMentionsTableView.addSubview(self.refreshControl)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peekMentionsArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = twitterMentionsTableView.dequeueReusableCellWithIdentifier("twitterMentionsCell", forIndexPath: indexPath) as! TwitterMentionsTableViewCell
        
        cell.userNameLabel?.text = "@" + peekMentionsArray[indexPath.row].user.screenName
        cell.tweetLabel?.text = peekMentionsArray[indexPath.row].text
        cell.userAvatarImageView.image = UIImage(data: peekMentionsArray[indexPath.row].user.profileImageData!)
        
        //I choose colors that were similar to Peek's website theme.
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 100/100.0)
            cell.tweetLabel.textColor = UIColor(red: 61/255.0, green: 165/255.0, blue: 217/255.0, alpha: 100/100.0)
            cell.userNameLabel.textColor = UIColor(red: 61/255.0, green: 165/255.0, blue: 217/255.0, alpha: 100/100.0)

        }
        else {
            cell.backgroundColor = UIColor(red: 61/255.0, green: 165/255.0, blue: 217/255.0, alpha: 100/100.0)
            cell.tweetLabel.textColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 100/100.0)
            cell.userNameLabel.textColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 100/100.0)
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    //When user sees the last available cell is time to load oldet tweets.
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == peekMentionsArray.count-1{
            let twitterRequestForOlder = self.twitterRequest!.requestForOlder
            if twitterRequestForOlder != nil{
                twitterRequest = twitterRequestForOlder
                twitterRequest!.fetchTweets{
                    (tweetArray: [Tweet]) in
                    for tweet in tweetArray {
                        self.peekMentionsArray.append(tweet)
                    }
                    self.twitterMentionsTableView.reloadData()
                }
            }
            else{
                debugPrint("Infinite scroll - No more tweets to show")
            }
        }
    }
    
    //Search for newer tweets in pull-to-refresh functionality
    func handleRefresh(refreshControl: UIRefreshControl) {
        let twitterRequestForNewer = self.twitterRequest!.requestForNewer
        if twitterRequestForNewer != nil {
            twitterRequest = twitterRequestForNewer
            twitterRequest!.fetchTweets{
                (tweetArray: [Tweet]) in
                for tweet in tweetArray {
                    self.peekMentionsArray.insert(tweet, atIndex: 0)
                }
                self.twitterMentionsTableView.reloadData()
                refreshControl.endRefreshing()
            }
            refreshControl.endRefreshing()
        }
        else {
            debugPrint("No more tweets to show")
        }
        refreshControl.endRefreshing()
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    //Implement buttons on each row to delete tweet or retweet. Swipe to the left to see them.
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let deleteClosure = { (action: UITableViewRowAction!, indexPath: NSIndexPath!) -> Void in
            self.peekMentionsArray.removeAtIndex(indexPath.row)
            self.twitterMentionsTableView.reloadData()
        }
        
        let retweetClosure = { (action: UITableViewRowAction!, indexPath: NSIndexPath!) -> Void in
            let retweetItem = self.peekMentionsArray[indexPath.row]
            self.retweetRequest?.retweet(retweetItem)
            self.twitterMentionsTableView.reloadData()
        }
        
        let deleteAction = UITableViewRowAction(style: .Default, title: "Delete", handler: deleteClosure)
        let retweetAction = UITableViewRowAction(style: .Normal, title: "Retweet", handler: retweetClosure)
        
        return [deleteAction, retweetAction]
    }


}

