//
//  OCVWhereAmI.swift
//  OCVSwift
//
//  Created by Eddie Seay on 6/14/16.
//  Copyright © 2016 OCV,LLC. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import SnapKit

class OCVWhereAmI: UIViewController, CLLocationManagerDelegate {

    let infoCell = OCVWhereAmIInfoCell()

    var locationHasBeenFound = false
    let locationManager = CLLocationManager()
    let mapView = MKMapView()

    deinit {
        print("WhereAmI Deinitialized")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "My Location"
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 50
        mapView.showsUserLocation = true

        setupViews()
        refresh()

        requestAuthorizationForLocation {
            if $0 == true { self.locationManager.startUpdatingLocation() }
        }
    }

    func centerMapOnLocation(_ location: CLLocation?) {
        if let currentLocation = location {
            locationHasBeenFound = true
            let regionRadius: CLLocationDistance = 500
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(currentLocation.coordinate, regionRadius * 2.0, regionRadius * 2.0)
            mapView.setRegion(coordinateRegion, animated: true)
            setupWithNewLocation(currentLocation)
        }
    }

    func setupWithNewLocation(_ location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarkArray, error) in
            if let mark = placemarkArray?.first {
                if let streetNumber = mark.subThoroughfare,
                    let streetName = mark.thoroughfare,
                    let city = mark.locality,
                    let state = mark.administrativeArea,
                    let zip = mark.postalCode,
                    let countyName = mark.subAdministrativeArea {
                    self.infoCell.refreshLocationInformationLabels(Double(location.coordinate.latitude),
                                                                   lon: Double(location.coordinate.longitude),
                                                                   address: "\(streetNumber) \(streetName)\n\(city), \(state) \(zip)",
                                                                   county: countyName)
                } else {
                    self.infoCell.refreshLocationInformationLabels(Double(location.coordinate.latitude),
                                                                   lon: Double(location.coordinate.longitude),
                                                                   address: nil,
                                                                   county: nil)
                }
            } else {
                self.infoCell.refreshLocationInformationLabels(Double(location.coordinate.latitude),
                                                               lon: Double(location.coordinate.longitude),
                                                               address: nil,
                                                               county: nil)
            }
        }
    }

    func shareLocation() {
        refresh()
        guard let currentLocation = locationManager.location else {
            let alertController = UIAlertController(
                title: "Error",
                message: "Could not get current location.",
                preferredStyle: .alert)
            let tryAgain = UIAlertAction(title: "Try Again", style: .default, handler: { (action) in
                self.shareLocation()
            })
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                self.dismiss(animated: true, completion: nil)
            })
            alertController.addAction(tryAgain)
            alertController.addAction(cancel)
            if UIDevice().modelName.contains("Pad") {
                OCVAppUtilities.setupForPopOver(alertController, view: self.infoCell)
            }
            self.present(alertController, animated: true, completion: nil)
            return
        }
        let options = MKMapSnapshotOptions()
        options.region = mapView.region
        options.scale = UIScreen.main.scale
        options.size = mapView.frame.size

        let snapshotter = MKMapSnapshotter(options: options)
        snapshotter.start (completionHandler: { (snapshot, error) in
            guard snapshot != nil else {
                let alertController = UIAlertController(
                    title: "Error",
                    message: "An error has occurred snapshotting the map view.\n\(error)",
                    preferredStyle: .alert)
                let tryAgain = UIAlertAction(title: "Try Again", style: .default, handler: { (action) in
                    self.shareLocation()
                })
                let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                    self.dismiss(animated: true, completion: nil)
                })
                alertController.addAction(tryAgain)
                alertController.addAction(cancel)
                if UIDevice().modelName.contains("Pad") {
                    OCVAppUtilities.setupForPopOver(alertController, view: self.infoCell)
                }
                self.present(alertController, animated: true, completion: nil)
                return
            }
            self.createImageAndActivityController(snapshot!, location: currentLocation)
        })
    }

    func createImageAndActivityController(_ snapshot: MKMapSnapshot, location: CLLocation) {
        let image = snapshot.image
        let imageSize = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        let pin = MKPinAnnotationView(annotation: nil, reuseIdentifier: nil)
        UIGraphicsBeginImageContextWithOptions(image.size, true, image.scale)

        image.draw(at: CGPoint(x: 0, y: 0))

        for annotation in self.mapView.annotations {
            var point = snapshot.point(for: annotation.coordinate)

            if imageSize.contains(point) {
                let pinCenterOffset = pin.centerOffset
                point.x -= pin.bounds.size.width / 2.0
                point.y -= pin.bounds.size.height / 2.0
                point.x += pinCenterOffset.x
                point.y += pinCenterOffset.y

                pin.image?.draw(at: point)
            }
        }

        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        let locationDetails = "\nMy Current Location:\nLat: \(location.coordinate.latitude)\nLong: \(location.coordinate.longitude)\n\nApproximate Address:\n\(infoCell.addressLabel.text!)\n\nhttp://maps.google.com/maps?q=\(location.coordinate.latitude),\(location.coordinate.longitude)\n\nSent from the \(Config.appName) mobile app at \(Config.shareLink)."

        let activityController = UIActivityViewController(activityItems: [locationDetails, finalImage!], applicationActivities: nil)
        if UIDevice().modelName.contains("Pad") {
            OCVAppUtilities.setupForPopOver(activityController, view: infoCell)
        }
        present(activityController, animated: true, completion: nil)
    }

    func refresh() {
        centerMapOnLocation(locationManager.location)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        } else if status == .denied || status == .restricted {
            showErrorAlert()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !locationHasBeenFound { centerMapOnLocation(locations.last) }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error finding location: \(error.localizedDescription)")
    }

    func showErrorAlert() {
        if self.presentedViewController != nil { return }

        let alertController = UIAlertController(
            title: "Location Access Disabled",
            message: "This feature relies on accessing your current location. Please open this app's settings and set location access to 'While Using the App'.",
            preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
            let _ = self.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(cancelAction)

        let openAction = UIAlertAction(title: "Open Settings", style: .default) { (action) in
            if let url = URL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.shared.openURL(url)
            }
        }
        alertController.addAction(openAction)
        self.present(alertController, animated: true, completion: nil)
    }

    func setupViews() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "currentLocation"), style: .plain, target: self, action: #selector(OCVWhereAmI.refresh))

        let toolbar = UIToolbar()
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let share = UIBarButtonItem(title: "Share My Location", style: .plain, target: self, action: #selector(OCVWhereAmI.shareLocation))
        share.setTitleTextAttributes([NSFontAttributeName: AppFonts.SemiboldText.font(18)], for: UIControlState())
        share.tintColor = AppColors.oppositeOfPrimary.color

        toolbar.items = [flex, share, flex]

        view.addSubview(mapView)
        view.addSubview(toolbar)
        toolbar.snp.makeConstraints { (make) in
            make.bottom.equalTo(view)
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.top.equalTo(mapView.snp.bottom)
        }
        mapView.snp.makeConstraints { (make) in
            make.top.equalTo(view)
            make.left.equalTo(view)
            make.right.equalTo(view)
        }
        view.addSubview(infoCell)
        infoCell.snp.makeConstraints { (make) in
            if UIDevice().modelName.contains("Pad") {
                make.centerX.equalTo(view)
                make.width.equalTo(375)
            } else {
                make.left.equalTo(view).offset(10)
                make.right.equalTo(view).offset(-10)
            }
            make.height.equalTo(130)
            make.bottom.equalTo(toolbar.snp.top).offset(-10)
        }
    }
}
