//
//  PlacesTVC.swift
//  GooglePlacesDemo
//
//  Created by Eric Stein on 5/29/20.
//  Copyright © 2020 Eric Stein All rights reserved.
//

import UIKit

class PlacesTVC: UITableViewCell {

    @IBOutlet weak var placeImgV: UIImageView!
    @IBOutlet weak var placeNameLbl: UILabel!
    @IBOutlet weak var distanceLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
