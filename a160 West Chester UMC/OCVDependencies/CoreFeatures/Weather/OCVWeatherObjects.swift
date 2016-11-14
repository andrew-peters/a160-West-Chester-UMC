//
//  WeatherObjects.swift
//  OCVSwift
//
//  Created by Eddie Seay on 6/6/16.
//  Copyright © 2016 OCV,LLC. All rights reserved.
//

import Foundation

struct CurrentWeatherForecast {
    let date: Date
    let summary: String
    let icon: String
    let precipIntensity: Double
    let precipProbability: Double
    let temperatureF: Double
    let apparentTemperatureF: Double
    let dewPoint: Double
    let humidity: Double
    let windSpeedMPH: Double
    let windBearing: Double
    let visibility: Double
    let cloudCover: Double
    let pressure: Double
    let ozone: Double
}

struct HourlyForecast {
    let date: Date
    let summary: String
    let icon: String
    let precipIntensity: Double
    let precipProbability: Double
    let temperatureF: Double
    let apparentTemperatureF: Double
    let dewPoint: Double
    let humidity: Double
    let windSpeedMPH: Double
    let windBearing: Double
    let visibility: Double
    let cloudCover: Double
    let pressure: Double
    let ozone: Double
}

struct DailyForecast {
    let date: Date
    let summary: String
    let icon: String
    let sunriseTime: Date
    let sunsetTime: Date
    let moonPhase: Double
    let precipIntensity: Double
    let precipIntensityMax: Double
    let precipProbability: Double
    let temperatureMinF: Double
    let temperatureMinTime: Date
    let temperatureMaxF: Double
    let temperatureMaxTime: Date
    let apparentTemperatureMinF: Double
    let apparentTemperatureMinTime: Date
    let apparentTemperatureMaxF: Double
    let apparentTemperatureMaxTime: Date
    let dewPoint: Double
    let humidity: Double
    let windSpeedMPH: Double
    let windBearing: Double
    let cloudCover: Double
    let pressure: Double
    let ozone: Double
}

struct RadarLinks {
    let local: String
    let state: String
    let regional: String
    let national: String
}

struct WeatherAlert {
    let alertID: String
    let updatedTime: Date
    let title: String
    let summary: String?
}
