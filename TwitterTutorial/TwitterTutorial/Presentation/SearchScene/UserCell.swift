//
//  UserCell.swift
//  TwitterTutorial
//
//  Created by Daehoon Lee on 7/4/24.
//

import Kingfisher
import SnapKit
import Then
import UIKit

class UserCell: UITableViewCell {
    
    // MARK: - Properties
    
    var user: User? {
        didSet { configure() }
    }
    
    private lazy var profileImageView = UIImageView().then { imageView in
        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(40)
        }
        
        imageView.backgroundColor = .twitterBlue
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 40 / 2
        imageView.clipsToBounds = true
    }
    
    private let usernameLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 14)
        $0.text = "Username"
    }
    
    private let fullNameLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.text = "Full name"
    }
    
    private lazy var labelStackView = UIStackView(arrangedSubviews: [usernameLabel, fullNameLabel]).then {
        $0.axis = .vertical
        $0.spacing = 2
    }
    
    // MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    
    private func configure() {
        guard let user = user else { return }
        
        usernameLabel.text = user.username
        fullNameLabel.text = user.fullName
        profileImageView.kf.setImage(with: user.profileImageUrl)
    }
    
    private func configureUI() {
        contentView.addSubview(profileImageView)
        profileImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(12)
        }
        
        addSubview(labelStackView)
        labelStackView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(profileImageView.snp.trailing).offset(12)
        }
    }
}
