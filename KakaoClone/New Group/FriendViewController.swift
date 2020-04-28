//
//  FriendViewController.swift
//  KakaoClone
//
//  Created by 이진하 on 2020/04/22.
//  Copyright © 2020 이진하. All rights reserved.
//

import UIKit

class FriendViewController: UIViewController {
    


    @IBOutlet weak var profile: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var state: UILabel!
    @IBAction func editName(_ sender: Any) {
        let alert = UIAlertController(title: "editName", message: "친구의 이름을 변경합니다", preferredStyle: .alert)
        let editAction = UIAlertAction(title: "변경",
                                     style: .default) {
        [unowned self] action in
                                      
        guard let textField = alert.textFields?.first,
          let nameToSave = textField.text else {
            return
            }
            self.name.text = nameToSave
        }

        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        alert.addTextField()
        alert.addAction(editAction)
        alert.addAction(cancelAction)
     
        self.present(alert, animated: true)
    }
    
    var detailData: friend = friend(profile:nil , name: "", state: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        }
    override func viewWillAppear(_ animated: Bool) {
        name.text = detailData.name
        if let imageData = detailData.profile {
            profile.image = UIImage(data: imageData)
        }else{
            profile.image = UIImage(named: "기본")
        }
//        state.text = detailData.state
        
    }

}
