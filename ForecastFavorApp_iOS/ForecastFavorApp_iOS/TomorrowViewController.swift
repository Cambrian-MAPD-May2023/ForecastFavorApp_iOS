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
    @IBOutlet weak var hourlyStackView: UIStackView!
    // ... other labels for additional forecast details

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self // Set the search bar delegate
        conditionLabel.text = "Condition: "
        temperatureLabel.text = "Current temp: "
        precipitationLabel.text = "Precipitation: "
        fetchWeatherForCity("Sudbury")
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
                   let forecastData = try await WeatherAPI_Helper.fetchForecastData(cityName: cityName, days: 2)
                   // Index should be 0 for the first element which is tomorrow's forecast
                   if let tomorrowForecast = forecastData.forecast?.forecastday[1] {
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
        
        // Update the hourly forecast
        updateHourlyForecast(weatherData: forecastDay.hour)
    }
    
    @MainActor
       private func updateHourlyForecast(weatherData: [HourlyForecast]) {
           // Remove all existing hourly views
           hourlyStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

           // Add new hourly views
           for hour in weatherData {
               let hourView = createHourlyView(for: hour)
               hourlyStackView.addArrangedSubview(hourView)
           }
       }
    
    private func createHourlyView(for hour: HourlyForecast) -> UIView {
        let hourView = UIView()
        hourView.translatesAutoresizingMaskIntoConstraints = false
        
        // Create a vertical stack view
        let verticalStackView = UIStackView()
        verticalStackView.axis = .vertical
        verticalStackView.alignment = .fill
        verticalStackView.distribution = .equalSpacing
        verticalStackView.spacing = 4
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let timeLabel = UILabel()
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.text = formatTime(hour.time)
        
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        
        let tempLabel = UILabel()
        tempLabel.translatesAutoresizingMaskIntoConstraints = false
        tempLabel.text = "\(hour.temp_c)°C"
        
        let rainProbLabel = UILabel()
        rainProbLabel.translatesAutoresizingMaskIntoConstraints = false
        rainProbLabel.text = "Rain: \(hour.chance_of_rain)%"
        
        // Add each label and image view to the vertical stack view
        verticalStackView.addArrangedSubview(timeLabel)
        verticalStackView.addArrangedSubview(imageView)
        verticalStackView.addArrangedSubview(tempLabel)
        verticalStackView.addArrangedSubview(rainProbLabel)
        
        // Assuming you want each hourView to be 80 points wide:
           let hourViewWidth = 80
        hourView.widthAnchor.constraint(equalToConstant: CGFloat(hourViewWidth)).isActive = true

        // Add the vertical stack view to the hourView
        hourView.addSubview(verticalStackView)
        
        // Define constraints
        NSLayoutConstraint.activate([
            verticalStackView.leadingAnchor.constraint(equalTo: hourView.leadingAnchor),
            verticalStackView.trailingAnchor.constraint(equalTo: hourView.trailingAnchor),
            verticalStackView.topAnchor.constraint(equalTo: hourView.topAnchor),
            verticalStackView.bottomAnchor.constraint(equalTo: hourView.bottomAnchor)
        ])
        // Fetch and set the image
        Task {
            do {
                let imageData = try await WeatherAPI_Helper.fetchImageData(from: hour.condition.icon)
                DispatchQueue.main.async {
                    imageView.image = UIImage(data: imageData)
                }
            } catch {
                print("Failed to fetch image for hour: \(error)")
                // Handle errors, such as setting a placeholder image
            }
        }
        
        return hourView
    }
    
    private func formatTime(_ timeString: String) -> String {
        // Assuming the time string is in the format "yyyy-MM-dd HH:mm"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        if let date = dateFormatter.date(from: timeString) {
            dateFormatter.dateFormat = "ha" // Example format: 3PM, 4AM, etc.
            return dateFormatter.string(from: date)
        } else {
            return timeString // Or handle the error appropriately
        }
    }
    
    
   
    
  
    
}
