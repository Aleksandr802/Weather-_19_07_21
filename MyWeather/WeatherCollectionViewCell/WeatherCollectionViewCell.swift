//
//  WeatherCollectionViewCell.swift
//  MyWeather
//
//  Created by Aleksandr Seminov on 16.07.2021.
//

import UIKit

class WeatherCollectionViewCell: UICollectionViewCell {

    static let identifier = "WeatherCollectionViewCell"

    static func nib() -> UINib {
        return UINib(nibName: "WeatherCollectionViewCell",
                     bundle: nil)
    }

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var tempLabel: UILabel!

    func configure(with model: Hourly) {
        let removeADecimal = String(format: "%.0f", model.temp)
        self.tempLabel.text = "\(removeADecimal)°"
        self.tempLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        let houlyDate = Date(timeIntervalSince1970: Double(model.dt))
        let hour = hourFormatter.string(from: houlyDate)
        self.timeLabel.text = hour
        
        self.iconImageView.contentMode = .scaleAspectFit
        
        let iconUrl = GetWeatherIcon.getIcon(icon: model.weather[0].icon)
        
        guard let url = URL(string: iconUrl) else { return }

        DispatchQueue.global().async {
            
            if let data = try? Data(contentsOf: url) {
                DispatchQueue.main.async {
                    
                    self.iconImageView.image = UIImage(data: data)
                }
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    private let hourFormatter: DateFormatter = {
        let hourFormatter = DateFormatter()
        hourFormatter.dateFormat = "HH:mm"
        return hourFormatter
    }()
}
