//
//  Constants.swift
//  WBC
//
//  Created by Maat on 05/05/19.
//  Copyright © 2019 Maat. All rights reserved.
//

import UIKit


import Foundation
import UIKit
//import KeychainSwift
//---**----UserDefaults globle object----***--
var nsud = UserDefaults.standard

//---**----AppDelegate globle object----***--
let appDelegate = UIApplication.shared.delegate  as! AppDelegate


//---**----mainStoryboard globle object----***--
let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)

//---**----App Name & Bundle Identifier ----***--
let AppName:String = ""
let BundleIdentifier:String = ""

let DATE_FORMAT:String = "dd/MM/yyyy"

//let keychain = KeychainSwift()


struct Entity {
    // entity
    static let REGISTER: String = "Register"
    static let STOCK: String = "Stock"
    static let CATEGORY: String = "Category"
    static let PREDICTION: String = "Prediction"
}

struct Attr {
    // attribute
    
    // login
    static let UID: String = "uid"
    static let USERNAME: String = "username"
    static let PASSWORD: String = "password"
    static let DOB: String = "dob"
    static let ADDRESS: String = "address"
    static let COMPANY: String = "company"
    static let PHONE: String = "phone"
    static let EXTRA: String = "extra"
    static let TIMESTAMP: String = "timestamp"
    static let EMAIL: String = "email"
    
    // add stock
    static let STOCK_NAME: String = "stockname"
    static let SIZE: String = "size"
    static let SUPPLIER: String = "supplier"
    static let QUANTITY: String = "quantity"
    static let PRICE: String = "price"
    static let STOCK_IMAGE: String = "stockimage"
    static let PRODUCT_DESC: String = "productdesc"
    static let SID: String = "sid"
    static let CATEGORY: String = "category"
    static let STOCK_DATE: String = "stockdate"

    // add cate
    static let CID: String = "cid"
    static let CATEGORY_NAME: String = "categoryname"

    //
    static let PID: String = "pid"
    static let Message: String = "message"
    static let DELETE_DATE: String = "deletedate"
    static let TITTLE: String = "tittle"


}

struct Constants {
    static let supportEmail: String = ""
    
    static let privacyPolicy: String = ""
    static let termsConditions: String = ""
}

struct UD {
    static let STOCK_DELETED: String = "stock_deleted"
    static let SET_STOCK_LIMIT: String = "stock_limit"

}
