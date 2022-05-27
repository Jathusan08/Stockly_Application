//
//  AddCategoryViewController.swift
//  Stockly
//
//  Created by Maat on 15/05/19.
//  Copyright © 2019 Maat. All rights reserved.
//

import UIKit
import CoreData

class AddCategoryViewController: UIViewController {

    @IBOutlet weak var btnAddCategory: UIButton!
    @IBOutlet weak var btnDeleteCategory: UIButton!
    @IBOutlet weak var tfCategoryName: UITextField!
    
    var isEdit = false
    var index = 0
    
    // core data objects
    var cont_list = [NSManagedObject]()
    var contentList: [NSManagedObject] = []
    
    //date vars
    let date = Date()
    let formatter = DateFormatter()
    
    var uid = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        uid = nsud.integer(forKey: Attr.UID)

        if isEdit {
           
            self.navigationItem.title = "Update Category"
            btnAddCategory.addTarget(self, action: #selector(updateCategoryClicked(_:)), for: .touchUpInside)
            
            btnAddCategory.setTitle("Update Category", for: .normal)
            
            tfCategoryName.text = cont_list[index].value(forKey: Attr.CATEGORY_NAME) as? String
            
            self.btnDeleteCategory.isHidden = false
            
            btnDeleteCategory.tag = index
            btnDeleteCategory.addTarget(self, action: #selector(deleteCategoryClicked(_:)), for: .touchUpInside)

        } else {
            btnAddCategory.addTarget(self, action: #selector(addCategoryClicked(_:)), for: .touchUpInside)
            self.btnDeleteCategory.isHidden = true

        }
        // Do any additional setup after loading the view.
    }
    

    @objc func addCategoryClicked(_ sender: Any)  {
        addCategory()
    }
    
    @objc func updateCategoryClicked(_ sender: Any)  {
        update(indexRow: index)
    }
   
    @objc func deleteCategoryClicked(_ sender: UIButton)  {
        deleteItem(sender)
    }
    
    func addCategory() {
        
        print("--> start of save");
        
        //print("id \(id)")
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        if #available(iOS 10.0, *) {
            let managedContext = appDelegate.persistentContainer.viewContext
            
            let entity = NSEntityDescription.entity(forEntityName: Entity.CATEGORY,
                                                    in: managedContext)!
            
            let object = NSManagedObject(entity: entity,
                                         insertInto: managedContext)
            
            formatter.dateFormat = "yyyy-MM-dd HH:mm:a"
            let timestamp = formatter.string(from: date)
            
            let cid = 0
            
            object.setPrimitiveValue(uid, forKey: Attr.UID)
            object.setPrimitiveValue(cid, forKey: Attr.CID)
            object.setValue(tfCategoryName.text!, forKey: Attr.CATEGORY_NAME)
            object.setValue(timestamp, forKey: Attr.TIMESTAMP)
            object.setValue("", forKey: Attr.EXTRA)
            
            do {
                try managedContext.save()
                contentList.append(object)
                
                print("saved")
                
                tfCategoryName.text = ""
                showAlert(message: "New Category added.")
        //
        //                let vc = self.storyboard?.instantiateViewController(withIdentifier: "CategoryListViewController") as! CategoryListViewController
        //                self.navigationController?.pushViewController(vc, animated: true)
                
                
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
            
        } else {
            // Fallback on earlier versions
        }
        
        //print("--> end of save");
    }
    
    func showAlert(message: String)  {
        
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
        
        alert.addAction(ok)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func update(indexRow: NSInteger) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        let object = cont_list[indexRow]
        
        formatter.dateFormat = "yyyy-MM-dd HH:mm:a"
        let timestamp = formatter.string(from: date)
        
        let cid = 0
//        let uid = nsud.integer(forKey: Attr.UID)

        object.setPrimitiveValue(uid, forKey: Attr.UID)
        object.setPrimitiveValue(cid, forKey: Attr.CID)
        object.setValue(tfCategoryName.text!, forKey: Attr.CATEGORY_NAME)
        object.setValue(timestamp, forKey: Attr.TIMESTAMP)
        object.setValue("", forKey: Attr.EXTRA)
     
        do {
            try managedObjectContext.save()
            // contentList[0] = contact
            contentList.append(object)
            print("updated")
            self.navigationController?.popViewController(animated: true)
       
        } catch let error as NSError {
            print("Couldn't update. \(error)")
        }
    }

    
    @objc func deleteItem(_ sender: UIButton) {
        
        //print("delete itm \(sender.tag)")
        let stag = sender.tag
        
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.CATEGORY)
        do {
            
            let fetchedResults = try managedContext.fetch(fetchRequest)
                as [Any]?
            if let results = fetchedResults
            {
                let value = results[stag]
                managedContext.delete(value as! NSManagedObject)
                
                try managedContext.save()
               
                self.navigationController?.popViewController(animated: true)

            }
        } catch {
            // Do something... fatalerror
        }
        
        DispatchQueue.main.async() {
            
            // self.tableView.reloadData()
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
