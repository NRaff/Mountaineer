//
//  SessionTableViewCell.swift
//  SkiBum
//
//  Created by Nick Raff on 7/27/15.
//  Copyright (c) 2015 Nick Raff. All rights reserved.
//

import UIKit
//import Firebase
//import FirebaseUI

class SessionTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBOutlet weak var randomImage: UIImageView!
    @IBOutlet weak var sessionName: UILabel!
    @IBOutlet weak var createdDate: UILabel!
    
}
