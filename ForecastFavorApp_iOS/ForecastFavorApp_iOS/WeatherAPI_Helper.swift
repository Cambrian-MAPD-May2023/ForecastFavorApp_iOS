//
//  WeatherAPI_Helper.swift
//  ForecastFavorApp_iOS
//
//  Created by Daphne Rivera on 2023-11-08.
//


import Foundation

enum WeatherAPI_Errors: Error {
    case cannotConvertStringToURL
    case cannotCreateURLComponent
    case dataFetchingError(Error)
}

actor WeatherAPI_Helper {
    private static let baseURL = "https://api.weatherapi.com/v1/"
    private static let apiKey = "bcea99f817174902bdc03259230311"
    private static let decoder = JSONDecoder()
    private static let cache: NSCache<NSString, CacheEntryObject> = NSCache()



    private static func fetch(urlString: String) async throws -> Data {
        guard let url = URL(string: urlString) else {
            throw WeatherAPI_Errors.cannotConvertStringToURL
        }
        
        if let cached = cache[url] {
                    switch cached {
                    case let .inProgress(task):
                        return try await task.value
                    case let .ready(data):
                        return data
                    }
                }
                
                print(urlString)


        let task = Task {
            let (data, _) = try await URLSession.shared.data(from: url)
            return data
        }
        
        // ... (Caching logic)
        cache[url] = .inProgress(task)

        do {
            let data = try await task.value
            cache[url] = .ready(data)
            return data
        } catch {
            cache[url] = nil
            throw WeatherAPI_Errors.dataFetchingError(error)
        }
    }
    
    public static func fetchWeatherData(cityName: String) async throws -> WeatherResponse {
        guard var urlComponents = URLComponents(string: "\(baseURL)current.json") else {
            throw WeatherAPI_Errors.cannotCreateURLComponent
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "q", value: cityName),
            URLQueryItem(name: "aqi", value: "no")
        ]

        guard let urlString = urlComponents.string else {
            throw WeatherAPI_Errors.cannotCreateURLComponent
        }

        do {
            let data = try await fetch(urlString: urlString)
            let weatherResponse = try decoder.decode(WeatherResponse.self, from: data)
            return weatherResponse
        } catch {
            throw error
        }
    }
    
    // Method to fetch image data from a given URL
      public static func fetchImageData(from urlString: String) async throws -> Data {
          // Ensure the URL string starts with "http://" or "https://"
          let validUrlString = urlString.starts(with: "http") ? urlString : "https:\(urlString)"
          
          guard let url = URL(string: validUrlString) else {
              throw WeatherAPI_Errors.cannotConvertStringToURL
          }
          
          let (data, _) = try await URLSession.shared.data(from: url)
          return data
      }
    
    public static func fetchForecastData(cityName: String, days: Int) async throws -> WeatherResponse {
        guard var urlComponents = URLComponents(string: "\(baseURL)forecast.json") else {
            throw WeatherAPI_Errors.cannotCreateURLComponent
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "q", value: cityName),
            URLQueryItem(name: "days", value: String(days)),
            URLQueryItem(name: "aqi", value: "no"),
            URLQueryItem(name: "alerts", value: "no")
        ]

        guard let urlString = urlComponents.string else {
            throw WeatherAPI_Errors.cannotCreateURLComponent
        }

        let data = try await fetch(urlString: urlString)
        let forecastResponse = try decoder.decode(WeatherResponse.self, from: data)
        return forecastResponse
    }

}

