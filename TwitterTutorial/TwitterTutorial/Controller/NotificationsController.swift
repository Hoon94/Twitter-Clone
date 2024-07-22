//
//  NotificationsController.swift
//  TwitterTutorial
//
//  Created by Daehoon Lee on 7/1/24.
//

import UIKit

private let reuseIdentifier = "NotificationCell"

class NotificationsController: UITableViewController {
    
    // MARK: - Properties
    
    private var notifications = [Notification]() {
        didSet { tableView.reloadData() }
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchNotifications()
        configureUI()
        configureTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    // MARK: - API
    
    private func fetchNotifications() {
        refreshControl?.beginRefreshing()
        
        NotificationService.shared.fetchNotifications { notifications in
            self.refreshControl?.endRefreshing()
            self.notifications = notifications
            self.checkIfUserIsFollowed(notifications: notifications)
        }
    }
    
    private func checkIfUserIsFollowed(notifications: [Notification]) {
        guard !notifications.isEmpty else { return }
        
        notifications.forEach { notification in
            guard case .follow = notification.type else { return }
            
            let user = notification.user
            
            // FIXME: - 첫 index만을 수정하므로 follow를 여러번 한 경우 이전에 follow한 내용에 대해서는 버튼이 following으로 변하지 않는다.
            UserService.shared.checkIfUserIsFollowed(userId: user.userId) { isFollowed in
                if let index = self.notifications.firstIndex(where: { $0.user.userId == notification.user.userId }) {
                    self.notifications[index].user.isFollowed = isFollowed
                }
            }
        }
    }
    
    // MARK: - Selectors
    
    @objc private func handleRefresh() {
        fetchNotifications()
    }
    
    // MARK: - Helpers
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        navigationItem.title = "Notifications"
    }
    
    private func configureTableView() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        
        tableView.rowHeight = 60
        tableView.separatorStyle = .none
        tableView.refreshControl = refreshControl
        tableView.register(NotificationCell.self, forCellReuseIdentifier: reuseIdentifier)
    }
}

// MARK: - UITableViewDataSource

extension NotificationsController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? NotificationCell else { return UITableViewCell() }
        
        cell.notification = notifications[indexPath.row]
        cell.delegate = self
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension NotificationsController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let notification = notifications[indexPath.row]
        
        guard let tweetId = notification.tweetId else { return }
        
        TweetService.shared.fetchTweet(withTweetId: tweetId) { tweet in
            let controller = TweetController(tweet: tweet)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}

// MARK: - NotificationCellDelegate

extension NotificationsController: NotificationCellDelegate {
    func didTapProfileImage(_ cell: NotificationCell) {
        guard let user = cell.notification?.user else { return }
        
        let controller = ProfileController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func didTapFollowButton(_ cell: NotificationCell) {
        guard let user = cell.notification?.user else { return }
        
        if user.isFollowed {
            UserService.shared.unfollowUser(userId: user.userId) { error, reference in
                cell.notification?.user.isFollowed = false
            }
        } else {
            UserService.shared.followUser(userId: user.userId) { error, reference in
                cell.notification?.user.isFollowed = true
            }
        }
    }
}
