//
//  LogInViewController.swift
//  ScholarHighPrototype1
//
//  Created by Myleston Law on 2018/11/14.
//  Copyright © 2018 FRESHNESS. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import SVProgressHUD

class LogInViewController: UIViewController {

    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    @IBAction func LogInButtonPressed(_ sender: Any) {
     
            SVProgressHUD.show()
            
            //TODO: Log in the user
            Auth.auth().signIn(withEmail: emailTextfield.text!, password: passwordTextfield.text!) {
                (user, error) in
                if error != nil{
                    print(error!)
                    
                }else{
                    print("log in successful!")
                    
                    SVProgressHUD.dismiss()
                    
                    self.performSegue(withIdentifier: "goToRoom", sender: self)
                }
                
            }
        
    }
    
}
