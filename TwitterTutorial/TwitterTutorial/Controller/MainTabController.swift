//
//  MainTabController.swift
//  TwitterTutorial
//
//  Created by Daehoon Lee on 7/1/24.
//

import Firebase
import UIKit

class MainTabController: UITabBarController {
    
    // MARK: - Properties
    
    var user: User? {
        didSet {
            guard let navigationController = viewControllers?[0] as? UINavigationController else { return }
            guard let feedController = navigationController.viewControllers.first as? FeedController else { return }
            
            feedController.user = user
        }
    }
    
    lazy var actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .white
        button.backgroundColor = .twitterBlue
        button.setImage(UIImage(resource: .newTweet), for: .normal)
        button.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        logUserOut()
        view.backgroundColor = .twitterBlue
        authenticateUserAndConfigureUI()
    }
    
    // MARK: - API
    
    func fetchUser() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        UserService.shared.fetchUser(userId: userId) { user in
            self.user = user
        }
    }
    
    func authenticateUserAndConfigureUI() {
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {
                let navigationController = UINavigationController(rootViewController: LoginController())
                navigationController.modalPresentationStyle = .fullScreen
                self.present(navigationController, animated: true)
            }
        } else {
            configureUI()
            configureViewControllers()
            fetchUser()
        }
    }
    
    func logUserOut() {
        do {
            try Auth.auth().signOut()
            print("DEBUG: Did log user out..")
        } catch let error {
            print("DEBUG: Failed to sign out with error \(error.localizedDescription)")
        }
    }
    
    // MARK: - Selectors
    
    @objc func actionButtonTapped() {
        guard let user = user else { return }
        
        let controller = UploadTweetController(user: user)
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        view.addSubview(actionButton)
        actionButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingBottom: 64, paddingRight: 16, width: 56, height: 56)
        actionButton.layer.cornerRadius = 56 / 2
    }
    
    func configureViewControllers() {
        let feed = templateNavigationController(image: UIImage(resource: .homeUnselected), rootViewController: FeedController(collectionViewLayout: UICollectionViewFlowLayout()))
        let explore = templateNavigationController(image: UIImage(resource: .searchUnselected), rootViewController: ExploreController())
        let notifications = templateNavigationController(image: UIImage(resource: .likeUnselected), rootViewController: NotificationsController())
        let conversations = templateNavigationController(image: UIImage(resource: .icMailOutlineWhite2X1), rootViewController: ConversationsController())
        
        viewControllers = [feed, explore, notifications, conversations]
    }
    
    func templateNavigationController(image: UIImage, rootViewController: UIViewController) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: rootViewController)
        navigationController.tabBarItem.image = image
        
        return navigationController
    }
}
