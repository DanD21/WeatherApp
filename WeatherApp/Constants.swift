//
//  Constants.swift
//  WeatherApp
//
//  Created by Dan Danilescu on 01.02.2024.
//

import Foundation

struct Constants {
    static var weatherAPIKey: String {
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let secrets = NSDictionary(contentsOfFile: path),
              let apiKey = secrets["WEATHER_API_KEY"] as? String else {
            fatalError("Failed to load API key from Secrets.plist. Please copy Secrets.template.plist to Secrets.plist and add your API key.")
        }
        return apiKey
    }
}

