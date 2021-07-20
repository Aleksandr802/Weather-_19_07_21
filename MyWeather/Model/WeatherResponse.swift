//
//  WeatherModel.swift
//  MyWeather
//
//  Created by Aleksandr Seminov on 20.07.2021.
//

import Foundation

struct WeatherResponse: Codable {
    let lat: Float
    let lon: Float
    let timezone: String
    let current: CurrentWeather
    let hourly: [Hourly]
    let daily: [Daily]
    let timezone_offset: Float
}

struct CurrentWeather: Codable {
    let dt: Int
    let temp: Double
    let weather: [Weather]
}

struct Weather: Codable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}

struct Hourly: Codable {
    let dt: Int
    let temp: Double
    let weather: [Weather]
}

struct Daily: Codable {
    let dt: Int
    let temp: DailyTemp
    let weather: [Weather]
}

struct DailyTemp: Codable {
    let min: Double
    let max: Double
}

struct GetWeatherIcon {

    static func getIcon(icon: String ) -> String {
        var iconUrl = ""
        let urlString = "https://openweathermap.org/img/wn/"
        
        switch icon {
        case "01d": iconUrl = "\(urlString)01d@2x.png"
        case "02d": iconUrl = "\(urlString)02d@2x.png"
        case "03d": iconUrl = "\(urlString)03d@2x.png"
        case "04d": iconUrl = "\(urlString)04d@2x.png"
        case "09d": iconUrl = "\(urlString)09d@2x.png"
        case "10d": iconUrl = "\(urlString)10d@2x.png"
        case "11d": iconUrl = "\(urlString)11d@2x.png"
        case "13d": iconUrl = "\(urlString)13d@2x.png"
        case "50d": iconUrl = "\(urlString)50d@2x.png"
        default:
            iconUrl = "\(urlString)01d@2x.png"
        }
        return iconUrl
    }
}

extension CLPlacemark {
    var city: String? { locality }
    var country: String? { locality }
}

extension CLLocation {
    func placemark(completion: @escaping (_ placemark: CLPlacemark?, _ error: Error?) -> ()) {
        CLGeocoder().reverseGeocodeLocation(self) { completion($0?.first, $1) }
    }
}
