//
//  Constants.swift
//  TwitterTutorial
//
//  Created by Daehoon Lee on 7/2/24.
//

import Firebase
import FirebaseStorage

// MARK: - Firebase Storage

let STORAGE_REF = Storage.storage().reference()
let STORAGE_PROFILE_IMAGES = STORAGE_REF.child("profile_images")

// MARK: - Firebase Database

let DB_REF = Database.database().reference()
let REF_USERS = DB_REF.child("users")
let REF_TWEETS = DB_REF.child("tweets")
let REF_USER_TWEETS = DB_REF.child("user-tweets")
