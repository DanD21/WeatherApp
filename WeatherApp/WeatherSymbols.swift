//
//  WeatherSymbols.swift
//  WeatherApp
//
//  Created by Dan Danilescu on 01.02.2024.
//

import SwiftUI

struct WeatherSymbols {
    static func symbol(forConditionCode code: Int) -> String {
        switch code {
        case 1000: return "sun.max.fill"    // Clear
        case 1003: return "cloud.sun.fill"  // Partly cloudy
        case 1006: return "cloud.fill"      // Cloudy
        case 1009: return "smoke.fill"      // Overcast
        case 1030: return "cloud.fog.fill"  // Mist
        case 1063, 1183: return "cloud.drizzle.fill" // Drizzle
        case 1066, 1210: return "cloud.snow.fill"    // Snow
        case 1069, 1204: return "cloud.sleet.fill"   // Sleet
        case 1072, 1150, 1153: return "cloud.drizzle.fill" // Light drizzle
        case 1087: return "cloud.bolt.rain.fill" // Thundery outbreaks
        default: return "cloud.fill"        // Default: Cloudy
        }
    }
}

struct WeatherColors {
    static func color(forConditionCode code: Int) -> Color {
        switch code {
        case 1000: return .yellow // Clear
        case 1003: return .orange // Partly cloudy
        case 1006: return .gray   // Cloudy
        case 1009: return .blue   // Overcast
        case 1030, 1135, 1147: return .blue.opacity(0.4) // Mist, Fog
        case 1063, 1150, 1153, 1180, 1183, 1189, 1192, 1195: return .blue.opacity(0.7) // Rain
        case 1066, 1114, 1210, 1213, 1216, 1219, 1222, 1225: return .white // Snow
        case 1069, 1072, 1145, 1204, 1207, 1249, 1252: return .purple // Sleet
        case 1087, 1273, 1276, 1279, 1282: return .red // Thunderstorms
        default: return .gray // Default for unknown conditions
        }
    }
}

