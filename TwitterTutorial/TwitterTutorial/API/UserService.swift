//
//  UserService.swift
//  TwitterTutorial
//
//  Created by Daehoon Lee on 7/2/24.
//

import Firebase

struct UserService {
    
    // MARK: - Typealias
    
    typealias DatabaseCompletion = (Error?, DatabaseReference) -> Void
    
    // MARK: - Static
    
    static let shared = UserService()
    
    // MARK: - Helpers
    
    func fetchUser(userId: String, completion: @escaping (User) -> Void) {        
        REF_USERS.child(userId).observeSingleEvent(of: .value) { snapshot in
            guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
            
            let user = User(userId: userId, dictionary: dictionary)
            completion(user)
        }
    }
    
    func fetchUsers(completion: @escaping ([User]) -> Void) {
        var users = [User]()
        
        REF_USERS.observe(.childAdded) { snapshot in            
            guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
            
            let userId = snapshot.key
            let user = User(userId: userId, dictionary: dictionary)
            users.append(user)
            completion(users)
        }
    }
    
    func followUser(userId: String, completion: @escaping DatabaseCompletion) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        REF_USER_FOLLOWING.child(currentUserId).updateChildValues([userId: 1]) { error, reference in
            REF_USER_FOLLOWERS.child(userId).updateChildValues([currentUserId: 1], withCompletionBlock: completion)
        }
    }
    
    func unfollowUser(userId: String, completion: @escaping DatabaseCompletion) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        REF_USER_FOLLOWING.child(currentUserId).child(userId).removeValue { error, reference in
            REF_USER_FOLLOWERS.child(userId).child(currentUserId).removeValue(completionBlock: completion)
        }
    }
    
    func checkIfUserIsFollowed(userId: String, completion: @escaping (Bool) -> Void) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        REF_USER_FOLLOWING.child(currentUserId).child(userId).observeSingleEvent(of: .value) { snapshot in
            print("DEBUG: User is followed is \(snapshot.exists())")
            completion(snapshot.exists())
        }
    }
    
    func fetchUserStats(userId: String, completion: @escaping (UserRelationStats) -> Void) {
        REF_USER_FOLLOWERS.child(userId).observeSingleEvent(of: .value) { snapshot in
            let followers = snapshot.children.allObjects.count
            
            REF_USER_FOLLOWING.child(userId).observeSingleEvent(of: .value) { snapshot in
                let following = snapshot.children.allObjects.count
                
                let stats = UserRelationStats(followers: followers, following: following)
                completion(stats)
            }
        }
    }
}
