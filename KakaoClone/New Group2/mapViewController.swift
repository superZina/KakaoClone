//
//  weatherViewController.swift
//  KakaoClone
//
//  Created by 이진하 on 2020/04/26.
//  Copyright © 2020 이진하. All rights reserved.
//

import UIKit
import GoogleMaps
import MapKit

class mapViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func loadView() {
        let lat: Double = 37.566535
        let lon:Double = 126.977969
        let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: lon, zoom: 6.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero ,camera: camera)
               mapView.isMyLocationEnabled = true
               view = mapView
               
               // Creates a marker in the center of the map.
               let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: lat, longitude: lon)
               marker.title = "Seoul"
               marker.snippet = "Republic of Korea"
               marker.map = mapView
    }
}
