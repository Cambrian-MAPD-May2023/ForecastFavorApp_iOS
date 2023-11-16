//
//  WeatherAPI.swift
//  ForecastFavorApp_iOS
//
//  Created by Daphne Rivera on 2023-11-08.
//

import Foundation

// The structure for the "location" part of the response
struct Location: Codable {
    let name: String
    let region: String
    let country: String
    let lat: Double
    let lon: Double
    let tz_id: String
    let localtime_epoch: Int
    let localtime: String
}

// The structure for the "condition" part of the "current" response
struct Condition: Codable {
    let text: String
    let icon: String
    let code: Int
}

// The structure for the "current" part of the response
struct Current: Codable {
    let last_updated_epoch: Int
    let last_updated: String
    let temp_c: Double
    let temp_f: Double
    let is_day: Int
    let condition: Condition
    let wind_mph: Double
    let wind_kph: Double
    let wind_degree: Int
    let wind_dir: String
    let pressure_mb: Double
    let pressure_in: Double
    let precip_mm: Double
    let precip_in: Double
    let humidity: Int
    let cloud: Int
    let feelslike_c: Double
    let feelslike_f: Double
    let vis_km: Double
    let vis_miles: Double
    let uv: Double
    let gust_mph: Double
    let gust_kph: Double
}

// The top-level structure that includes both "location" and "current" parts
struct WeatherResponse: Codable {
    let location: Location
    let current: Current
    let forecast: Forecast?

}

// The structure for the "day" part of the "forecastday" response
struct ForecastDay: Codable {
    let maxtemp_c: Double
    let mintemp_c: Double
    let avgtemp_c: Double
    let maxwind_kph: Double
    let totalprecip_mm: Double
    let avgvis_km: Double
    let avghumidity: Double
    let condition: Condition
    let uv: Double
    let daily_chance_of_rain: Int
    let daily_chance_of_snow: Int
}

// The structure for the "hour" part of the "forecastday" response
struct HourlyForecast: Codable {
    let time_epoch: Int
    let time: String
    let temp_c: Double
    let is_day: Int
    let condition: Condition
    let wind_kph: Double
    let wind_degree: Int
    let wind_dir: String
    let pressure_mb: Double
    let precip_mm: Double
    let humidity: Int
    let cloud: Int
    let feelslike_c: Double
    let chance_of_rain: Int
    let chance_of_snow: Int
    let gust_kph: Double
   
}

// Now include the hourly forecast in the ForecastdayContainer structure
struct ForecastdayContainer: Codable {
    let date: String
    let day: ForecastDay
    let hour: [HourlyForecast] // Add this line to include hourly data
   
}


// The structure for the "forecast" part of the response
struct Forecast: Codable {
    let forecastday: [ForecastdayContainer]
}
