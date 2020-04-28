//
//  kakaoLogin.swift
//  KakaoClone
//
//  Created by 이진하 on 2020/04/27.
//  Copyright © 2020 이진하. All rights reserved.
//

import UIKit
import KakaoOpenSDK

class kakaoLogin: UIViewController {
    
    private let loginButton: KOLoginButton = {
      let button = KOLoginButton()
      button.addTarget(self, action: #selector(touchUpLoginButton(_:)), for: .touchUpInside)
      button.translatesAutoresizingMaskIntoConstraints = false
      button.isHidden = false
      return button
    }()
    
    private let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("로그아웃", for: .normal)
        button.addTarget(self, action: #selector(touchUpLogoutButton(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nickName.isHidden = true
        self.birth.isHidden = true
        self.email.isHidden = true
        view.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        layout()
    }
    @IBOutlet weak var nickName: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var birth: UILabel!
    
    @objc private func touchUpLoginButton(_ sender: UIButton) {
      guard let session = KOSession.shared() else {
        return
      }
       
      if session.isOpen() {
        session.close()
      }
      
      session.open { (error) in
        if error != nil || !session.isOpen() { return }
        KOSessionTask.userMeTask(completion: { (error, user) in
          guard let user = user,
                let email = user.account?.email,
                let birth = user.account?.birthday,
                let nickname = user.nickname else { return }
            self.nickName.isHidden = false
            self.birth.isHidden = false
            self.nickName.text = nickname+"님!"
            self.email.isHidden = false
            self.birth.text = "birth : "+birth
            self.email.text = "email: "+email
            myList.append(friend(profile: UIImage(named: "농담곰")?.pngData(), name: nickname, state: email))
            self.loginButton.isHidden = true
            self.logoutButton.isHidden = false
        })
      }
    }
    @objc private func touchUpLogoutButton(_ sender: UIButton){
        guard let session = KOSession.shared() else {return}
        session.logoutAndClose{(success, error) in
            if success{
                
                
                print("logout success.")
                let alert = UIAlertController(title: "알림", message: "로그아웃 되셨습니다!", preferredStyle: .alert)
                let cancel = UIAlertAction(title: "확인", style: .default) { _ in
                    self.nickName.isHidden = true
                    self.birth.isHidden = true
                    self.email.isHidden = true
                    self.loginButton.isHidden = false
                    self.logoutButton.isHidden = true
                }
                alert.addAction(cancel)
                self.present(alert,animated: false,completion: nil)
                self.view.setNeedsLayout()
            }else {
              print(error?.localizedDescription)
            }
        }
    }
    private func layout() {
      let guide = view.safeAreaLayoutGuide
      view.addSubview(loginButton)
      view.addSubview(logoutButton)
      loginButton.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 20).isActive = true
      loginButton.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -20).isActive = true
      loginButton.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -30).isActive = true
      loginButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        logoutButton.topAnchor.constraint(equalTo: birth.bottomAnchor, constant: 30).isActive = true
        logoutButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
    }
}
