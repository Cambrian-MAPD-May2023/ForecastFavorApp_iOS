//
//  WeatherDataManager.swift
//  ForecastFavorApp_iOS
//
//  Created by Sreenath Segar on 2023-12-06.
//

import Foundation

class WeatherDataManager {
    static let shared = WeatherDataManager()

    var currentConditionText: String?

    func updateWeatherData(completion: @escaping () -> Void) {
        completion()
    }
}
