//
//  LoginViewController.swift
//  Grocer
//
//  Created by Richard Martin on 2016-11-05.
//  Copyright © 2016 richard martin. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    
    @IBOutlet weak var emailTextField: EmailPasswordTextFieldStyle!
    @IBOutlet weak var passwordTextField: EmailPasswordTextFieldStyle!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let attributes = [NSForegroundColorAttributeName: UIColor.black]
        emailTextField.attributedPlaceholder = NSAttributedString(string: "Email", attributes: attributes)
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: attributes)
        
        
    }

    
    @IBAction func loginButtonTapped(_ sender: LoginButton) {
        
        
    }
    



}
