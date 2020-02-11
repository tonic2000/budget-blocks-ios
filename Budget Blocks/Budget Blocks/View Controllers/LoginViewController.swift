//
//  LoginViewController.swift
//  Budget Blocks
//
//  Created by Isaac Lyons on 1/27/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit

protocol LoginViewControllerDelegate {
    func loginSuccessful()
}

class LoginViewController: UIViewController {
    
    // MARK: Outlets

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var confirmPasswordLabel: UILabel!
    
    // MARK: Properties
    
    var networkingController: NetworkingController!
    var signIn: Bool = true
    var delegate: LoginViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpViews()
        updateViews()
    }
    
    private func setUpViews() {
        let title = "Sign \(signIn ? "In" : "Up")"
        loginButton.setTitle(title, for: .normal)
        loginLabel.text = title
        
        confirmPasswordTextField.isHidden = signIn
        confirmPasswordLabel.isHidden = signIn
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        
        let loginLabelFontSize = loginLabel.font.pointSize
        loginLabel.font = UIFont(name: "Exo-Regular", size: loginLabelFontSize)
        
        if let textFieldFontSize = emailTextField.font?.pointSize {
            let exo = UIFont(name: "Exo-Regular", size: textFieldFontSize)
            emailTextField.font = exo
            passwordTextField.font = exo
            confirmPasswordTextField.font = exo
        }
        
        if let buttonFontSize = loginButton.titleLabel?.font.pointSize {
            loginButton.titleLabel?.font = UIFont(name: "Exo-Regular", size: buttonFontSize)
        }
    }
    
    private func updateViews() {
        let daybreakBlue = UIColor(red: 0.094, green: 0.565, blue: 1, alpha: 1)
        
        //TODO: check the status of the form
        loginButton.layer.cornerRadius = 4
        loginButton.layer.borderWidth = 1
        loginButton.layer.borderColor = daybreakBlue.cgColor
        loginButton.setTitleColor(daybreakBlue, for: .normal)
    }
    
    // MARK: Actions
    
    @IBAction func login(_ sender: Any) {
        guard let email = emailTextField.text,
            let password = passwordTextField.text,
            !email.isEmpty,
            !password.isEmpty else { return }
        
        if signIn {
            signIn(email: email, password: password)
        } else {
            guard let confirmPassword = confirmPasswordTextField.text,
                confirmPassword == password else {
                    //TODO: indicate this to the user
                    print("Passwords don't match!")
                    return
            }
            
            networkingController.register(email: email, password: password) { message, error in
                if let error = error {
                    return NSLog("Error signing up: \(error)")
                }
                
                guard let message = message else {
                    return NSLog("No message back from register.")
                }
                
                if message == "success" {
                    NSLog("Sign up successful!")
                    self.signIn(email: email, password: password)
                } else {
                    //TODO: alert the user
                    print(message)
                }
            }
        }
    }
    
    private func signIn(email: String, password: String) {
        networkingController.login(email: email, password: password) { token, error in
            if let error = error {
                return NSLog("Error signing in: \(error)")
            }
            
            guard let token = token else {
                return NSLog("No token returned from login.")
            }
            
            print(token)
            DispatchQueue.main.async {
                self.delegate?.loginSuccessful()
            }
        }
    }

}

// MARK: Text field delegate

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailTextField:
            passwordTextField.becomeFirstResponder()
        case passwordTextField where !signIn:
            confirmPasswordTextField.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        
        return true
    }
}
