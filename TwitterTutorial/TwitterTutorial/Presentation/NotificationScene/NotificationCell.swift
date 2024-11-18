//
//  NotificationCell.swift
//  TwitterTutorial
//
//  Created by Daehoon Lee on 7/9/24.
//

import Kingfisher
import SnapKit
import Then
import UIKit

protocol NotificationCellDelegate: AnyObject {
    func didTapProfileImage(_ cell: NotificationCell)
    func didTapFollowButton(_ cell: NotificationCell)
}

class NotificationCell: UITableViewCell {
    
    // MARK: - Properties
    
    var notification: Notification? {
        didSet { configure() }
    }
    
    weak var delegate: NotificationCellDelegate?
    
    private lazy var profileImageView = UIImageView().then { imageView in
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 40 / 2
        imageView.backgroundColor = .twitterBlue
        
        imageView.snp.makeConstraints { make in
            make.size.equalTo(40)
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleProfileImageTapped))
        imageView.addGestureRecognizer(tapGesture)
        imageView.isUserInteractionEnabled = true
    }
    
    private let notificationLabel = UILabel().then {
        $0.numberOfLines = 2
        $0.font = UIFont.systemFont(ofSize: 14)
    }
    
    private lazy var stackView = UIStackView(arrangedSubviews: [profileImageView, notificationLabel]).then {
        $0.spacing = 8
        $0.alignment = .center
    }
    
    private lazy var followButton = UIButton(type: .system).then { button in
        button.setTitleColor(.twitterBlue, for: .normal)
        button.backgroundColor = .systemBackground
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.twitterBlue.cgColor
        button.addTarget(self, action: #selector(handleFollowTapped), for: .touchUpInside)
    }
    
    // MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selectors
    
    @objc private func handleProfileImageTapped() {
        delegate?.didTapProfileImage(self)
    }
    
    @objc private func handleFollowTapped() {
        delegate?.didTapFollowButton(self)
    }
    
    // MARK: - Helpers
    
    private func configure() {
        guard let notification = notification else { return }
        
        let viewModel = NotificationViewModel(notification: notification)
        profileImageView.kf.setImage(with: viewModel.profileImageUrl)
        notificationLabel.attributedText = viewModel.notificationText
        followButton.isHidden = viewModel.shouldHideFollowButton
        followButton.setTitle(viewModel.followButtonText, for: .normal)
    }
    
    private func configureUI() {
        selectionStyle = .none
        
        contentView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.directionalHorizontalEdges.equalToSuperview().inset(12)
        }
        
        contentView.addSubview(followButton)
        followButton.layer.cornerRadius = 32 / 2
        followButton.snp.makeConstraints { make in
            make.width.equalTo(92)
            make.height.equalTo(32)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(12)
        }
    }
}
