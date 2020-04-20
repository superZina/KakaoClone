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

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SaveDataDelegate {
    
//    @IBAction func addFriend(_ sender: Any) {
//        let alert = UIAlertController(title: "friend", message: "추가할 친구의 이름과 상태메세지를 입력하세요", preferredStyle: .alert)
//        let saveAction = UIAlertAction(title: "Save", style: .default) { [unowned self] action in
//            guard let nameField = alert.textFields?.first,
//                 let nameToSave = nameField.text else {
//                   return
//            }
//            
//            self.save(name: nameToSave)
//            self.friendTable.reloadData()
//        }
//        
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
//        
//        alert.addTextField()
//        alert.addAction(saveAction)
//        alert.addAction(cancelAction)
//        
//        present(alert, animated: true)
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.friendList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = friendTable.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath) as? TableViewCell else { return UITableViewCell() }
        let friend = friendList[indexPath.row]
        
//        cell.porfile.image = UIImage(contentsOfFile: friend.value(forKey: "profile") as! String)
        cell.name.text = friend.value(forKey: "name") as? String
        cell.state.text = friend.value(forKey: "state") as? String
//        let imgName = friend.value(forKey: "name") as? String
        let imageData = friend.value(forKey: "profile") as? Data
//        cell.profile?.image = UIImage(
        return cell
    }
    
    //core data 삭제
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let deleteEntity = friendList[indexPath.row]
            let deleteName = deleteEntity.value(forKey: "name")
            deleteFriend(name: deleteName as! String)
        }
    }
    
    var friendList: [NSManagedObject] = []

    @IBOutlet weak var friendTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let kakaoCellNib = UINib(nibName: "TableViewCell", bundle: nil)
        self.friendTable.register(kakaoCellNib, forCellReuseIdentifier: "friendCell")
        self.friendTable.delegate = self
        self.friendTable.dataSource = self
    }
    
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
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "add"{
            let destination = segue.destination as! ViewController2
            destination.delegate = self
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
    func deleteFriend(name: String){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Friend")
        fetchRequest.predicate = NSPredicate(format: "name = %@", name)
        
        do{
            let test = try managedContext.fetch(fetchRequest)
            let objectToDelete = test[0] as! NSManagedObject
            managedContext.delete(objectToDelete)
            do{
                try managedContext.save()
            } catch {
                print(error)
            }
        } catch {
            print(error)
        }
    }
}

