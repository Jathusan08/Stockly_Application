//
//  ContentCell.swift
//  Stockly
//
//  Created by Maat on 04/05/19.
//  Copyright © 2019 Maat. All rights reserved.
//

import UIKit

class StockCell: UITableViewCell {

    @IBOutlet var stockLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var quantityLabel: UILabel!
    @IBOutlet var sizeLabel: UILabel!
    @IBOutlet var supplierLabel: UILabel!
    @IBOutlet var descLabel: UILabel!

    @IBOutlet var moreClicked: UIButton!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
