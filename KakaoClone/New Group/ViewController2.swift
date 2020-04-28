//
//  ViewController2.swift
//  KakaoClone
//
//  Created by 이진하 on 2020/04/18.
//  Copyright © 2020 이진하. All rights reserved.
//

import UIKit
protocol  SaveDataDelegate: class {
    func save(data saveData:friend)
}

class ViewController2: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    var delegate:SaveDataDelegate?

    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var state: UITextView!
    @IBOutlet weak var profile: UIImageView!
    
    let picker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        // Do any additional setup after loading the view.
    }
    
    @IBAction func addImage(_ sender: Any) {
        let alert = UIAlertController(title: "profile image", message: "프로필 사진 설정", preferredStyle: .actionSheet)
        
        let library = UIAlertAction(title: "앨범에서 사진 선택", style: .default) { (action) in
            self.openLibrary()
        }
        
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alert.addAction(library)
        alert.addAction(cancel)
        present(alert,animated: true, completion: nil)
    }
    //친구추가
    @IBAction func addFriend(_ sender: Any) {
        let imageData = profile.image?.pngData()
        let data: friend = friend(profile: imageData, name: self.name.text!, state: self.state.text)
        delegate?.save(data: data)
        self.navigationController?.popViewController(animated: true)
    }
    
    //갤러리 여는 메소드
    func openLibrary(){
        picker.sourceType = .photoLibrary
        present(picker, animated: false, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            profile.image = image
            print(info)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "내용을 입력해주세요"{
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }
    //아무런 내용을 적지 않았을 때의 textView의 placeholder 지정
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "내용을 입력해주세요"
            textView.textColor = UIColor.systemGray3
        }
    }
    
    //done을 누르면 키보드 사라짐 : textField
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if(string == "\n"){
            textField.resignFirstResponder()
        }
        return true
    }
    //done을 누르면 키보드 사라짐 : textView
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n"){
            textView.resignFirstResponder()
        }else{}
        return true
    }
}
