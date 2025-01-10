//
//  StringConstants.swift
//  Crypto Analyser
//
//  Created by IE15 on 20/12/24.
//

import Foundation

struct StringConstants {
    static let cryptoAnalyser = "CryptoAnalyser"
    static let chatGPTApiUrl = "https://api.openai.com/v1/chat/completions"
    static let newsApiUrl = "https://cryptonews-api.com/api/v1/category"
    static let newsApiToken = "yhck3vg1nq37g8djvm0qfhp7xlmwdztqd6i9qgzu"
    
    // Sign Up
    static let signUpTitle = "Sign Up"
    static let nameTitle = "Name"
    static let emailTitle = "Email"
    static let passwordTitle = "Password"
    static let confirmPasswordTitle = "Confirm Password"
    static let typeHerePlaceholder = "Type here"
    static let validationErrorTitle = "Error"
    static let validationNameEmpty = "Name cannot be empty."
    static let validationEmailEmpty = "Email cannot be empty."
    static let validationEmailInvalid = "Invalid email address"
    static let validationPasswordEmpty = "Password cannot be empty."
    static let validationConfirmPasswordEmpty = "Confirm Password cannot be empty."
    static let validationPasswordsMismatch = "Passwords do not match."
    static let signUpButton = "Sign Up"
    static let alreadyHaveAnAccount = "Already have an account?"
    static let orText = "Or"
    static let oKText = "OK"
    
    // Login
    static let loginTitle = "Login"
    static let forgotPassword = "Forgot Password?"
    static let loginButton = "Login"
    static let doNotHaveAccount = "Don't have an account?"
    static let invalidEmailError = "Invalid email address"
    static let passwordEmptyError = "Password cannot be empty."
    
    // Forgot Password
    static let forgotPasswordTitle = "Forgot Password"
    static let passwordResetDes = "Please Enter Your Email Address to Reset Password"
    static let resetPassword = "Reset Password"
    static let send = "Send"
    static let checkYourEmail = "Check Your Email"
    
    
    // Home
    static let search = "search"
    static let analyseCrypto = "Analyse Crypto"
    static let takeAPic = "Take a \n picture"
    static let or = "or"
    static let uploadFromGallery = "Upload from gallery"
    static let searchForCoin = "Search for a coin"
    static let recentSearches = "Recent Searches"
    
    // ImageAnalyse
    static let invalid = "Invalid"
    static let invalidImageAlertMessage = "The provided image is not a crypto chart. Please upload a valid crypto chart for analysis."
    static let error = "Error"
    
    // Setting
    static let deleteAccount = "Delete Account"
    static let deleteAccountDes = "Are you sure you want to delete your account? This action cannot be undone."
    static let cancel = "Cancel"
    static let delete = "Delete"
    static let confirmLogout = "Confirm Logout"
    static let logout = "Logout"
    static let logoutDes = "Are you sure you want to log out?"
    
    static let setting = "Setting"
    static let account = "Account"
    static let accountInformation = "Account information"
    static let resetPasswordDes = "Are you sure you want to reset your password? A reset link will be sent to"
    static let sendEmail = "Send Email"
    static let privacy = "Privacy"
    static let privacyPolicy = "Privacy Policy"
    static let termsAndConditions = "Terms & Conditions"
    static let helpAndSupport = "Help & support"
    static let securityOptions = "Security Options"

}
