//
//  NotificationViewModel.swift
//  TwitterTutorial
//
//  Created by Daehoon Lee on 7/9/24.
//

import UIKit

struct NotificationViewModel {
    
    // MARK: - Properties
    
    private let notification: Notification
    private let type: NotificationType?
    private let user: User
    
    private var timestamp: String {
        let now = Date()
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .abbreviated
        
        guard let startDate = notification.timestamp, let timestamp = formatter.string(from: startDate, to: now) else { return "2m" }
        
        return timestamp
    }
    
    private var notificationMessage: String {
        guard let type = type else { return "" }
        
        switch type {
        case .follow:
            return " started following you"
        case .like:
            return " liked your tweet"
        case .reply:
            return " replied to your tweet"
        case .retweet:
            return " retweeted your tweet"
        case .mention:
            return " mentioned you in a tweet"
        }
    }
    
    var notificationText: NSAttributedString {
        let attributedText = NSMutableAttributedString(string: user.username, attributes: [.font: UIFont.boldSystemFont(ofSize: 12)])
        attributedText.append(NSAttributedString(string: notificationMessage, attributes: [.font: UIFont.systemFont(ofSize: 12)]))
        
        attributedText.append(NSAttributedString(string: " \(timestamp)", attributes: [.font: UIFont.systemFont(ofSize: 12),
                                                                                       .foregroundColor: UIColor.lightGray]))
        
        return attributedText
    }
    
    var profileImageUrl: URL? {
        return user.profileImageUrl
    }
    
    var shouldHideFollowButton: Bool {
        return type != .follow
    }
    
    var followButtonText: String {
        return user.isFollowed ? "Following" : "Follow"
    }
    
    // MARK: - Lifecycle
    
    init(notification: Notification) {
        self.notification = notification
        self.type = notification.type
        self.user = notification.user
    }
}
