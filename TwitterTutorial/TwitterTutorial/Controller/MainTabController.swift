//
//  MainTabController.swift
//  TwitterTutorial
//
//  Created by Daehoon Lee on 7/1/24.
//

import Firebase
import UIKit

enum ActionButtonConfiguration {
    case tweet
    case message
}

class MainTabController: UITabBarController {
    
    // MARK: - Properties
    
    private var actionButtonConfig: ActionButtonConfiguration = .tweet
    
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
    
    // MARK: - Selectors
    
    @objc func actionButtonTapped() {
        let controller: UIViewController
        
        switch actionButtonConfig {
        case .tweet:
            guard let user = user else { return }
            
            controller = UploadTweetController(user: user, config: .tweet)
        case .message:
            controller = SearchController(config: .messages)
        }
        
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        delegate = self
        
        view.addSubview(actionButton)
        actionButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingBottom: 64, paddingRight: 16, width: 56, height: 56)
        actionButton.layer.cornerRadius = 56 / 2
    }
    
    func configureViewControllers() {
        let feed = templateNavigationController(image: UIImage(resource: .homeUnselected), rootViewController: FeedController(collectionViewLayout: UICollectionViewFlowLayout()))
        let search = templateNavigationController(image: UIImage(resource: .searchUnselected), rootViewController: SearchController(config: .userSearch))
        let notifications = templateNavigationController(image: UIImage(resource: .likeUnselected), rootViewController: NotificationsController())
        let conversations = templateNavigationController(image: UIImage(resource: .icMailOutlineWhite2X1), rootViewController: ConversationsController())
        
        viewControllers = [feed, search, notifications, conversations]
    }
    
    func templateNavigationController(image: UIImage, rootViewController: UIViewController) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: rootViewController)
        navigationController.tabBarItem.image = image
        
        return navigationController
    }
}

// MARK: - UITabBarControllerDelegate

extension MainTabController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let index = viewControllers?.firstIndex(of: viewController)
        let imageName = index == 3 ? "mail" : "new_tweet"
        let imageResource = ImageResource(name: imageName, bundle: .main)
        actionButton.setImage(UIImage(resource: imageResource), for: .normal)
        actionButtonConfig = index == 3 ? .message : .tweet
    }
}
