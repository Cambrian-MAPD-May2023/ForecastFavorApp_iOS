//
//  ThreeDayForecastViewController.swift
//  ForecastFavorApp_iOS
//
//  Created by Daphne Rivera on 2023-11-15.
//

import UIKit

class ThreeDayForecastViewController: UIViewController, UISearchBarDelegate {
    // Outlets for your UI components, assuming one set of labels for each day
    @IBOutlet weak var dayOneImageView: UIImageView!
    @IBOutlet weak var dayOneTemperatureLabel: UILabel!
    @IBOutlet weak var dayOneConditionLabel: UILabel!

    @IBOutlet weak var dayTwoImageView: UIImageView!
    @IBOutlet weak var dayTwoTemperatureLabel: UILabel!
    @IBOutlet weak var dayTwoConditionLabel: UILabel!

    @IBOutlet weak var dayThreeImageView: UIImageView!
    @IBOutlet weak var dayThreeTemperatureLabel: UILabel!
    @IBOutlet weak var dayThreeConditionLabel: UILabel!
    
    @IBOutlet weak var dayOneDateLabel: UILabel!
    @IBOutlet weak var dayTwoDateLabel: UILabel!
    @IBOutlet weak var dayThreeDateLabel: UILabel!


    @IBOutlet weak var searchBar: UISearchBar!
    // Additional outlets as needed...
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        // Initial UI setup - clear labels and image views
        clearForecastUI()
    }

    private func clearForecastUI() {
        // Set initial states for your labels and image views
        let labels = [dayOneTemperatureLabel, dayTwoTemperatureLabel, dayThreeTemperatureLabel,
                      dayOneConditionLabel, dayTwoConditionLabel, dayThreeConditionLabel, dayOneDateLabel, dayTwoDateLabel, dayThreeDateLabel]
        for label in labels {
            label?.text = ""
        }
        
        let imageViews = [dayOneImageView, dayTwoImageView, dayThreeImageView]
        for imageView in imageViews {
            imageView?.image = nil
        }
    }

    


    @MainActor
    private func updateUI(with forecastDays: [ForecastdayContainer]) {
        // Assuming forecastDays has at least 3 elements
        if forecastDays.count >= 3 {
            updateDayUI(day: forecastDays[0],
                        imageView: dayOneImageView,
                        temperatureLabel: dayOneTemperatureLabel,
                        conditionLabel: dayOneConditionLabel,
                        dateLabel: dayOneDateLabel)
            
            updateDayUI(day: forecastDays[1],
                        imageView: dayTwoImageView,
                        temperatureLabel: dayTwoTemperatureLabel,
                        conditionLabel: dayTwoConditionLabel,
                        dateLabel: dayTwoDateLabel)
            
            updateDayUI(day: forecastDays[2],
                        imageView: dayThreeImageView,
                        temperatureLabel: dayThreeTemperatureLabel,
                        conditionLabel: dayThreeConditionLabel,
                        dateLabel: dayThreeDateLabel)
        }
    }

    private func updateDayUI(day: ForecastdayContainer,
                             imageView: UIImageView,
                             temperatureLabel: UILabel,
                             conditionLabel: UILabel,
                             dateLabel: UILabel) {
        let minTemp = day.day.mintemp_c
        let maxTemp = day.day.maxtemp_c
        let conditionText = day.day.condition.text
        let iconURL = day.day.condition.icon
        let dateText = day.date
        
        // Update labels
        temperatureLabel.text = "High: \(maxTemp)°C, Low: \(minTemp)°C"
        conditionLabel.text = conditionText
        if let dayOfWeek = dayOfWeek(from: dateText) {
            dateLabel.text = dayOfWeek
        }

        // Fetch and update image
        Task {
            do {
                let imageData = try await WeatherAPI_Helper.fetchImageData(from: "https:\(iconURL)")
                if let image = UIImage(data: imageData) {
                    imageView.image = image
                }
            } catch {
                print("Error fetching image: \(error.localizedDescription)")
                // Handle image fetching errors, perhaps set a placeholder image
            }
        }
    }
    
    // MARK: - Date Formatting Utility
        func dayOfWeek(from dateString: String) -> String? {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd" // Adjust the date format to the format provided by your API
            
            if let date = dateFormatter.date(from: dateString) {
                dateFormatter.dateFormat = "EEEE" // Format to get the day of the week
                return dateFormatter.string(from: date)
            }
            return nil
        }
    
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
                    let forecastData = try await WeatherAPI_Helper.fetchForecastData(cityName: cityName, days: 3)
                    if let forecastDays = forecastData.forecast?.forecastday {
                        updateUI(with: forecastDays)
                    }
                } catch {
                    // Handle errors, perhaps by showing an alert with the error description
                    print("Error fetching forecast: \(error.localizedDescription)")
                }
            }
        }
}

