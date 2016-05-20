//
//  TwitterRequest.swift
//  PeekCodingChallenge
//
//  Created by Cristián Garay on 5/17/16.
//  Copyright © 2016 Cristian Garay. All rights reserved.
//

import Foundation
import Accounts
import Social
import CoreLocation

/*
 MARK: Wrapper class for request calls to the Twitter API.
 */

//To get user account from phone settings.
private var twitterAccount: ACAccount?

public class TwitterRequest
{
    public let requestType: String
    public let parameters: [String: String]
    
    //To specify the type of result a query of tweets will return.
    public enum SearchResultType {
        case Mixed
        case Recent
        case Popular
    }
    
    //Common codes to create Twitter searches.
    struct TwitterKey {
        static let Count = "count"
        static let Query = "q"
        static let Tweets = "statuses"
        static let ResultType = "result_type"
        static let ResultTypeRecent = "recent"
        static let ResultTypePopular = "popular"
        static let Geocode = "geocode"
        static let SearchForTweets = "search/tweets"
        static let Retweet = "statuses/retweet/"
        static let MaxID = "max_id"
        static let SinceID = "since_id"
        struct SearchMetadata {
            static let MaxID = "search_metadata.max_id_str"
            static let NextResults = "search_metadata.next_results"
            static let Separator = "&"
        }
    }
    
    let JSONExtension = ".json"
    let TwitterURLPrefix = "https://api.twitter.com/1.1/"
    
    private var min_id: String? = nil
    private var max_id: String? = nil
    
    public typealias PropertyList = AnyObject
    
    public init(_ requestType: String, _ parameters: Dictionary<String, String> = [:]) {
        self.requestType = requestType
        self.parameters = parameters
        
    }
    
    //MARK: Convenience initializer for TwitterRequest for a seach of Tweets.
    public convenience init(search: String, count: Int = 0, _ resultType: SearchResultType = .Mixed, _ region: CLCircularRegion? = nil) {
        //Setting parameters for query tweets.
        var parameters = [TwitterKey.Query: search]
        if count > 0 {
            parameters[TwitterKey.Count] = "\(count)"
        }
        switch resultType {
        case .Recent: parameters[TwitterKey.ResultType] = TwitterKey.ResultTypeRecent
        case .Popular: parameters[TwitterKey.ResultType] = TwitterKey.ResultTypePopular
        default: break
        }
        //TODO: Remove geolocation (??)
        if let geocode = region {
            parameters[TwitterKey.Geocode] = "\(geocode.center.latitude),\(geocode.center.longitude),\(geocode.radius/1000.0)km"
        }
        
        self.init(TwitterKey.SearchForTweets, parameters)
        
    }
    
    private func log(whatToLog: AnyObject) {
        debugPrint("TwitterRequest: \(whatToLog)")
    }
    
    private func synchronize(closure: () -> Void) {
        objc_sync_enter(self)
        closure()
        objc_sync_exit(self)
    }
    
    private func captureFollowonRequestInfo(propertyListResponse: PropertyList?) {
        if let responseDictionary = propertyListResponse as? NSDictionary {
            self.max_id = responseDictionary.valueForKeyPath(TwitterKey.SearchMetadata.MaxID) as? String
            if let next_results = responseDictionary.valueForKeyPath(TwitterKey.SearchMetadata.NextResults) as? String {
                for queryTerm in next_results.componentsSeparatedByString(TwitterKey.SearchMetadata.Separator) {
                    if queryTerm.hasPrefix("?\(TwitterKey.MaxID)=") {
                        let next_id = queryTerm.componentsSeparatedByString("=")
                        if next_id.count == 2 {
                            self.min_id = next_id[1]
                        }
                    }
                }
            }
        }
    }
    
    func performTwitterRequest(request: SLRequest, handler: (PropertyList?) -> Void) {
        if let account = twitterAccount {
            request.account = account
            request.performRequestWithHandler { (jsonResponse, httpResponse, _) in
                var propertyListResponse: PropertyList?
                if jsonResponse != nil {
                    do {
                        propertyListResponse = try NSJSONSerialization.JSONObjectWithData(
                            jsonResponse,
                            options: NSJSONReadingOptions.MutableLeaves
                        )
                    }
                    catch {
                        let error = "Couldn't parse JSON response."
                        self.log(error)
                        propertyListResponse = error
                    }
                } else {
                    let error = "No response from Twitter."
                    self.log(error)
                    propertyListResponse = error
                }
                self.synchronize {
                    self.captureFollowonRequestInfo(propertyListResponse)
                }
                handler(propertyListResponse)
            }
        } else {
            let accountStore = ACAccountStore()
            let twitterAccountType = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
            accountStore.requestAccessToAccountsWithType(twitterAccountType, options: nil) { (granted: Bool, _: NSError!) in
                if granted {
                    if let account = accountStore.accountsWithAccountType(twitterAccountType)?.last as? ACAccount {
                        twitterAccount = account
                        self.performTwitterRequest(request, handler: handler)
                    } else {
                        let error = "Couldn't discover Twitter account type."
                        self.log(error)
                        handler(error)
                    }
                } else {
                    let error = "Access to Twitter was not granted."
                    self.log(error)
                    handler(error)
                }
            }
        }
    }
    
    func performRetweetRequest(request: SLRequest) {
        if let account = twitterAccount {
            request.account = account
            request.performRequestWithHandler { (jsonResponse, httpResponse, _) in
                //TODO: Handle this
                print("Retweeted")
            }
        } else {
            let accountStore = ACAccountStore()
            let twitterAccountType = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
            accountStore.requestAccessToAccountsWithType(twitterAccountType, options: nil) { (granted: Bool, _: NSError!) in
                if granted {
                    if let account = accountStore.accountsWithAccountType(twitterAccountType)?.last as? ACAccount {
                        twitterAccount = account
                        self.performRetweetRequest(request)
                    } else {
                        let error = "Couldn't discover Twitter account type."
                        self.log(error)
                    }
                } else {
                    let error = "Access to Twitter was not granted."
                    self.log(error)
                }
            }
        }
    }

    
    func performTwitterRequest(method: SLRequestMethod, handler: (PropertyList?) -> Void) {
        let jsonExtension = (self.requestType.rangeOfString(JSONExtension) == nil) ? JSONExtension : ""
        let request = SLRequest(
            forServiceType: SLServiceTypeTwitter,
            requestMethod: method,
            URL: NSURL(string: "\(TwitterURLPrefix)\(self.requestType)\(jsonExtension)"),
            parameters: self.parameters
        )
        performTwitterRequest(request, handler: handler)
    }
    
    func performRetweetRequest(method: SLRequestMethod, tweetId: String){
        let jsonExtension = (self.requestType.rangeOfString(JSONExtension) == nil) ? JSONExtension : ""
        let request = SLRequest(
            forServiceType: SLServiceTypeTwitter,
            requestMethod: method,
            URL: NSURL(string: "\(TwitterURLPrefix)\(self.requestType)\(tweetId)\(jsonExtension)"),
            parameters: self.parameters
        )
        performRetweetRequest(request)
    }
    
    public func fetch(handler: (results: PropertyList?) -> Void) {
        performTwitterRequest(SLRequestMethod.GET, handler: handler)
    }
    
    public func fetchTweets(handler: ([Tweet]) -> Void) {
        fetch { results in
            var tweets = [Tweet]()
            var tweetArray: NSArray?
            if let dictionary = results as? NSDictionary {
                if let tweets = dictionary[TwitterKey.Tweets] as? NSArray {
                    tweetArray = tweets
                } else if let tweet = Tweet(data: dictionary) {
                    tweets = [tweet]
                }
            } else if let array = results as? NSArray {
                tweetArray = array
            }
            if tweetArray != nil {
                for tweetData in tweetArray! {
                    if let tweet = Tweet(data: tweetData as? NSDictionary) {
                        tweets.append(tweet)
                    }
                }
            }
            handler(tweets)
        }
    }

    public func retweet(tweet: Tweet) {
        //TODO: Check when tweet id is null.
        performRetweetRequest(SLRequestMethod.POST, tweetId: tweet.id!)
    }
    
    private func modifiedRequest(parametersToChange parametersToChange: Dictionary<String,String>, clearCount: Bool = false) -> TwitterRequest {
        var newParameters = parameters
        for (key, value) in parametersToChange {
            newParameters[key] = value
        }
        if clearCount { newParameters[TwitterKey.Count] = nil }
        return TwitterRequest(requestType, newParameters)
    }
    
    public var requestForOlder: TwitterRequest? {
        return min_id != nil ? modifiedRequest(parametersToChange: [TwitterKey.MaxID : min_id!]) : nil
    }
    
    public var requestForNewer: TwitterRequest? {
        return (max_id != nil) ? modifiedRequest(parametersToChange: [TwitterKey.SinceID : max_id!], clearCount: true) : nil
    }

    
}