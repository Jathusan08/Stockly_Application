//
//  ChartViewController.swift
//  Stockly
//
//  Created by Maat on 17/05/19.
//  Copyright © 2019 Maat. All rights reserved.
//

import UIKit
import CoreData

class ReportViewController: UIViewController, UITextFieldDelegate {

    let pieChartView = PieChartView()
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var navSegment: UISegmentedControl!

    @IBOutlet weak var tfFromDate: UITextField!
    @IBOutlet weak var tfCategory: UITextField!

    @IBOutlet weak var lblStockName: UILabel!
    @IBOutlet weak var lblStockSold: UILabel!
    @IBOutlet weak var lblStockRemaining: UILabel!
    @IBOutlet weak var lblQuantity: UILabel!
    @IBOutlet weak var lblTotalStock: UILabel!

    
    // core data objects
    var stock_list = [NSManagedObject]()
    var cat_list = [NSManagedObject]()
    var contentList: [NSManagedObject] = []
    
    var datePicker = UIDatePicker()
    var monthPicker = MonthYearPickerView()

    // picker view var
    var itemPicker: UIPickerView! = UIPickerView()
    
    var isWeekly = true
    var isMonthly = false
    var firstCustomDate = ""
    var secondCustomDate = ""
    var isCustomFromDate = true
    
    
    let formatter = DateFormatter()
    
    
    var stock_sold = 0
    var stock_left = 0
    var total_quantity = 0

    var appDelegate = UIApplication.shared.delegate as? AppDelegate

    var fromDate = ""
    var toDate = ""
    var selectedCategory = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        fetchStocks()   // fetch all stocks
        fetchCateogries()   // all categories

    
        tfFromDate.delegate = self
        tfCategory.delegate = self
        
        tfFromDate.tintColor = .clear
        tfCategory.tintColor = .clear
        

        showDatePicker()
        setupPickerView()
        
        
        formatter.dateFormat = DATE_FORMAT

        // Do any additional setup after loading the view.
    }
    
    @IBAction func listGraphValueChanged(_ sender: UISegmentedControl) {
        
        print("lst graph")
        if sender.selectedSegmentIndex == 0 {
            self.tableView.isHidden = false
            self.pieChartView.isHidden = true
        } else {
            self.tableView.isHidden = true
            self.pieChartView.isHidden = false
        }
    }
    
    @IBAction func weeklyMonthlyValueChanged(_ sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0 { // weekly
            
            showDatePicker()
            isWeekly = true
            isMonthly = false
        } else if sender.selectedSegmentIndex == 1 {  // monthly
            
            showMonthPicker()
            isWeekly = false
            isMonthly = true
            
            tfFromDate.placeholder = "Select Month"
            
        } else {    // custom dates

            isWeekly = false
            isMonthly = false

            tfFromDate.placeholder = "Select Dates"
            
            showCustomDatePicker(firstDate: true)

        }
    }
    
    
    func setupPieChart() {
        
        
        let total_deleted = nsud.object(forKey: UD.STOCK_DELETED) as? Int
        stock_sold = total_deleted!
    
        print("stock sold \(stock_sold)")
        
        
        stock_left = stock_list.count - stock_sold
        
        if stock_left < 1 {
            stock_left = 0
        }
        
        
        // pie chart
        let padding: CGFloat = 20
        let height = (view.frame.height - padding * 3) / 2
        
        pieChartView.frame = CGRect(
            x: padding, y: padding + tfCategory.frame.origin.y + tfCategory.frame.size.height, width: view.frame.size.width - padding * 2, height: height
        )
        
        pieChartView.segments = [
            LabelledSegment(color: #colorLiteral(red: 1.0, green: 0.121568627, blue: 0.28627451, alpha: 1.0), name: "Stock Sold",    value: CGFloat(stock_sold) ),
            LabelledSegment(color: #colorLiteral(red: 1.0, green: 0.541176471, blue: 0.0, alpha: 1.0), name: "Total Stock",     value: CGFloat(stock_list.count)),
            LabelledSegment(color: #colorLiteral(red: 0.478431373, green: 0.423529412, blue: 1.0, alpha: 1.0), name: "Stock Remaining",     value: CGFloat(stock_left)),
            LabelledSegment(color: #colorLiteral(red: 0.0, green: 0.870588235, blue: 1.0, alpha: 1.0), name: "Total Quantity", value: CGFloat(total_quantity)),
            //            LabelledSegment(color: #colorLiteral(red: 0.392156863, green: 0.945098039, blue: 0.717647059, alpha: 1.0), name: "Green",      value: 25),
            //            LabelledSegment(color: #colorLiteral(red: 0.0, green: 0.392156863, blue: 1.0, alpha: 1.0), name: "Blue",       value: 38)
        ]
        
        pieChartView.segmentLabelFont = .systemFont(ofSize: 10)
        
        view.addSubview(pieChartView)
        
        self.pieChartView.isHidden = true
        
        lblStockSold.textColor = UIColor.init(red: 1.0, green: 0.121568627, blue: 0.28627451, alpha: 1.0)
        lblTotalStock.textColor = UIColor.init(red: 1.0, green: 0.541176471, blue: 0.0, alpha: 1.0)
        lblStockRemaining.textColor = UIColor.init(red: 0.478431373, green: 0.423529412, blue: 1.0, alpha: 1.0)
        lblQuantity.textColor = UIColor.init(red: 0.0, green: 0.870588235, blue: 1.0, alpha: 1.0)
        
        
        lblTotalStock.text = "Total Stock : " + String(stock_list.count)
        lblStockSold.text  = "Stock Sold : " + String(stock_sold)
        lblStockRemaining.text = "Stock Remaining : " + String(stock_left)
        lblQuantity.text = "Total Quantity : " + String(total_quantity)
        
        
    }
    
    func setupPickerView() {
        
        tfCategory.delegate = self
        tfCategory.tintColor = .clear
        itemPicker!.delegate = self
        itemPicker!.dataSource = self
        
        self.tfCategory.inputView = itemPicker
    }
    
    
    func fetchFilteredStocks() {
        
        print("filtered")
        //print("--> start of read");
        stock_list = [NSManagedObject]()
        total_quantity = 0
        
        var condition = "OR"
        if self.selectedCategory == "" {
            condition = "OR"
        } else {
            condition = "AND"
        }
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        if #available(iOS 10.0, *) {
            let managedContext = appDelegate.persistentContainer.viewContext
            
//            let fromdate = fromDate // add hours and mins to fromdate
//            let todate = toDate // add hours and mins to todate
            
            
          

            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: Entity.STOCK)
            fetchRequest.returnsObjectsAsFaults = false
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "\(DATE_FORMAT) HH:mm"
            dateFormatter.timeZone = NSTimeZone(name: "GMT") as TimeZone? // this line resolved me the issue of getting one day less than the selected date
         
            
            if isWeekly { // weekly
                
                let fromdate = "\(self.fromDate) 00:00" // add hours and mins to fromdate
                let todate = "\(self.toDate) 23:59" // add hours and mins to todate
            
                let startDate:NSDate = dateFormatter.date(from: fromdate)! as NSDate
                let endDate:NSDate = dateFormatter.date(from: todate)! as NSDate
                
                fetchRequest.predicate = NSPredicate(format: "(stockdate >= %@) AND (stockdate <= %@) \(condition) category = %@", startDate, endDate, self.selectedCategory)
            
            } else if isMonthly { // montly
                
                
                let sd = "01/"
                let ed = "30/"

                let fromdate = "\(sd)\(tfFromDate.text!) 00:00" // add hours and mins to fromdate
                let todate = "\(ed)\(tfFromDate.text!) 23:59" // add hours and mins to todate
                
                
                let startDate:NSDate = dateFormatter.date(from: fromdate)! as NSDate
                let endDate:NSDate = dateFormatter.date(from: todate)! as NSDate
                
                fetchRequest.predicate = NSPredicate(format: "(stockdate >= %@) AND (stockdate <= %@) \(condition) category = %@", startDate, endDate, self.selectedCategory)

            } else { // custom dates
                
                let fromdate = "\(self.firstCustomDate) 00:00" // add hours and mins to fromdate
                let todate = "\(self.secondCustomDate) 23:59" // add hours and mins to todate
                
                let startDate:NSDate = dateFormatter.date(from: fromdate)! as NSDate
                let endDate:NSDate = dateFormatter.date(from: todate)! as NSDate
                
                fetchRequest.predicate = NSPredicate(format: "(stockdate >= %@) AND (stockdate <= %@) \(condition) category = %@", startDate, endDate, self.selectedCategory)
            }
            
           // fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
            
            do {
                
                let results = try managedContext.fetch(fetchRequest)
                
                for result in results {
                    stock_list.append(result)
                    
                    let quantity = result.value(forKey: Attr.QUANTITY) as? String
                    
                    total_quantity += Int(quantity!)!
                }
                
                DispatchQueue.main.async() {
                    self.tableView.reloadData()
                    
                    self.setupPieChart()
                }
                
                
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            
        } else {
            // Fallback on earlier versions
        }
        
        //print("--> end of read");
    }
    
    func fetchStocks() {
        
        //print("--> start of read");
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        if #available(iOS 10.0, *) {
            let managedContext = appDelegate.persistentContainer.viewContext
           
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: Entity.STOCK)
            do {
                
                let results = try managedContext.fetch(fetchRequest)
                
                for result in results {
                    stock_list.append(result)
                    
                    let quantity = result.value(forKey: Attr.QUANTITY) as? String
                    
                    total_quantity += Int(quantity!)!
                }
                
                DispatchQueue.main.async() {
                   self.tableView.reloadData()
                    
                    self.setupPieChart()
                }
                
                
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            
        } else {
            // Fallback on earlier versions
        }
        
        //print("--> end of read");
    }
    
    func showMonthPicker() {
        
        monthPicker = MonthYearPickerView()
        self.tfFromDate.inputView = monthPicker

//        let expiryDatePicker = MonthYearPickerView()
//        expiryDatePicker.onDateSelected = { (month: Int, year: Int) in
//            let str = String(format: "%02d/%d", month, year)
//            NSLog(str) // should show something like 05/2015
//        }
        

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
        
        //tfFromDate.inputAccessoryView = toolbar
        tfFromDate.inputView = datePicker
        
    }
    
    
    func showCustomDatePicker(firstDate : Bool){
        

        
        
        //Formate Date
        datePicker.datePickerMode = .date
        
        //ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        
        var doneButton = UIBarButtonItem()
        
        if isCustomFromDate == true {
            doneButton = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(nextDatePicker));

        } else {
            doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donedatePicker));
        }

     //   let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(nextDatePicker));

        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));
        
        toolbar.setItems([cancelButton,spaceButton,doneButton], animated: false)
        
        tfFromDate.inputAccessoryView = toolbar
        tfFromDate.inputView = datePicker
        
    }
    
    @objc func nextDatePicker() {
        
        
        isCustomFromDate = false
        
        datePicker = UIDatePicker()

        tfFromDate.placeholder = "Select To Date"
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        firstCustomDate = formatter.string(from: datePicker.date)

        self.view.endEditing(true)

        showCustomDatePicker(firstDate: false)
        
    }
        
    @objc func donedatePicker() {
        
        isCustomFromDate = true

        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"

//        let arrWeekDates = datePicker.date.getWeekDates() // Get dates of Current and Next week.
//        let dateFormat = "dd/MM/yyyy" // Date format
//        let thisMon = arrWeekDates.thisWeek.first!.toDate(format: dateFormat)
//        let thisSat = arrWeekDates.thisWeek[arrWeekDates.thisWeek.count - 2].toDate(format: dateFormat)
//        let thisSun = arrWeekDates.thisWeek[arrWeekDates.thisWeek.count - 1].toDate(format: dateFormat)
//
//        let nextMon = arrWeekDates.nextWeek.first!.toDate(format: dateFormat)
//        let nextSat = arrWeekDates.nextWeek[arrWeekDates.nextWeek.count - 2].toDate(format: dateFormat)
//        let nextSun = arrWeekDates.nextWeek[arrWeekDates.nextWeek.count - 1].toDate(format: dateFormat)
//
//        print("Today: \(Date().toDate(format: dateFormat))") // Sep 26
//        print("Tomorrow: \(Date().tomorrow.toDate(format: dateFormat))") // Sep 27
//        print("This Week: \(thisMon) - \(thisSun)") // Sep 24 - Sep 30
//        print("This Weekend: \(thisSat) - \(thisSun)") // Sep 29 - Sep 30
//        print("Next Week: \(nextMon) - \(nextSun)") // Oct 01 - Oct 07
//        print("Next Weekend: \(nextSat) - \(nextSun)") // Oct 06 - Oct 07

        
        if isWeekly {
           // tfFromDate.text = "\(thisMon) - \(thisSun)"

        } else if isMonthly {
           

        } else {
            
            secondCustomDate = formatter.string(from: datePicker.date)
            tfFromDate.text = "\(firstCustomDate) - \(secondCustomDate)"
            
            self.view.endEditing(true)
        }
            
      
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if isWeekly {
            
        } else if isMonthly
        {
            
        } else {
            
            if isCustomFromDate == true {
                
                
                showCustomDatePicker(firstDate: true)
              //  firstCustomDate = ""
              //  secondCustomDate = ""
                
                isCustomFromDate = true
                tfFromDate.text = ""
                tfFromDate.placeholder = "Select From Date"

            } else {
                isCustomFromDate = false

            }
            
        }
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        print(isWeekly)
        print(isMonthly)
     
        if isWeekly {
            
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            
            let arrWeekDates = datePicker.date.getWeekDates() // Get dates of Current and Next week.
            let dateFormat = "dd/MM/yyyy" // Date format
            let thisMon = arrWeekDates.thisWeek.first!.toDate(format: dateFormat)
            let thisSun = arrWeekDates.thisWeek[arrWeekDates.thisWeek.count - 1].toDate(format: dateFormat)
            
            fromDate = thisMon
            toDate = thisSun
            
            tfFromDate.text = "\(thisMon) - \(thisSun)"
            
            print("date \(thisMon)  -  \(thisSun)")
            
            fetchFilteredStocks()
        }
        
        if isMonthly {

            monthPicker.onDateSelected = { (month: Int, year: Int) in
                let str = String(format: "%01d/%d", month, year)
                print(str) // should show something like 05/2015
                self.tfFromDate.text = str
                
                self.fetchFilteredStocks()

            }
            
        }
        
        
        
    }
    
    
    @objc func cancelDatePicker(){
        self.view.endEditing(true)
    }
    
    func fetchCateogries() {
        
        //print("--> start of read");
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        if #available(iOS 10.0, *) {
            let managedContext = appDelegate.persistentContainer.viewContext
            
            
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: Entity.CATEGORY)
            do {
                
                let results = try managedContext.fetch(fetchRequest)
                
                print(results.count)
                if results.count == 0 {
                } else {
                }
                
                
                for result in results {
                    
                    cat_list.append(result)
                    
                }
                
                DispatchQueue.main.async() {
                    
                    self.itemPicker.reloadInputViews()
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

extension ReportViewController : UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // returns the # of rows in each component..
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return cat_list.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return cat_list[row].value(forKey: Attr.CATEGORY_NAME) as? String
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        tfCategory.text = cat_list[row].value(forKey: Attr.CATEGORY_NAME) as? String
        
        self.selectedCategory = (cat_list[row].value(forKey: Attr.CATEGORY_NAME) as? String)!
        
        self.fetchFilteredStocks()

        //.hidden = true;
    }
    
    //    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
    //        itemPicker.hidden = false
    //        return false
    //    }
    
}
