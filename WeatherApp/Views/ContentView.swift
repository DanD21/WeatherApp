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
    @State private var showingSearchHistory = false
    @State private var searchTask: Task<Void, Never>?

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search field with autocomplete
                VStack(spacing: 0) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)

                        TextField("Search city", text: $inputCityName)
                            .submitLabel(.search)
                            .onSubmit {
                                performSearch()
                            }
                            .onChange(of: inputCityName) { newValue in
                                // Debounce search
                                searchTask?.cancel()
                                if !newValue.isEmpty && newValue.count > 2 {
                                    showingSearchHistory = true
                                } else {
                                    showingSearchHistory = false
                                }
                            }
                            .accessibilityLabel("City search field")
                            .accessibilityHint("Enter a city name to search")

                        if !inputCityName.isEmpty {
                            Button(action: {
                                inputCityName = ""
                                showingSearchHistory = false
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                            .accessibilityLabel("Clear search")
                        }
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.secondary.opacity(0.1))
                    )
                    .padding(.horizontal)
                    .padding(.top)

                    // Search history dropdown
                    if showingSearchHistory && !inputCityName.isEmpty {
                        let filtered = viewModel.searchHistory.filter {
                            $0.lowercased().contains(inputCityName.lowercased())
                        }
                        if !filtered.isEmpty {
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(filtered.prefix(5), id: \.self) { city in
                                    Button(action: {
                                        inputCityName = city
                                        performSearch()
                                        showingSearchHistory = false
                                    }) {
                                        HStack {
                                            Image(systemName: "clock.arrow.circlepath")
                                                .foregroundColor(.secondary)
                                            Text(city)
                                                .foregroundColor(.primary)
                                            Spacer()
                                        }
                                        .padding(12)
                                    }
                                    Divider()
                                }
                            }
                            .background(Color(.systemBackground))
                            .cornerRadius(10)
                            .shadow(radius: 5)
                            .padding(.horizontal)
                        }
                    }
                }

                // Favorites section
                if !viewModel.favoriteLocations.isEmpty && inputCityName.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(viewModel.favoriteLocations, id: \.self) { city in
                                Button(action: {
                                    inputCityName = city
                                    performSearch()
                                }) {
                                    VStack(spacing: 4) {
                                        Image(systemName: "star.fill")
                                            .foregroundColor(.yellow)
                                        Text(city)
                                            .font(.caption)
                                            .foregroundColor(.primary)
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.secondary.opacity(0.1))
                                    )
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top, 8)
                }

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
                            // Current weather card with favorite button
                            VStack(spacing: 0) {
                                HStack {
                                    Spacer()
                                    Button(action: {
                                        viewModel.toggleFavorite(city: weatherData.location.name)
                                    }) {
                                        Image(systemName: viewModel.isFavorite(city: weatherData.location.name) ? "star.fill" : "star")
                                            .foregroundColor(viewModel.isFavorite(city: weatherData.location.name) ? .yellow : .gray)
                                            .font(.title3)
                                    }
                                    .accessibilityLabel(viewModel.isFavorite(city: weatherData.location.name) ? "Remove from favorites" : "Add to favorites")
                                }
                                .padding(.horizontal)

                                NavigationLink(destination: WeatherDetailView(weatherData: weatherData, viewModel: viewModel)) {
                                    CurrentWeatherCard(
                                        weatherData: weatherData,
                                        viewModel: viewModel
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .padding(.horizontal)

                            // Quick stats
                            HStack(spacing: 16) {
                                QuickStatView(
                                    icon: "humidity",
                                    value: "\(weatherData.current.humidity)%",
                                    label: "Humidity"
                                )

                                QuickStatView(
                                    icon: "wind",
                                    value: String(format: "%.0f km/h", weatherData.current.wind_kph),
                                    label: "Wind"
                                )

                                QuickStatView(
                                    icon: "sun.max",
                                    value: String(format: "%.0f", weatherData.current.uv),
                                    label: "UV Index"
                                )
                            }
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
                                Label(unit.rawValue, systemImage: unit == .celsius ? "c.circle" : "f.circle")
                                    .tag(unit)
                            }
                        }
                        .accessibilityLabel("Temperature unit selector")

                        Divider()

                        if !viewModel.searchHistory.isEmpty {
                            Button(role: .destructive, action: {
                                viewModel.clearSearchHistory()
                            }) {
                                Label("Clear Search History", systemImage: "trash")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .accessibilityLabel("Settings")
                    }
                }
            }
            .onAppear {
                viewModel.requestLocation()
            }
            .onTapGesture {
                // Dismiss search history on tap outside
                showingSearchHistory = false
            }
        }
        .navigationViewStyle(.stack)
    }

    private func performSearch() {
        guard !inputCityName.isEmpty else { return }
        showingSearchHistory = false
        Task {
            await viewModel.fetchWeather(forCity: inputCityName)
        }
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
                    .symbolRenderingMode(.multicolor)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 4) {
                    Text("\(viewModel.temperature(celsius: weatherData.current.temp_c))°")
                        .font(.system(size: 56, weight: .bold))
                        .accessibilityLabel("Temperature: \(viewModel.temperature(celsius: weatherData.current.temp_c)) degrees \(viewModel.temperatureUnit.rawValue)")

                    Text(weatherData.current.condition.text)
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .accessibilityLabel("Condition: \(weatherData.current.condition.text)")

                    Text("Feels like \(viewModel.temperature(celsius: weatherData.current.feelslike_c))°")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }

            // Tap for details hint
            HStack {
                Image(systemName: "chevron.right.circle")
                    .foregroundColor(.blue)
                Text("Tap for detailed weather")
                    .font(.caption)
                    .foregroundColor(.blue)
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

struct QuickStatView: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
            Text(value)
                .font(.headline)
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.secondary.opacity(0.1))
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
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
