//
//  TomorrowViewController.swift
//  ForecastFavorApp_iOS
//
//  Created by Daphne Rivera on 2023-11-15.
//

import UIKit

class TomorrowViewController: UIViewController,  UISearchBarDelegate  {

    // Outlets for your UI components

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var precipitationLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    // ... other labels for additional forecast details

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self // Set the search bar delegate
        conditionLabel.text = "Condition: "
        temperatureLabel.text = "Current temp: "
        precipitationLabel.text = "Precipitation: "
        // Set initial states for your labels, image views, etc.
    }
    // This method is called when the user taps the search button on the keyboard
       func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
           searchBar.resignFirstResponder() // Hide the keyboard

           guard let cityName = searchBar.text, !cityName.isEmpty else {
               // Optionally, inform the user that the search bar is empty
               return
           }

           fetchWeatherForCity(cityName)
       }

       private func fetchWeatherForCity(_ cityName: String) {
           Task {
               do {
                   let forecastData = try await WeatherAPI_Helper.fetchForecastData(cityName: cityName, days: 1)
                   // Index should be 0 for the first element which is tomorrow's forecast
                   if let tomorrowForecast = forecastData.forecast?.forecastday.first {
                       await updateUI(with: tomorrowForecast)
                   }
               } catch {
                   // Handle errors, perhaps by showing an alert with the error description
                   print("Error fetching forecast: \(error.localizedDescription)")
               }
           }
       }
    // Ensure updateUI is marked as async to perform async operations
    @MainActor
    private func updateUI(with forecastDay: ForecastdayContainer) async {
        // Update the UI with the details from forecastDay
        let condition = forecastDay.day.condition
        cityLabel.text = searchBar.text
        dateLabel.text = forecastDay.date
        conditionLabel.text = "\(condition.text)"
        temperatureLabel.text = "\(forecastDay.day.maxtemp_c)°C ↑,\(forecastDay.day.mintemp_c)°C ↓"
        precipitationLabel.text = "\(forecastDay.day.totalprecip_mm)% chance of precipitation"
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
