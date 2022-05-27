//
//  AddStockViewController.swift
//  Stockly
//
//  Created by Maat on 15/05/19.
//  Copyright © 2019 Maat. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

class AddStockViewController: UIViewController, UIGestureRecognizerDelegate, UITextFieldDelegate {

    @IBOutlet weak var btnAddStock: UIButton!

    @IBOutlet weak var ivStockImage: UIImageView!
    @IBOutlet weak var tfQuantity: SkyFloatingLabelTextField!
    @IBOutlet weak var tfSupplier: SkyFloatingLabelTextField!
    @IBOutlet weak var tfCategory: SkyFloatingLabelTextField!
    @IBOutlet weak var tfPrice: SkyFloatingLabelTextField!
    @IBOutlet weak var tfSize: SkyFloatingLabelTextField!
    @IBOutlet weak var tfStockName: SkyFloatingLabelTextField!
    @IBOutlet weak var tfDate: SkyFloatingLabelTextField!
    @IBOutlet weak var descriptionTxtView: IQTextView!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!

    var appDelegate = UIApplication.shared.delegate as? AppDelegate

    var lineWidth:CGFloat = 320.0
    
    var isEdit = false
    var index = 0
    // core data objects
    var cont_list = [NSManagedObject]()
    var contentList: [NSManagedObject] = []
    var stock_list = [NSManagedObject]()

    var cat_list = [NSManagedObject]()

    //date vars
    let date = Date()
    let formatter = DateFormatter()
    
    // picker view var
    var itemPicker: UIPickerView! = UIPickerView()
    
    // imagePickerController var
    let picker = UIImagePickerController()
    
    var checkImage = false
    
    let datePicker = UIDatePicker()
    
    var uid = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        
        if DeviceType.IS_IPHONE_7 {
            imageHeightConstraint.constant = 175
            
            lineWidth = 375.0
           
        } else if DeviceType.IS_IPHONE_5 {
            imageHeightConstraint.constant = 150
            
            lineWidth = 320.0
            
        } else {
            imageHeightConstraint.constant = 195
            
            lineWidth = 414.0
        }
        
        addBottomBorderWithColor(color: Utils.APP_COLORS.Theme, width: 1.5)
        uid = nsud.integer(forKey: Attr.UID)

        
        if isEdit {
            
            let item:NSManagedObject = cont_list[index]
            
            tfCategory.text = item.value(forKey: Attr.CATEGORY) as? String
            tfStockName.text = item.value(forKey: Attr.STOCK_NAME) as? String
            tfSize.text = item.value(forKey: Attr.SIZE) as? String
            tfPrice.text = item.value(forKey: Attr.PRICE) as? String
            tfQuantity.text = item.value(forKey: Attr.QUANTITY) as? String
            tfSupplier.text = item.value(forKey: Attr.SUPPLIER) as? String
           
            
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "\(DATE_FORMAT)"
            dateFormatter.timeZone = NSTimeZone(name: "GMT") as TimeZone? // this line resolved me the issue of getting one day less than the selected date
            let stockDAte = dateFormatter.string(from: item.value(forKey: Attr.STOCK_DATE) as! Date)
            tfDate.text = stockDAte
            
            descriptionTxtView.text = item.value(forKey: Attr.PRODUCT_DESC) as? String
            btnAddStock.addTarget(self, action: #selector(updateStockAction(_:)), for: .touchUpInside)
            btnAddStock.setTitle("Update Stock", for: .normal)
            
            let imgData = item.value(forKey: Attr.STOCK_IMAGE) as? NSData
            ivStockImage.image = UIImage(data: imgData! as Data)
            
        } else {
            btnAddStock.addTarget(self, action: #selector(addStockAction(_:)), for: .touchUpInside)
            btnAddStock.setTitle("Add Stock", for: .normal)

        }
        
        ivStockImage.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.imgaePicker(_:)))
        tap.delegate = self // This is not required
        ivStockImage.addGestureRecognizer(tap)


        setupPickerView()
        showDatePicker()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(true)
        
        cat_list = [NSManagedObject]()
        fetchCateogries()

    }
    
    @objc func imgaePicker(_ sender:AnyObject){
        setupImagePickerController()
    }
    
        func setupPickerView() {
    
            tfCategory.delegate = self
            tfCategory.tintColor = .clear
            itemPicker!.delegate = self
            itemPicker!.dataSource = self
            
            //  itemPicker!.backgroundColor = UIColor.black
            
            self.tfCategory.inputView = itemPicker
        }
    
    
    
    @IBAction func updateStockAction(_ sender: Any) {
        update(indexRow: index)
    }
    
    @IBAction func addStockAction(_ sender: Any) {
        
        var errorMessage = ""
        if tfCategory.text == ""
        {
            errorMessage = "Please Select Category."
            showAlert(message: errorMessage)
        } else if tfStockName.text == ""
        {
          errorMessage = "Please enter Stock name."
            showAlert(message: errorMessage)
        }
        else if tfSize.text == ""
        {
            errorMessage = "Please enter Size."
            showAlert(message: errorMessage)

        }else if tfPrice.text == ""
        {
            errorMessage = "Please enter Price."
            showAlert(message: errorMessage)

        }else if tfSupplier.text == ""
        {
            errorMessage = "Please enter Supplier name."
            showAlert(message: errorMessage)

        }else if tfQuantity.text == ""
        {
            errorMessage = "Please enter Quantity."
            showAlert(message: errorMessage)

        } else {
                
                self.addStock()
        }
        
    }
    
    func showAlert(message: String)  {
        
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
        
        alert.addAction(ok)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func addBottomBorderWithColor(color: UIColor, width: CGFloat) {
        let border = UIView()
        border.frame = CGRect(x:self.descriptionTxtView.frame.origin.x, y:self.descriptionTxtView.frame.origin.y+self.descriptionTxtView.frame.height-width, width:lineWidth - self.descriptionTxtView.frame.origin.x * 2, height: width)
        border.backgroundColor = color
        self.descriptionTxtView.superview!.insertSubview(border, aboveSubview: descriptionTxtView)
    }
    
    func addStock() {
        
        print("--> start of save");
        
        //print("id \(id)")
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        if #available(iOS 10.0, *) {
            let managedContext = appDelegate.persistentContainer.viewContext
            
            let entity = NSEntityDescription.entity(forEntityName: Entity.STOCK,
                                                    in: managedContext)!
            
            let object = NSManagedObject(entity: entity,
                                         insertInto: managedContext)
            
            formatter.dateFormat = "yyyy-MM-dd HH:mm:a"
            let timestamp = formatter.string(from: date)
            
            let sid = 0
            let uid = nsud.integer(forKey: Attr.UID)
            
            let data = self.ivStockImage.image!.pngData()

            object.setValue(data, forKey: Attr.STOCK_IMAGE)
            object.setValue(tfCategory.text!, forKey: Attr.CATEGORY)

            
            
            object.setPrimitiveValue(uid, forKey: Attr.UID)
            object.setPrimitiveValue(sid, forKey: Attr.SID)
            object.setValue(tfStockName.text!, forKey: Attr.STOCK_NAME)
            object.setValue(tfSize.text!, forKey: Attr.SIZE)
            object.setValue(tfPrice.text!, forKey: Attr.PRICE)
            object.setValue(tfSupplier.text!, forKey: Attr.SUPPLIER)
            object.setValue(tfQuantity.text!, forKey: Attr.QUANTITY)
            object.setValue(descriptionTxtView.text!, forKey: Attr.PRODUCT_DESC)
            object.setValue(timestamp, forKey: Attr.TIMESTAMP)
            object.setValue("", forKey: Attr.EXTRA)
            
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "\(DATE_FORMAT)"
            dateFormatter.timeZone = NSTimeZone(name: "GMT") as TimeZone? // this line resolved me the issue of getting one day less than the selected date
            print(tfDate.text!)
            
            let stDate:NSDate = dateFormatter.date(from: "\(tfDate.text!)")! as NSDate
            
            print(stDate)
            
            object.setValue(stDate, forKey: Attr.STOCK_DATE)

            
            do {
                try managedContext.save()
                contentList.append(object)
                
                print("saved")
                
                index = contentList.count - 1
                
                self.fetchStocks()

                self.navigationController?.popViewController(animated: true)

                
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
            
        } else {
            // Fallback on earlier versions
        }
        
        //print("--> end of save");
    }
    
    func update(indexRow: NSInteger) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        let object = cont_list[indexRow]
       
        formatter.dateFormat = "yyyy-MM-dd HH:mm:a"
        let timestamp = formatter.string(from: date)
        
        let sid = 0
        let uid = nsud.integer(forKey: Attr.UID)

        let data = self.ivStockImage.image!.pngData()
        
        object.setValue(data, forKey: Attr.STOCK_IMAGE)
        
        object.setPrimitiveValue(uid, forKey: Attr.UID)
        object.setPrimitiveValue(sid, forKey: Attr.SID)
        object.setValue(tfStockName.text!, forKey: Attr.STOCK_NAME)
        object.setValue(tfSize.text!, forKey: Attr.SIZE)
        object.setValue(tfPrice.text!, forKey: Attr.PRICE)
        object.setValue(tfSupplier.text!, forKey: Attr.SUPPLIER)
        object.setValue(tfQuantity.text!, forKey: Attr.QUANTITY)
        object.setValue(descriptionTxtView.text!, forKey: Attr.PRODUCT_DESC)
        object.setValue(timestamp, forKey: Attr.TIMESTAMP)
        object.setValue("", forKey: Attr.EXTRA)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "\(DATE_FORMAT)"
        dateFormatter.timeZone = NSTimeZone(name: "GMT") as TimeZone? // this line resolved me the issue of getting one day less than the selected date
        print(tfDate.text!)
        
        let stDate:NSDate = dateFormatter.date(from: "\(tfDate.text!)")! as NSDate
        
        print(stDate)
        
        object.setValue(stDate, forKey: Attr.STOCK_DATE)
        
        do {
            try managedObjectContext.save()
            // contentList[0] = contact
            contentList.append(object)
            print("updated")
            
            fetchStocks()

            self.navigationController?.popViewController(animated: true)
        } catch let error as NSError {
            print("Couldn't update. \(error)")
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
                
               // print(results.count)
                
                for result in results {
                    
                    stock_list.append(result)

                }
                
                
                if results.count == 0 {
                } else {
                    self.notificationFire()
                }
                

                DispatchQueue.main.async() {
                    
                   // self.tableView.reloadData()
                }
                
                
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            
        } else {
            // Fallback on earlier versions
        }
        
        //print("--> end of read");
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
        
        tfDate.inputAccessoryView = toolbar
        tfDate.inputView = datePicker
        
    }
    
    @objc func donedatePicker(){
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        tfDate.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    
    @objc func cancelDatePicker() {
        self.view.endEditing(true)
    }
    

    func notificationFire() {
        
        print("fire")
        
        if stock_list.count > 0 {
        
            let item: NSManagedObject = stock_list[index]
            
            let quantity = item.value(forKey: Attr.QUANTITY) as? String
            let stockname = item.value(forKey: Attr.STOCK_NAME) as? String

            var setLimit = nsud.integer(forKey: UD.SET_STOCK_LIMIT)
            
            if setLimit == 0 {
                setLimit = 5
            }
            
            print("limit \(setLimit)")
            
            if Int(quantity!)! < setLimit {
                let notificationType = stockname!
                self.appDelegate?.scheduleNotification(notificationType: notificationType)
            }
        }
    }
    
    
    
    
    
}


extension AddStockViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func setupImagePickerController() {
        
        picker.delegate = self
        
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        
        // picker.sourceType = .camera
        // picker.cameraCaptureMode = .photo
        
        self.present(picker, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }

        ivStockImage.image = selectedImage

        checkImage = true
        dismiss(animated: true, completion: nil)
    }

 

    
//    private func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
//        let chosenImage = info[UIImagePickerControllerOriginalImage] as? UIImage
//        // use the image
//        ivStockImage.image = chosenImage
//        checkImage = true
//        dismiss(animated: true, completion: nil)
//    }
//
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

extension AddStockViewController : UIPickerViewDataSource, UIPickerViewDelegate {
    
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
            //.hidden = true;
        }
    
    //    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
    //        itemPicker.hidden = false
    //        return false
    //    }
    
}
