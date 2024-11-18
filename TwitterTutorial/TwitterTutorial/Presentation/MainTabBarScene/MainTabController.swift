//
//  MainTabController.swift
//  TwitterTutorial
//
//  Created by Daehoon Lee on 7/1/24.
//

import Firebase
import SnapKit
import Then
import UIKit

enum ActionButtonConfiguration {
    case tweet
    case message
}

class MainTabController: UITabBarController {
    
    // MARK: - Properties
    
    var user: User? {
        didSet {
            guard let navigationController = viewControllers?[0] as? UINavigationController else { return }
            guard let feedController = navigationController.viewControllers.first as? FeedController else { return }
            
            feedController.user = user
        }
    }
        
    private lazy var actionButton = UIButton(type: .system).then {
        $0.tintColor = .systemBackground
        $0.backgroundColor = .twitterBlue
        $0.setImage(UIImage(resource: .newTweet), for: .normal)
        $0.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
    }
    
    private var actionButtonConfig: ActionButtonConfiguration = .tweet
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        authenticateUserAndConfigureUI()
    }
    
    // MARK: - API
    
    private func fetchUser() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        UserService.shared.fetchUser(userId: userId) { user in
            self.user = user
        }
    }
    
    func authenticateUserAndConfigureUI() {
        view.backgroundColor = .twitterBlue
        
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {
                let navigationController = UINavigationController(rootViewController: LoginController())
                navigationController.modalPresentationStyle = .fullScreen
                self.present(navigationController, animated: true)
            }
        } else {
            fetchUser()
            configureUI()
            configureViewControllers()
        }
    }
    
    // MARK: - Selectors
    
    @objc private func actionButtonTapped() {
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
    
    private func configureUI() {
        view.addSubview(actionButton)
        actionButton.layer.cornerRadius = 56 / 2
        actionButton.snp.makeConstraints { make in
            make.height.width.equalTo(56)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(64)
            make.trailing.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
    }
    
    private func configureViewControllers() {
        let feed = templateNavigationController(image: UIImage(resource: .homeUnselected), rootViewController: FeedController(collectionViewLayout: UICollectionViewFlowLayout()))
        let search = templateNavigationController(image: UIImage(resource: .searchUnselected), rootViewController: SearchController(config: .userSearch))
        let notifications = templateNavigationController(image: UIImage(resource: .likeUnselected), rootViewController: NotificationsController())
        let conversations = templateNavigationController(image: UIImage(resource: .icMailOutlineWhite2X1), rootViewController: ConversationsController())
        
        delegate = self
        viewControllers = [feed, search, notifications, conversations]
    }
    
    private func templateNavigationController(image: UIImage, rootViewController: UIViewController) -> UINavigationController {
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
