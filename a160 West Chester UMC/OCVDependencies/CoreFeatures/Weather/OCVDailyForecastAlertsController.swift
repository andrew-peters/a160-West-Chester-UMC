//
//  OCVDailyForecastController.swift
//  OCVSwift
//
//  Created by Eddie Seay on 6/6/16.
//  Copyright © 2016 OCV,LLC. All rights reserved.
//

import UIKit

private let weatherCellIdentifier = "WeatherCell"
private let alertCellIdentifier = "AlertCell"
private let currentWeatherCellID = "CurrentWeather"
private let radarCellIdentifier = "RadarCell"

protocol ExpandableTable {
    var openCellHeight: CGFloat { get set }
}

class OCVDailyForecastAlertsController: NSObject, UITableViewDelegate, UITableViewDataSource {

    let dateFormatter = DateFormatter()

    var tableView = UITableView()
    var parentVC = UIViewController()
    let hourlyCollectionController = OCVWeatherHourlyCollection()
    var visibleWeather = ""
    var local = false
    var openCellHeight = CGFloat(50)

    var dayArray = [DailyForecast]() {
        didSet {
            tableView.reloadData()
        }
    }

    var alertArray = [WeatherAlert]() {
        didSet {
            tableView.reloadData()
        }
    }

    var currentWeather: CurrentWeatherForecast? = nil {
        didSet {
            tableView.reloadData()
        }
    }

    var hourArray = [HourlyForecast]() {
        didSet {
            hourlyCollectionController.hourlyWeather = hourArray
        }
    }

    var radarLinks: RadarLinks? = nil {
        didSet {
            tableView.reloadData()
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return currentWeather != nil ? 1 : 0
        case 2: return dayArray.count
        case 3: return alertArray.count
        case 4: if local { return 0 }
            return 1
        default: return 0
        }
    }

    // swiftlint:disable function_body_length
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerLabel: UILabel = {
            $0.font = AppFonts.SemiboldText.font(18)
            $0.textColor = WeatherColors.text.color
            return $0
        }(UILabel())

        let headerView: UIView = {
            $0.frame = CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 20)
            $0.backgroundColor = WeatherColors.primary.color
            return $0
        }(UIView())

        headerView.addSubview(headerLabel)
        headerLabel.snp.makeConstraints { (make) in
            make.top.equalTo(headerView)
            make.bottom.equalTo(headerView)
            make.left.equalTo(headerView).offset(5)
            make.right.equalTo(headerView)
        }

        switch section {
        case 0: headerLabel.text = "Current Weather"
            return headerView
        case 2: headerLabel.text = "Daily Forecast"
            return headerView
        case 3: headerLabel.text = "Active Weather Alerts"
            return headerView
        case 4:
            headerLabel.text = nil
            headerLabel.backgroundColor = UIColor.clear
            headerView.backgroundColor = UIColor.clear
        default: headerLabel.text = nil
        }

        if section == 1 {
            let flowLayout: UICollectionViewFlowLayout = {
                $0.scrollDirection = .horizontal
                $0.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 0)
                $0.itemSize = CGSize(width: 100, height: 100)
                $0.minimumInteritemSpacing = 10.0
                $0.minimumLineSpacing = 10.0
                return $0
            }(UICollectionViewFlowLayout())

            let hourlyCollection: UICollectionView = {
                $0.delegate = hourlyCollectionController
                $0.dataSource = hourlyCollectionController
                hourlyCollectionController.collectionView = $0
                $0.bounces = true
                $0.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
                $0.register(OCVHourlyWeatherCell.self, forCellWithReuseIdentifier: "Cell")
                $0.backgroundColor = UIColor.clear
                return $0
            }(UICollectionView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 110), collectionViewLayout: flowLayout))

            return hourlyCollection
        }

        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 1: return 110
        default: return 25
        }
    }

    // swiftlint:disable function_body_length
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath as NSIndexPath).section {
        case 0:
            let tableCellIdentifier = currentWeatherCellID
            guard let cell = tableView.dequeueReusableCell(withIdentifier: tableCellIdentifier) as? OCVCurrentWeatherCell else {
                fatalError("Could not dequeue cell with identifier: \(tableCellIdentifier)")
            }
            return configuredCurrentWeatherCell(cell, currentWeather: currentWeather)
        case 2:
            let tableCellIdentifier = weatherCellIdentifier
            guard let cell = tableView.dequeueReusableCell(withIdentifier: tableCellIdentifier) as? OCVWeatherForecastCell else {
                fatalError("Could not dequeue cell with identifier: \(tableCellIdentifier)")
            }
            return configuredDailyCell(cell, forecast: dayArray[(indexPath as NSIndexPath).row])
        case 3:
            let tableCellIdentifier = alertCellIdentifier
            guard let cell = tableView.dequeueReusableCell(withIdentifier: tableCellIdentifier) as? OCVWeatherAlertCell else {
                fatalError("Could not dequeue cell with identifier: \(tableCellIdentifier)")
            }
            return configuredAlertCell(cell, alert: alertArray[(indexPath as NSIndexPath).row])
        case 4:
            let tableCellIdentifier = radarCellIdentifier
            guard let cell = tableView.dequeueReusableCell(withIdentifier: tableCellIdentifier) as? OCVRadarCell else {
                fatalError("Could not dequeue cell with identifier: \(tableCellIdentifier)")
            }
            cell.radarLinks = self.radarLinks
            cell.parentTableView = self.tableView
            cell.parentController = self
            return cell
        default: fatalError("ReuseIdentifer not set up for section")
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath as NSIndexPath).section {
        case 2:
            OCVWeatherDetailPopup(day: dayArray[(indexPath as NSIndexPath).row]).present(in: parentVC)
        case 3:
            let alert = alertArray[(indexPath as NSIndexPath).row]
            let alertDate = Date().timeAgoSinceDate(alert.updatedTime, numericDates: true)

            let tableObject = OCVTableObject(id: nil, title: alert.title, content: alert.summary, creator: nil, date: alertDate, imageArr: nil)
            parentVC.navigationController?.pushViewController(OCVDetail(object: tableObject), animated: true)
        default: break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath as NSIndexPath).section {
        case 0: return 135
        case 2: return 88
        case 3: return 88
        case 4:
            if local { return 0 }
            return openCellHeight
        default: return 44
        }
    }

    func roundDecimalPercent(_ number: Double) -> Int {
        return Int(number * 100.0)
    }

    func configuredCurrentWeatherCell(_ cell: OCVCurrentWeatherCell, currentWeather: CurrentWeatherForecast?) -> OCVCurrentWeatherCell {
        guard let current = currentWeather else {
            return cell
        }

        dateFormatter.timeZone = TimeZone.current
        dateFormatter.timeStyle = .short

        cell.isUserInteractionEnabled = false

        let temperatureText = "\(Int(round(current.temperatureF)))º"
        cell.currentTempLabel.text = temperatureText
        cell.locationLabel.text = visibleWeather
        cell.conditionLabel.text = current.summary
        if let today = dayArray.first {
            cell.hiLoValueLabel.text = "\(Int(round(today.temperatureMaxF)))º / \(Int(round(today.temperatureMinF)))º"
            cell.sunriseLabel.text = "Sunrise:\n\(dateFormatter.string(from: today.sunriseTime as Date))"
            cell.sunsetLabel.text = "Sunset:\n\(dateFormatter.string(from: today.sunsetTime as Date))"
        }
        cell.feelsLikeLabel.text = "Feels like: \(Int(round(current.apparentTemperatureF)))º"
        cell.humidityLabel.text = "\(Int(roundDecimalPercent(current.humidity)))% Humidity"
        cell.windspeedLabel.text = "Wind Speed: \(current.windSpeedMPH) MPH \(OCVAppUtilities.compassDirection(current.windBearing, full: false))"
        cell.selectionStyle = .gray
        return cell
    }

    func configuredDailyCell(_ cell: OCVWeatherForecastCell, forecast: DailyForecast) -> OCVWeatherForecastCell {
        dateFormatter.dateFormat = "EEEE, MMMM d"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")

        cell.imageItem.image = UIImage(named: forecast.icon)?.withRenderingMode(.alwaysTemplate)
        cell.dayLabel.text = dateFormatter.string(from: forecast.date as Date)
        cell.conditionLabel.text = forecast.summary
        cell.precipLabel.text = "\(roundDecimalPercent(forecast.precipProbability))% Precipitation"
        cell.hiValueLabel.text = "\(Int(round(forecast.temperatureMaxF)))º"
        cell.loValueLabel.text = "\(Int(round(forecast.temperatureMinF)))º"
        cell.selectionStyle = .gray
        return cell
    }

    func configuredAlertCell(_ cell: OCVWeatherAlertCell, alert: WeatherAlert) -> OCVWeatherAlertCell {
        cell.titleLabel.text = alert.title
        cell.descLabel.text = alert.summary
        cell.selectionStyle = .gray
        cell.dateLabel.text = Date().timeAgoSinceDate(alert.updatedTime, numericDates: true)
        return cell
    }

}
