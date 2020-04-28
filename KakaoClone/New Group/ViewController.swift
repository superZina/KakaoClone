//
//  ViewController.swift
//  KakaoClone
//
//  Created by 이진하 on 2020/04/17.
//  Copyright © 2020 이진하. All rights reserved.
//

import UIKit
import CoreData


struct friend {
    var profile: Data?
    var name: String!
    var state: String?
    
    init(profile: Data?, name: String? , state: String?){
        self.profile = profile
        self.name = name
        self.state = state
    }
}
    var myList: [friend] = []

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SaveDataDelegate {
    
    
    //친구 목록
    var friendList: [NSManagedObject] = []
    //내 프로필

    // 목록
    private let sections: [String] = ["내 프로필","친구"]
    
    //section title
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    // section 개수
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    // cell 개수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return myList.count
        }else if section == 1{
            return friendList.count
        }else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "detail", sender: nil)
    }
 
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = friendTable.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath) as? TableViewCell else { return UITableViewCell() }
        if indexPath.section == 0{
            let my = myList[indexPath.row]
            cell.name.text = my.name
            cell.state.text = my.state
            guard let imageData = my.profile as? Data else {return UITableViewCell()}
            cell.profile?.image = UIImage(data: imageData)
            
        }else if indexPath.section == 1{
            let friend = friendList[indexPath.row]
            cell.profile?.adjustsImageSizeForAccessibilityContentSizeCategory = true
            cell.name.text = friend.value(forKey: "name") as? String
            cell.state.text = friend.value(forKey: "state") as? String
            if let imageData = friend.value(forKey: "profile") as? Data {
                cell.profile?.image = UIImage(data: imageData)
            }else{
                cell.profile?.image = UIImage(named: "기본")
            }
        }
   
        return cell
    }
    
    //core data 삭제
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let deleteEntity = friendList[indexPath.row]

            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
            
                    let managedContext = appDelegate.persistentContainer.viewContext
            
                    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Friend")
            fetchRequest.predicate = NSPredicate(format: "name = %@", deleteEntity.value(forKey: "name") as! CVarArg)
            
                    do{
                        let test = try managedContext.fetch(fetchRequest)
                        let objectToDelete = test[0] as! NSManagedObject
                        managedContext.delete(objectToDelete)
                        do{
                            try managedContext.save()
                            self.friendTable.reloadData()
                        } catch {
                            print(error)
                        }
                    } catch {
                        print(error)
                }
                
        }
    }


    @IBOutlet weak var friendTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        //내 카톡 프로필
        UserDefaults.standard.set(myImage, forKey: "myImage")
        UserDefaults.standard.set(myName, forKey: "myName")
        UserDefaults.standard.set(myState, forKey: "myState")
        let myProfile: friend = friend(profile: myImage, name: myName, state: myState)
        myList.append(myProfile)
        
        let kakaoCellNib = UINib(nibName: "TableViewCell", bundle: nil)
        self.friendTable.register(kakaoCellNib, forCellReuseIdentifier: "friendCell")
        self.friendTable.delegate = self
        self.friendTable.dataSource = self
        self.friendTable.rowHeight = UITableView.automaticDimension
        self.friendTable.estimatedRowHeight = 550.0
        
        
        }
        
    //내 프로필
    var myImage: Data? = UIImage(named: "농담곰")?.pngData()
    var myName: String? = "Rosa"
    var myState: String? = "hello"
    
    override func viewWillAppear(_ animated: Bool) {
        friendTable.reloadData()
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        
        let managedContext = appDelegate.persistentContainer.viewContext
                
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Friend")
        do{
            friendList = try managedContext.fetch(fetchRequest)
        } catch let error as NSError{
            print("save error")
        }
        
        if self.friendList.isEmpty{
            UserDefaults.standard.set(true,forKey: "empty")
        }else{
            UserDefaults.standard.set(false,forKey: "empty")
        }
        //ftiendList가 비어있다면
        if UserDefaults.standard.bool(forKey: "empty"){
                let alert = UIAlertController(title: "friend", message: "친구를 추가해주세요!", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "확인", style: .cancel)
                alert.addAction(cancelAction)
                self.present(alert, animated: true)
            }
        print(UserDefaults.standard.bool(forKey: "empty"))
        print(self.friendList)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "add"{
            let destination = segue.destination as! ViewController2
            destination.delegate = self
        }
        if segue.identifier == "detail"{
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
            
            let managedContext = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Friend")
            do{
                let friendList = try managedContext.fetch(fetchRequest)
                let seletedFriend = friendList[self.friendTable.indexPathForSelectedRow!.row]
                let name =  seletedFriend.value(forKey: "name")
                let state = seletedFriend.value(forKey: "state")
                let profile = seletedFriend.value(forKey: "profile")
                (segue.destination as! FriendViewController).detailData = friend(profile: profile as? Data, name: name as? String, state: state as? String)
            }catch let error as NSError{
                print("fetch error")
            }
            
        }
    }
    
    func save(data: friend){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        
        let entity = NSEntityDescription.entity(forEntityName: "Friend", in: managedContext)!
        
        let friend = NSManagedObject(entity: entity, insertInto: managedContext)
        
        friend.setValue(data.name, forKey: "name")
        friend.setValue(data.state, forKey: "state")
        friend.setValue(data.profile, forKey: "profile")
        
        do{
            try managedContext.save()
            friendList.append(friend)
        } catch let error as NSError{
            print("save error")
        }
        
    }
    
    //delete core data
//    func deleteFriend(name: String){
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
//
//        let managedContext = appDelegate.persistentContainer.viewContext
//
//        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Friend")
//        fetchRequest.predicate = NSPredicate(format: "name = %@", name)
//
//        do{
//            let test = try managedContext.fetch(fetchRequest)
//            let objectToDelete = test[0] as! NSManagedObject
//            managedContext.delete(objectToDelete)
//            do{
//                try managedContext.save()
//            } catch {
//                print(error)
//            }
//        } catch {
//            print(error)
//        }
//    }
//    func deleteData(){
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
//        let managedContext = appDelegate.persistentContainer.viewContext
//
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Friend")
//        fetchRequest.returnsObjectsAsFaults = false
//
//        do{
//            let result = try managedContext.fetch(fetchRequest)
//            for managedObject in result{
//                let managedObjectData:NSManagedObject = managedObject as! NSManagedObject
//                managedContext.delete(managedObjectData)
//            }
//        }catch let error as NSError{
//            print("delete error")
//        }
//    }
}

