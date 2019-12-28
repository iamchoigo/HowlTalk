//
//  SigninViewController.swift
//  HowlTalk
//
//  Created by 최고은 on 2019/11/17.
//  Copyright © 2019 goeun choi. All rights reserved.
//

import UIKit
import Firebase

class SigninViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    
    override func viewDidLoad() {
        emailTextField.text = "hoohoo@gmail.com"
        passwordTextField.text = "1234567"
        super.viewDidLoad()
        loginButton.addTarget(self, action: #selector(actionSignin), for: UIControl.Event.touchUpInside)
        signupButton.addTarget(self, action: #selector(moveSignupPage), for: UIControl.Event.touchUpInside)
    }
    
    @objc func actionSignin() {
        //var email = emailTextField.text
        //var pw = passwordTextField.text
        
        //createUser(withEmail: email, password: pw)
        Auth.auth().signIn(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!) { (user, err) in
            if(err != nil){
                //에러가 발생하면 에러를 출력
                //print("login err : \(err)")
            }else{
                //메인페이지로 이동하는 Seuge Identifier 호출
                self.performSegue(withIdentifier: "MainSeuge", sender: nil)
            }
        }
    }
    
    @objc func moveSignupPage() {
        performSegue(withIdentifier: "SignupSeuge", sender: nil)
    }
}
