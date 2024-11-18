//
//  TweetCell.swift
//  TwitterTutorial
//
//  Created by Daehoon Lee on 7/3/24.
//

import ActiveLabel
import Kingfisher
import SnapKit
import Then
import UIKit

protocol TweetCellDelegate: AnyObject {
    func handleProfileImageTapped(_ cell: TweetCell)
    func handleReplyTapped(_ cell: TweetCell)
    func handleLikeTapped(_ cell: TweetCell)
    func handleFetchUser(withUsername username: String)
}

class TweetCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    var tweet: Tweet? {
        didSet { configure() }
    }
    
    weak var delegate: TweetCellDelegate?
    
    private lazy var profileImageView = UIImageView().then { imageView in
        imageView.backgroundColor = .twitterBlue
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 48 / 2
        imageView.clipsToBounds = true
        
        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(48)
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleProfileImageTapped))
        imageView.addGestureRecognizer(tapGesture)
        imageView.isUserInteractionEnabled = true
    }
    
    private let replyLabel = ActiveLabel().then {
        $0.textColor = .lightGray
        $0.mentionColor = .twitterBlue
        $0.font = UIFont.systemFont(ofSize: 12)
    }
    
    private let informationLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14)
    }
    
    private let captionLabel = ActiveLabel().then {
        $0.numberOfLines = 0
        $0.mentionColor = .twitterBlue
        $0.hashtagColor = .twitterBlue
        $0.font = UIFont.systemFont(ofSize: 14)
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
    
    private let underlineView = UIView().then {
        $0.backgroundColor = .systemGroupedBackground
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
        delegate?.handleProfileImageTapped(self)
    }
    
    @objc private func handleCommentTapped() {
        delegate?.handleReplyTapped(self)
    }
    
    @objc private func handleRetweetTapped() {
        
    }
    
    @objc private func handleLikeTapped() {
        delegate?.handleLikeTapped(self)
    }
    
    @objc private func handleShareTapped() {
        
    }
    
    // MARK: - Helpers
    
    private func configure() {
        guard let tweet = tweet else { return }
        
        let viewModel = TweetViewModel(tweet: tweet)
        profileImageView.kf.setImage(with: viewModel.profileImageUrl)
        informationLabel.attributedText = viewModel.userInformationText
        captionLabel.text = tweet.caption
        likeButton.tintColor = viewModel.likeButtonTintColor
        likeButton.setImage(viewModel.likeButtonImage, for: .normal)
        replyLabel.isHidden = viewModel.shouldHideReplyLabel
        replyLabel.text = viewModel.replyText
    }
    
    private func configureUI() {
        backgroundColor = .systemBackground
        
        let captionStackView = UIStackView(arrangedSubviews: [informationLabel, captionLabel]).then {
            $0.spacing = 4
            $0.axis = .vertical
            $0.distribution = .fillProportionally
        }
        
        let imageCaptionStackView = UIStackView(arrangedSubviews: [profileImageView, captionStackView]).then {
            $0.spacing = 12
            $0.alignment = .leading
            $0.distribution = .fillProportionally
        }
        
        let stackView = UIStackView(arrangedSubviews: [replyLabel, imageCaptionStackView]).then {
            $0.spacing = 8
            $0.axis = .vertical
            $0.distribution = .fillProportionally
        }
        
        contentView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(4)
            make.leading.trailing.equalToSuperview().inset(12)
        }
        
        contentView.addSubview(actionStackView)
        actionStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(8)
        }
        
        contentView.addSubview(underlineView)
        underlineView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    
    private func createButton(withImageName imageName: String) -> UIButton {
        let button = UIButton(type: .system)
        let imageResource = ImageResource(name: imageName, bundle: .main)
        button.setImage(UIImage(resource: imageResource), for: .normal)
        button.tintColor = .darkGray
        button.setDimensions(width: 20, height: 20)
        
        return button
    }
    
    private func configureMentionHandler() {
        captionLabel.handleMentionTap { username in
            self.delegate?.handleFetchUser(withUsername: username)
        }
    }
}
