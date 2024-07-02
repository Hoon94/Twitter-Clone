//
//  AuthService.swift
//  TwitterTutorial
//
//  Created by Daehoon Lee on 7/2/24.
//

import Firebase
import UIKit

struct AuthCredentials {
    
    // MARK: - Properties
    
    let email: String
    let password: String
    let fullName: String
    let username: String
    let profileImage: UIImage
}

struct AuthService {
    
    // MARK: - Static
    
    static let shared = AuthService()
    
    // MARK: - Helpers
    
    func logUserIn(withEmail email: String, password: String, completion: @escaping (AuthDataResult?, Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password, completion: completion)
    }
    
    func registerUser(credentials: AuthCredentials, completion: @escaping (Error?, DatabaseReference) -> Void) {
        let email = credentials.email
        let password = credentials.password
        let fullName = credentials.fullName
        let username = credentials.username
        let filename = UUID().uuidString
        let storageReference = STORAGE_PROFILE_IMAGES.child(filename)
        
        guard let imageData = credentials.profileImage.jpegData(compressionQuality: 0.3) else { return }
        
        storageReference.putData(imageData) { meta, error in
            storageReference.downloadURL { url, error in
                guard let profileImageUrl = url?.absoluteString else { return }
                
                Auth.auth().createUser(withEmail: email, password: password) { result, error in
                    if let error = error {
                        print("DEBUG: Error is \(error.localizedDescription)")
                        return
                    }
                    
                    guard let userId = result?.user.uid else { return }
                    
                    let values = ["email": email, "username": username, "fullName": fullName, "profileImageUrl": profileImageUrl]
                    REF_USERS.child(userId).updateChildValues(values, withCompletionBlock: completion)
                }
            }
        }
    }
}
