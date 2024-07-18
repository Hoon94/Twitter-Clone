//
//  TweetCell.swift
//  TwitterTutorial
//
//  Created by Daehoon Lee on 7/3/24.
//

import ActiveLabel
import Kingfisher
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
    
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.setDimensions(width: 48, height: 48)
        imageView.layer.cornerRadius = 48 / 2
        imageView.backgroundColor = .twitterBlue
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleProfileImageTapped))
        imageView.addGestureRecognizer(tapGesture)
        imageView.isUserInteractionEnabled = true
        
        return imageView
    }()
    
    private let replyLabel: ActiveLabel = {
        let label = ActiveLabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 12)
        label.mentionColor = .twitterBlue
        
        return label
    }()
    
    private let captionLabel: ActiveLabel = {
        let label = ActiveLabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.mentionColor = .twitterBlue
        label.hashtagColor = .twitterBlue
        
        return label
    }()
    
    private lazy var commentButton: UIButton = {
        let button = createButton(withImageName: "comment")
        button.addTarget(self, action: #selector(handleCommentTapped), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var retweetButton: UIButton = {
        let button = createButton(withImageName: "retweet")
        button.addTarget(self, action: #selector(handleRetweetTapped), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var likeButton: UIButton = {
        let button = createButton(withImageName: "like")
        button.addTarget(self, action: #selector(handleLikeTapped), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var shareButton: UIButton = {
        let button = createButton(withImageName: "share")
        button.addTarget(self, action: #selector(handleShareTapped), for: .touchUpInside)
        
        return button
    }()
    
    private let informationLabel = UILabel()
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        let captionStackView = UIStackView(arrangedSubviews: [informationLabel, captionLabel])
        captionStackView.axis = .vertical
        captionStackView.distribution = .fillProportionally
        captionStackView.spacing = 4
        
        let imageCaptionStackView = UIStackView(arrangedSubviews: [profileImageView, captionStackView])
        imageCaptionStackView.distribution = .fillProportionally
        imageCaptionStackView.spacing = 12
        imageCaptionStackView.alignment = .leading
        
        let stackView = UIStackView(arrangedSubviews: [replyLabel, imageCaptionStackView])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.distribution = .fillProportionally
        
        addSubview(stackView)
        stackView.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 4, paddingLeft: 12, paddingRight: 12)
                
        informationLabel.font = UIFont.systemFont(ofSize: 14)
        
        let actionStackView = UIStackView(arrangedSubviews: [commentButton, retweetButton, likeButton, shareButton])
        actionStackView.axis = .horizontal
        actionStackView.spacing = 72
        
        addSubview(actionStackView)
        actionStackView.centerX(inView: self)
        actionStackView.anchor(bottom: bottomAnchor, paddingBottom: 8)
        
        let underlineView = UIView()
        underlineView.backgroundColor = .systemGroupedBackground
        addSubview(underlineView)
        underlineView.anchor(left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, height: 1)
        
        configureMentionHandler()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selectors
    
    @objc func handleProfileImageTapped() {
        delegate?.handleProfileImageTapped(self)
    }
    
    @objc func handleCommentTapped() {
        delegate?.handleReplyTapped(self)
    }
    
    @objc func handleRetweetTapped() {
        
    }
    
    @objc func handleLikeTapped() {
        delegate?.handleLikeTapped(self)
    }
    
    @objc func handleShareTapped() {
        
    }
    
    // MARK: - Helpers
    
    func configure() {
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
    
    func createButton(withImageName imageName: String) -> UIButton {
        let button = UIButton(type: .system)
        let imageResource = ImageResource(name: imageName, bundle: .main)
        button.setImage(UIImage(resource: imageResource), for: .normal)
        button.tintColor = .darkGray
        button.setDimensions(width: 20, height: 20)
        
        return button
    }
    
    func configureMentionHandler() {
        captionLabel.handleMentionTap { username in
            self.delegate?.handleFetchUser(withUsername: username)
        }
    }
}
