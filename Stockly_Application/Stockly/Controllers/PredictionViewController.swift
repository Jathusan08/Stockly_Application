//
//  PredictionViewController.swift
//  Stockly
//
//  Created by Maat on 20/05/19.
//  Copyright © 2019 Maat. All rights reserved.
//

import UIKit
import CoreData

class PredictionViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    var predict_list = [NSManagedObject]()

    var uid = 0

    override func viewDidLoad() {
        super.viewDidLoad()
       
        tableView.delegate = self
        tableView.dataSource = self
        
        uid = nsud.integer(forKey: Attr.UID)

        fetchPrediction()
        
        // Do any additional setup after loading the view.
    }
    
    
    func fetchPrediction() {
        
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
            
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: Entity.PREDICTION)
            
            fetchRequest.predicate = predicate
            
            do {
                
                let results = try managedContext.fetch(fetchRequest)
                
                
                
                print("total pred \(results.count)")
                
                for result in results {
                    predict_list.append(result)
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension PredictionViewController: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        var numOfSections: Int = 0
        if predict_list.count > 0
        {
            tableView.separatorStyle = .singleLine
            numOfSections            = 1
            tableView.backgroundView = nil
        }
        else
        {
            let noDataLabel: UILabel  = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text          = "No Prediction"
            noDataLabel.textColor     = UIColor.black
            noDataLabel.textAlignment = .center
            tableView.backgroundView  = noDataLabel
            tableView.separatorStyle  = .none
        }
        return numOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return predict_list.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PredictionCell", for: indexPath) as! PredictionCell
        
        cell.backgroundColor = UIColor.white
        cell.selectionStyle = .none
        
        //        let item = items[indexPath.row];
        //
        //        cell.tittleLabel.text = item
        
        let item:NSManagedObject = predict_list[indexPath.row]
        
        
        
        var stockname = ""
        
        stockname = (item.value(forKey: Attr.STOCK_NAME) as? String)!
        
        cell.stockLabel.text = item.value(forKey: Attr.STOCK_NAME) as? String
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "\(DATE_FORMAT)"
        dateFormatter.timeZone = NSTimeZone(name: "GMT") as TimeZone? // this line resolved me the issue of getting one day less than the selected date
        let deleteDate = dateFormatter.string(from: item.value(forKey: Attr.DELETE_DATE) as! Date)
        
        cell.dateLabel.text = "Date: " + deleteDate
        
        let stock_date = item.value(forKey: Attr.STOCK_DATE) as? Date
        let delete_date = item.value(forKey: Attr.DELETE_DATE) as? Date
        
        let diffInDays = delete_date?.days(from: stock_date!)
        
        print("diff \(String(describing: diffInDays))")
        
        let diff = diffInDays
        
        var qty = ""
        qty = (item.value(forKey: Attr.QUANTITY) as? String)!

        let prediction = diff! + Int(qty)!
        
        cell.messageLabel.text = "In next " + "\(prediction)" + " days " + "\(stockname)" + " will sell or likely to sell out by " + "\(qty)" + " more pieces."
        
        cell.btnDelete.addTarget(self, action: #selector(deleteClicked(_:)), for: .touchUpInside)
        cell.btnDelete.tag = indexPath.row
        
        return cell
    }
    
    @objc func deleteClicked(_ sender: UIButton)  {

        
        let myalert = UIAlertController(title: "", message: "Are you sure want to delete?", preferredStyle: UIAlertController.Style.alert)
        
        myalert.addAction(UIAlertAction(title: "No", style: .default) { (action:UIAlertAction!) in
         
        })
        
        myalert.addAction(UIAlertAction(title: "Yes", style: .destructive) { (action:UIAlertAction!) in
            print("delete")
            self.deleteItem(sender)
        })
        
//        myalert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction!) in
//            print("Cancel")
//        })
        
        self.present(myalert, animated: true)
    }
    
    @objc func deleteItem(_ sender: UIButton) {
        
        //print("delete itm \(sender.tag)")
        let stag = sender.tag
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.PREDICTION)
        
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
        
       // fetchPrediction()
        
        DispatchQueue.main.async() {
            
           // self.tableView.reloadData()
        }
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
   
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // retuen height of row
        return 150.0
    }
    
}
