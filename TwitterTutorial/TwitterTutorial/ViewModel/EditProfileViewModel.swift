//
//  EditProfileViewModel.swift
//  TwitterTutorial
//
//  Created by Daehoon Lee on 7/15/24.
//

import Foundation

enum EditProfileOptions: Int, CaseIterable {
    
    // MARK: - Case
    
    case fullName
    case username
    case bio
    
    // MARK: - Properties
    
    var description: String {
        switch self {
        case .fullName:
            return "Name"
        case .username:
            return "Username"
        case .bio:
            return "Bio"
        }
    }
}

struct EditProfileViewModel {
    
    // MARK: - Properties
    
    private let user: User
    let option: EditProfileOptions
    
    var titleText: String {
        return option.description
    }
    
    var optionValue: String {
        switch option {
        case .fullName:
            return user.fullName
        case .username:
            return user.username
        case .bio:
            return user.bio
        }
    }
    
    var shouldHideTextField: Bool {
        return option == .bio
    }
    
    var shouldHideTextView: Bool {
        return option != .bio
    }
    
    var shouldHidePlaceholderLabel: Bool {
        return !user.bio.isEmpty
    }
    
    // MARK: - Lifecycle
    
    init(user: User, option: EditProfileOptions) {
        self.user = user
        self.option = option
    }
}
