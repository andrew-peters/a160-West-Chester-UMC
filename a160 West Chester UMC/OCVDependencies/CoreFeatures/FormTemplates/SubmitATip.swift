//
//  SubmitATip.swift
//  OCVSwift
//
//  Created by Eddie Seay on 5/25/16.
//  Copyright © 2016 OCV,LLC. All rights reserved.
//

// swiftlint:disable function_body_length

import UIKit
import Eureka
import CoreLocation
import SVProgressHUD

class SubmitATip: FormViewController, CLLocationManagerDelegate {
    
    var fromDrawer = false
    
    let formID: String!
    let defaultLocation: (Double, Double)!
    let locationManager = CLLocationManager()
    let locationRow: LocationRow!
    let addressRow: NameRow!
    var locationChanged = false
    let defaultLat: Double
    let defoultLong: Double
    
    var seenError: Bool = false
    var locationStatus: NSString = "Not Started"
    
    init(formID: String, defaultLat: Double, defaultLong: Double) {
        self.formID = formID
        self.defaultLocation = (defaultLat, defaultLong)
        self.defaultLat = defaultLat
        self.defoultLong = defaultLong
        locationRow = LocationRow("location") {
            $0.title = "Location of Incident"
            $0.value = CLLocation(latitude: defaultLat, longitude: defaultLong)        }
        addressRow = NameRow("address") {
            $0.title = "Address"
            $0.placeholder = "Optional"
        }
        super.init(style: .grouped)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        if seenError == false {
            seenError = true
            print(error)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let currentCoordinate = locations.last?.coordinate {
            locationRow.value = CLLocation(latitude: currentCoordinate.latitude, longitude: currentCoordinate.longitude)
        }
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case CLAuthorizationStatus.restricted:
            locationStatus = "Restricted Access to location"
        case CLAuthorizationStatus.denied:
            locationStatus = "User denied access to location"
        case CLAuthorizationStatus.notDetermined:
            locationStatus = "Status not determined"
        default:
            locationStatus = "Allowed to access location"
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager.stopUpdatingLocation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Submit A Tip"
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        form =
            Section()
            <<< PushRow<String>("reportType") {
                $0.title = "Report Type"
                $0.value = "Tap to Select"
                $0.options = ["Warrant",
                              "Most Wanted",
                              "Stolen Vehicle",
                              "Sex Crime",
                              "Robbery/Burglary/Theft",
                              "Kidnapping",
                              "Homicide",
                              "Fraud/Forgery",
                              "Elderly Abuse",
                              "Drug Crime",
                              "Assault/Battery",
                              "Other Crime"]
            }
            
            +++ Section("Contact Information")
            <<< NameRow("name") {
                $0.title = "Name"
                $0.placeholder = "Optional"
            }
            
            <<< EmailRow("emailAddress") {
                $0.title = "Email Address"
                $0.placeholder = "Optional"
            }
            
            <<< PhoneRow("phone") {
                $0.title = "Phone Number"
                $0.placeholder = "Optional"
            }
            
            +++ Section(header: "Incident Information", footer: "Please specify either the coordinates or address of this incident.")
            <<< locationRow.onCellSelection({ (cell, row) in
                if self.locationStatus == "Allowed to access location" {
                    self.locationManager.startUpdatingLocation()
                }
            })
            
            <<< addressRow
            
            <<< DateTimeInlineRow("dateTime") {
                $0.title = "Date and Time of Incident"
                $0.value = Date()
            }
            
            +++ Section("Additional Information")
            <<< ImageRow("images") {
                $0.title = "Tap to Add Image"
            }
            <<< TextAreaRow("feedbackText") {
                $0.placeholder = "Please give us any additional information you may have."
            }
            
            +++ Section(footer: "All personal information will remain confidential and will be used only for purposes of rectifying the situation at hand.")
            <<< ButtonRow("Submit Tip") {
                $0.title = $0.tag
                $0.onCellSelection({ (cell, row) in
                    self.submitForm()
                })
        }
    }
    
    func submitForm() {
        let reportTypeRow: PushRow<String>? = form.rowBy(tag: "reportType")
        let reportTypeVal = reportTypeRow?.value
        
        let nameRow: NameRow? = form.rowBy(tag: "name")
        let nameVal = nameRow?.value ?? "empty"
        
        let myEmailRow: EmailRow? = form.rowBy(tag: "emailAddress")
        let emailVal = myEmailRow?.value ?? "empty"
        
        let myPhoneRow: PhoneRow? = form.rowBy(tag: "phone")
        let myPhoneVal = myPhoneRow?.value ?? "empty"
        
        let locationRow: LocationRow? = form.rowBy(tag: "location")
        var locationVal = defaultLocation
        let location1 = locationRow!.value?.coordinate
        let location2 = CLLocationCoordinate2D(latitude: self.defaultLat, longitude: self.defoultLong)
        if location1?.latitude != location2.latitude {
            let coord = location1
            locationVal = (Double(coord!.latitude), Double(coord!.longitude))
        }
        
        let addressRow: NameRow? = form.rowBy(tag: "address")
        let addressVal = addressRow?.value ?? "empty"
        
        let myDateTimeRow: DateTimeInlineRow? = form.rowBy(tag: "dateTime")
        let myDateTime = myDateTimeRow?.value?.description ?? "could not get date and time"
        
        let myImageRow: ImageRow? = form.rowBy(tag: "images")
        let myImage = myImageRow?.value
        var encodedData = [String]()
        if myImage != nil {
            let imageData = UIImageJPEGRepresentation(myImage!, 0.25)!
            encodedData.append(imageData.base64EncodedString())
        }
        
        let feedbackTextRow: TextAreaRow? = form.rowBy(tag: "feedbackText")
        let feedbackTextVal: String? = feedbackTextRow?.value
        
        if reportTypeVal == "Tap to Select" {
            SVProgressHUD.showError(withStatus: "Must Select Report Type!")
        } else if locationVal! == defaultLocation && addressVal == "empty" {
            SVProgressHUD.showError(withStatus: "Must Provide Valid Location of Incident!")
        } else if feedbackTextVal == nil {
            SVProgressHUD.showError(withStatus: "Must Provide Feedback Text!")
        } else {
            let formFields: [String: AnyObject] = [
                "report_name": "Submit-A-Tip" as AnyObject,
                "selection_type": reportTypeVal! as AnyObject,
                "user_Name": nameVal as AnyObject,
                "user_Phone": myPhoneVal as AnyObject,
                "user_Email": emailVal as AnyObject,
                "report_addCoordinates": "\(locationVal!.0), \(locationVal!.1)" as AnyObject,
                "report_addAddress": addressVal as AnyObject,
                "report_date": myDateTime as AnyObject,
                "report_time": myDateTime as AnyObject,
                "report_details": feedbackTextVal! as AnyObject,
                "images": encodedData as AnyObject]
            
            _ = EZLoadingActivity.show("Submitting...", disableUI: true)
            OCVNetworkClient().apiRequest(atPath: "/forms/submit/\(Config.applicationID)/\(formID)", httpMethod: .post, parameters: formFields, showProgress: false) { resultData, code in
                if code == 200 {
                    _ = EZLoadingActivity.hide(true, animated: false)
                    self.perform(#selector(self.dismissView), with: self, afterDelay: 1.0)
                } else {
                    _ = EZLoadingActivity.hide()
                    let alertController = UIAlertController(title: "Submission Failure", message: "Error Code: \(code)", preferredStyle: .alert)
                    let actionReload = UIAlertAction(title: "Try Again", style: .default) { (action) -> Void in
                        self.submitForm()
                    }
                    let actionDismiss = UIAlertAction(title: "Dismiss", style: .cancel, handler: { (action) -> Void in
                        _ = self.navigationController?.popViewController(animated: true)
                    })
                    alertController.addAction(actionReload)
                    alertController.addAction(actionDismiss)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    func dismissView() {
        if !fromDrawer {
            _ = self.navigationController?.popViewController(animated: true)
        } else {
            self.evo_drawerController?.toggleDrawerSide(.left, animated: true, completion: nil)
        }
    }
}
