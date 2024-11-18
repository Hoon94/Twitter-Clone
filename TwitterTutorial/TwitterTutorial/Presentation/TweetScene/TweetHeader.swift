//
//  TweetHeader.swift
//  TwitterTutorial
//
//  Created by Daehoon Lee on 7/5/24.
//

import ActiveLabel
import Kingfisher
import SnapKit
import Then
import UIKit

protocol TweetHeaderDelegate: AnyObject {
    func showActionSheet()
    func handleFetchUser(withUsername username: String)
}

class TweetHeader: UICollectionReusableView {
    
    // MARK: - Properties
    
    var tweet: Tweet? {
        didSet { configure() }
    }
    
    weak var delegate: TweetHeaderDelegate?
    
    private let replyLabel = ActiveLabel().then {
        $0.textColor = .lightGray
        $0.mentionColor = .twitterBlue
        $0.font = UIFont.systemFont(ofSize: 12)
    }
    
    private lazy var profileImageView = UIImageView().then { imageView in
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.backgroundColor = .twitterBlue
        imageView.layer.cornerRadius = 48 / 2
        imageView.snp.makeConstraints { make in
            make.size.equalTo(48)
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleProfileImageTapped))
        imageView.addGestureRecognizer(tapGesture)
        imageView.isUserInteractionEnabled = true
    }
    
    private let fullNameLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 14)
    }
    
    private let usernameLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.textColor = .lightGray
    }
    
    private lazy var labelStackView = UIStackView(arrangedSubviews: [fullNameLabel, usernameLabel]).then {
        $0.spacing = -6
        $0.axis = .vertical
    }
    
    private lazy var profileStackView = UIStackView(arrangedSubviews: [profileImageView, labelStackView]).then {
        $0.spacing = 12
    }
    
    private lazy var stackView = UIStackView(arrangedSubviews: [replyLabel, profileStackView]).then {
        $0.spacing = 8
        $0.axis = .vertical
        $0.distribution = .fillProportionally
    }
    
    private let captionLabel = ActiveLabel().then {
        $0.font = UIFont.systemFont(ofSize: 20)
        $0.mentionColor = .twitterBlue
        $0.hashtagColor = .twitterBlue
        $0.numberOfLines = 0
    }
    
    private let dateLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.textColor = .lightGray
        $0.textAlignment = .left
    }
    
    private lazy var optionsButton = UIButton(type: .system).then {
        $0.tintColor = .lightGray
        $0.setImage(UIImage(resource: .downArrow24Pt), for: .normal)
        $0.addTarget(self, action: #selector(showActionSheet), for: .touchUpInside)
    }
    
    private let retweetsLabel = UILabel()
    private let likesLabel = UILabel()
    
    private lazy var statsStackView = UIStackView(arrangedSubviews: [retweetsLabel, likesLabel]).then {
        $0.spacing = 12
        $0.axis = .horizontal
    }
    
    private let upperDividerView = UIView().then {
        $0.backgroundColor = .systemGroupedBackground
    }
    
    private let lowerDividerView = UIView().then {
        $0.backgroundColor = .systemGroupedBackground
    }
    
    private lazy var statsView = UIView().then { view in
        view.addSubview(upperDividerView)
        upperDividerView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.directionalHorizontalEdges.equalToSuperview().inset(8)
            make.height.equalTo(1)
        }
        
        view.addSubview(statsStackView)
        statsStackView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(16)
        }
        
        view.addSubview(lowerDividerView)
        lowerDividerView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.directionalHorizontalEdges.equalToSuperview().inset(8)
            make.height.equalTo(1)
        }
    }
    
    private lazy var commentButton = createButton(withImageName: "comment").then {
        $0.addTarget(self, action: #selector(handleCommentTapped), for: .touchUpInside)
    }
    
    private lazy var retweetButton = createButton(withImageName: "retweet").then {
        $0.addTarget(self, action: #selector(handleRetweetTapped), for: .touchUpInside)
    }
    
    private lazy var likeButton = createButton(withImageName: "like").then {
        $0.addTarget(self, action: #selector(handleLikeTapped), for: .touchUpInside)
    }
    
    private lazy var shareButton = createButton(withImageName: "share").then {
        $0.addTarget(self, action: #selector(handleShareTapped), for: .touchUpInside)
    }
    
    private lazy var actionStackView = UIStackView(arrangedSubviews: [commentButton, retweetButton, likeButton, shareButton]).then {
        $0.spacing = 72
    }
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        configureMentionHandler()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selectors
    
    @objc private func handleProfileImageTapped() {
        print("DEBUG: Go to user profile..")
    }
    
    @objc private func showActionSheet() {
        delegate?.showActionSheet()
    }
    
    @objc private func handleCommentTapped() {
        
    }
    
    @objc private func handleRetweetTapped() {
        
    }
    
    @objc private func handleLikeTapped() {
        
    }
    
    @objc private func handleShareTapped() {
        
    }
    
    // MARK: - Helpers
    
    private func configure() {
        guard let tweet = tweet else { return }
        
        let viewModel = TweetViewModel(tweet: tweet)
        captionLabel.text = tweet.caption
        fullNameLabel.text = tweet.user.fullName
        usernameLabel.text = viewModel.usernameText
        dateLabel.text = viewModel.headerTimestamp
        profileImageView.kf.setImage(with: viewModel.profileImageUrl)
        retweetsLabel.attributedText = viewModel.retweetsAttributedString
        likesLabel.attributedText = viewModel.likesAttributedString
        likeButton.setImage(viewModel.likeButtonImage, for: .normal)
        likeButton.tintColor = viewModel.likeButtonTintColor
        replyLabel.isHidden = viewModel.shouldHideReplyLabel
        replyLabel.text = viewModel.replyText
    }
    
    private func createButton(withImageName imageName: String) -> UIButton {
        let button = UIButton(type: .system)
        let imageResource = ImageResource(name: imageName, bundle: .main)
        button.setImage(UIImage(resource: imageResource), for: .normal)
        button.tintColor = .darkGray
        button.setDimensions(width: 20, height: 20)
        
        return button
    }
    
    private func configureUI() {
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.leading.equalToSuperview().inset(16)
        }
        
        addSubview(optionsButton)
        optionsButton.snp.makeConstraints { make in
            make.centerY.equalTo(profileStackView)
            make.trailing.equalToSuperview().inset(8)
        }
        
        addSubview(captionLabel)
        captionLabel.snp.makeConstraints { make in
            make.top.equalTo(profileStackView.snp.bottom).offset(12)
            make.directionalHorizontalEdges.equalToSuperview().inset(16)
        }
        
        addSubview(dateLabel)
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(captionLabel.snp.bottom).offset(20)
            make.leading.equalToSuperview().inset(16)
        }
        
        addSubview(statsView)
        statsView.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(12)
            make.directionalHorizontalEdges.equalToSuperview()
            make.height.equalTo(40)
        }
        
        addSubview(actionStackView)
        actionStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(statsView.snp.bottom).offset(16)
        }
    }
    
    private func configureMentionHandler() {
        captionLabel.handleMentionTap { username in
            self.delegate?.handleFetchUser(withUsername: username)
        }
    }
}
