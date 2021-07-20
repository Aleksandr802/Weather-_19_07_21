//
//  ViewController.swift
//  MyWeather
//
//  Created by Aleksandr Seminov on 16.07.2021.
//

import UIKit
import CoreLocation

protocol WeatherResponseDelegate {
    func didUpdateWeather(weather: WeatherResponse)
}

class WeatherViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {

    @IBOutlet var table: UITableView!
    
    var delegate: WeatherResponseDelegate?
    var models = [Daily]()
    var hourlyModels = [Hourly]()

    let locationManager = CLLocationManager()
    var location: CLLocation?
    var current: CurrentWeather?
    
    private var long: Double?
    private var lat: Double?
    var cityOfLocation = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        table.register(HourlyTableViewCell.nib(), forCellReuseIdentifier: HourlyTableViewCell.identifier)
        table.register(WeatherTableViewCell.nib(), forCellReuseIdentifier: WeatherTableViewCell.identifier)

        table.delegate = self
        table.dataSource = self

        table.backgroundColor = #colorLiteral(red: 0.2858207822, green: 0.5610625148, blue: 0.8834721446, alpha: 1)
        view.backgroundColor = #colorLiteral(red: 0.285818547, green: 0.5648732185, blue: 0.8869404197, alpha: 1)

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupLocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    func setupLocation() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !locations.isEmpty, location == nil  {
            location = locations.first
            locationManager.stopUpdatingLocation()
            requestWeatherForLocation()
        }
    }

    func requestWeatherForLocation() {
        guard let currentLocation = location else {
            return
        }
        
        long = currentLocation.coordinate.longitude
        lat = currentLocation.coordinate.latitude
        location = CLLocation(latitude: lat ?? 47.8561438, longitude: long ?? 35.0352698)
        location?.placemark { placemark, error in
            guard let placemark = placemark else {
                print("Error:", error ?? "nil")
                return
            }
            self.cityOfLocation = placemark.city ?? "Zaporizhzhia"
        }

        let url = "https://api.openweathermap.org/data/2.5/onecall?exclude=minutely&appid=d9eecd0f61ca912669020a911bb85fc8&units=metric&lat=\(lat ?? 47.8561438)&lon=\(long ?? 35.0352698)"
        print("URL: \(url)")

        URLSession.shared.dataTask(with: URL(string: url)!, completionHandler: { data, response, error in

            guard let data = data, error == nil else {
                print("something went wrong")
                return
            }
            
            var json: WeatherResponse?
            do {
                json = try JSONDecoder().decode(WeatherResponse.self, from: data)
            }
            catch {
                print("error: \(error)")
            }

            guard let result = json else {
                return
            }

            let entries = result.daily

            self.models.append(contentsOf: entries)

            let current = result.current
            self.current = current

            self.hourlyModels = result.hourly

            DispatchQueue.main.async {
                self.table.reloadData()

                self.table.tableHeaderView = self.createTableHeader()
            }

        }).resume()
    }

    func createTableHeader() -> UIView {
        let headerVIew = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.width))

        headerVIew.backgroundColor = #colorLiteral(red: 0.2858207822, green: 0.5610625148, blue: 0.8834721446, alpha: 1)

        let locationLabel = UILabel(frame: CGRect(x: 10, y: 10, width: view.frame.size.width-20, height: headerVIew.frame.size.height/5))
        let weatherNowIcon = UIImageView(frame: CGRect(x: 10, y: 20+locationLabel.frame.size.height, width: view.frame.size.width-20, height: headerVIew.frame.size.height/3))
        let tempLabel = UILabel(frame: CGRect(x: 10, y: 20+locationLabel.frame.size.height+weatherNowIcon.frame.size.height, width: view.frame.size.width-20, height: headerVIew.frame.size.height/5))
        let mapButton = UIButton(frame: CGRect(x: 10, y: 20+locationLabel.frame.size.height+weatherNowIcon.frame.size.height+tempLabel.frame.size.height, width: view.frame.size.width-20, height: headerVIew.frame.size.height/5))

        headerVIew.addSubview(locationLabel)
        headerVIew.addSubview(tempLabel)
        headerVIew.addSubview(weatherNowIcon)
        headerVIew.addSubview(mapButton)

        tempLabel.textAlignment = .center
        locationLabel.textAlignment = .center
        weatherNowIcon.contentMode = .scaleAspectFit
        
        let iconUrl = GetWeatherIcon.getIcon(icon: current?.weather[0].icon ?? "01d")

        guard let url = URL(string: iconUrl) else { return UIView()}

        DispatchQueue.global().async {
            
            if let data = try? Data(contentsOf: url) {
                DispatchQueue.main.async {
                    
                    weatherNowIcon.image = UIImage(data: data)
                }
            }
        }

        locationLabel.text = cityOfLocation
        locationLabel.font = UIFont(name: "Helvetica-Bold", size: 22)
        locationLabel.numberOfLines = 2
        locationLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        

        guard let currentWeather = self.current else {
            return UIView()
        }
        
        let removeADecimal = String(format: "%.0f", currentWeather.temp)
        tempLabel.text = "\(removeADecimal)°"
        tempLabel.font = UIFont(name: "Helvetica-Bold", size: 32)
        tempLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        mapButton.setImage(UIImage(named: "myLocationWhite"), for: .normal)
        mapButton.addTarget(self, action: #selector(mapButtonTupped(_:)), for: .touchUpInside)
        
        return headerVIew
    }

    @IBAction func mapButtonTupped(_ sender: AnyObject) {

        self.performSegue(withIdentifier: "Map", sender: nil)

    }
    
    // Table

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            // 1 cell that is collectiontableviewcell
            return 1
        }
        // return models count
        return models.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: HourlyTableViewCell.identifier, for: indexPath) as! HourlyTableViewCell
            cell.configure(with: hourlyModels)
            cell.backgroundColor = #colorLiteral(red: 0.3540199399, green: 0.6251620054, blue: 0.9420546889, alpha: 1)
            return cell
        }

        // Continue
        let cell = tableView.dequeueReusableCell(withIdentifier: WeatherTableViewCell.identifier, for: indexPath) as! WeatherTableViewCell
        cell.configure(with: models[indexPath.row])
        cell.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

}
