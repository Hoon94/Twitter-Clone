//
//  ProfileHeaderViewModel.swift
//  TwitterTutorial
//
//  Created by Daehoon Lee on 7/4/24.
//

import UIKit

enum ProfileFilterOptions: Int, CaseIterable {
    
    // MARK: - Case
    
    case tweets
    case replies
    case likes
    
    // MARK: - Properties
    
    var description: String {
        switch self {
        case .tweets:
            return "Tweets"
        case .replies:
            return "Tweets & Replies"
        case .likes:
            return "Likes"
        }
    }
}

struct ProfileHeaderViewModel {
    
    // MARK: - Properties
    
    private let user: User
    
    let usernameText: String
    
    var followersString: NSAttributedString? {
        return attributedText(withValue: user.stats?.followers ?? 0, text: "followers")
    }
    
    var followingString: NSAttributedString? {
        return attributedText(withValue: user.stats?.following ?? 0, text: "following")
    }
    
    var actionButtonTitle: String {
        if user.isCurrentUser {
            return "Edit Profile"
        } else {
            if user.isFollowed {
                return "Following"
            } else {
                return "Follow"
            }
        }
    }
    
    // MARK: - Lifecycle
    
    init(user: User) {
        self.user = user
        usernameText = "@" + user.username
    }
    
    // MARK: - Helpers
    
    fileprivate func attributedText(withValue value: Int, text: String) -> NSAttributedString {
        let attributedTitle = NSMutableAttributedString(string: "\(value)", attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedTitle.append(NSAttributedString(string: " \(text)", attributes: [.font: UIFont.systemFont(ofSize: 14),
                                                                                   .foregroundColor: UIColor.lightGray]))
        
        return attributedTitle
    }
}
