//
//  TableViewCell.swift
//  KakaoClone
//
//  Created by 이진하 on 2020/04/17.
//  Copyright © 2020 이진하. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var profile: UIImageView?
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var state: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
