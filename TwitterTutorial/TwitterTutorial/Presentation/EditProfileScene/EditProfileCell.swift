//
//  EditProfileCell.swift
//  TwitterTutorial
//
//  Created by Daehoon Lee on 7/15/24.
//

import SnapKit
import Then
import UIKit

protocol EditProfileCellDelegate: AnyObject {
    func updateUserInformation(_ cell: EditProfileCell)
}

class EditProfileCell: UITableViewCell {
    
    // MARK: - Properties
    
    var viewModel: EditProfileViewModel? {
        didSet { configure() }
    }
    
    weak var delegate: EditProfileCellDelegate?
    
    private let titleLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14)
    }
    
    lazy var informationTextField = UITextField().then {
        $0.borderStyle = .none
        $0.textAlignment = .left
        $0.textColor = .twitterBlue
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.addTarget(self, action: #selector(handleUpdateUserInformation), for: .editingDidEnd)
    }
    
    let bioTextView = InputTextView().then {
        $0.textColor = .twitterBlue
        $0.placeholderLabel.text = "Bio"
        $0.font = UIFont.systemFont(ofSize: 14)
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
    
    @objc private func handleUpdateUserInformation() {
        delegate?.updateUserInformation(self)
    }
    
    // MARK: - Helpers
    
    private func configure() {
        guard let viewModel = viewModel else { return }
        
        titleLabel.text = viewModel.titleText
        informationTextField.text = viewModel.optionValue
        informationTextField.isHidden = viewModel.shouldHideTextField
        bioTextView.text = viewModel.optionValue
        bioTextView.isHidden = viewModel.shouldHideTextView
        bioTextView.placeholderLabel.isHidden = viewModel.shouldHidePlaceholderLabel
    }
    
    private func configureUI() {
        selectionStyle = .none
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.width.equalTo(100)
            make.top.equalToSuperview().inset(12)
            make.leading.equalToSuperview().inset(16)
        }
        
        contentView.addSubview(informationTextField)
        informationTextField.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(-4)
            make.bottom.equalToSuperview()
            make.leading.equalTo(titleLabel.snp.trailing).offset(16)
            make.trailing.equalToSuperview().inset(8)
        }
        
        contentView.addSubview(bioTextView)
        bioTextView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(4)
            make.bottom.equalToSuperview()
            make.leading.equalTo(titleLabel.snp.trailing).offset(12)
            make.trailing.equalToSuperview().inset(8)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateUserInformation), name: UITextView.textDidEndEditingNotification, object: nil)
    }
}
