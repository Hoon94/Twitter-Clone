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
        
        var values = ["uid": userId, "timestamp": Int(Date().timeIntervalSince1970), "likes": 0, "retweets": 0, "caption": caption] as [String: Any]
        
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
            values["replyingTo"] = tweet.user.username
            
            REF_TWEET_REPLIES.child(tweet.tweetId).childByAutoId().updateChildValues(values) { error, reference in
                guard let replyKey = reference.key else { return }
                
                REF_USER_REPLIES.child(userId).updateChildValues([tweet.tweetId: replyKey], withCompletionBlock: completion)
            }
        }
    }
    
    func fetchTweets(completion: @escaping ([Tweet]) -> Void) {
        var tweets = [Tweet]()
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        REF_USER_FOLLOWING.child(currentUserId).observe(.childAdded) { snapshot in
            let followingUserId = snapshot.key
            
            REF_USER_TWEETS.child(followingUserId).observe(.childAdded) { snapshot in
                let tweetId = snapshot.key
                
                self.fetchTweet(withTweetId: tweetId) { tweet in
                    tweets.append(tweet)
                    completion(tweets)
                }
            }
        }
        
        REF_USER_TWEETS.child(currentUserId).observe(.childAdded) { snapshot in
            let tweetId = snapshot.key
            
            self.fetchTweet(withTweetId: tweetId) { tweet in
                tweets.append(tweet)
                completion(tweets)
            }
        }
    }
    
    func fetchTweets(forUser user: User, completion: @escaping ([Tweet]) -> Void) {
        var tweets = [Tweet]()
        
        REF_USER_TWEETS.child(user.userId).observe(.childAdded) { snapshot in
            let tweetId = snapshot.key
            
            self.fetchTweet(withTweetId: tweetId) { tweet in
                tweets.append(tweet)
                completion(tweets)
            }
        }
    }
    
    func fetchTweet(withTweetId tweetId: String, completion: @escaping (Tweet) -> Void) {
        REF_TWEETS.child(tweetId).observeSingleEvent(of: .value) { snapshot in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            guard let userId = dictionary["uid"] as? String else { return }
            
            UserService.shared.fetchUser(userId: userId) { user in
                let tweet = Tweet(user: user, tweetId: tweetId, dictionary: dictionary)
                completion(tweet)
            }
        }
    }
    
    func fetchReplies(forUser user: User, completion: @escaping ([Tweet]) -> Void) {
        var replies = [Tweet]()
        
        REF_USER_REPLIES.child(user.userId).observe(.childAdded) { snapshot in
            let tweetId = snapshot.key
            
            guard let replyKey = snapshot.value as? String else { return }
            
            REF_TWEET_REPLIES.child(tweetId).child(replyKey).observeSingleEvent(of: .value) { snapshot in
                guard let dictionary = snapshot.value as? [String: Any] else { return }
                guard let userId = dictionary["uid"] as? String else { return }
                
                let replyId = snapshot.key
                
                UserService.shared.fetchUser(userId: userId) { user in
                    let reply = Tweet(user: user, tweetId: replyId, dictionary: dictionary)
                    replies.append(reply)
                    completion(replies)
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
    
    func fetchLikes(forUser user: User, completion: @escaping ([Tweet]) -> Void) {
        var tweets = [Tweet]()
        
        REF_USER_LIKES.child(user.userId).observe(.childAdded) { snapshot in
            let tweetId = snapshot.key
            self.fetchTweet(withTweetId: tweetId) { tweet in
                var likedTweet = tweet
                likedTweet.didLike = true
                tweets.append(likedTweet)
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
