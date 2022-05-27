//
//  PredictionCell.swift
//  Stockly
//
//  Created by Maat on 20/05/19.
//  Copyright © 2019 Maat. All rights reserved.
//

import UIKit

class PredictionCell: UITableViewCell {

    @IBOutlet var stockLabel: UILabel!
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var btnDelete: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
