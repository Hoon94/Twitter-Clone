//
//  InputTextView.swift
//  TwitterTutorial
//
//  Created by Daehoon Lee on 7/3/24.
//

import SnapKit
import Then
import UIKit

class InputTextView: UITextView {
    
    // MARK: - Properties
    
    let placeholderLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.text = "What's happening?"
        $0.textColor = .darkGray
    }
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selectors
    
    @objc private func handleTextInputChange() {
        placeholderLabel.isHidden = !text.isEmpty
    }
    
    // MARK: - Helpers
    
    private func configureUI() {
        backgroundColor = .systemBackground
        font = UIFont.systemFont(ofSize: 16)
        isScrollEnabled = false
        
        snp.makeConstraints { make in
            make.height.equalTo(100)
        }
        
        addSubview(placeholderLabel)
        placeholderLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(8)
            make.leading.equalToSuperview().inset(4)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextInputChange), name: UITextView.textDidChangeNotification, object: nil)
    }
}
