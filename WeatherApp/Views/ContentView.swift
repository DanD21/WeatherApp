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
            VStack(spacing: 0) {
                // Search field
                HStack {
                    TextField("Enter City Name", text: $inputCityName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .submitLabel(.search)
                        .onSubmit {
                            if !inputCityName.isEmpty {
                                Task {
                                    await viewModel.fetchWeather(forCity: inputCityName)
                                }
                            }
                        }
                        .accessibilityLabel("City search field")
                        .accessibilityHint("Enter a city name and press return to search")

                    Button(action: {
                        if !inputCityName.isEmpty {
                            Task {
                                await viewModel.fetchWeather(forCity: inputCityName)
                            }
                        }
                    }) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.blue)
                    }
                    .accessibilityLabel("Search button")
                    .disabled(inputCityName.isEmpty)
                }
                .padding()

                // Content area
                ScrollView {
                    VStack(spacing: 16) {
                        if viewModel.isLoading {
                            ProgressView("Loading weather data...")
                                .progressViewStyle(CircularProgressViewStyle())
                                .padding()
                                .accessibilityLabel("Loading weather data")
                        }

                        if let errorMessage = viewModel.errorMessage {
                            ErrorView(message: errorMessage)
                                .accessibilityLabel("Error: \(errorMessage)")
                        }

                        if let weatherData = viewModel.weatherData {
                            // Current weather card
                            CurrentWeatherCard(
                                weatherData: weatherData,
                                viewModel: viewModel
                            )
                            .padding(.horizontal)

                            // Forecast section
                            VStack(alignment: .leading, spacing: 12) {
                                Text("3-Day Forecast")
                                    .font(.title2)
                                    .bold()
                                    .padding(.horizontal)
                                    .accessibilityAddTraits(.isHeader)

                                ForEach(weatherData.forecast.forecastday) { day in
                                    ForecastView(
                                        forecast: day,
                                        temperatureUnit: viewModel.temperatureUnit,
                                        temperatureFormatter: viewModel.temperatureRange
                                    )
                                }
                            }
                        } else if !viewModel.isLoading && viewModel.errorMessage == nil {
                            WelcomeView()
                                .padding()
                        }
                    }
                }
                .refreshable {
                    await viewModel.refreshWeather()
                }
            }
            .navigationTitle("Weather")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Picker("Temperature Unit", selection: $viewModel.temperatureUnit) {
                            ForEach(TemperatureUnit.allCases) { unit in
                                Text(unit.rawValue).tag(unit)
                            }
                        }
                        .accessibilityLabel("Temperature unit selector")
                    } label: {
                        Image(systemName: "thermometer")
                            .accessibilityLabel("Temperature unit settings")
                    }
                }
            }
            .onAppear {
                viewModel.requestLocation()
            }
        }
        .navigationViewStyle(.stack)
    }
}

// MARK: - Subviews

struct CurrentWeatherCard: View {
    let weatherData: WeatherData
    @ObservedObject var viewModel: WeatherViewModel

    var body: some View {
        VStack(spacing: 16) {
            // Location
            HStack {
                Image(systemName: "location.fill")
                    .foregroundColor(.secondary)
                Text(weatherData.location.name)
                    .font(.title2)
                    .bold()
            }
            .accessibilityLabel("Location: \(weatherData.location.name)")

            // Temperature and condition
            HStack(spacing: 20) {
                Image(systemName: WeatherSymbols.symbol(forConditionCode: weatherData.current.condition.code))
                    .font(.system(size: 60))
                    .foregroundColor(WeatherColors.color(forConditionCode: weatherData.current.condition.code))
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 4) {
                    Text("\(viewModel.temperature(celsius: weatherData.current.temp_c))°")
                        .font(.system(size: 56, weight: .bold))
                        .accessibilityLabel("Temperature: \(viewModel.temperature(celsius: weatherData.current.temp_c)) degrees \(viewModel.temperatureUnit.rawValue)")

                    Text(weatherData.current.condition.text)
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .accessibilityLabel("Condition: \(weatherData.current.condition.text)")
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.blue.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
    }
}

struct ErrorView: View {
    let message: String

    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
            Text(message)
                .foregroundColor(.primary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.orange.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal)
    }
}

struct WelcomeView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "cloud.sun.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)
                .symbolRenderingMode(.multicolor)

            Text("Welcome to Weather App")
                .font(.title2)
                .bold()

            Text("Search for a city or allow location access to get started")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Welcome screen. Search for a city or allow location access to get started")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
