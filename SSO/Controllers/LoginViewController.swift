//
//  ViewController.swift
//  SSO
//
//  Created by Ritam Sarmah on 8/27/18.
//  Copyright © 2018 Ritam Sarmah. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import Material

class LoginViewController: UIViewController, AuthenticatorDelegate, UITextFieldDelegate {
    
    // MARK: - Properties
    
    // MARK: Views
    private var logoImageView: UIImageView!
    private var activityIndicator: NVActivityIndicatorView!
    private var usernameTextField: TextField!
    private var passwordTextField: TextField!
    private var manualLoginButton: UIButton!
    private var socialLogin: LoginButtonGroup!
    
    private var logoBottomConstraint: NSLayoutConstraint!
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        hideLogin()
        
        Authenticator.shared.delegate = self
        Authenticator.shared.logInSilently()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
    func updateUI() {
        view.backgroundColor = Color.Theme.Background
        
        // Activity Indicator
        activityIndicator = NVActivityIndicatorView(frame: CGRect.zero,
                                                    type: NVActivityIndicatorType.circleStrokeSpin,
                                                    color: Color.Theme.Main,
                                                    padding: 0)
        
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.widthAnchor.constraint(equalToConstant: Constraint.Indicator.width).isActive = true
        activityIndicator.heightAnchor.constraint(equalToConstant: Constraint.Indicator.height).isActive = true
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        activityIndicator.startAnimating()
        
        // Logo Image View
        logoImageView = UIImageView(image: UIImage(named: "sso_icon"))
        logoImageView.tintColor = Color.Theme.Main
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.alpha = 0
        
        view.addSubview(logoImageView)
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.widthAnchor.constraint(equalToConstant: Constraint.Logo.width).isActive = true
        logoImageView.heightAnchor.constraint(equalToConstant: Constraint.Logo.height).isActive = true
        logoImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constraint.Logo.topConstant).isActive = true
      
        // Username Text Field
        usernameTextField = createTextField(withPlaceholder: "Username")
        usernameTextField.tag = 0

        view.addSubview(usernameTextField)
        usernameTextField.translatesAutoresizingMaskIntoConstraints = false
        usernameTextField.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: Constraint.UsernameTextField.leftConstant).isActive = true
        usernameTextField.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: Constraint.UsernameTextField.rightConstant).isActive = true
        usernameTextField.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: Constraint.UsernameTextField.topConstant).isActive = true
        usernameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        // Password Text Field
        passwordTextField = createTextField(withPlaceholder: "Password")
        passwordTextField.isSecureTextEntry = true
        passwordTextField.tag = 1
        
        view.addSubview(passwordTextField)
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: Constraint.PasswordTextField.leftConstant).isActive = true
        passwordTextField.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: Constraint.PasswordTextField.rightConstant).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: Constraint.PasswordTextField.topConstant).isActive = true
        passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        // Manual Login Button
        manualLoginButton = UIButton(type: .system)
        manualLoginButton.setTitle("Login", for: .normal)
        manualLoginButton.titleLabel?.font = Font.Default
        manualLoginButton.setTitleColor(.white, for: .normal)
        manualLoginButton.backgroundColor = Color.Theme.Main
        manualLoginButton.setBackgroundColor(color: view.tintColor.darker(), forState: .highlighted)
        manualLoginButton.layer.masksToBounds = true
        manualLoginButton.layer.cornerRadius = 4
        manualLoginButton.alpha = 0
        manualLoginButton.addTarget(self, action: #selector(loginManually), for: .touchUpInside)
        
        view.addSubview(manualLoginButton)
        manualLoginButton.translatesAutoresizingMaskIntoConstraints = false
        manualLoginButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: Constraint.ManualLoginButton.leftConstant).isActive = true
        manualLoginButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: Constraint.ManualLoginButton.rightConstant).isActive = true
        manualLoginButton.heightAnchor.constraint(equalToConstant: Constraint.ManualLoginButton.height).isActive = true
        manualLoginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        manualLoginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: Constraint.ManualLoginButton.topConstant).isActive = true
        
        // Login Button Group
        socialLogin = LoginButtonGroup(types: [.google, .facebook, .twitter])
        socialLogin.buttons.forEach { $0.alpha = 0 }

        view.addSubview(socialLogin)
        socialLogin.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        socialLogin.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: Constraint.LoginButtonGroup.bottomConstant).isActive = true
        
        // Dismiss keyboard on tap
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func showLogin() {
        if socialLogin.buttons[0].alpha != 0 {
            return
        }
        
        activityIndicator.stopAnimating()
        
        socialLogin.buttons.forEach { $0.alpha = 0 }
        logoImageView.alpha = 0
        usernameTextField.alpha = 0
        passwordTextField.alpha = 0
        manualLoginButton.alpha = 0
        
        UIView.animate(withDuration: 0.6, delay: 0, options: [], animations: {
            self.logoImageView.alpha = 1
        }, completion: nil)
        UIView.animate(withDuration: 0.6, delay: 0.3, options: [], animations: {
            self.usernameTextField.alpha = 1
            self.passwordTextField.alpha = 1
            self.manualLoginButton.alpha = 1
        }, completion: nil)
        UIView.animate(withDuration: 0.6, delay: 0.5, options: [], animations: {
            self.socialLogin.buttons.forEach { $0.alpha = 1 }
        }, completion: nil)
    }
    
    func hideLogin() {
        socialLogin.buttons.forEach { $0.alpha = 0 }
        logoImageView.alpha = 0
        usernameTextField.alpha = 0
        passwordTextField.alpha = 0
        manualLoginButton.alpha = 0
        if !activityIndicator.isAnimating {
            activityIndicator.startAnimating()
        }
    }
    
    func createTextField(withPlaceholder placeholder: String) -> TextField {
        let textField = TextField()
        textField.font = Font.Default
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.textColor = Color.Theme.Text
        textField.placeholder = placeholder
        textField.placeholderActiveColor = Color.Theme.Main
        textField.placeholderNormalColor = Color.Theme.PlaceholderText
        textField.placeholderVerticalOffset = 5
        textField.dividerActiveColor = Color.Theme.Main
        textField.dividerNormalColor = Color.Theme.PlaceholderText
        textField.delegate = self
        textField.backgroundColor = UIColor.clear
        textField.alpha = 0
        return textField
    }
    
    @objc func loginManually() {
    }
    
    // MARK: - AuthenticatorDelegate
    func authenticator(_ authenticator: Authenticator, didLogInFor user: User?, withError error: Error?) {
        guard let user = user else {
            if let error = error {
                Alert.presentLoginError(on: self, message: error.localizedDescription)
            }
            showLogin()
            return
        }
        hideLogin()
        Presenter.toHome(from: self, user: user, transition: .flipHorizontal)
    }
    
    func authenticator(_ authenticator: Authenticator, didLogOutFor user: User?, withError error: Error?) {
        showLogin()
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag = textField.tag + 1
        let nextResponder = textField.superview?.viewWithTag(nextTag) as UIResponder?
        
        if nextResponder != nil {
            // Found next responder, so set it
            nextResponder?.becomeFirstResponder()
        } else {
            // Not found, so remove keyboard and login
            textField.resignFirstResponder()
            loginManually()
        }
        return false
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
        
    func showLoginFailure() {
        let alert = UIAlertController(title: "Login fields empty", message: "Either the username or password fields are empty", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alert.addAction(action)
        present(alert, animated: true)
    }
}

fileprivate enum Constraint {
    enum Logo {
        static let topConstant: CGFloat = 80
        static let width: CGFloat = 80
        static let height: CGFloat = 80
    }
    enum Indicator {
        static let width: CGFloat = 40
        static let height: CGFloat = 40
    }
    
    enum UsernameTextField {
        static let leftConstant: CGFloat = 40
        static let rightConstant: CGFloat = -leftConstant
        static let topConstant: CGFloat = 50
    }
    
    enum PasswordTextField {
        static let leftConstant: CGFloat = UsernameTextField.leftConstant
        static let rightConstant: CGFloat = UsernameTextField.rightConstant
        static let topConstant: CGFloat = 30
    }
    
    enum ManualLoginButton {
        static let leftConstant: CGFloat = UsernameTextField.leftConstant
        static let rightConstant: CGFloat = UsernameTextField.rightConstant
        static let height: CGFloat = 44
        static let topConstant: CGFloat = 40
    }
    
    enum LoginButtonGroup {
        static let bottomConstant: CGFloat = -50
    }
}

