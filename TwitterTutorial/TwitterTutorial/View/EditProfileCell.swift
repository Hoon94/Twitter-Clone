//
//  EditProfileCell.swift
//  TwitterTutorial
//
//  Created by Daehoon Lee on 7/15/24.
//

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
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        
        return label
    }()
    
    lazy var informationTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .none
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.textAlignment = .left
        textField.textColor = .twitterBlue
        textField.addTarget(self, action: #selector(handleUpdateUserInformation), for: .editingDidEnd)
        textField.text = "Test User Attribute"
        
        return textField
    }()
    
    let bioTextView: InputTextView = {
        let textView = InputTextView()
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.textColor = .twitterBlue
        textView.placeholderLabel.text = "Bio"
        
        return textView
    }()
    
    // MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        contentView.addSubview(titleLabel)
        titleLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        titleLabel.anchor(top: topAnchor, left: leftAnchor, paddingTop: 12, paddingLeft: 16)
        
        contentView.addSubview(informationTextField)
        informationTextField.anchor(top: topAnchor, left: titleLabel.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 4, paddingLeft: 16, paddingRight: 8)
        
        contentView.addSubview(bioTextView)
        bioTextView.anchor(top: topAnchor, left: titleLabel.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 4, paddingLeft: 12, paddingRight: 8)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateUserInformation), name: UITextView.textDidEndEditingNotification, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selectors
    
    @objc func handleUpdateUserInformation() {
        delegate?.updateUserInformation(self)
    }
    
    // MARK: - Helpers
    
    func configure() {
        guard let viewModel = viewModel else { return }
        
        titleLabel.text = viewModel.titleText
        informationTextField.text = viewModel.optionValue
        informationTextField.isHidden = viewModel.shouldHideTextField
        bioTextView.text = viewModel.optionValue
        bioTextView.isHidden = viewModel.shouldHideTextView
        bioTextView.placeholderLabel.isHidden = viewModel.shouldHidePlaceholderLabel
    }
}
