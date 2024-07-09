//
//  NotificationService.swift
//  TwitterTutorial
//
//  Created by Daehoon Lee on 7/9/24.
//

import Firebase

struct NotificationService {
    
    // MARK: - Static
    
    static let shared = NotificationService()
    
    // MARK: - Helpers
    
    func uploadNotification(type: NotificationType, tweet: Tweet? = nil, user: User? = nil) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        var values: [String: Any] = ["timestamp": Int(Date().timeIntervalSince1970), "uid": userId, "type": type.rawValue]
        
        if let tweet = tweet {
            values["tweetId"] = tweet.tweetId
            
            REF_NOTIFICATIONS.child(tweet.userId).childByAutoId().updateChildValues(values)
        } else if let user = user {
            REF_NOTIFICATIONS.child(user.userId).childByAutoId().updateChildValues(values)
        }
    }
    
    func fetchNotifications(completion: @escaping ([Notification]) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        var notifications = [Notification]()
        
        REF_NOTIFICATIONS.child(userId).observe(.childAdded) { snapshot in
            guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
            guard let userId = dictionary["uid"] as? String else { return }
            
            UserService.shared.fetchUser(userId: userId) { user in
                let notification = Notification(user: user, dictionary: dictionary)
                notifications.append(notification)
                completion(notifications)
            }
        }
    }
}
