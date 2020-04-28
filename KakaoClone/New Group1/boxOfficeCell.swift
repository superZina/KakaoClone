//
//  boxOfficeCell.swift
//  KakaoClone
//
//  Created by 이진하 on 2020/04/27.
//  Copyright © 2020 이진하. All rights reserved.
//

import UIKit

class boxOfficeCell: UITableViewCell {

    @IBOutlet weak var rank: UILabel!
    @IBOutlet weak var movieNm: UILabel!
    @IBOutlet weak var audiAcc: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
