//
//  TwitterRequestTest.swift
//  PeekCodingChallenge
//
//  Created by Cristián Garay on 5/18/16.
//  Copyright © 2016 Cristian Garay. All rights reserved.
//

import XCTest
@testable import PeekCodingChallenge

class TwitterRequestTest: XCTestCase {
    
    var twitterRequest: TwitterRequest? = TwitterRequest(search: "%40peek", count: 7, .Mixed, nil)
    var peekMentionsArray = [Tweet]()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testFetchTweets(){
        twitterRequest!.fetchTweets{
            (tweetArray: [Tweet]) in
            for tweet in tweetArray {
                self.peekMentionsArray.append(tweet)
            }
            XCTAssertEqual(self.peekMentionsArray.count, 7)
        }
    }

}
