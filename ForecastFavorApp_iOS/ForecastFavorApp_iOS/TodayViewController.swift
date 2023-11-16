//
//  TodayViewController.swift
//  ForecastFavorApp_iOS
//
//  Created by Daphne Rivera on 2023-11-08.
//

import UIKit

class TodayViewController: UIViewController, UISearchBarDelegate {


    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var feelsLikeLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var cloudLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var precipLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self // Set the search bar delegate
        conditionLabel.text = "Current condition:"
        temperatureLabel.text = "Current temp: "
        feelsLikeLabel.text = "Feels like: "
        humidityLabel.text = "Humidity: "
        cloudLabel.text = "Cloud: "
        windLabel.text = "Wind: "
        pressureLabel.text = "Pressure: "
        precipLabel.text = "Precipitation: "
        // Additional setup if needed
    }

    // UISearchBarDelegate method to handle the search action
       func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
           searchBar.resignFirstResponder() // Dismiss the keyboard

           guard let cityName = searchBar.text, !cityName.isEmpty else {
               // Optionally, inform the user that the search bar is empty
               return
           }

           fetchWeatherForCity(cityName)
       }

       private func fetchWeatherForCity(_ cityName: String) {
           Task {
               do {
                   let weatherData = try await WeatherAPI_Helper.fetchWeatherData(cityName: cityName)
                   updateUI(with: weatherData)
               } catch {
                   // Handle errors, perhaps by showing an alert with the error description
                   print("Error fetching weather: \(error.localizedDescription)")
               }
           }
       }

    // This should be marked with @MainActor if not already, to ensure it runs on the main thread.
    @MainActor
    private func updateUI(with weatherData: WeatherResponse) {
        Task {
            do {
                let iconURLString = "https:\(weatherData.current.condition.icon)"
                let imageData = try await WeatherAPI_Helper.fetchImageData(from: iconURLString)
                if let image = UIImage(data: imageData) {
                    self.conditionImageView.image = image
                }
            } catch {
                print("Failed to fetch image: \(error)")
                // Handle errors, such as setting a placeholder image
            }
            
            // Since this is already on the main thread, you can update the UI directly
            conditionLabel.text = "Current condition: \(weatherData.current.condition.text)"
            temperatureLabel.text = "Current temp: \(weatherData.current.temp_c)°C"
            feelsLikeLabel.text = "Feels like: \(weatherData.current.feelslike_c)°C"
            humidityLabel.text = "Humidity: \(weatherData.current.humidity)%"
            cloudLabel.text = "Cloud: \(weatherData.current.cloud)%"
            windLabel.text = "Wind: \(weatherData.current.wind_kph) kph"
            pressureLabel.text = "Pressure: \(weatherData.current.pressure_in) in"
            precipLabel.text = "Precipitation: \(weatherData.current.precip_in) in"
            // ... update other labels ...
        }
    }

    
  
}
