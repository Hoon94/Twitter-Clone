//
//  TweetService.swift
//  TwitterTutorial
//
//  Created by Daehoon Lee on 7/3/24.
//

import Firebase

struct TweetService {
    
    // MARK: - Typealias
    
    typealias DatabaseCompletion = (Error?, DatabaseReference) -> Void
    
    // MARK: - Static
    
    static let shared = TweetService()
    
    // MARK: - Helpers
    
    func uploadTweet(caption: String, type: UploadTweetConfiguration, completion: @escaping DatabaseCompletion) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let values = ["uid": userId, "timestamp": Int(Date().timeIntervalSince1970), "likes": 0, "retweets": 0, "caption": caption] as [String: Any]
        
        switch type {
        case .tweet:
            REF_TWEETS.childByAutoId().updateChildValues(values) { error, reference in
                if let error = error {
                    print("DEBUG: Failed to upload tweet for with error \(error.localizedDescription)")
                    return
                }
                
                guard let tweetId = reference.key else { return }
                
                REF_USER_TWEETS.child(userId).updateChildValues([tweetId: 1], withCompletionBlock: completion)
            }
        case .reply(let tweet):
            REF_TWEET_REPLIES.child(tweet.tweetId).childByAutoId().updateChildValues(values, withCompletionBlock: completion)
        }
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
    
    func fetchTweets(forUser user: User, completion: @escaping ([Tweet]) -> Void) {
        var tweets = [Tweet]()
        
        REF_USER_TWEETS.child(user.userId).observe(.childAdded) { snapshot in
            let tweetId = snapshot.key
            
            REF_TWEETS.child(tweetId).observeSingleEvent(of: .value) { snapshot in
                guard let dictionary = snapshot.value as? [String: Any] else { return }
                guard let userId = dictionary["uid"] as? String else { return }
                
                UserService.shared.fetchUser(userId: userId) { user in
                    let tweet = Tweet(user: user, tweetId: tweetId, dictionary: dictionary)
                    tweets.append(tweet)
                    completion(tweets)
                }
            }
        }
    }
    
    func fetchReplies(forTweet tweet: Tweet, completion: @escaping ([Tweet]) -> Void) {
        var tweets = [Tweet]()
        
        REF_TWEET_REPLIES.child(tweet.tweetId).observe(.childAdded) { snapshot in
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
    
    func likeTweet(tweet: Tweet, completion: @escaping DatabaseCompletion) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let likes = tweet.didLike ? tweet.likes - 1 : tweet.likes + 1
        REF_TWEETS.child(tweet.tweetId).child("likes").setValue(likes)
        
        if tweet.didLike {
            // unlike tweet: remove like data from firebase
            REF_USER_LIKES.child(userId).child(tweet.tweetId).removeValue { error, reference in
                REF_TWEET_LIKES.child(tweet.tweetId).removeValue(completionBlock: completion)
            }
        } else {
            // like tweet: add like data to firebase
            REF_USER_LIKES.child(userId).updateChildValues([tweet.tweetId: 1]) { error, reference in
                REF_TWEET_LIKES.child(tweet.tweetId).updateChildValues([userId: 1], withCompletionBlock: completion)
            }
        }
    }
    
    func checkIfUserLikedTweet(_ tweet: Tweet, completion: @escaping (Bool) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        REF_USER_LIKES.child(userId).child(tweet.tweetId).observeSingleEvent(of: .value) { snapshot in
            completion(snapshot.exists())
        }
    }
}
