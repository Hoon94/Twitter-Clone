//
//  EditProfileController.swift
//  TwitterTutorial
//
//  Created by Daehoon Lee on 7/15/24.
//

import UIKit

private let reuseIdentifier = "EditProfileCell"

protocol EditProfileControllerDelegate: AnyObject {
    func controller(_ controller: EditProfileController, wantsToUpdate user: User)
}

class EditProfileController: UITableViewController {
    
    // MARK: - Properties
    
    private var user: User
    private lazy var headerView = EditProfileHeader(user: user)
    private let imagePickerController = UIImagePickerController()
    private var userInformationChanged = false
    
    weak var delegate: EditProfileControllerDelegate?
    
    private var imageChanged: Bool {
        return selectedImage != nil
    }
    
    private var selectedImage: UIImage? {
        didSet { headerView.profileImageView.image = selectedImage }
    }
    
    // MARK: - Lifecycle
    
    init(user: User) {
        self.user = user
        super.init(style: .plain)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        configureImagePicker()
        configureNavigationBar()
    }
    
    // MARK: - API
    
    func updateUserData() {
        if imageChanged && !userInformationChanged {
            print("DEBUG: Changed image and not data")
            updateProfileImage()
        }
        
        if userInformationChanged && !imageChanged {
            print("DEBUG: Changed data and not image..")
            UserService.shared.saveUserData(user: user) { error, reference in
                self.delegate?.controller(self, wantsToUpdate: self.user)
            }
        }
        
        if userInformationChanged && imageChanged {
            print("DEBUG: Changed both..")
            UserService.shared.saveUserData(user: user) { error, reference in
                self.updateProfileImage()
            }
        }
    }
    
    func updateProfileImage() {
        guard let image = selectedImage else { return }
        
        UserService.shared.updateProfileImage(image: image) { profileImageUrl in
            self.user.profileImageUrl = profileImageUrl
            self.delegate?.controller(self, wantsToUpdate: self.user)
        }
    }
    
    // MARK: - Selectors
    
    @objc func handleCancel() {
        dismiss(animated: true)
    }
    
    @objc func handleDone() {
        view.endEditing(true)
        
        guard imageChanged || userInformationChanged else { return }
        
        updateUserData()
    }
    
    // MARK: - Helpers
    
    func configureTableView() {
        tableView.tableHeaderView = headerView
        headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 180)
        tableView.isScrollEnabled = false
        
        headerView.delegate = self
        
        tableView.register(EditProfileCell.self, forCellReuseIdentifier: reuseIdentifier)
    }
    
    func configureImagePicker() {
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
    }
    
    func configureNavigationBar() {
        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .twitterBlue
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = navigationController?.navigationBar.standardAppearance
        } else {
            navigationController?.navigationBar.barTintColor = .twitterBlue
        }
        
        navigationItem.title = "Edit Profile"
        navigationController?.navigationBar.tintColor = .white
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(handleDone))
    }
}

// MARK: - UITableViewDataSource

extension EditProfileController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return EditProfileOptions.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? EditProfileCell else { return UITableViewCell() }
        
        cell.delegate = self
        
        guard let option = EditProfileOptions(rawValue: indexPath.row) else { return cell }
        
        cell.viewModel = EditProfileViewModel(user: user, option: option)
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension EditProfileController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let option = EditProfileOptions(rawValue: indexPath.row) else { return 0 }
        
        return option == .bio ? 100 : 48
    }
}

// MARK: - EditProfileHeaderDelegate

extension EditProfileController: EditProfileHeaderDelegate {
    func didTapChangeProfilePhoto() {
        present(imagePickerController, animated: true)
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension EditProfileController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        
        selectedImage = image
        
        dismiss(animated: true)
    }
}

// MARK: - EditProfileCellDelegate

extension EditProfileController: EditProfileCellDelegate {
    func updateUserInformation(_ cell: EditProfileCell) {
        guard let viewModel = cell.viewModel else { return }
        
        userInformationChanged = true
        navigationItem.rightBarButtonItem?.isEnabled = true
        
        switch viewModel.option {
        case .fullName:
            guard let fullName = cell.informationTextField.text else { return }
            
            user.fullName = fullName
        case .username:
            guard let username = cell.informationTextField.text else { return }
            
            user.username = username
        case .bio:
            user.bio = cell.bioTextView.text
        }
    }
}
