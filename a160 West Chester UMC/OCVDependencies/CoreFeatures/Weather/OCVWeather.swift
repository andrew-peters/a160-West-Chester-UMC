//
//  OCVWeather.swift
//  OCVSwift
//
//  Created by Eddie Seay on 6/6/16.
//  Copyright © 2016 OCV,LLC. All rights reserved.
//

import UIKit
import CoreLocation
import SnapKit
import SVProgressHUD

class OCVWeather: UIViewController, CLLocationManagerDelegate {

    let locationManager = CLLocationManager()

    let countyName: String!
    var visibleTab: WeatherDataSource = .county

    var mostRecentLocation: CLLocation? = nil
    var mostRecentCityState: String? = nil

    let coordinator = OCVWeatherDataCoordinator()
    lazy var dailyForecastController = OCVDailyForecastAlertsController()
    let countyLocalSwitch: UISegmentedControl!

    init(countyName: String) {
        self.countyName = countyName
        self.countyLocalSwitch = UISegmentedControl(items: [countyName.components(separatedBy: " ")[0], "Local"])
        super.init(nibName: nil, bundle: nil)
        self.coordinator.sendingViewController = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        SVProgressHUD.show(withStatus: "Loading")

        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.delegate = self

        dailyForecastController.visibleWeather = self.countyName

        countyLocalSwitch.selectedSegmentIndex = 0
        countyLocalSwitch.addTarget(self, action: #selector(OCVWeather.segmentedControlAction), for: .valueChanged)

        self.navigationItem.titleView = countyLocalSwitch
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(OCVWeather.reload))
        setupViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barTintColor = WeatherColors.primary.color
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        SVProgressHUD.dismiss()
        self.navigationController?.navigationBar.barTintColor = AppColors.primary.color
    }

    func reload() {
        let latitude = Double(mostRecentLocation?.coordinate.latitude ?? 0)
        let longitude = Double(mostRecentLocation?.coordinate.longitude ?? 0)
        coordinator.reloadWeatherData(visibleTab, lat: latitude, lon: longitude)
    }

    func segmentedControlAction(_ sender: UISegmentedControl) {
        SVProgressHUD.show(withStatus: "Loading")
        switch sender.selectedSegmentIndex {
        case 0:
            self.setCounty()
            reload()
        case 1:
            visibleTab = .local
            dailyForecastController.local = true
            if let _ = mostRecentLocation, let recentCity = mostRecentCityState {
                dailyForecastController.visibleWeather = recentCity
                reload()
            } else {
                requestAuthorizationForLocation {
                    if $0 == true {
                        if #available(iOS 9.0, *) {
                            self.locationManager.requestLocation()
                        } else {
                            self.locationManager.startUpdatingLocation()
                        }
                    } else if $0 == false {
                        sender.selectedSegmentIndex = 0
                        self.setCounty()
                    }
                }
            }
        default: print("OUT OF BOUNDS")
        }
    }

    func setupWithNewLocation(_ location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarkArray, error) in
            if let mark = placemarkArray?.first {
                if let city = mark.locality, let state = mark.administrativeArea {
                    self.dailyForecastController.visibleWeather = "\(city), \(state)"
                    self.mostRecentCityState = "\(city), \(state)"
                } else {
                    self.dailyForecastController.visibleWeather = "\(self.mostRecentLocation?.coordinate.latitude), \(self.mostRecentLocation?.coordinate.longitude)"
                }
                self.reload()
            } else {
                self.countyLocalSwitch.selectedSegmentIndex = 0
                self.setCounty()
            }
        }
    }

    func setCounty() {
        visibleTab = .county
        dailyForecastController.visibleWeather = self.countyName
        dailyForecastController.local = false
    }

    func updateCurrentViewCell(_ currentObject: CurrentWeatherForecast?) {
        if let newCurrent = currentObject {
            dailyForecastController.currentWeather = newCurrent
            let bgImageView = UIImageView(frame: dailyForecastController.tableView.frame)
            bgImageView.image = UIImage(named: "\(newCurrent.icon)Background")
            dailyForecastController.tableView.backgroundView = bgImageView
        }
    }

    func updateDailyForecastTable(_ days: [DailyForecast]) {
        dailyForecastController.dayArray = days
    }

    func updateHourlyCollectionView(_ hours: [HourlyForecast]) {
        dailyForecastController.hourArray = hours
    }

    func updateWeatherAlerts(_ alerts: [WeatherAlert]) {
        dailyForecastController.alertArray = alerts
    }

    func updateRadarLinks(_ radarLinks: RadarLinks) {
        dailyForecastController.radarLinks = radarLinks
    }

    func setupViews() {
        let dailyForecastTable: UITableView = {
            $0.delegate = dailyForecastController
            $0.dataSource = dailyForecastController
            $0.backgroundColor = WeatherColors.standardWhite.color
            dailyForecastController.parentVC = self
            dailyForecastController.tableView = $0
            $0.register(OCVWeatherForecastCell.self, forCellReuseIdentifier: "WeatherCell")
            $0.register(OCVWeatherAlertCell.self, forCellReuseIdentifier: "AlertCell")
            $0.register(OCVCurrentWeatherCell.self, forCellReuseIdentifier: "CurrentWeather")
            $0.register(OCVRadarCell.self, forCellReuseIdentifier: "RadarCell")
            return $0
        }(UITableView())

        view.addSubview(dailyForecastTable)

        dailyForecastTable.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }
    }

    func requestAuthorizationForLocation(_ completion: (_ hasLocation: Bool?) -> Void) {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            completion(true)
        case .authorizedAlways:
            completion(true)
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            completion(nil)
        case .restricted, .denied:
            let alertController = UIAlertController(
                title: "Location Access Disabled",
                message: "In order to view weather for your current location, please open this app's settings and set location access to 'While Using the App'.",
                preferredStyle: .alert)

            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)

            let openAction = UIAlertAction(title: "Open Settings", style: .default) { (action) in
                if let url = URL(string: UIApplicationOpenSettingsURLString) {
                    UIApplication.shared.openURL(url)
                }
            }
            alertController.addAction(openAction)
            SVProgressHUD.dismiss()
            self.present(alertController, animated: true, completion: nil)
            completion(false)
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if visibleTab == .local {
            if status == .authorizedAlways || status == .authorizedWhenInUse {
                if #available(iOS 9.0, *) {
                    locationManager.requestLocation()
                } else {
                    locationManager.startUpdatingLocation()
                }
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let loc = locations.last {
            self.mostRecentLocation = loc
            self.setupWithNewLocation(loc)
        }
        locationManager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error finding location: \(error.localizedDescription)")
    }
}
