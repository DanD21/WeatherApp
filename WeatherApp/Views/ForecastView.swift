//
//  ForecastView.swift
//  WeatherApp
//
//  Created by Dan Danilescu on 31.01.2024.
//

import SwiftUI

struct ForecastView: View {
    let forecast: ForecastDay
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(localizedDate(from: forecast.date))
                    .bold()
                Text("Max Temp: \(forecast.day.maxtemp_c, specifier: "%.1f")°C")
                Text("Min Temp: \(forecast.day.mintemp_c, specifier: "%.1f")°C")
            }
            Spacer()
            Image(systemName: WeatherSymbols.symbol(forConditionCode: forecast.day.condition.code))
                .font(.largeTitle)
                .foregroundColor(WeatherColors.color(forConditionCode: forecast.day.condition.code))
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.secondary.opacity(0.2)))
        .padding(.horizontal)
    }
    
    private func localizedDate(from dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        if let date = inputFormatter.date(from: dateString) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateStyle = .medium
            outputFormatter.timeStyle = .none
            return outputFormatter.string(from: date)
        }
        return dateString
    }
}

struct ForecastView_Previews: PreviewProvider {
    static var previews: some View {
        ForecastView(forecast: ForecastDay(date: "2024-01-31", day: Day(maxtemp_c: 21.0, mintemp_c: 15.0, condition: WeatherCondition(text: "Partly cloudy", icon: "", code: 1003))))
    }
}
