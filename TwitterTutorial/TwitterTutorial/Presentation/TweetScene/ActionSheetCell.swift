//
//  ActionSheetCell.swift
//  TwitterTutorial
//
//  Created by Daehoon Lee on 7/6/24.
//

import SnapKit
import Then
import UIKit

class ActionSheetCell: UITableViewCell {
    
    // MARK: - Properties
    
    var option: ActionSheetOptions? {
        didSet { configure() }
    }
    
    private let optionImageView = UIImageView().then {
        $0.image = UIImage(resource: .twitterLogoBlue)
        $0.contentMode = .scaleAspectFit
        $0.clipsToBounds = true
    }
    
    private let titleLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 18)
    }
    
    // MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    
    private func configure() {
        titleLabel.text = option?.description
    }
    
    private func configureUI() {
        addSubview(optionImageView)
        optionImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(8)
            make.size.equalTo(36)
        }
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(optionImageView.snp.trailing).offset(12)
        }
    }
}
