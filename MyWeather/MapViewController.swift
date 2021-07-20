//
//  MapViewController.swift
//  MyWeather
//
//  Created by Aleksandr Seminov on 19.07.2021.
//

import Foundation
import GoogleMaps

class MapViewController: UIViewController {
    
    var location = CLLocation()
    var currentLocation = CLLocationCoordinate2D()
    var locationManager = CLLocationManager()
    var preciseLocationZoomLevel: Float = 15.0
    var approximateLocationZoomLevel: Float = 10.0
    var geocoder = GMSGeocoder()
    
    @IBOutlet weak var mapView: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        let camera = GMSCameraPosition.camera(withLatitude: locationManager.location?.coordinate.latitude ?? 0.0, longitude: locationManager.location?.coordinate.longitude ?? 0.0, zoom: 6.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        view = mapView
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: locationManager.location?.coordinate.latitude ?? 0, longitude: locationManager.location?.coordinate.longitude ?? 0)
        
        marker.title = "Zaporizhzhia"
        marker.snippet = "Ukraine"
        marker.map = mapView
        mapView.settings.myLocationButton = true
        
    }
}

// MARK: - CLLocationManagerDelegate

extension MapViewController: CLLocationManagerDelegate {
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
            mapView.isMyLocationEnabled = true
            mapView.settings.myLocationButton = true
        }
    }

    private func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.first {
            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
            locationManager.stopUpdatingLocation()
        }
    }
}
