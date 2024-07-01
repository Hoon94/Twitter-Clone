//
//  FeedController.swift
//  TwitterTutorial
//
//  Created by Daehoon Lee on 7/1/24.
//

import UIKit

class FeedController: UIViewController {
    // MARK: - Properties
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        view.backgroundColor = .systemBackground
        let imageView = UIImageView(image: UIImage(resource: .twitterLogoBlue))
        imageView.contentMode = .scaleAspectFit
        navigationItem.titleView = imageView
    }
}
