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
//    
//    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        
//        SessionID = UILabel()
//        randomImage = UIImageView()
//        sessionName = UILabel()
//        createdDate = UILabel()
//    
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    @IBOutlet weak var SessionID: UILabel!
    @IBOutlet weak var randomImage: UIImageView!
    @IBOutlet weak var sessionName: UILabel!
    @IBOutlet weak var createdDate: UILabel!
    
    
//    static var dateFormatter: NSDateFormatter = {
//        var formatter = NSDateFormatter()
//        formatter.dateFormat = "MM-dd-yyy"
//        return formatter
//        }()
//    
//    var session: Firebase? {
//        didSet {
//            if let session = session, sessionName = sessionName, createdDate = createdDate {
//                self.sessionName.text = session.sessionTitle
//                self.createdDate.text = SessionTableViewCell.dateFormatter.stringFromDate(session.Date)
//                self.randomImage.image = UIImage(named:"cell_bg\(session.imageID)")
//            }
//        }
//    }

}
