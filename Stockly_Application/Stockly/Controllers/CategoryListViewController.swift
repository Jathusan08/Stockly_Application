//
//  CategoryListViewController.swift
//  Stockly
//
//  Created by Maat on 15/05/19.
//  Copyright © 2019 Maat. All rights reserved.
//

import UIKit
import CoreData

class CategoryListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var items = ["BASOPHIL", "EOSINOPHIL", "LYMPHOCYTE"]
    
    var cat_list = [NSManagedObject]()
    
    var uid = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        uid = nsud.integer(forKey: Attr.UID)

        tableView.delegate = self
        tableView.dataSource = self
        
        // tableView.reloadData()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
                cat_list = [NSManagedObject]()
                fetchCateogries()
        
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    @objc func searchClicked(_ sender: Any)  {
        
    }
    
    @objc func moreClicked(_ sender: UIButton)  {
        
        let myalert = UIAlertController(title: "", message: "Alert", preferredStyle: UIAlertController.Style.actionSheet)
        
        myalert.addAction(UIAlertAction(title: "Edit", style: .default) { (action:UIAlertAction!) in
            print("Selected")
            
            
            
        })
        
        myalert.addAction(UIAlertAction(title: "Delete", style: .default) { (action:UIAlertAction!) in
            print("delete")
            self.deleteItem(sender)
        })
        
        myalert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction!) in
            print("Cancel")
        })
        
        self.present(myalert, animated: true)
        
    }
    
    
    
    func fetchCateogries() {
        
        //print("--> start of read");
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        if #available(iOS 10.0, *) {
            let managedContext = appDelegate.persistentContainer.viewContext
            
            var predicate: NSPredicate = NSPredicate()
            //predicate = NSPredicate(format: "tittle contains[c] '\("")'")
            predicate = NSPredicate(format: "\(Attr.UID) = %@", argumentArray: [uid]) // Specify your condition here
            
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: Entity.CATEGORY)

            fetchRequest.predicate = predicate

            do {
                
                let results = try managedContext.fetch(fetchRequest)
             
                print(results.count)
                if results.count == 0 {
                    self.tableView.isHidden = true
                } else {
                    self.tableView.isHidden = false
                }
                
                
                for result in results {
                    
                    cat_list.append(result)
                    
                }
                
                DispatchQueue.main.async() {
                    
                    self.tableView.reloadData()
                }
                
                
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            
        } else {
            // Fallback on earlier versions
        }
        
        //print("--> end of read");
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
                
            }
        } catch {
            // Do something... fatalerror
        }
        
        fetchCateogries()
        DispatchQueue.main.async() {
            
            // self.tableView.reloadData()
        }
    }
    
}



extension CategoryListViewController: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - UITableViewDataSource
    
    //    func tableView( _ tableView: UITableView, heightForHeaderInSection section: Int ) -> CGFloat
    //    {
    //        return 10.0
    //    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cat_list.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
        
        cell.backgroundColor = UIColor.white
        cell.selectionStyle = .none
        
        let item:NSManagedObject = cat_list[indexPath.row]
       
        cell.categoryNameLabel.text = item.value(forKey: Attr.CATEGORY_NAME) as? String
       
        //        cell.moreClicked.addTarget(self, action: #selector(moreClicked(_:)), for: .touchUpInside)
        //        cell.moreClicked.tag = indexPath.row
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddCategoryViewController") as! AddCategoryViewController
        vc.index = indexPath.row
        vc.cont_list = self.cat_list
        vc.isEdit = true
        
        self.navigationController?.pushViewController(vc, animated: true)
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // retuen height of row
        return 60.0
    }
    
}
