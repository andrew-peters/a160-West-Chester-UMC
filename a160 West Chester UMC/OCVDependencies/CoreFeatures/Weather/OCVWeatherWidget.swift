//
//  OCVWeatherWidget.swift
//  OCVSwift
//
//  Created by Eddie Seay on 6/10/16.
//  Copyright © 2016 OCV,LLC. All rights reserved.
//

import UIKit
import CoreLocation
import SnapKit

enum WeatherWidgetLayoutStyle {
    case wide
    case compact
}

class OCVWeatherWidget: UIView, CLLocationManagerDelegate {

    let defaultLocationName: String!
    let layoutDirection: WeatherWidgetLayoutStyle
    let locationManager = CLLocationManager()
    var mostRecentUpdate = Date(timeIntervalSinceNow: -600)

    let imageItem: UIImageView = {
        $0.clipsToBounds = true
        $0.contentMode = .scaleAspectFit
        $0.tintColor = WeatherColors.oppositeOfPrimary.color
        $0.image = UIImage(named: "clear-day")?.withRenderingMode(.alwaysTemplate)
        return $0
    }(UIImageView())

    let locationLabel: UILabel = {
        $0.font = AppFonts.SemiboldText.font(14)
        $0.textColor = WeatherColors.standardWhite.color
        $0.textAlignment = .center
        $0.text = "----, --"
        $0.numberOfLines = 1
        $0.minimumScaleFactor = 0.5
        $0.adjustsFontSizeToFitWidth = true
        $0.lineBreakMode = .byTruncatingTail
        $0.setContentCompressionResistancePriority(UILayoutPriority(1000), for: .vertical)
        return $0
    }(UILabel())

    let temperatureLabel: UILabel = {
        $0.font = AppFonts.SemiboldText.font(28)
        $0.textColor = WeatherColors.oppositeOfPrimary.color
        $0.textAlignment = .center
        $0.text = "--º"
        return $0
    }(UILabel())

    let hiLoValueLabel: UILabel = {
        $0.font = AppFonts.RegularText.font(12)
        $0.textColor = WeatherColors.standardWhite.color
        $0.textAlignment = .center
        $0.text = "-º / -º"
        return $0
    }(UILabel())

    let tempContainer = UIView()

    let weatherButton: UIButton = {
        $0.backgroundColor = UIColor.clear
        return $0
    }(UIButton())
    
    let tapForDetails: UILabel = {
        $0.font = AppFonts.LightItalicText.font(10)
        $0.textColor = WeatherColors.standardWhite.color
        $0.textAlignment = .center
        $0.text = "Tap for More Details"
        return $0
    }(UILabel())
    
    init(defaultLocation: String, layoutDirection: WeatherWidgetLayoutStyle) {
        self.defaultLocationName = defaultLocation
        self.layoutDirection = layoutDirection
        super.init(frame: CGRect())
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        setupSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setLabelsToDefaultValues() {
        imageItem.image = UIImage(named: "clear-day")?.withRenderingMode(.alwaysTemplate)
        locationLabel.text = "----, --"
        temperatureLabel.text = "--º"
        hiLoValueLabel.text = "-º / -º"
    }

    // swiftlint:disable function_body_length
    func setupSubviews() {

        getCurrentWeather()
        self.backgroundColor = WeatherColors.primary.color
        weatherButton.addTarget(self, action: #selector(OCVWeatherWidget.pushWeather), for: .touchUpInside)

        addSubview(imageItem)
        addSubview(locationLabel)
        addSubview(tempContainer)
        addSubview(weatherButton)
        addSubview(tapForDetails)
        tempContainer.addSubview(temperatureLabel)
        tempContainer.addSubview(hiLoValueLabel)

        switch layoutDirection {
        case .wide:
            locationLabel.snp.makeConstraints { (make) in
                make.centerX.equalTo(self)
                make.top.equalTo(self).offset(2)
            }
            imageItem.snp.makeConstraints { (make) in
                make.top.equalTo(self).offset(2)
                make.bottom.equalTo(self).offset(-2)
                make.left.equalTo(self).offset(5)
                make.width.equalTo(self.snp.height).offset(-4)
                make.right.lessThanOrEqualTo(locationLabel.snp.left).offset(-5)
            }
            tempContainer.snp.makeConstraints { (make) in
                make.top.equalTo(self).offset(2)
                make.bottom.equalTo(self).offset(-2)
                make.right.equalTo(self).offset(-5)
                make.left.greaterThanOrEqualTo(locationLabel.snp.right).offset(5)
            }
            temperatureLabel.snp.makeConstraints { (make) in
                make.left.equalTo(tempContainer)
                make.right.equalTo(tempContainer)
                make.top.greaterThanOrEqualTo(tempContainer)
            }
            hiLoValueLabel.snp.makeConstraints { (make) in
                make.top.equalTo(temperatureLabel.snp.bottom)
                make.left.equalTo(tempContainer)
                make.right.equalTo(tempContainer)
                make.bottom.equalTo(tempContainer)
            }
            tapForDetails.snp.makeConstraints { (make) in
                make.top.equalTo(locationLabel.snp.bottom)
                make.bottom.lessThanOrEqualTo(self).offset(-2)
                make.left.equalTo(locationLabel)
                make.right.equalTo(locationLabel)
            }
            locationLabel.font = AppFonts.SemiboldText.font(22)
        case .compact:
            locationLabel.snp.makeConstraints { (make) in
                make.top.equalTo(self)
                make.left.equalTo(self)
                make.right.equalTo(self)
            }
            imageItem.snp.makeConstraints { (make) in
                make.width.equalTo(self).dividedBy(2)
                make.top.equalTo(locationLabel.snp.bottom)
                make.right.equalTo(self).offset(-2)
                make.bottom.equalTo(self).offset(-2)
            }
            tempContainer.snp.makeConstraints { (make) in
                make.width.equalTo(self).dividedBy(2)
                make.top.equalTo(locationLabel.snp.bottom)
                make.left.equalTo(self).offset(2)
                make.bottom.equalTo(self).offset(-2)
            }
            temperatureLabel.snp.makeConstraints { (make) in
                make.left.equalTo(tempContainer)
                make.right.equalTo(tempContainer)
                make.top.greaterThanOrEqualTo(tempContainer)
            }
            hiLoValueLabel.snp.makeConstraints { (make) in
                make.top.equalTo(temperatureLabel.snp.bottom)
                make.left.equalTo(tempContainer)
                make.right.equalTo(tempContainer)
                make.bottom.equalTo(tempContainer)
            }

            if UIDevice().modelName.contains("Pad") {
                temperatureLabel.font = AppFonts.SemiboldText.font(48)
                hiLoValueLabel.font = AppFonts.RegularText.font(28)
                locationLabel.font = AppFonts.SemiboldText.font(28)
                tapForDetails.font = AppFonts.LightItalicText.font(20)
            } else if UIDevice().modelName.contains("4") {
                temperatureLabel.font = AppFonts.SemiboldText.font(24)
            }
        }

        weatherButton.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }

    func pushWeather() {
        AWSAnalytics.SharedInstance.closeFeature()
        AWSAnalytics.SharedInstance.openFeature(name: "weather")
        if let nav = self.getParentViewController()?.navigationController {
            nav.pushViewController(OCVWeather(countyName: self.defaultLocationName), animated: true)
        }
    }

    func getCurrentWeather() {
        if mostRecentUpdate.timeIntervalSinceNow < -300 {

            switch CLLocationManager.authorizationStatus() {
            case .authorizedWhenInUse, .authorizedAlways:
                if #available(iOS 9.0, *) {
                    locationManager.requestLocation()
                } else {
                    locationManager.startUpdatingLocation()
                }
            case .restricted, .denied, .notDetermined:
                self.locationLabel.text = self.defaultLocationName
                let url = "https://apps.myocv.com/feed/ext/\(Config.applicationID)/weather"
                OCVNetworkClient().downloadFrom(url: url, showProgress: true) { resultData, _ in
                    if let data = resultData {
                        let parser = OCVFeedParser()
                        guard let currentWeather = parser.parseCurrentWeather(data, local: false) else { return }
                        guard let today = parser.parseWeeksForecast(data, local: false).first else { return }
                        self.temperatureLabel.text = "\(Int(round(currentWeather.temperatureF)))º"
                        self.imageItem.image = UIImage(named: currentWeather.icon)?.withRenderingMode(.alwaysTemplate)
                        self.hiLoValueLabel.text = "\(Int(round(today.temperatureMinF)))º / \(Int(round(today.temperatureMaxF)))º"
                    }
                }
            }
            mostRecentUpdate = Date()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()

        if let loc = locations.last {
            OCVNetworkClient().apiRequest(atPath: "/forecast/\(loc.coordinate.latitude)/\(loc.coordinate.longitude)", httpMethod: .get, parameters: [:], showProgress: false) { resultData, _ in
                if let data = resultData {
                    let parser = OCVFeedParser()
                    guard let currentWeather = parser.parseCurrentWeather(data, local: true) else { return }
                    guard let today = parser.parseWeeksForecast(data, local: true).first else { return }
                    self.temperatureLabel.text = "\(Int(round(currentWeather.temperatureF)))º"
                    self.imageItem.image = UIImage(named: currentWeather.icon)?.withRenderingMode(.alwaysTemplate)
                    self.hiLoValueLabel.text = "\(Int(round(today.temperatureMinF)))º / \(Int(round(today.temperatureMaxF)))º"
                }
            }
            setLocationLabel(loc)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error finding location: \(error.localizedDescription)")
    }

    func setLocationLabel(_ location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarkArray, error) in
            if let mark = placemarkArray?.first {
                if let city = mark.locality, let state = mark.administrativeArea {
                    self.locationLabel.text = "\(city), \(state)"
                } else {
                    self.locationLabel.text = "\(location.coordinate.latitude), \(location.coordinate.longitude)"
                }
            } else {
                self.locationLabel.text = "Could Not Find Location"
            }
        }
    }
}
