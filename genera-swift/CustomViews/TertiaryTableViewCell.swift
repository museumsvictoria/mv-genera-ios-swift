//
//  TertiaryTableViewCell.swift
//  genera-swift
//
//  Created by Simon Sherrin on 9/10/2016.
//  Copyright © 2016 museumvictoria. All rights reserved.
//

import UIKit

class TertiaryTableViewCell: UITableViewCell {

    @IBOutlet weak var tertiaryLabel: UILabel?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
