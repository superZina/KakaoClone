//
//  boxOfficeViewController.swift
//  KakaoClone
//
//  Created by 이진하 on 2020/04/27.
//  Copyright © 2020 이진하. All rights reserved.
//
import UIKit
import ObjectMapper
import Alamofire
import AlamofireObjectMapper
import Foundation
import SwiftyJSON

struct Movie {
    var salesAmt: String!
}
extension Movie: Mappable {
    init?(map: Map) {
        
    }
    mutating func mapping(map: Map) {
        salesAmt <- map["salesAmt"]
    }
}

struct MovieList {
    var result: [Movie]!
}
extension MovieList: Mappable {
    init?(map: Map) {
        
    }
    mutating func mapping(map: Map) {
        result <- map["boxOfficeResult"]
    }
}

struct movie{
    var rank:String
    var mvName:String
    var audiAcc:String
    init(rank: String, mvName:String, audiAcc:String){
        self.rank = rank
        self.mvName = mvName
        self.audiAcc = audiAcc
    }
}
var mvList: [movie] = []

class boxOfficeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var mvTableView: UITableView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mvTableView.delegate = self
        self.mvTableView.dataSource = self
        self.mvTableView.rowHeight = UITableView.automaticDimension
        self.mvTableView.estimatedRowHeight = 550.0
        let boxOfficeNib = UINib(nibName: "boxOfficeCell", bundle: nil)
        self.mvTableView.register(boxOfficeNib, forCellReuseIdentifier: "boxOfficeCell")
        var mv:JSON = []
        Alamofire.request("https://www.kobis.or.kr/kobisopenapi/webservice/rest/boxoffice/searchDailyBoxOfficeList.json?key=430156241533f1d058c603178cc3ca0e&targetDt=20200420")
            .responseObject { (response: DataResponse<Movie>) in
            if let value = response.result.value{
                mv = value.boxOfficeResult["dailyBoxOfficeList"]
                for i in 0...9{
                    mvList.append(movie(rank: mv[i]["rank"].stringValue, mvName:mv[i]["movieNm"].stringValue , audiAcc:mv[i]["audiAcc"].stringValue ))
                    
                }
                self.mvTableView.reloadData()
            }
            print(mv)
        }
        print(mv)
    }
    override func viewWillAppear(_ animated: Bool) {
        self.mvTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mvList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "boxOfficeCell", for: indexPath) as? boxOfficeCell else {return UITableViewCell()}
        cell.rank.text = mvList[indexPath.row].rank
        cell.movieNm.text = mvList[indexPath.row].mvName
        cell.audiAcc.text = mvList[indexPath.row].audiAcc
        return cell
    }
}
func getData(URL: String,comlete: (_ reviews: JSON)->Void){
    
}
