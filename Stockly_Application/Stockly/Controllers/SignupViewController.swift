//
//  SignupViewController.swift
//  Stockly
//
//  Created by Maat on 15/05/19.
//  Copyright © 2019 Maat. All rights reserved.
//

import UIKit

class SignupViewController: UIViewController {

    @IBOutlet weak var space1Constraint: NSLayoutConstraint!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var tfUsername: SkyFloatingLabelTextField!
    @IBOutlet weak var tfPassword: SkyFloatingLabelTextField!
    @IBOutlet weak var tfConfirmPassword: SkyFloatingLabelTextField!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        if DeviceType.IS_IPHONE_5 {
            space1Constraint.constant = 10
            imageHeightConstraint.constant = 90
            
        } else {
            
        }
        // Do any additional setup after loading the view.
    }
    
  
    
    func showAlert(message: String)  {
        
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
        
        alert.addAction(ok)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "register" {
            var errorMessage = ""
            if tfUsername.text == ""
            {
                errorMessage = "Please enter Username."
                showAlert(message: errorMessage)
            } else if tfPassword.text == ""
            {
                errorMessage = "Please enter Password."
                showAlert(message: errorMessage)
            }
            else if tfConfirmPassword.text == ""
            {
                errorMessage = "Please enter confirm password."
                showAlert(message: errorMessage)
                
            } else if tfConfirmPassword.text != tfPassword.text
            {
                errorMessage = "Password doesn't match."
                showAlert(message: errorMessage)
                
            } else {
                return true
            }
            
        }
        return true
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "register") {
            // pass data to next view
            let viewController:RegisterViewController = segue.destination as! RegisterViewController
           // let indexPath = self.tableView.indexPathForSelectedRow()
            viewController.username = tfUsername.text!
            viewController.password = tfPassword.text!

        }
        
        
        

        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    

}
