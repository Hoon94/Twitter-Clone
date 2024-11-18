//
//  UploadTweetController.swift
//  TwitterTutorial
//
//  Created by Daehoon Lee on 7/3/24.
//

import ActiveLabel
import Kingfisher
import SnapKit
import Then
import UIKit

class UploadTweetController: UIViewController {
    
    // MARK: - Properties
    
    private let user: User
    private let config: UploadTweetConfiguration
    private lazy var viewModel = UploadTweetViewModel(config: config)
    
    private lazy var actionButton = UIButton(type: .system).then { button in
        button.backgroundColor = .twitterBlue
        button.setTitle("Tweet", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 64, height: 32)
        button.layer.cornerRadius = 32 / 2
        button.addTarget(self, action: #selector(handleUploadTweet), for: .touchUpInside)
    }
    
    private let profileImageView = UIImageView().then { imageView in
        imageView.backgroundColor = .twitterBlue
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 48 / 2
        imageView.snp.makeConstraints { make in
            make.size.equalTo(48)
        }
    }
    
    private let replyLabel = ActiveLabel().then {
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.textColor = .lightGray
        $0.mentionColor = .twitterBlue
    }
    
    private let captionTextView = InputTextView()
    
    private lazy var imageCaptionStackView = UIStackView(arrangedSubviews: [profileImageView, captionTextView]).then {
        $0.spacing = 12
        $0.axis = .horizontal
        $0.alignment = .leading
    }
    
    private lazy var stackView = UIStackView(arrangedSubviews: [replyLabel, imageCaptionStackView]).then {
        $0.axis = .vertical
        $0.spacing = 12
    }
    
    // MARK: - Lifecycle
    
    init(user: User, config: UploadTweetConfiguration) {
        self.user = user
        self.config = config
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureMentionHandler()
    }
    
    // MARK: - Selectors
    
    @objc private func handleCancel() {
        dismiss(animated: true)
    }
    
    @objc private func handleUploadTweet() {
        guard let caption = captionTextView.text else { return }
        
        TweetService.shared.uploadTweet(caption: caption, type: config) { error, reference in
            if let error = error {
                print("DEBUG: Failed to upload tweet for user-tweets with error \(error.localizedDescription)")
                return
            }
            
            if case .reply(let tweet) = self.config {
                NotificationService.shared.uploadNotification(toUser: tweet.user, type: .reply, tweetId: tweet.tweetId)
            }
            
            // FIXME: - tweetId 대신 userId를 사용함으로 노티에서 멘션 cell 클릭 시 tweet으로 넘어가지 않는다.
            self.uploadMentionNotification(forCaption: caption, tweetId: reference.key)
            
            self.dismiss(animated: true)
        }
    }
    
    // MARK: - API
    
    private func uploadMentionNotification(forCaption caption: String, tweetId: String?) {
        guard caption.contains("@") else { return }
        
        let words = caption.components(separatedBy: .whitespacesAndNewlines)
        
        words.forEach { word in
            guard word.hasPrefix("@") else { return }
            
            var username = word.trimmingCharacters(in: .symbols)
            username = username.trimmingCharacters(in: .punctuationCharacters)
            
            UserService.shared.fetchUser(withUsername: username) { mentionedUser in
                NotificationService.shared.uploadNotification(toUser: mentionedUser, type: .mention, tweetId: tweetId)
            }
        }
    }
    
    // MARK: - Helpers
    
    private func configureUI() {
        view.backgroundColor = .systemBackground

        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.directionalHorizontalEdges.equalToSuperview().inset(16)
        }
        
        configureNavigationBar()
        profileImageView.kf.setImage(with: user.profileImageUrl)
        actionButton.setTitle(viewModel.actionButtonTitle, for: .normal)
        captionTextView.placeholderLabel.text = viewModel.placeholderText
        replyLabel.isHidden = !viewModel.shouldShowReplyLabel
        replyLabel.text = viewModel.replyText
    }
    
    private func configureNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: actionButton)
    }
    
    private func configureMentionHandler() {
        replyLabel.handleMentionTap { username in
            print("DEBUG: Mentioned user is \(username)")
        }
    }
}
