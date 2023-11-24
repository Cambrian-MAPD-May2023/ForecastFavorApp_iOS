//
//  TodayViewController.swift
//  ForecastFavorApp_iOS
//
//  Created by Daphne Rivera on 2023-11-08.
//

import UIKit

class TodayViewController: UIViewController, UISearchBarDelegate {
    
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var hourlyStackView: UIStackView!
    @IBOutlet weak var hourlyScrollView: UIScrollView!
    @IBOutlet weak var searchBar: UISearchBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self // Set the search bar delegate
        conditionLabel.text = "Current condition:"
        temperatureLabel.text = "Current temp: "
        humidityLabel.text = "Humidity: "
        windLabel.text = "Wind: "
        pressureLabel.text = "Pressure: "
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
                let forecastData = try await WeatherAPI_Helper.fetchForecastData(cityName: cityName, days: 1)
                    updateUI(with: weatherData)
                if let hourlyData = forecastData.forecast?.forecastday.first?.hour {
                    updateHourlyForecast(weatherData: hourlyData)
                }
            } catch {
                // Handle errors, perhaps by showing an alert with the error description
                print("Error fetching weather or forecast: \(error.localizedDescription)")
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
            cityLabel.text = searchBar.text
            conditionLabel.text = "\(weatherData.current.condition.text)"
            temperatureLabel.text = "\(weatherData.current.temp_c)°C"
            humidityLabel.text = "\(weatherData.current.humidity)%"
            windLabel.text = "\(weatherData.current.wind_kph) kph"
            pressureLabel.text = "\(weatherData.current.pressure_in) hPa"
            
            // Update hourly forecast
            if let hourlyData = weatherData.forecast?.forecastday.first?.hour {
                updateHourlyForecast(weatherData: hourlyData)
            }
        }
    }
        @MainActor
        private func updateHourlyForecast(weatherData: [HourlyForecast]) {
            // Clean up any existing views in the stack view
            hourlyStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            
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
