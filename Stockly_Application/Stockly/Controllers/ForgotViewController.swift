//
//  ForgotViewController.swift
//  Stockly
//
//  Created by Maat on 15/05/19.
//  Copyright © 2019 Maat. All rights reserved.
//

import UIKit
import CoreData

class ForgotViewController: UIViewController {

    @IBOutlet weak var btnReset: UIButton!
    @IBOutlet weak var tfForgotdetails: SkyFloatingLabelTextField!
    
    @IBOutlet weak var segment: UISegmentedControl!
    
    @IBOutlet weak var resultsLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func resetClicked(_ sender: UIButton) {
        
        let selectedIndex = sender.tag
        
      print(selectedIndex)
        
        if tfForgotdetails.text == ""
        {
            let alert = UIAlertController(title: "Alert", message: "Please enter username or password", preferredStyle: .alert)
            
            let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
            
            alert.addAction(ok)
            
            self.present(alert, animated: true, completion: nil)
        }
        else
        {
            
            if selectedIndex == 1 {
                fetchUsername()
            } else {
                fetchPassword()
            }
        }
    }
    
    @IBAction func segmentValueChanged(_ sender: UISegmentedControl) {
        
        
        if sender.selectedSegmentIndex == 0 {
           tfForgotdetails.placeholder = "Enter Username"
        } else {
            tfForgotdetails.placeholder = "Enter Password"
        }
        
        btnReset.tag = sender.selectedSegmentIndex
        
        tfForgotdetails.text = ""
    }
    
    
    func fetchPassword()  {
        
        var predicate: NSPredicate = NSPredicate()
        //predicate = NSPredicate(format: "tittle contains[c] '\("")'")
        predicate = NSPredicate(format: "username = %@", argumentArray: [tfForgotdetails.text!]) // Specify your condition here
        // Or for integer value
        // let predicate = NSPredicate(format: "age > %d", argumentArray: [10])
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:Entity.REGISTER)
        fetchRequest.predicate = predicate
        do {
          //  contacts = try managedObjectContext.fetch(fetchRequest) as! [NSManagedObject]
            
            let result = try managedObjectContext.fetch(fetchRequest)
            
            print(result)
            
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
                    
                    let getPwd = data.value(forKey: "password") as? String
                    self.resultsLabel.text = "Your password is : " + getPwd!
                }
            }
                
            }
            
            
            
        } catch let error as NSError {
            print("Could not fetch. \(error)")
        }
    }
    
    func fetchUsername() {
       
        var predicate: NSPredicate = NSPredicate()
        //predicate = NSPredicate(format: "tittle contains[c] '\("")'")
        predicate = NSPredicate(format: "password = %@", argumentArray: [tfForgotdetails.text!]) // Specify your condition here
        // Or for integer value
        // let predicate = NSPredicate(format: "age > %d", argumentArray: [10])
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:Entity.REGISTER)
        fetchRequest.predicate = predicate
        do {
            //  contacts = try managedObjectContext.fetch(fetchRequest) as! [NSManagedObject]
            
            let result = try managedObjectContext.fetch(fetchRequest)
           
            if result.count == 0 {
                print("user not found")
                let alert = UIAlertController(title: "Alert", message: "Please enter correct password. ", preferredStyle: .alert)
                
                let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
                
                alert.addAction(ok)
                
                self.present(alert, animated: true, completion: nil)
                
            } else {
            
            for data in result as! [NSManagedObject] {
                print(data.value(forKey: "username") as! String)
                print(data.value(forKey: "password") as! String)
                print(data.value(forKey: "phone") as! String)
                
                DispatchQueue.main.async() {
                    
                    let getUsername = data.value(forKey: "username") as? String
                    self.resultsLabel.text = "Your username is : " + getUsername!
                }
            }
                
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
