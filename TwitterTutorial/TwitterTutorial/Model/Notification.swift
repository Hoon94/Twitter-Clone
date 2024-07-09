//
//  Notification.swift
//  TwitterTutorial
//
//  Created by Daehoon Lee on 7/9/24.
//

import Foundation

enum NotificationType: Int {
    case follow
    case like
    case reply
    case retweet
    case mention
}

struct Notification {
    
    // MARK: - Properties
    
    var tweetId: String?
    var timestamp: Date?
    var user: User
    var tweet: Tweet?
    var type: NotificationType?
    
    // MARK: - Lifecycle
    
    init(user: User, dictionary: [String: AnyObject]) {
        self.user = user
        
        if let tweetId = dictionary["tweetId"] as? String {
            self.tweetId = tweetId
        }
        
        if let timestamp = dictionary["timestamp"] as? Double {
            self.timestamp = Date(timeIntervalSince1970: timestamp)
        }
        
        if let type = dictionary["type"] as? Int {
            self.type = NotificationType(rawValue: type)
        }
    }
}
