//
//  TweetViewModel.swift
//  TwitterTutorial
//
//  Created by Daehoon Lee on 7/3/24.
//

import UIKit

struct TweetViewModel {
    
    // MARK: - Properties
    
    let tweet: Tweet
    let user: User
    
    var profileImageUrl: URL? {
        return user.profileImageUrl
    }
    
    var timestamp: String {
        let now = Date()
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .abbreviated
        
        guard let startDate = tweet.timestamp, let timestamp = formatter.string(from: startDate, to: now) else { return "2m" }
        
        return timestamp
    }
    
    var userInformationText: NSAttributedString {
        let title = NSMutableAttributedString(string: user.fullName, attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
        title.append(NSAttributedString(string: " @\(user.username)", attributes: [.font: UIFont.systemFont(ofSize: 14),
                                                                                   .foregroundColor: UIColor.lightGray]))
        title.append(NSAttributedString(string: " ・ \(timestamp)", attributes: [.font: UIFont.systemFont(ofSize: 14),
                                                                                .foregroundColor: UIColor.lightGray]))
        
        return title
    }
    
    // MARK: - Lifecycle
    
    init(tweet: Tweet) {
        self.tweet = tweet
        self.user = tweet.user
    }
}
