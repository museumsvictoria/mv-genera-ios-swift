//
//  TertiaryTableViewCell.swift
//  genera-swift
//
//  Created by Simon Sherrin on 11/05/2017.
//  Copyright © 2017 museumvictoria. All rights reserved.
//

import UIKit

class SecondaryTableViewCell: UITableViewCell {

    @IBOutlet weak var thumbnail: UIImageView!
    
    @IBOutlet weak var primaryLabel: UILabel!
        
    @IBOutlet weak var secondaryLabel: UILabel!
    
    @IBOutlet weak var tertiaryLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
