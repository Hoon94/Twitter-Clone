//
//  ProfileHeader.swift
//  TwitterTutorial
//
//  Created by Daehoon Lee on 7/4/24.
//

import Kingfisher
import SnapKit
import Then
import UIKit

protocol ProfileHeaderDelegate: AnyObject {
    func handleDismissal()
    func handleEditProfileFollow(_ header: ProfileHeader)
    func didSelect(filter: ProfileFilterOptions)
}

class ProfileHeader: UICollectionReusableView {
    
    // MARK: - Properties
    
    var user: User? {
        didSet { configure() }
    }
    
    weak var delegate: ProfileHeaderDelegate?
    
    private lazy var filterBar = ProfileFilterView().then {
        $0.delegate = self
    }
    
    private lazy var containerView = UIView().then {
        $0.backgroundColor = .twitterBlue
    }
    
    private lazy var backButton = UIButton(type: .system).then {
        $0.setImage(UIImage(resource: .baselineArrowBackWhite24Dp).withRenderingMode(.alwaysOriginal), for: .normal)
        $0.addTarget(self, action: #selector(handleDismissal), for: .touchUpInside)
    }
    
    private let profileImageView = UIImageView().then { imageView in
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.backgroundColor = .lightGray
        imageView.layer.borderWidth = 4
        imageView.layer.borderColor = UIColor.white.cgColor
    }
    
    private lazy var editProfileFollowButton = UIButton(type: .system).then { button in
        button.setTitle("Loading", for: .normal)
        button.setTitleColor(.twitterBlue, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.layer.borderWidth = 1.25
        button.layer.borderColor = UIColor.twitterBlue.cgColor
        button.addTarget(self, action: #selector(handleEditProfileFollow), for: .touchUpInside)
    }
    
    private let fullNameLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 20)
    }
    
    private let usernameLabel = UILabel().then {
        $0.textColor = .lightGray
        $0.font = UIFont.systemFont(ofSize: 16)
    }
    
    private let bioLabel = UILabel().then {
        $0.text = "This is a user bio that will span more than one line for test purposes"
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.numberOfLines = 3
    }
    
    private lazy var userDetailsStackView = UIStackView(arrangedSubviews: [fullNameLabel, usernameLabel, bioLabel]).then {
        $0.spacing = 4
        $0.axis = .vertical
        $0.distribution = .fillProportionally
    }
    
    private lazy var followingLabel = UILabel().then {
        let followingTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleFollowingTapped))
        $0.addGestureRecognizer(followingTapGesture)
        $0.isUserInteractionEnabled = true
    }
    
    private lazy var followersLabel = UILabel().then {
        let followersTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleFollowersTapped))
        $0.addGestureRecognizer(followersTapGesture)
        $0.isUserInteractionEnabled = true
    }
    
    private lazy var followStackView = UIStackView(arrangedSubviews: [followingLabel, followersLabel]).then {
        $0.spacing = 8
        $0.axis = .horizontal
        $0.distribution = .fillEqually
    }
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selectors
    
    @objc private func handleDismissal() {
        delegate?.handleDismissal()
    }
    
    @objc private func handleEditProfileFollow() {
        delegate?.handleEditProfileFollow(self)
    }
    
    @objc private func handleFollowingTapped() {
        print("DEBUG: User following label tapped..")
    }

    @objc private func handleFollowersTapped() {
        print("DEBUG: User followers label tapped..")
    }
    
    // MARK: - Helpers
    
    private func configure() {
        guard let user = user else { return }
        
        let viewModel = ProfileHeaderViewModel(user: user)
        profileImageView.kf.setImage(with: user.profileImageUrl)
        editProfileFollowButton.setTitle(viewModel.actionButtonTitle, for: .normal)
        fullNameLabel.text = user.fullName
        usernameLabel.text = viewModel.usernameText
        bioLabel.text = user.bio
        followingLabel.attributedText = viewModel.followingString
        followersLabel.attributedText = viewModel.followersString
    }
    
    private func configureUI() {
        addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(108)
        }
        
        containerView.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(42)
            make.leading.equalToSuperview().inset(16)
        }
        
        addSubview(profileImageView)
        profileImageView.layer.cornerRadius = 80 / 2
        profileImageView.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.bottom).offset(-24)
            make.leading.equalToSuperview().inset(8)
            make.size.equalTo(80)
        }
        
        addSubview(editProfileFollowButton)
        editProfileFollowButton.layer.cornerRadius = 36 / 2
        editProfileFollowButton.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.bottom).offset(12)
            make.trailing.equalToSuperview().inset(12)
            make.width.equalTo(100)
            make.height.equalTo(36)
        }
        
        addSubview(userDetailsStackView)
        userDetailsStackView.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(8)
            make.directionalHorizontalEdges.equalToSuperview().inset(12)
        }
        
        addSubview(followStackView)
        followStackView.snp.makeConstraints { make in
            make.top.equalTo(userDetailsStackView.snp.bottom).offset(8)
            make.leading.equalToSuperview().inset(12)
        }
        
        addSubview(filterBar)
        filterBar.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(50)
        }
    }
}

// MARK: - ProfileFilterViewDelegate

extension ProfileHeader: ProfileFilterViewDelegate {
    func filterView(_ view: ProfileFilterView, didSelect index: Int) {
        guard let filter = ProfileFilterOptions(rawValue: index) else { return }
        
        delegate?.didSelect(filter: filter)
    }
}
