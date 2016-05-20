//
//  MediaItem.swift
//  PeekCodingChallenge
//
//  Created by Cristián Garay on 5/17/16.
//  Copyright © 2016 Cristian Garay. All rights reserved.
//

import Foundation

/*
MARK: Structure for media objects attached to a tweet with an url.
Based on a work at cs193p.stanford.edu.
*/

public struct MediaItem {
    public let url: NSURL!
    public let aspectRatio: Double
    
    public var description: String {
        return (url.absoluteString ?? "no url") + " (aspect ratio = \(aspectRatio))"
    }
    
    struct TwitterKey {
        static let MediaURL = "media_url_https"
        static let Width = "sizes.small.w"
        static let Height = "sizes.small.h"
    }
    
    init?(data: NSDictionary?) {
        if let urlString = data?.valueForKeyPath(TwitterKey.MediaURL) as? NSString {
            if let urlFromString = NSURL(string: urlString as String) {
                url = urlFromString
                let h = data?.valueForKeyPath(TwitterKey.Height) as? NSNumber
                let w = data?.valueForKeyPath(TwitterKey.Width) as? NSNumber
                if h != nil && w != nil && h?.doubleValue != 0 {
                    aspectRatio = w!.doubleValue / h!.doubleValue
                    return
                }
            }
        }
        return nil
    }
}