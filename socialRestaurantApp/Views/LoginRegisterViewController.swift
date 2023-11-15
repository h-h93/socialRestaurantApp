//
//  LoginViewController.swift
//  socialRestaurantApp
//
//  Created by hanif hussain on 04/11/2023.
//

import UIKit
import FirebaseAuth
import Firebase

// make this a popup view

class LoginViewController: UIViewController {
    
    let firebaseDB = FirebaseDB()
    
    var emailText: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = .roundedRect
        textField.layer.cornerRadius = 4
        textField.backgroundColor = .white
        textField.textColor = .black
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.borderWidth = 2
        textField.autocorrectionType = .no
        textField.keyboardType = .emailAddress
        textField.returnKeyType = .done
        textField.autocapitalizationType = .none
        textField.attributedPlaceholder = NSAttributedString(string: "Enter Email address", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        return textField
    }()
    
    var passwordText: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = .roundedRect
        textField.layer.cornerRadius = 4
        textField.backgroundColor = .white
        textField.textColor = .black
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.borderWidth = 2
        textField.autocorrectionType = .no
        textField.isSecureTextEntry = true
        textField.returnKeyType = .done
        textField.autocapitalizationType = .none
        textField.attributedPlaceholder = NSAttributedString(string: "Enter Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        return textField
    }()
    
    let emailLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Email: "
        label.textAlignment = .left
        label.textColor = .black
        return label
    }()
    
    let passwordLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.text = "Password: "
        label.textColor = .black
        return label
    }()
    
    var loginButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Login", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 20
        button.backgroundColor = .white
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.shadowColor = UIColor.lightGray.cgColor
        button.layer.shadowOffset = CGSize(width: 0.0, height: 4.0)
        button.layer.shadowRadius = 6
        button.layer.shadowOpacity = 1
        return button
    }()
    
    var registerButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Register", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 20
        button.backgroundColor = .white
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.shadowColor = UIColor.lightGray.cgColor
        button.layer.shadowOffset = CGSize(width: 0.0, height: 4.0)
        button.layer.shadowRadius = 6
        button.layer.shadowOpacity = 1
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubview(emailLabel)
        view.addSubview(emailText)
        view.addSubview(passwordLabel)
        view.addSubview(passwordText)
        view.addSubview(loginButton)
        view.addSubview(registerButton)
        
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(registerTapped), for: .touchUpInside)
        
        setupViewConstraints()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    
    func setupViewConstraints() {
        NSLayoutConstraint.activate([
            emailLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            emailLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emailLabel.heightAnchor.constraint(equalToConstant: 50),
            emailLabel.widthAnchor.constraint(equalToConstant: 100),
            
            emailText.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            emailText.leadingAnchor.constraint(equalTo: emailLabel.trailingAnchor, constant: 10),
            emailText.heightAnchor.constraint(equalToConstant: 50),
            emailText.widthAnchor.constraint(equalToConstant: 250),
            
            passwordLabel.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 50),
            passwordLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            passwordLabel.heightAnchor.constraint(equalToConstant: 50),
            passwordLabel.widthAnchor.constraint(equalToConstant: 100),
            
            passwordText.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 50),
            passwordText.leadingAnchor.constraint(equalTo: passwordLabel.trailingAnchor, constant: 10),
            passwordText.heightAnchor.constraint(equalToConstant: 50),
            passwordText.widthAnchor.constraint(equalToConstant: 250),
            
            loginButton.topAnchor.constraint(equalTo: passwordLabel.bottomAnchor, constant: 70),
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 145),
            loginButton.widthAnchor.constraint(equalToConstant: 100),
            loginButton.heightAnchor.constraint(equalToConstant: 40),
            
            registerButton.topAnchor.constraint(equalTo: passwordLabel.bottomAnchor, constant: 70),
            registerButton.leadingAnchor.constraint(equalTo: loginButton.trailingAnchor, constant: 20),
            registerButton.widthAnchor.constraint(equalToConstant: 100),
            registerButton.heightAnchor.constraint(equalToConstant: 40),
        ])
    }
    
    @objc func loginTapped(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveLinear) { [weak self] in
            sender.backgroundColor = .lightGray
            sender.transform = CGAffineTransform.init(scaleX: 0.95, y: 0.95)
        } completion: { complete in
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveLinear) { [weak self] in
                sender.transform = CGAffineTransform.init(scaleX: 1, y: 1)
                sender.backgroundColor = .white
            }
        }
        
        guard let email = emailText.text else { return }
        guard let password = passwordText.text else { return }
        if isValidEmail(email) && isValidPassword(password) {
            firebaseDB.login(email: email, password: password)
        }
    }
    
    @objc func registerTapped(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveLinear) { [weak self] in
            sender.backgroundColor = .lightGray
            sender.transform = CGAffineTransform.init(scaleX: 0.95, y: 0.95)
        } completion: { complete in
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveLinear) { [weak self] in
                sender.backgroundColor = .white
                sender.transform = CGAffineTransform(scaleX: 1, y: 1)
            }
        }
        
        guard let email = emailText.text else { return }
        guard let password = passwordText.text else { return }
        if isValidEmail(email) && isValidPassword(password) {
            firebaseDB.createNewUser(email: email, password: password)
        }
    }
    
    
    
    // check if email is valid
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    // basic check to see if password is valid
    func isValidPassword(_ password: String) -> Bool {
        let minPasswordLength = 6
        return password.count >= minPasswordLength
    }
    
}
