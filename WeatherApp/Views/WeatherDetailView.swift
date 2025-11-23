//
//  WeatherDetailView.swift
//  WeatherApp
//
//  Detailed weather information view
//

import SwiftUI

struct WeatherDetailView: View {
    let weatherData: WeatherData
    @ObservedObject var viewModel: WeatherViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header with location and main temperature
                VStack(spacing: 8) {
                    Text(weatherData.location.name)
                        .font(.largeTitle)
                        .bold()

                    Text("\(weatherData.location.region), \(weatherData.location.country)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Image(systemName: WeatherSymbols.symbol(forConditionCode: weatherData.current.condition.code))
                        .font(.system(size: 80))
                        .foregroundColor(WeatherColors.color(forConditionCode: weatherData.current.condition.code))
                        .symbolRenderingMode(.multicolor)

                    Text("\(viewModel.temperature(celsius: weatherData.current.temp_c))°")
                        .font(.system(size: 72, weight: .thin))

                    Text(weatherData.current.condition.text)
                        .font(.title2)
                }
                .padding()

                // Current conditions grid
                VStack(alignment: .leading, spacing: 12) {
                    Text("Current Conditions")
                        .font(.title3)
                        .bold()
                        .padding(.horizontal)

                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        DetailCard(
                            icon: "thermometer",
                            title: "Feels Like",
                            value: viewModel.formatTemperature(weatherData.current.feelslike_c)
                        )

                        DetailCard(
                            icon: "humidity",
                            title: "Humidity",
                            value: "\(weatherData.current.humidity)%"
                        )

                        DetailCard(
                            icon: "wind",
                            title: "Wind",
                            value: String(format: "%.0f km/h %@", weatherData.current.wind_kph, weatherData.current.wind_dir)
                        )

                        DetailCard(
                            icon: "gauge",
                            title: "Pressure",
                            value: String(format: "%.0f mb", weatherData.current.pressure_mb)
                        )

                        DetailCard(
                            icon: "eye",
                            title: "Visibility",
                            value: String(format: "%.0f km", weatherData.current.vis_km)
                        )

                        DetailCard(
                            icon: "sun.max",
                            title: "UV Index",
                            value: String(format: "%.0f", weatherData.current.uv)
                        )

                        if weatherData.current.precip_mm > 0 {
                            DetailCard(
                                icon: "drop",
                                title: "Precipitation",
                                value: String(format: "%.1f mm", weatherData.current.precip_mm)
                            )
                        }
                    }
                    .padding(.horizontal)
                }

                // Sunrise/Sunset (if available)
                if let firstDay = weatherData.forecast.forecastday.first {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Sun & Moon")
                            .font(.title3)
                            .bold()
                            .padding(.horizontal)

                        HStack(spacing: 20) {
                            DetailCard(
                                icon: "sunrise",
                                title: "Sunrise",
                                value: firstDay.astro.sunrise
                            )

                            DetailCard(
                                icon: "sunset",
                                title: "Sunset",
                                value: firstDay.astro.sunset
                            )
                        }
                        .padding(.horizontal)

                        HStack(spacing: 20) {
                            DetailCard(
                                icon: "moonrise",
                                title: "Moonrise",
                                value: firstDay.astro.moonrise
                            )

                            DetailCard(
                                icon: "moon.stars",
                                title: "Moon Phase",
                                value: firstDay.astro.moon_phase
                            )
                        }
                        .padding(.horizontal)
                    }
                }

                // Hourly forecast
                if let hourlyData = weatherData.forecast.forecastday.first?.hour {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Hourly Forecast")
                            .font(.title3)
                            .bold()
                            .padding(.horizontal)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(hourlyData.prefix(24)) { hour in
                                    HourlyForecastCard(hour: hour, viewModel: viewModel)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Weather Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DetailCard: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)

            Text(value)
                .font(.headline)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.secondary.opacity(0.1))
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value)")
    }
}

struct HourlyForecastCard: View {
    let hour: HourlyWeather
    @ObservedObject var viewModel: WeatherViewModel

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    private var formattedTime: String {
        let date = Date(timeIntervalSince1970: TimeInterval(hour.time_epoch))
        return Self.timeFormatter.string(from: date)
    }

    var body: some View {
        VStack(spacing: 8) {
            Text(formattedTime)
                .font(.caption)
                .foregroundColor(.secondary)

            Image(systemName: WeatherSymbols.symbol(forConditionCode: hour.condition.code))
                .font(.title2)
                .foregroundColor(WeatherColors.color(forConditionCode: hour.condition.code))

            Text("\(viewModel.temperature(celsius: hour.temp_c))°")
                .font(.headline)

            if hour.chance_of_rain > 0 {
                HStack(spacing: 2) {
                    Image(systemName: "drop.fill")
                        .font(.caption2)
                    Text("\(hour.chance_of_rain)%")
                        .font(.caption2)
                }
                .foregroundColor(.blue)
            }
        }
        .frame(width: 70)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.secondary.opacity(0.1))
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Hour: \(formattedTime), Temperature: \(viewModel.temperature(celsius: hour.temp_c)) degrees, \(hour.condition.text)")
    }
}
