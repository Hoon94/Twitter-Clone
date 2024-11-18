//
//  EditProfileHeader.swift
//  TwitterTutorial
//
//  Created by Daehoon Lee on 7/15/24.
//

import Kingfisher
import SnapKit
import Then
import UIKit

protocol EditProfileHeaderDelegate: AnyObject {
    func didTapChangeProfilePhoto()
}

class EditProfileHeader: UIView {
    
    // MARK: - Properties
    
    private let user: User
    
    weak var delegate: EditProfileHeaderDelegate?
    
    let profileImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.backgroundColor = .lightGray
        $0.layer.borderColor = UIColor.white.cgColor
        $0.layer.borderWidth = 3.0
    }
    
    private lazy var changePhotoButton = UIButton(type: .system).then {
        $0.setTitleColor(.white, for: .normal)
        $0.setTitle("Change Profile Photo", for: .normal)
        $0.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        $0.addTarget(self, action: #selector(handleChangeProfilePhoto), for: .touchUpInside)
    }
    
    // MARK: - Lifecycle
    
    init(user: User) {
        self.user = user
        super.init(frame: .zero)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selectors
    
    @objc private func handleChangeProfilePhoto() {
        delegate?.didTapChangeProfilePhoto()
    }
    
    // MARK: - Helpers
    
    private func configureUI() {
        backgroundColor = .twitterBlue
        profileImageView.kf.setImage(with: user.profileImageUrl)
        
        addSubview(profileImageView)
        profileImageView.layer.cornerRadius = 100 / 2
        profileImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-16)
            make.size.equalTo(100)
        }
        
        addSubview(changePhotoButton)
        changePhotoButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(profileImageView.snp.bottom).offset(8)
        }
    }
}
