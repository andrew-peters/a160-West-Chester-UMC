//
//  OCVWeatherDetailPopup.swift
//  OCVSwift
//
//  Created by Eddie Seay on 6/7/16.
//  Copyright © 2016 OCV,LLC. All rights reserved.
//

import UIKit
import STPopup

class OCVWeatherDetailPopup: STPopupController {

    override init() {
        super.init()
    }

    init(day: DailyForecast) {
        let popupView = OCVWeatherPopupView(day: day)
        super.init(rootViewController: popupView)
        self.navigationBar.barTintColor = WeatherColors.primary.color
        self.navigationBar.tintColor = WeatherColors.text.color
        self.navigationBar.isTranslucent = false
        self.navigationBar.barStyle = UIBarStyle.default
        self.transitionStyle = .slideVertical
        self.containerView.layer.cornerRadius = 4.0
    }
}

class OCVWeatherPopupView: UITableViewController {
    let tableCellIdentifier = "Cell"
    let dateFormatter = DateFormatter()

    let day: DailyForecast!

    init(day: DailyForecast) {
        self.day = day
        super.init(nibName: nil, bundle: nil)
        self.contentSizeInPopup = CGSize(width: 300, height: 400)
        self.landscapeContentSizeInPopup = CGSize(width: 400, height: 200)
        if UIDevice().modelName.contains("Pad") {
            self.contentSizeInPopup = CGSize(width: 300, height: 700)
            self.landscapeContentSizeInPopup = CGSize(width: 400, height: 400)
        }

        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "EEEE, MMMM d"
        self.title = dateFormatter.string(from: day.date as Date)
        dateFormatter.timeZone = TimeZone.current
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: tableCellIdentifier)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 16
    }

    // swiftlint:disable function_body_length
    // swiftlint:disable cyclomatic_complexity
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: tableCellIdentifier)

        var cellTitle = ""
        var cellDetail = ""

        switch (indexPath as NSIndexPath).row {
        case 0:
            cellTitle = "Sunrise"
            dateFormatter.timeStyle = .short
            cellDetail = "\(dateFormatter.string(from: day.sunriseTime as Date))"
        case 1:
            cellTitle = "Sunset"
            dateFormatter.timeStyle = .short
            cellDetail = "\(dateFormatter.string(from: day.sunsetTime as Date))"
        case 2:
            cellTitle = "Moon Phase"
            cellDetail = percent(day.moonPhase)
        case 3:
            cellTitle = "Avg. Precipitation Intensity"
            cellDetail = percent(day.precipIntensity)
        case 4:
            cellTitle = "Max Precipitation Intensity"
            cellDetail = percent(day.precipIntensityMax)
        case 5:
            cellTitle = "Precipitation Probability"
            cellDetail = percent(day.precipProbability)
        case 6:
            cellTitle = "Low"
            cellDetail = "\(day.temperatureMinF)º"
        case 7:
            cellTitle = "Coldest Time"
            dateFormatter.timeStyle = .short
            cellDetail = dateFormatter.string(from: day.temperatureMinTime as Date)
        case 8:
            cellTitle = "High"
            cellDetail = "\(day.temperatureMaxF)º"
        case 9:
            cellTitle = "Hottest Time"
            dateFormatter.timeStyle = .short
            cellDetail = dateFormatter.string(from: day.temperatureMaxTime as Date)
        case 10:
            cellTitle = "Dew Point"
            cellDetail = "\(day.dewPoint)º"
        case 11:
            cellTitle = "Humidity"
            cellDetail = percent(day.humidity)
        case 12:
            cellTitle = "Avg. Wind Speed"
            cellDetail = "\(day.windSpeedMPH) MPH \(OCVAppUtilities.compassDirection(day.windBearing, full: false))"
        case 13:
            cellTitle = "Cloud Cover"
            cellDetail = percent(day.cloudCover)
        case 14:
            cellTitle = "Pressure"
            let pressureString = String(format: "%.2f", day.pressure)
            cellDetail = "\(pressureString) Hg"
        case 15:
            cellTitle = "Ozone"
            cellDetail = "\(day.ozone) ppb"
        default: break
        }

        cell.textLabel?.text = cellTitle
        cell.textLabel?.font = AppFonts.RegularText.font(16)
        cell.detailTextLabel?.text = cellDetail
        cell.detailTextLabel?.font = AppFonts.LightText.font(16)
        cell.isUserInteractionEnabled = false
        return cell
    }

    func percent(_ num: Double) -> String {
        return "\(Int(num*100))%"
    }
}
