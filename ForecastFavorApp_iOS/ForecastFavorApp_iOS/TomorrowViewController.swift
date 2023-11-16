//
//  TomorrowViewController.swift
//  ForecastFavorApp_iOS
//
//  Created by Daphne Rivera on 2023-11-15.
//

import UIKit

class TomorrowViewController: UIViewController {

    // Outlets for your UI components
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var precipitationLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var chanceOfRainLabel: UILabel!
    @IBOutlet weak var chanceOfSnowLabel: UILabel!
    @IBOutlet weak var uvLabel: UILabel!
    // ... other labels for additional forecast details

    override func viewDidLoad() {
        super.viewDidLoad()
        conditionLabel.text = ""
        temperatureLabel.text = "Current temp: "
        chanceOfRainLabel.text = "Chance of rain: "
        humidityLabel.text = "Humidity: "
        precipitationLabel.text = "Precipitation: "
        windLabel.text = "Wind: "
        chanceOfSnowLabel.text = "Chance of Snow: "
        uvLabel.text = "UV Index: "
        // Set initial states for your labels, image views, etc.
    }

    @IBAction func fetchTomorrowForecastTapped(_ sender: Any) {
        guard let location = locationTextField.text, !location.isEmpty else {
            // Handle empty text field case
            return
        }
        
        Task {
            do {
                // Asynchronously fetch the forecast data for the next day
                let forecastData = try await WeatherAPI_Helper.fetchForecastData(cityName: location, days: 3)
                // Make sure to safely unwrap the array element to avoid potential index out of range error
                if let tomorrowForecast = forecastData.forecast?.forecastday[1] {
                    await updateUI(with: tomorrowForecast)
                }
            } catch {
                // Handle errors, perhaps show an alert to the user
            }
        }
    }

    // Ensure updateUI is marked as async to perform async operations
    @MainActor
    private func updateUI(with forecastDay: ForecastdayContainer) async {
        // Update the UI with the details from forecastDay
        let condition = forecastDay.day.condition
        conditionLabel.text = condition.text
        temperatureLabel.text = "High: \(forecastDay.day.maxtemp_c)°C, Low: \(forecastDay.day.mintemp_c)°C"
        windLabel.text = "Wind: \(forecastDay.day.maxwind_kph) kph"
        precipitationLabel.text = "Precipitation: \(forecastDay.day.totalprecip_mm) mm"
        humidityLabel.text = "Humidity: \(forecastDay.day.avghumidity)%"
        chanceOfRainLabel.text = "Chance of Rain: \(forecastDay.day.daily_chance_of_rain)%"
        chanceOfSnowLabel.text = "Chance of Snow: \(forecastDay.day.daily_chance_of_snow)%"
        uvLabel.text = "UV Index: \(forecastDay.day.uv)"
        // Fetch and set the condition image
        do {
            let iconURLString = "https:\(condition.icon)"
            let imageData = try await WeatherAPI_Helper.fetchImageData(from: iconURLString)
            if let image = UIImage(data: imageData) {
                self.conditionImageView.image = image
            }
        } catch {
            print("Failed to fetch image: \(error)")
            // Handle image fetching errors, perhaps set a placeholder image
        }
    }

    
}
