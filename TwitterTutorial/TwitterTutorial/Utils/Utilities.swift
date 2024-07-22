//
//  Utilities.swift
//  TwitterTutorial
//
//  Created by Daehoon Lee on 7/1/24.
//

import SnapKit
import UIKit

class Utilities {
    
    // MARK: - Helpers
    
    func inputContainerView(withImage image: UIImage, textField: UITextField) -> UIView {
        let view = UIView()
        let imageView = UIImageView()
        let dividerView = UIView()
        
        imageView.image = image
        dividerView.backgroundColor = .white
        
        view.addSubview(imageView)
        view.addSubview(textField)
        view.addSubview(dividerView)
        
        view.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
        
        imageView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.bottom.equalToSuperview().inset(8)
            make.width.height.equalTo(24)
        }
        
        textField.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(8)
            make.bottom.equalToSuperview().inset(8)
            make.trailing.equalToSuperview()
        }
        
        dividerView.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview()
            make.height.equalTo(0.75)
        }
        
        return view
    }
    
    func textField(withPlaceholder placeholder: String) -> UITextField {
        let textField = UITextField()
        textField.textColor = .white
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [.foregroundColor: UIColor.white])
        
        return textField
    }
    
    func attributedButton(_ firstPart: String, _ secondPart: String) -> UIButton {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: firstPart, attributes: [.font: UIFont.systemFont(ofSize: 16),
                                                                                        .foregroundColor: UIColor.white])
        attributedTitle.append(NSMutableAttributedString(string: secondPart, attributes: [.font: UIFont.boldSystemFont(ofSize: 16),
                                                                                         .foregroundColor: UIColor.white]))
        button.setAttributedTitle(attributedTitle, for: .normal)
        
        return button
    }
}
