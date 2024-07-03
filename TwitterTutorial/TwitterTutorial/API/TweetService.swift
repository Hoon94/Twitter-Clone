//
//  TweetService.swift
//  TwitterTutorial
//
//  Created by Daehoon Lee on 7/3/24.
//

import Firebase

struct TweetService {
    
    // MARK: - Static
    
    static let shared = TweetService()
    
    // MARK: - Helpers
    
    func uploadTweet(caption: String, completion: @escaping (Error?, DatabaseReference) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let values = ["uid": userId, "timestamp": Int(Date().timeIntervalSince1970), "likes": 0, "retweets": 0, "caption": caption] as [String: Any]
        
        REF_TWEETS.childByAutoId().updateChildValues(values, withCompletionBlock: completion)
    }
    
    func fetchTweets(completion: @escaping ([Tweet]) -> Void) {
        var tweets = [Tweet]()
        
        REF_TWEETS.observe(.childAdded) { snapshot in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            guard let userId = dictionary["uid"] as? String else { return }
            
            let tweetId = snapshot.key
            
            UserService.shared.fetchUser(userId: userId) { user in
                let tweet = Tweet(user: user, tweetId: tweetId, dictionary: dictionary)
                tweets.append(tweet)
                completion(tweets)
            }
        }
    }
}
