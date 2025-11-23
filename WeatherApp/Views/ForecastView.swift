//
//  ForecastView.swift
//  WeatherApp
//
//  Created by Dan Danilescu on 31.01.2024.
//

import SwiftUI

struct ForecastView: View {
    let forecast: ForecastDay
    let temperatureUnit: TemperatureUnit
    let temperatureFormatter: (Double, Double) -> String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(localizedDate(from: forecast.date))
                    .bold()
                    .font(.headline)
                    .accessibilityLabel("Date: \(localizedDate(from: forecast.date))")

                Text(forecast.day.condition.text)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .accessibilityLabel("Condition: \(forecast.day.condition.text)")

                Text(temperatureFormatter(forecast.day.mintemp_c, forecast.day.maxtemp_c))
                    .font(.subheadline)
                    .accessibilityLabel("Temperature range: \(temperatureFormatter(forecast.day.mintemp_c, forecast.day.maxtemp_c))")
            }

            Spacer()

            Image(systemName: WeatherSymbols.symbol(forConditionCode: forecast.day.condition.code))
                .font(.largeTitle)
                .foregroundColor(WeatherColors.color(forConditionCode: forecast.day.condition.code))
                .accessibilityLabel("Weather icon: \(forecast.day.condition.text)")
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.secondary.opacity(0.2)))
        .padding(.horizontal)
        .accessibilityElement(children: .combine)
    }

    // Static formatters for performance
    private static let inputFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    private static let outputFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    private func localizedDate(from dateString: String) -> String {
        if let date = Self.inputFormatter.date(from: dateString) {
            return Self.outputFormatter.string(from: date)
        }
        return dateString
    }
}

struct ForecastView_Previews: PreviewProvider {
    static var previews: some View {
        ForecastView(
            forecast: ForecastDay(
                date: "2024-01-31",
                day: Day(
                    maxtemp_c: 21.0,
                    mintemp_c: 15.0,
                    maxtemp_f: 69.8,
                    mintemp_f: 59.0,
                    condition: WeatherCondition(text: "Partly cloudy", icon: "", code: 1003)
                )
            ),
            temperatureUnit: .celsius,
            temperatureFormatter: { min, max in
                "\(Int(min.rounded()))° / \(Int(max.rounded()))°"
            }
        )
    }
}
