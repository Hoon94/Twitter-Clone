//
//  RegistrationController.swift
//  TwitterTutorial
//
//  Created by Daehoon Lee on 7/1/24.
//

import Firebase
import SnapKit
import Then
import UIKit

class RegistrationController: UIViewController {
    
    // MARK: - Properties
    
    private let imagePicker = UIImagePickerController()
    private var profileImage: UIImage?
    
    private lazy var plusPhotoButton = UIButton(type: .system).then {
        $0.tintColor = .white
        $0.setImage(UIImage(resource: .plusPhoto), for: .normal)
        $0.addTarget(self, action: #selector(handleAddProfilePhoto), for: .touchUpInside)
    }
    
    private lazy var emailContainerView = Utilities().inputContainerView(withImage: UIImage(resource: .icMailOutlineWhite2X1), textField: emailTextField)
    private lazy var passwordContainerView = Utilities().inputContainerView(withImage: UIImage(resource: .icLockOutlineWhite2X), textField: passwordTextField)
    private lazy var fullNameContainerView = Utilities().inputContainerView(withImage: UIImage(resource: .icPersonOutlineWhite2X), textField: fullNameTextField)
    private lazy var usernameContainerView = Utilities().inputContainerView(withImage: UIImage(resource: .icPersonOutlineWhite2X), textField: usernameTextField)
    
    private let emailTextField = Utilities().textField(withPlaceholder: "Email").then {
        $0.autocapitalizationType = .none
    }
    
    private let passwordTextField = Utilities().textField(withPlaceholder: "Password").then {
        $0.isSecureTextEntry = true
    }
    
    private let fullNameTextField = Utilities().textField(withPlaceholder: "Full Name")
    private let usernameTextField = Utilities().textField(withPlaceholder: "Username")
    
    private lazy var registrationButton = UIButton(type: .system).then { button in
        button.setTitle("Sign Up", for: .normal)
        button.setTitleColor(.twitterBlue, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.layer.cornerRadius = 5
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(handleRegistration), for: .touchUpInside)
    }
    
    private lazy var stackView = UIStackView(arrangedSubviews: [emailContainerView, passwordContainerView, fullNameContainerView, usernameContainerView, registrationButton]).then {
        $0.spacing = 20
        $0.axis = .vertical
        $0.distribution = .fillEqually
    }
    
    private lazy var alreadyHaveAccountButton = Utilities().attributedButton("Already have an account?", " Log In").then {
        $0.addTarget(self, action: #selector(handleShowLogin), for: .touchUpInside)
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - Selectors
    
    @objc private func handleAddProfilePhoto() {
        present(imagePicker, animated: true)
    }
    
    @objc private func handleRegistration() {
        guard let profileImage = profileImage else {
            print("DEBUG: Please select a profile image..")
            return
        }
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        guard let fullName = fullNameTextField.text else { return }
        guard let username = usernameTextField.text?.lowercased() else { return }
        
        let credentials = AuthCredentials(email: email, password: password, fullName: fullName, username: username, profileImage: profileImage)
        
        AuthService.shared.registerUser(credentials: credentials) { error, reference in
            guard let mainTabController = self.view.window?.rootViewController as? MainTabController else { return }
            
            mainTabController.authenticateUserAndConfigureUI()
            self.dismiss(animated: true)
        }
    }
    
    @objc private func handleShowLogin() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Helpers
    
    private func configureUI() {
        view.backgroundColor = .twitterBlue
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        view.addSubview(plusPhotoButton)
        plusPhotoButton.snp.makeConstraints { make in
            make.width.height.equalTo(128)
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide)
        }
        
        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(plusPhotoButton.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview().inset(32)
        }
        
        registrationButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.leading.trailing.equalToSuperview()
        }
        
        view.addSubview(alreadyHaveAccountButton)
        alreadyHaveAccountButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
    }
}

// MARK: - UIImagePickerControllerDelegate

extension RegistrationController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let profileImage = info[.editedImage] as? UIImage else { return }
        
        self.profileImage = profileImage
        plusPhotoButton.layer.cornerRadius = 128 / 2
        plusPhotoButton.layer.masksToBounds = true
        plusPhotoButton.imageView?.contentMode = .scaleAspectFill
        plusPhotoButton.imageView?.clipsToBounds = true
        plusPhotoButton.layer.borderColor = UIColor.white.cgColor
        plusPhotoButton.layer.borderWidth = 3
        plusPhotoButton.setImage(profileImage.withRenderingMode(.alwaysOriginal), for: .normal)
        
        dismiss(animated: true)
    }
}
