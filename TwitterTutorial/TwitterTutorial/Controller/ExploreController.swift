//
//  ExploreController.swift
//  TwitterTutorial
//
//  Created by Daehoon Lee on 7/1/24.
//

import UIKit

class ExploreController: UIViewController {
    // MARK: - Properties
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        view.backgroundColor = .systemBackground
        navigationItem.title = "Explore"
    }
}
