//
//  UserService.swift
//  TwitterTutorial
//
//  Created by Daehoon Lee on 7/2/24.
//

import Firebase

struct UserService {
    
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
}
