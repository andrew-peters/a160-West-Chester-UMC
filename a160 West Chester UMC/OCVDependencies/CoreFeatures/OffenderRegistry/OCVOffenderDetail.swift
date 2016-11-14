//
//  OCVOffenderDetail.swift
//  OCVSwift
//
//  Created by Eddie Seay on 6/20/16.
//  Copyright © 2016 OCV,LLC. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import AlamofireImage

class OCVOffenderDetail: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {

    let locationManager = CLLocationManager()

    let offenderNameLabel: UILabel = {
        $0.font = AppFonts.SemiboldText.font(20)
        $0.textAlignment = .center
        $0.textColor = AppColors.primary.color
        return $0
    }(UILabel())
    let offenderImage: UIImageView = {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        return $0
    }(UIImageView())
    let mapView = MKMapView()
    let offenderAddressLabel: UILabel = {
        $0.font = AppFonts.LightItalicText.font(18)
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.textColor = AppColors.primary.color
        return $0
    }(UILabel())
    let detailTable = UITableView()

    let numberFormatter = NumberFormatter()

    let offender: OCVOffenderObjectViewModel!
    
    var tableCellTitles: [String] = []
    var tableCellDetails: [String] = []

    init(offender: OCVOffenderObjectViewModel) {
        self.offender = offender
        super.init(nibName: nil, bundle: nil)
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 2
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy"

        if Config.offenderType == "Florida" {
            tableCellTitles = ["Distance From Me", "Status", "Type", "Person Number", "DC Number", "Hair Color", "Eye Color", "Sex", "Race", "Weight", "Height", "Birth Date"]
        } else if Config.offenderType == "Alabama" {
            tableCellTitles = ["Distance From Me", "Charges", "Hair Color", "Eye Color", "Sex", "Race", "Registration Date"]
        }
        
        
        if Config.offenderType == "Florida" {
            tableCellDetails = ["Input address",
                offender.status,
                offender.type,
                offender.personNumber,
                offender.dcNumber,
                offender.hair,
                offender.eye,
                offender.sex,
                offender.race,
                offender.weight,
                offender.height,
                dateFormatter.string(from: offender.date as Date)]
        } else if Config.offenderType == "Alabama" {
            var charge = offender.type
            if (charge == "") {
                charge = "Not Given"
            }
            tableCellDetails = ["Input address",
                charge,
                offender.hair,
                offender.eye,
                offender.sex,
                offender.race,
                dateFormatter.string(from: offender.date as Date)]
        }
        
        detailTable.delegate = self
        detailTable.dataSource = self
        getDistance()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 50
        mapView.showsUserLocation = true
        setupSubViews()
       // self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Map", style: .Plain, target: self, action: #selector(OCVOffenderController.goToMap))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(OCVOffenderDetail.share))
    }
    
    func share() {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy"
        
        let shareDescription = "\(offender.displayName)\n\(offender.address)\n\nCharges:\n\(offender.type)\n\nDescription:\nHair Color: \(offender.hair)\nEye Color: \(offender.eye)\nSex: \(offender.sex)\nRace: \(offender.race)\nRegistration Date: \(dateFormatter.string(from: offender.date as Date))"
        let myActivityController = UIActivityViewController(activityItems: [shareDescription], applicationActivities: nil)
        myActivityController.modalPresentationStyle = .popover
        myActivityController.popoverPresentationController?.sourceView = self.view
        myActivityController.popoverPresentationController?.permittedArrowDirections = .any

        self.present(myActivityController, animated: true, completion: nil)
    }

    func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return tableCellTitles.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "Cell")
        return configured(cell, indexPath: indexPath)
    }

    func configured(_ cell: UITableViewCell, indexPath: IndexPath) -> UITableViewCell {
        if (indexPath as NSIndexPath).row == 0 {
            cell.isUserInteractionEnabled = true
            cell.accessoryType = .disclosureIndicator
        } else {
            cell.isUserInteractionEnabled = false
            cell.accessoryType = .none
        }

        cell.textLabel?.text = tableCellTitles[(indexPath as NSIndexPath).row]
        cell.detailTextLabel?.text = tableCellDetails[(indexPath as NSIndexPath).row]
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alertController = UIAlertController(title: "Get Distance", message: nil, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let fromMe = UIAlertAction(title: "From Me", style: .default) { (action) in
            if self.tableCellDetails[0] != "Input address" {
                self.getDistance()
                self.dismiss(animated: true, completion: nil)
            } else {
                self.requestAuthorizationForLocation {
                    if $0 == true { self.locationManager.startUpdatingLocation() }
                }
            }
        }
        let fromAddress = UIAlertAction(title: "From Address", style: .default) { (action) in
            if let address = alertController.textFields?.first?.text {
                self.geocode(address)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
        alertController.addTextField { $0.placeholder = "Address" }
        alertController.addAction(cancel)
        alertController.addAction(fromAddress)
        alertController.addAction(fromMe)

        present(alertController, animated: true, completion: nil)

        tableView.deselectRow(at: indexPath, animated: true)
    }

    func getDistance() {
        if let myLocation = locationManager.location {
            let distanceDouble = myLocation.distance(from: CLLocation(latitude: offender.coordinates.latitude, longitude: offender.coordinates.longitude)) * 0.000621371
            tableCellDetails[0] = "\(numberFormatter.string(from: NSNumber.init(value: distanceDouble))!) mi"
            tableCellTitles[0] = "Distance From Me"
            detailTable.reloadData()
        } else {
            switch CLLocationManager.authorizationStatus() {
            case .authorizedWhenInUse, .authorizedAlways:
                locationManager.startUpdatingLocation()
            case .notDetermined, .restricted, .denied:
                break
            }
        }
    }

    func geocode(_ address: String) {
        let geocoder = CLGeocoder()

        geocoder.geocodeAddressString(address, completionHandler: {(placemarks, error) -> Void in
            if error != nil {
                self.tableCellTitles[0] = "Please Try Again"
                self.tableCellDetails[0] = "Invalid Address"
            }
            if let placemark = placemarks?.first {
                let coordinates = placemark.location!.coordinate
                let distanceDouble = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude).distance(from: CLLocation(latitude: self.offender.coordinates.latitude, longitude: self.offender.coordinates.longitude)) * 0.000621371
                self.tableCellDetails[0] = "\(self.numberFormatter.string(from: NSNumber.init(value: distanceDouble))!) mi"
                self.tableCellTitles[0] = "Distance From \(address)"
            }
            self.detailTable.reloadData()
        })
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
            completion(false)
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        if let myLocation = locationManager.location {
            let distanceDouble = myLocation.distance(from: CLLocation(latitude: offender.coordinates.latitude, longitude: offender.coordinates.longitude)) * 0.000621371
            tableCellDetails[0] = "\(numberFormatter.string(from: NSNumber.init(value: distanceDouble))!) mi"
            tableCellTitles[0] = "Distance From Me"
            detailTable.reloadData()
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error finding location: \(error.localizedDescription)")
    }

    func setupSubViews() {
        view.backgroundColor = AppColors.secondary.alpha(0.7)

        view.addSubview(offenderNameLabel)
        view.addSubview(offenderAddressLabel)
        view.addSubview(offenderImage)
        view.addSubview(mapView)
        view.addSubview(detailTable)

        offenderNameLabel.text = offender.displayName
        offenderAddressLabel.text = offender.address
        offenderImage.af_setImage(withURL: offender.imageURL, placeholderImage: UIImage(named: "noimage-person"))

        offenderNameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(view)
            make.right.equalTo(view)
            
            make.top.equalTo(view)
        }
        offenderAddressLabel.snp.makeConstraints { (make) in
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.top.equalTo(offenderNameLabel.snp.bottom)
        }
        
        if Config.offenderType == "Florida" {
            offenderImage.snp.makeConstraints { (make) in
                make.left.equalTo(view).offset(2)
                make.right.equalTo(view.snp.centerX).offset(-1)
                make.top.equalTo(offenderAddressLabel.snp.bottom)
                make.height.equalTo(view).dividedBy(3)
            }
            
            mapView.snp.makeConstraints { (make) in
                make.left.equalTo(offenderImage.snp.right).offset(2)
                make.right.equalTo(view).offset(-2)
                make.top.equalTo(offenderAddressLabel.snp.bottom)
                make.height.equalTo(view).dividedBy(3)
            }
        } else if Config.offenderType == "Alabama" {
            mapView.snp.makeConstraints { (make) in
                make.left.equalTo(view).offset(2)
                make.right.equalTo(view).offset(-2)
                make.top.equalTo(offenderAddressLabel.snp.bottom)
                make.height.equalTo(view).dividedBy(3)
            }
        } 

        detailTable.snp.makeConstraints { (make) in
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.top.equalTo(mapView.snp.bottom).offset(2)
            make.bottom.equalTo(view)
        }

        let coordinateSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: offender.coordinates, span: coordinateSpan)
        let annotation = MKPointAnnotation()
        annotation.coordinate = offender.coordinates
        annotation.title = offender.displayName
        mapView.addAnnotation(annotation)
        mapView.setRegion(region, animated: true)
        mapView.regionThatFits(region)
    }
}
