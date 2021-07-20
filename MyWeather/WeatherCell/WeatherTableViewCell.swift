//
//  WeatherTableViewCell.swift
//  MyWeather
//
//  Created by Aleksandr Seminov on 16.07.2021.
//

import UIKit

class WeatherTableViewCell: UITableViewCell {

    @IBOutlet var dayLabel: UILabel!
    @IBOutlet var highTempLabel: UILabel!
    @IBOutlet var lowTempLabel: UILabel!
    @IBOutlet var iconImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
        
    static let identifier = "WeatherTableViewCell"

    static func nib() -> UINib {
        return UINib(nibName: "WeatherTableViewCell",
                     bundle: nil)
    }
    
    func configure(with model: Daily) {
        self.highTempLabel.textAlignment = .center
        self.lowTempLabel.textAlignment = .center
        self.lowTempLabel.text = "\(Int(model.temp.min))°"
        self.highTempLabel.text = "\(Int(model.temp.max))°"
        self.dayLabel.text = getDayForDate(Date(timeIntervalSince1970: Double(model.dt)))
        self.iconImageView.contentMode = .scaleAspectFit
        
        var iconUrl = ""
        let urlString = "https://openweathermap.org/img/wn/"
        
        switch model.weather[0].icon {
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
        
        guard let url = URL(string: iconUrl) else { return }

        DispatchQueue.global().async {
            // Fetch Image Data
            if let data = try? Data(contentsOf: url) {
                DispatchQueue.main.async {
                    // Create Image and Update Image View
                    self.iconImageView.image = UIImage(data: data)
                }
            }
        }
    }

    func getDayForDate(_ date: Date?) -> String {
        guard let inputDate = date else {
            return ""
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE" // Monday
        return formatter.string(from: inputDate)
    }
    
}
