//
//  RegisterViewController.swift
//  Stockly
//
//  Created by Maat on 15/05/19.
//  Copyright © 2019 Maat. All rights reserved.
//

import UIKit
import CoreData

class RegisterViewController: UIViewController {

    @IBOutlet weak var tfCompanyName: SkyFloatingLabelTextField!
    @IBOutlet weak var tfPhoneNo: SkyFloatingLabelTextField!
    @IBOutlet weak var tfDateOfBirth: SkyFloatingLabelTextField!
    @IBOutlet weak var tfAddress: SkyFloatingLabelTextField!

    var username = ""
    var password = ""
    
    let date = Date()
    let formatter = DateFormatter()

    // core data objects
    var cont_list = [NSManagedObject]()
    var contentList: [NSManagedObject] = []

    let datePicker = UIDatePicker()

    var uid = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        print("user \(username) : pwd \(password)")
        
        showDatePicker()
        
        getTotalRegisteredUsers()
        // Do any additional setup after loading the view.
    }
    
    
    func getTotalRegisteredUsers()
    {
        let app = UIApplication.shared.delegate as! AppDelegate
        
        let context = app.persistentContainer.viewContext
        
        let fetchrequest = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.REGISTER)
        
//        let predicate = NSPredicate(format: "username = %@", username)
//
//        fetchrequest.predicate = predicate
       do
        {
           let result = try context.fetch(fetchrequest) as NSArray
            
            print("total user : \(result)")

            self.uid = result.count

            if result.count > 0 {
            }
            
        }
        catch
        {
            let fetch_error = error as NSError
            print("error", fetch_error.localizedDescription)
        }
        
    }
    
    func registerUser() {
        
        print("--> start of save");
        
        //print("id \(id)")
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        if #available(iOS 10.0, *) {
            let managedContext = appDelegate.persistentContainer.viewContext
            
            let entity = NSEntityDescription.entity(forEntityName: Entity.REGISTER,
                                                    in: managedContext)!
            
            let object = NSManagedObject(entity: entity,
                                         insertInto: managedContext)
            
            formatter.dateFormat = "yyyy-MM-dd HH:mm:a"
            let timestamp = formatter.string(from: date)
            
            
            object.setPrimitiveValue(uid, forKey: Attr.UID)
            object.setValue(username, forKey: Attr.USERNAME)
            object.setValue(password, forKey: Attr.PASSWORD)
            object.setValue(tfCompanyName.text!, forKey: Attr.COMPANY)
            object.setValue(tfPhoneNo.text!, forKey: Attr.PHONE)
            object.setValue(tfDateOfBirth.text!, forKey: Attr.DOB)
            object.setValue(tfAddress.text!, forKey: Attr.ADDRESS)
            object.setValue(timestamp, forKey: Attr.TIMESTAMP)
            object.setValue("", forKey: Attr.EXTRA)
            
            do {
                try managedContext.save()
                contentList.append(object)
                
                print("user registerd")
                
                fetchUserId()
//                let vc = self.storyboard?.instantiateViewController(withIdentifier: "StockListViewController") as! StockListViewController
//                self.navigationController?.pushViewController(vc, animated: true)
                
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
            
        } else {
            // Fallback on earlier versions
        }
        
        //print("--> end of save");
    }
    
    
    func fetchUserId()  {
        
        var predicate: NSPredicate = NSPredicate()
        //predicate = NSPredicate(format: "tittle contains[c] '\("")'")
        predicate = NSPredicate(format: "username = %@", argumentArray: [username]) // Specify your condition here
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
    

    @IBAction func registerClicked(_ sender: Any) {
        
        var errorMessage = ""
        if tfCompanyName.text == ""
        {
            errorMessage = "Please enter company name."
            showAlert(message: errorMessage)
        } else if tfPhoneNo.text == ""
        {
            errorMessage = "Please enter Phone Number."
            showAlert(message: errorMessage)
        }
        else if tfDateOfBirth.text == ""
        {
            errorMessage = "Please enter Date of Birth."
            showAlert(message: errorMessage)
            
        } else {
            
            registerUser()
        }
    }
    
    func showDatePicker(){
        //Formate Date
        datePicker.datePickerMode = .date
        
        //ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donedatePicker));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));
        
        toolbar.setItems([cancelButton,spaceButton,doneButton], animated: false)
        
        tfDateOfBirth.inputAccessoryView = toolbar
        tfDateOfBirth.inputView = datePicker
        
    }
    
    @objc func donedatePicker(){
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        tfDateOfBirth.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    
    @objc func cancelDatePicker() {
        self.view.endEditing(true)
    }
    
    @IBAction func registerAction(_ sender: Any) {
        
    }
    
    func showAlert(message: String)  {
        
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
        
        alert.addAction(ok)
        
        self.present(alert, animated: true, completion: nil)
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
