//
//  weatherViewController.swift
//  KakaoClone
//
//  Created by 이진하 on 2020/04/27.
//  Copyright © 2020 이진하. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireObjectMapper
import ObjectMapper
import SwiftyJSON


class Post: Mappable{
    var location:String = "" //위치
    var weather:JSON = []
    var main:JSON = []
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        location <- map["name"]
        weather <- map["weather"]
        main <- map["main"]
    }
}



class weatherViewController: UIViewController {

    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var temp: UILabel!
    @IBOutlet weak var main: UILabel!
    

    
    override func viewDidLoad() {

        Alamofire.request("https://api.openweathermap.org/data/2.5/weather?lat=37.566535&lon=126.977969&apiKey=05160b00e841f5984c23ee39056e664d").responseObject { (response: DataResponse<Post>) in
            if let value = response.result.value{
                self.location.text = value.location
                self.main.text = value.weather[0]["main"].stringValue
                print( value.main["temp"])
                let temp:Double = (value.main["temp"].doubleValue - 273)
                self.temp.text = String(format: "%f",temp)+"C"
                self.weatherIcon.image = UIImage(named: value.weather[0]["main"].stringValue)
        }
        super.viewDidLoad()

    }
    
    }
}
