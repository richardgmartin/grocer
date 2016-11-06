//
//  LoginViewController.swift
//  Grocer
//
//  Created by Richard Martin on 2016-11-05.
//  Copyright © 2016 richard martin. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    
    @IBOutlet weak var emailTextField: EmailPasswordTextFieldStyle!
    @IBOutlet weak var passwordTextField: EmailPasswordTextFieldStyle!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let attributes = [NSForegroundColorAttributeName: UIColor.darkGray]
        emailTextField.attributedPlaceholder = NSAttributedString(string: "Email", attributes: attributes)
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: attributes)
        
        
    }

    
    @IBAction func loginButtonTapped(_ sender: LoginButton) {
        FIRAuth.auth()?.signIn(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!, completion: nil)
        performSegue(withIdentifier: loginToList, sender: nil)
    }
    

    @IBAction func createAccountButtonTapped(_ sender: LoginButton) {
        
        // alert controller requesting email address and password for new account creation
        let alert = UIAlertController(title: "Create Account", message: "Create Grocer Account", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { action in
            let emailField = alert.textFields![0]
            let passwordField = alert.textFields![1]
            
            FIRAuth.auth()?.createUser(withEmail: emailField.text!, password: passwordField.text!, completion: { (user, error) in
                if error == nil {
                    FIRAuth.auth()?.signIn(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!, completion: nil)
                }
            })
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        
        alert.addTextField { (textEmail) in
            textEmail.placeholder = "Enter your email"
        }
        
        alert.addTextField { (textPassword) in
            textPassword.isSecureTextEntry = true
            textPassword.placeholder = "Enter your password"
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
        
        
    }


}
