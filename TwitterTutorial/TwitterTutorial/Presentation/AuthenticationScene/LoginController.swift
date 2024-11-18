//
//  LoginController.swift
//  TwitterTutorial
//
//  Created by Daehoon Lee on 7/1/24.
//

import SnapKit
import Then
import UIKit

class LoginController: UIViewController {
    
    // MARK: - Properties
    
    private let logoImageView = UIImageView().then {
        $0.image = UIImage(resource: .twitterLogo)
        $0.contentMode = .scaleAspectFit
        $0.clipsToBounds = true
    }
    
    private lazy var emailContainerView = Utilities().inputContainerView(withImage: UIImage(resource: .icMailOutlineWhite2X1), textField: emailTextField)
    
    private lazy var passwordContainerView = Utilities().inputContainerView(withImage: UIImage(resource: .icLockOutlineWhite2X), textField: passwordTextField)
    
    private let emailTextField = Utilities().textField(withPlaceholder: "Email").then {
        $0.autocapitalizationType = .none
    }
    
    private let passwordTextField = Utilities().textField(withPlaceholder: "Password").then {
        $0.isSecureTextEntry = true
    }
    
    private lazy var loginButton = UIButton(type: .system).then { button in
        button.setTitle("Log In", for: .normal)
        button.setTitleColor(.twitterBlue, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.backgroundColor = .white
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
    }
    
    private lazy var stackView = UIStackView(arrangedSubviews: [emailContainerView, passwordContainerView, loginButton]).then {
        $0.spacing = 20
        $0.axis = .vertical
        $0.distribution = .fillEqually
    }
    
    private lazy var dontHaveAccountButton = Utilities().attributedButton("Don't have an account?", " Sign Up").then {
        $0.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - Selectors
    
    @objc private func handleLogin() {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        AuthService.shared.logUserIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print("DEBUG: Error logging in \(error.localizedDescription)")
                return
            }
            
            guard let mainTabController = self.view.window?.rootViewController as? MainTabController else { return }
            
            mainTabController.authenticateUserAndConfigureUI()
            self.dismiss(animated: true)
        }
    }
    
    @objc private func handleShowSignUp() {
        let controller = RegistrationController()
        navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK: - Helpers
    
    private func configureUI() {
        view.backgroundColor = .twitterBlue
        navigationController?.navigationBar.isHidden = true
        
        view.addSubview(logoImageView)
        logoImageView.snp.makeConstraints { make in
            make.width.height.equalTo(150)
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide)
        }
        
        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(logoImageView.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(32)
        }
        
        loginButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.leading.trailing.equalToSuperview()
        }
        
        view.addSubview(dontHaveAccountButton)
        dontHaveAccountButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
    }
}
