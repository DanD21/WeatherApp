//
//  ContentView.swift
//  WeatherApp
//
//  Created by Dan Danilescu on 31.01.2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = WeatherViewModel()
    @State private var inputCityName = ""

    var body: some View {
        NavigationView {
            VStack {
                TextField("Enter City Name", text: $inputCityName, onCommit: {
                    viewModel.fetchWeather(forCity: inputCityName)
                })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                }
                
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }

                if let weatherData = viewModel.weatherData {
                    HStack(alignment: .center) {
                        Image(systemName: WeatherSymbols.symbol(forConditionCode: weatherData.current.condition.code))
                            .font(.largeTitle)
                            .foregroundColor(WeatherColors.color(forConditionCode: weatherData.current.condition.code))
                            .opacity(0.8)

                        VStack(alignment: .leading) {
                            Text(weatherData.location.name)
                                .font(.title)
                                .bold()

                            HStack {
                                Text("\(weatherData.current.temp_c, specifier: "%.0f")°")
                                    .font(.system(size: 50))
                                    .bold()
                                VStack(alignment: .leading) {
                                    Text("Condition")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(weatherData.current.condition.text)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.blue.opacity(0.2)))
                    .padding()

                    ScrollView {
                        ForEach(weatherData.forecast.forecastday) { day in
                            ForecastView(forecast: day)
                        }
                    }
                } else {
                    Text("Fetching weather data...")
                        .font(.headline)
                }
            }
            .navigationTitle("Weather Forecast")
            .onAppear {
                viewModel.requestLocation()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
