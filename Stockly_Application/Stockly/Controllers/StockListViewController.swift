//
//  StockListViewController.swift
//  Stockly
//
//  Created by Maat on 15/05/19.
//  Copyright © 2019 Maat. All rights reserved.
//

import UIKit
import CoreData

class StockListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var menuBarBtn: UIBarButtonItem!

    var stock_list = [NSManagedObject]()
    var deleted = 0
    var predict_list = [NSManagedObject]()

    var appDelegate = UIApplication.shared.delegate as? AppDelegate
    //date vars
    let date = Date()
    let formatter = DateFormatter()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        self.navigationItem.hidesBackButton = true
        
        nsud.set(deleted, forKey: UD.STOCK_DELETED)
      
         menuBarBtn = UIBarButtonItem(image: UIImage(named: "Menu"),
                                            style: .plain,
                                            target: self,
                                            action: #selector(menuClicked(_:)))
        
        // Adding button to navigation bar (rightBarButtonItem or leftBarButtonItem)
        self.navigationItem.leftBarButtonItem = menuBarBtn
        
        // Private action

            
            // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        stock_list = [NSManagedObject]()
        fetchStocks()
        
        let uid = nsud.integer(forKey: Attr.UID)
        print("uid \(uid)")
        
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
    

    
    @objc func menuClicked(_ sender: UIBarButtonItem)  {
        
        let myalert = UIAlertController(title: "", message: "Settings", preferredStyle: UIAlertController.Style.actionSheet)
        
        myalert.addAction(UIAlertAction(title: "Settings", style: .default) { (action:UIAlertAction!) in
            print("Selected")
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "SettingViewController") as! SettingViewController
            
            self.navigationController?.pushViewController(vc, animated: true)
        })
        
        myalert.addAction(UIAlertAction(title: "Logout", style: .destructive) { (action:UIAlertAction!) in
            print("delete")
            self.navigationController?.popToRootViewController(animated: true)
        })
        
        myalert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction!) in
            print("Cancel")
        })
        
        self.present(myalert, animated: true)
        
    }
    
    @objc func moreClicked(_ sender: UIButton)  {
        
        let myalert = UIAlertController(title: "", message: "Update Stock", preferredStyle: UIAlertController.Style.actionSheet)
        
        myalert.addAction(UIAlertAction(title: "Edit", style: .default) { (action:UIAlertAction!) in
            print("Selected")
         
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddStockViewController") as! AddStockViewController
            //        vc.index = indexPath.row
            
            vc.isEdit = true
            vc.cont_list = self.stock_list
            vc.index = sender.tag
            
            self.navigationController?.pushViewController(vc, animated: true)
        })
        
        myalert.addAction(UIAlertAction(title: "Delete", style: .destructive) { (action:UIAlertAction!) in
            print("delete")
            self.deleteItem(sender)
        })
        
        myalert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction!) in
            print("Cancel")
        })
        
        self.present(myalert, animated: true)
        
    }
    
    func fetchStocks() {
        
        //print("--> start of read");
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        if #available(iOS 10.0, *) {
            let managedContext = appDelegate.persistentContainer.viewContext
           
            let uid = nsud.integer(forKey: Attr.UID)
            
            var predicate: NSPredicate = NSPredicate()
            //predicate = NSPredicate(format: "tittle contains[c] '\("")'")
            predicate = NSPredicate(format: "\(Attr.UID) = %@", argumentArray: [uid]) // Specify your condition here

            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: Entity.STOCK)
            
            fetchRequest.predicate = predicate
           
            do {
                
                let results = try managedContext.fetch(fetchRequest)
                
                print(results.count)

                for result in results {
                    
                    stock_list.append(result)
                    
                }
                
                notificationFire(index: results.count - 1)

                
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
   
    func notificationFire(index: NSInteger) {
        
        print("fire")
        
        if stock_list.count > 0 && stock_list.count < index{
            
            let item: NSManagedObject = stock_list[index]
            
            let quantity = item.value(forKey: Attr.QUANTITY) as? String
            let stockname = item.value(forKey: Attr.STOCK_NAME) as? String
            
            
            var setLimit = nsud.integer(forKey: UD.SET_STOCK_LIMIT)
            
            if setLimit == 0 {
                setLimit = 5
            }
            
            if Int(quantity!)! < setLimit {
                let notificationType = stockname!
                self.appDelegate?.scheduleNotification(notificationType: notificationType)
            }
        }
    }
    
    
    @objc func deleteItem(_ sender: UIButton) {
        
        //print("delete itm \(sender.tag)")
        let stag = sender.tag
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.STOCK)
        do {
            
            self.addPrediction(index: stag)
            
            let fetchedResults = try managedContext.fetch(fetchRequest)
                as [Any]?
            if let results = fetchedResults
            {
                let value = results[stag]
                managedContext.delete(value as! NSManagedObject)
                
                try managedContext.save()
                
                
                var total_deleted = nsud.object(forKey: UD.STOCK_DELETED) as? String
                
                if total_deleted == nil {
                    total_deleted = String(0)
                }
                deleted = Int(total_deleted!)!
                
                nsud.set(Int(deleted) + 1, forKey: UD.STOCK_DELETED)
                nsud.synchronize()
             
                stock_list = [NSManagedObject]()

                fetchStocks()

            }
            
        } catch {
            // Do something... fatalerror
        }
        
        
        DispatchQueue.main.async() {
            
             self.tableView.reloadData()
        }
    }
    
    
    func addPrediction(index: NSInteger) {
        
        print("--> start of save");
        
        //print("id \(id)")
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        if #available(iOS 10.0, *) {
            let managedContext = appDelegate.persistentContainer.viewContext
            
            let entity = NSEntityDescription.entity(forEntityName: Entity.PREDICTION,
                                                    in: managedContext)!
            
            let object = NSManagedObject(entity: entity,
                                         insertInto: managedContext)
            
            formatter.dateFormat = "yyyy-MM-dd HH:mm:a"
            let timestamp = formatter.string(from: date)
            
            let pid = 0
            let uid = nsud.integer(forKey: Attr.UID)
            
            let item = stock_list[index]
            
            object.setValue(item.value(forKey: Attr.CATEGORY), forKey: Attr.CATEGORY)
            
            let quantity = item.value(forKey: Attr.QUANTITY) as? String

            
            object.setPrimitiveValue(uid, forKey: Attr.UID)
            object.setPrimitiveValue(pid, forKey: Attr.PID)
            object.setValue(item.value(forKey: Attr.STOCK_NAME), forKey: Attr.STOCK_NAME)
           // object.setValue(tfSize.text!, forKey: Attr.SIZE)
           // object.setValue(tfPrice.text!, forKey: Attr.PRICE)
            object.setValue(quantity, forKey: Attr.QUANTITY)
            object.setValue(timestamp, forKey: Attr.TIMESTAMP)
            object.setValue("", forKey: Attr.EXTRA)
            
            let stock_date = item.value(forKey: Attr.STOCK_DATE) as? Date
            object.setValue(stock_date, forKey: Attr.STOCK_DATE)

            
            
            let currdate = NSDate()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "\(DATE_FORMAT)"
            dateFormatter.timeZone = NSTimeZone(name: "GMT") as TimeZone? // this line resolved me the issue of getting one day less than the selected date
            let deleteDate = dateFormatter.string(from: currdate as Date)
            
            let dateStr = dateFormatter.date(from: deleteDate)

            object.setValue(dateStr, forKey: Attr.DELETE_DATE)

            do {
                try managedContext.save()
                predict_list.append(object)
                
                print("saved")
                
                
                
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
            
        } else {
            // Fallback on earlier versions
        }
        
        //print("--> end of save");
    }
    
}



extension StockListViewController: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        var numOfSections: Int = 0
        if stock_list.count > 0
        {
            tableView.separatorStyle = .singleLine
            numOfSections            = 1
            tableView.backgroundView = nil
        }
        else
        {
            let noDataLabel: UILabel  = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text          = "Tap (+) to add new stock"
            noDataLabel.textColor     = UIColor.black
            noDataLabel.textAlignment = .center
            tableView.backgroundView  = noDataLabel
            tableView.separatorStyle  = .none
        }
        return numOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return stock_list.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StockCell", for: indexPath) as! StockCell
        
        cell.backgroundColor = UIColor.white
        cell.selectionStyle = .none
        
        //        let item = items[indexPath.row];
        //
        //        cell.tittleLabel.text = item
        
        let item:NSManagedObject = stock_list[indexPath.row]

        cell.stockLabel.text = item.value(forKey: Attr.STOCK_NAME) as? String
        
            cell.sizeLabel.text = "Size: " + String((item.value(forKey: Attr.SIZE) as? String)!)

     //  let quanty = item.value(forKey: Attr.QUANTITY) as? String
       
//        if Int(quanty!)! < 10 {
//            cell.quantityLabel.textColor = .red
//        } else  {
//            cell.quantityLabel.textColor = Utils.APP_COLORS.Theme
//
//        }
        cell.quantityLabel.text = "Qty: " + String((item.value(forKey: Attr.QUANTITY) as? String)!)

        cell.priceLabel.text = "Price: £" + String((item.value(forKey: Attr.PRICE) as? String)!)

        cell.descLabel.text = item.value(forKey: Attr.PRODUCT_DESC) as? String

        cell.supplierLabel.text = item.value(forKey: Attr.SUPPLIER) as? String

        
        cell.moreClicked.addTarget(self, action: #selector(moreClicked(_:)), for: .touchUpInside)
        cell.moreClicked.tag = indexPath.row
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "StockDetailViewController") as! StockDetailViewController
//        vc.index = indexPath.row
//        vc.cont_list = self.cont_list
                
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // retuen height of row
        return 200.0
    }
    
}
