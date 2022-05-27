//
//  SettingViewController.swift
//  Stockly
//
//  Created by Har govind on 20/05/19.
//  Copyright © 2019 Jeff. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController {

    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var setLimitLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var setLimit = nsud.integer(forKey: UD.SET_STOCK_LIMIT)

        if setLimit == 0 {
            setLimit = 5
        }
        
        slider.value = Float(setLimit)
        
        DispatchQueue.main.async {
            self.setLimitLbl.text = "Current stock limit :  \(setLimit) "
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func stockLimitChanged(_ sender: UISlider) {
        let currentValue = Int(sender.value)
        DispatchQueue.main.async {
            self.setLimitLbl.text = "Current stock limit :  \(currentValue) "
            nsud.set(currentValue, forKey: UD.SET_STOCK_LIMIT)
            nsud.synchronize()
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
