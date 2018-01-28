//
//  PowerCell.swift
//  PowerRanger
//
//  Created by Donna Samuel on 27/1/18.
//  Copyright © 2018 donnali. All rights reserved.
//

import UIKit

class PowerCell: UITableViewCell {

    @IBOutlet weak var colourLabel: UILabel!
    @IBOutlet weak var colourRect: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(colour: String, id: String){
        
        let colour = UIColor(hex: colour)
    
        colourLabel.text = id
        colourLabel.textColor = colour
        colourRect.backgroundColor = colour
    }

}
