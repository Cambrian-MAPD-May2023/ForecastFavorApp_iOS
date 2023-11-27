//
//  TodayViewController.swift
//  ForecastFavorApp_iOS
//
//  Created by Daphne Rivera on 2023-11-08.
//

import UIKit
// TodayViewController is responsible for displaying the current weather and hourly forecast.
class TodayViewController: UIViewController, UISearchBarDelegate {
    // MARK: - Outlets
    // Outlets connect UI elements from the storyboard to the code.
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
    
    // MARK: - View Lifecycle
        // viewDidLoad is called after the view controller's view is loaded into memory.
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self // Set the search bar delegate
        conditionLabel.text = "Current condition:"
        temperatureLabel.text = "Current temp: "
        humidityLabel.text = "Humidity: "
        windLabel.text = "Wind: "
        pressureLabel.text = "Pressure: "
    }
    
    // MARK: - UISearchBarDelegate
    // searchBarSearchButtonClicked is called when the user taps the search button on the keyboard.
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder() // Dismiss the keyboard
        
        guard let cityName = searchBar.text, !cityName.isEmpty else {
            // Optionally, inform the user that the search bar is empty
            return
        }
        
        fetchWeatherForCity(cityName)
    }
    // MARK: - Data Fetching
    // fetchWeatherForCity initiates fetching of weather and forecast data for a given city.
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
    // MARK: - UI Updates
       // updateUI updates the UI with the current weather data.
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
    // updateHourlyForecast updates the hourly forecast stack view with new data.
        @MainActor
        private func updateHourlyForecast(weatherData: [HourlyForecast]) {
            // Clean up any existing views in the stack view
            hourlyStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            
            for hour in weatherData {
                let hourView = createHourlyView(for: hour)
                hourlyStackView.addArrangedSubview(hourView)
            }
        }
    // createHourlyView creates a view representing a single hour's forecast.
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
    // formatTime converts a time string to the desired format for display.
        private func formatTime(_ timeString: String) -> String {
            
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
