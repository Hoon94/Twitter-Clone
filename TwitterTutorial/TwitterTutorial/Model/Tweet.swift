//
//  Tweet.swift
//  TwitterTutorial
//
//  Created by Daehoon Lee on 7/3/24.
//

import Foundation

struct Tweet {
    
    // MARK: - Properties
    
    let caption: String
    let tweetId: String
    let userId: String
    let likes: Int
    var timestamp: Date?
    let retweetCount: Int
    let user: User
    
    // MARK: - Lifecycle
    
    init(user: User, tweetId: String, dictionary: [String: Any]) {
        self.user = user
        self.tweetId = tweetId
        
        self.caption = dictionary["caption"] as? String ?? ""
        self.userId = dictionary["uid"] as? String ?? ""
        self.likes = dictionary["likes"] as? Int ?? 0
        self.retweetCount = dictionary["retweets"] as? Int ?? 0
        
        if let timestamp = dictionary["timestamp"] as? Double {
            self.timestamp = Date(timeIntervalSince1970: timestamp)
        }
    }
}