//
//  EditProfileFooter.swift
//  TwitterTutorial
//
//  Created by Daehoon Lee on 7/16/24.
//

import SnapKit
import Then
import UIKit

protocol EditProfileFooterDelegate: AnyObject {
    func handleLogout()
}

class EditProfileFooter: UIView {
    
    // MARK: - Properties
    
    weak var delegate: EditProfileFooterDelegate?
    
    private lazy var logoutButton = UIButton(type: .system).then {
        $0.setTitle("Logout", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        $0.addTarget(self, action: #selector(handleLogout), for: .touchUpInside)
        $0.backgroundColor = .red
        $0.layer.cornerRadius = 5
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
    
    @objc private func handleLogout() {
        delegate?.handleLogout()
    }
    
    // MARK: - Helpers
    
    private func configureUI() {
        addSubview(logoutButton)
        logoutButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.height.equalTo(50)
            make.directionalHorizontalEdges.equalToSuperview().inset(16)
        }
    }
}
