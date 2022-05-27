//
//  LoginViewController.swift
//  Stockly
//
//  Created by Maat on 15/05/19.
//  Copyright © 2019 Maat. All rights reserved.
//

import UIKit
import CoreData
import Foundation

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var space1Constraint: NSLayoutConstraint!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var tfUsername: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    
    var result = NSArray()

    override func viewDidLoad() {
        super.viewDidLoad()

       // scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: 900)
        // Do any additional setup after loading the view.
        self.navigationItem.hidesBackButton = true

        tfUsername.delegate = self
        tfPassword.delegate = self

        tfPassword.isSecureTextEntry = true
//        tfUsername.text = "hargovind"
//        tfPassword.text = "123"
        
        if DeviceType.IS_IPHONE_5 {
            bottomConstraint.constant = 10
            space1Constraint.constant = 10
            imageHeightConstraint.constant = 90
        } else {
            bottomConstraint.constant = 27
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

    @IBAction func loginClicked(_ sender: Any) {
       
        if tfUsername.text == "" && tfPassword.text == ""
        {
            let alert = UIAlertController(title: "Alert", message: "Please enter username or password", preferredStyle: .alert)
            
            let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
            
            alert.addAction(ok)
            
            self.present(alert, animated: true, completion: nil)
        }
        else
        {
            
            self.CheckForUserNameAndPasswordMatch(username : tfUsername.text! as String, password : tfPassword.text! as String)            
        }
    }
    
    func CheckForUserNameAndPasswordMatch( username: String, password : String)
    {
        let app = UIApplication.shared.delegate as! AppDelegate
        
        let context = app.persistentContainer.viewContext
        
        let fetchrequest = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.REGISTER)
        
        let predicate = NSPredicate(format: "username = %@", username)
        
        fetchrequest.predicate = predicate
        do
        {
            result = try context.fetch(fetchrequest) as NSArray
            
            print(result.count)
            if result.count>0
            {
                print("account exist")
                let objectentity = result.firstObject as! NSManagedObject
                
                if objectentity.value(forKey: Attr.USERNAME) as! String == tfUsername.text! && objectentity.value(forKey: Attr.PASSWORD) as! String == tfPassword.text!
                {
                    print("Login Succesfully")
                    
                  let uId = objectentity.value(forKey: Attr.UID) as? Int64
                    
                    print("useId \(String(describing: uId))")
                    
                    fetchUserId()
                    
                  
                }
                else
                {
                    print("Wrong username or password !!!")
                    let alert = UIAlertController(title: "Alert", message: "Wrong username or password !!!", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                }
            } else {
                
                let alert = UIAlertController(title: "Alert", message: "Wrong username or password !!!", preferredStyle: .alert)
                let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
            }
        }
            
        catch
        {
            let fetch_error = error as NSError
            print("error", fetch_error.localizedDescription)
        }
        
    }

    func fetchUserId()  {
        
        var predicate: NSPredicate = NSPredicate()
        //predicate = NSPredicate(format: "tittle contains[c] '\("")'")
        predicate = NSPredicate(format: "username = %@", argumentArray: [tfUsername.text!]) // Specify your condition here
        // Or for integer value
        // let predicate = NSPredicate(format: "age > %d", argumentArray: [10])
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:Entity.REGISTER)
        fetchRequest.predicate = predicate
        do {
            //  contacts = try managedObjectContext.fetch(fetchRequest) as! [NSManagedObject]
            
            let result = try managedObjectContext.fetch(fetchRequest)
            
            print("restl \(result)")
            
            if result.count == 0 {
                print("user not found")
                let alert = UIAlertController(title: "Alert", message: "Please enter correct username. ", preferredStyle: .alert)
                
                let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
                
                alert.addAction(ok)
                
                self.present(alert, animated: true, completion: nil)
                
            } else {
                
                for data in result as! [NSManagedObject] {
                    print(data.value(forKey: "username") as! String)
                    print(data.value(forKey: "password") as! String)
                    print(data.value(forKey: "phone") as! String)
                    
                    DispatchQueue.main.async() {
                        
                        let getuserid = data.value(forKey: Attr.UID) as? NSInteger
                        nsud.set(getuserid, forKey: Attr.UID)
                        nsud.synchronize()
                        
                        print("getuser \(String(describing: getuserid))")

                    }
                }
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "StockListViewController") as! StockListViewController
                self.navigationController?.pushViewController(vc, animated: true)
                
                
            }
            
            
            
        } catch let error as NSError {
            print("Could not fetch. \(error)")
        }
    }
    
   
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
