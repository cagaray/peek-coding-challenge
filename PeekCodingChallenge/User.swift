//
//  User.swift
//  PeekCodingChallenge
//
//  Created by Cristián Garay on 5/17/16.
//  Copyright © 2016 Cristian Garay. All rights reserved.
//

import Foundation

/*
MARK: Structure with data for a Twitter user.
Based on a work at cs193p.stanford.edu.
 */

public struct User: CustomStringConvertible {
    public let screenName: String
    public let name: String
    public let profileImageURL: NSURL?
    public let profileImageData: NSData?
    public let verified: Bool
    public let id: String?
    
    public var description: String {
        let v = verified ? " ✅" : ""
        return "@\(screenName)(\(name))\(v)"
    }
    
    struct TwitterKey {
        static let Name = "name"
        static let ScreenName = "screen_name"
        static let ID = "id_str"
        static let Verified = "verified"
        static let ProfileImageURL = "profile_image_url"
    }
    
    init?(data: NSDictionary?){
        if let nameFromData = data?.valueForKeyPath(TwitterKey.Name) as? String {
            if let screenNameFromData = data?.valueForKeyPath(TwitterKey.ScreenName) as? String {
                name = nameFromData
                screenName = screenNameFromData
                id = data?.valueForKeyPath(TwitterKey.ID) as? String
                verified = data?.valueForKeyPath(TwitterKey.Verified)?.boolValue ?? false
                if let urlString = data?.valueForKeyPath(TwitterKey.ProfileImageURL) as? String {
                    profileImageURL = NSURL(string: urlString)
                    profileImageData = NSData(contentsOfURL: profileImageURL!)!
                }
                else {
                    profileImageURL = nil
                    profileImageData = nil
                }
                return
            }
        }
        return nil
    }
    
    var asPropertyList: AnyObject {
        var dictionary = Dictionary<String, String>()
        dictionary[TwitterKey.Name] = self.name
        dictionary[TwitterKey.ScreenName] = self.screenName
        dictionary[TwitterKey.ID] = self.id
        dictionary[TwitterKey.Verified] =  verified ? "YES" : "NO"
        dictionary[TwitterKey.ProfileImageURL] = profileImageURL?.absoluteString
        return dictionary
    }
}

