//
//  TableViewCellPrototype.swift
//  tumblerFeed
//
//  Created by Savio Tsui on 10/13/16.
//  Copyright © 2016 Savio Tsui. All rights reserved.
//

import UIKit

class TableViewCellPrototype: UITableViewCell {

    @IBOutlet weak var cellLabel: UILabel!
    @IBOutlet weak var cellImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
