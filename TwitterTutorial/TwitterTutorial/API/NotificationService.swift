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
    
    func uploadNotification(toUser user: User, type: NotificationType, tweetId: String? = nil) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        var values: [String: Any] = ["timestamp": Int(Date().timeIntervalSince1970), "uid": userId, "type": type.rawValue]
        
        if let tweetId = tweetId {
            values["tweetId"] = tweetId
        }
        
        REF_NOTIFICATIONS.child(user.userId).childByAutoId().updateChildValues(values)
    }
    
    func fetchNotifications(completion: @escaping ([Notification]) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let notifications = [Notification]()
        
        REF_NOTIFICATIONS.child(userId).observeSingleEvent(of: .value) { snapshot in
            guard snapshot.exists() else {
                completion(notifications)
                return
            }
            
            self.fetchNotifications(userId: userId, completion: completion)
        }
    }
    
    func fetchNotifications(userId: String, completion: @escaping ([Notification]) -> Void) {
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
