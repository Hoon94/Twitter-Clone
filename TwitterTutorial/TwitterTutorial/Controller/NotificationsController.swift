//
//  NotificationsController.swift
//  TwitterTutorial
//
//  Created by Daehoon Lee on 7/1/24.
//

import UIKit

class NotificationsController: UIViewController {
    // MARK: - Properties
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        view.backgroundColor = .systemBackground
        navigationItem.title = "Notifications"
    }
}
