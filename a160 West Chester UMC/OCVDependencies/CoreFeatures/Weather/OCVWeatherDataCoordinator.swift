//
//  OCVWeatherDataCoordinator.swift
//  OCVSwift
//
//  Created by Eddie Seay on 6/6/16.
//  Copyright © 2016 OCV,LLC. All rights reserved.
//

import Foundation

class OCVWeatherDataCoordinator {
    var sendingViewController: OCVWeather? = nil
    var currentWeather: CurrentWeatherForecast? = nil {
        didSet {
            sendingViewController?.updateCurrentViewCell(currentWeather)
        }
    }

    var todayWeather: DailyForecast? = nil

    var radarLinks: RadarLinks? = nil {
        didSet {
            if let nonNullLinks = radarLinks {
                sendingViewController?.updateRadarLinks(nonNullLinks)
            }
        }
    }

    var weatherDays: [DailyForecast] = [] {
        didSet {
            sendingViewController?.updateDailyForecastTable(weatherDays)
        }
    }

    var weatherHours: [HourlyForecast] = [] {
        didSet {
            sendingViewController?.updateHourlyCollectionView(weatherHours)
        }
    }

    var weatherAlerts: [WeatherAlert] = [] {
        didSet {
            sendingViewController?.updateWeatherAlerts(weatherAlerts)
        }
    }

    init() {
        reloadWeatherData(.county, lat: 0.0, lon: 0.0)
    }

    func reloadWeatherData(_ source: WeatherDataSource, lat: Double, lon: Double) {
        switch source {
        case .county:
            let url = "https://apps.myocv.com/feed/ext/\(Config.applicationID)/weather"
            OCVNetworkClient().downloadFrom(url: url, showProgress: true) { resultData, _ in
                if let data = resultData {
                    let parser = OCVFeedParser()
                    self.radarLinks = parser.parseRadarLinks(data)
                    self.weatherAlerts = parser.parseWeatherAlertsArray(data)
                    let weekWeather = parser.parseWeeksForecast(data, local: false)
                    if !weekWeather.isEmpty { self.todayWeather = weekWeather.first }
                    self.weatherDays = weekWeather
                    self.weatherHours = parser.parseHourlyWeather(data, local: false)
                    self.currentWeather = parser.parseCurrentWeather(data, local: false)
                }
            }
        case .local:
            OCVNetworkClient().apiRequest(atPath: "/forecast/\(lat)/\(lon)", httpMethod: .get, parameters: [:], showProgress: true) { resultData, _ in
                if let data = resultData {
                    let parser = OCVFeedParser()
                    self.radarLinks = nil
                    self.weatherAlerts = parser.parseWeatherAlertsArray(data)
                    let weekWeather = parser.parseWeeksForecast(data, local: true)
                    if !weekWeather.isEmpty { self.todayWeather = weekWeather.first }
                    self.weatherDays = weekWeather
                    self.weatherHours = parser.parseHourlyWeather(data, local: true)
                    self.currentWeather = parser.parseCurrentWeather(data, local: true)
                }
            }
        }
    }
}

enum WeatherDataSource {
    case county
    case local
}
