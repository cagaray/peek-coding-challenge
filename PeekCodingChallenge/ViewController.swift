//
//  ViewController.swift
//  PeekCodingChallenge
//
//  Created by Cristián Garay on 5/13/16.
//  Copyright © 2016 Cristian Garay. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //Table view to display Twitter mentions of @Peek
    @IBOutlet weak var twitterMentionsTableView: UITableView!
    
    let twitterRequest = TwitterRequest(search: "%40Peek", count: 5, .Recent, nil)
    var peekMentionsArray = [Tweet]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        twitterMentionsTableView.delegate = self
        twitterMentionsTableView.dataSource = self
        
        twitterRequest.fetchTweets{
            (tweetArray: [Tweet]) in
            print("\(tweetArray.count) Tweets retrieves from query")
            for tweet in tweetArray {
                //print("\(tweet.user.screenName) - \(tweet.text)")
                print("\(tweet.user.profileImageURL)")
                self.peekMentionsArray.append(tweet)
            }
            self.twitterMentionsTableView.reloadData()
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
        
        cell.userNameLabel?.text = peekMentionsArray[indexPath.row].user.screenName
        cell.tweetLabel?.text = peekMentionsArray[indexPath.row].text
        cell.userAvatarImageView.image = UIImage(data: peekMentionsArray[indexPath.row].user.profileImageData!)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }


}

