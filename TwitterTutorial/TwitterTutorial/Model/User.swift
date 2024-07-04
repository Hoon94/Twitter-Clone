//
//  User.swift
//  TwitterTutorial
//
//  Created by Daehoon Lee on 7/2/24.
//

import Firebase
import Foundation

struct User {
    
    // MARK: - Properties
    
    let fullName: String
    let email: String
    let username: String
    var profileImageUrl: URL?
    let userId: String
    var isFollowed = false
    var stats: UserRelationStats?
    
    var isCurrentUser: Bool {
        return Auth.auth().currentUser?.uid == userId
    }
    
    // MARK: - Lifecycle
    
    init(userId: String, dictionary: [String: AnyObject]) {
        self.userId = userId
        self.fullName = dictionary["fullName"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        self.username = dictionary["username"] as? String ?? ""
        
        if let profileImageUrl = dictionary["profileImageUrl"] as? String {
            guard let url = URL(string: profileImageUrl) else { return }
            
            self.profileImageUrl = url
        }
    }
}

struct UserRelationStats {
    
    // MARK: - Properties
    
    var followers: Int
    var following: Int
}
