//
//  DamageReport.swift
//  OCVSwift
//
//  Created by Eddie Seay on 5/25/16.
//  Copyright © 2016 OCV,LLC. All rights reserved.
//

// swiftlint:disable function_body_length

import UIKit
import Eureka
import SVProgressHUD

class DamageReport: FormViewController {

    var fromDrawer = false

    let formID: String!
    let state: String!

    init(formID: String, state: String) {
        self.formID = formID
        self.state = state
        super.init(style: .grouped)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Damage Report"

        form =
            Section()
            <<< PushRow<String>("reportType") {
                $0.title = "Report Type"
                $0.value = "Tap to Select"
                $0.options = ["Severe Weather", "Storm Damage", "Power Outage", "Non-Emergency Info"]
            }

            +++ Section("Personal Details")
            <<< NameRow("firstName") {
                $0.title = "First Name"
                $0.placeholder = "Optional"
            }

            <<< NameRow("lastName") {
                $0.title = "Last Name"
                $0.placeholder = "Optional"
            }

            <<< PhoneRow("phone") {
                $0.title = "Phone Number"
                $0.placeholder = "Optional"
            }

            <<< EmailRow("emailAddress") {
                $0.title = "Email Address"
                $0.placeholder = "Required"
            }

            +++ Section("Report Details")
//            <<< PostalAddressRow("address") {
//                $0.title = "Address of Incident"
//
//                $0.streetPlaceholder = "Street"
//                $0.statePlaceholder = "State"
//                $0.postalCodePlaceholder = "Zip Code"
//                $0.cityPlaceholder = "City"
//
//                $0.value = PostalAddress(street: nil, state: self.state, postalCode: nil, city: nil, country: "USA")}
            <<< TextRow("address") {
                $0.title = "Street Address"
            }
            
            <<< TextRow("cityState") {
                $0.title = "City, State"
            }
            
            <<< ZipCodeRow("zipCode") {
                $0.title = "Zip Code"
            }

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
            <<< ButtonRow("Submit Report") {
                $0.title = $0.tag
                $0.onCellSelection({ (cell, row) in
                    self.submitForm()
                })
        }
    }

    func submitForm() {
        let reportTypeRow: PushRow<String>? = form.rowBy(tag: "reportType")
        let reportTypeVal = reportTypeRow?.value

        let firstNameRow: NameRow? = form.rowBy(tag: "firstName")
        let firstNameVal = firstNameRow?.value ?? "empty"

        let lastNameRow: NameRow? = form.rowBy(tag: "lastName")
        let lastNameVal = lastNameRow?.value ?? "empty"

        let myPhoneRow: PhoneRow? = form.rowBy(tag: "phone")
        let myPhoneVal = myPhoneRow?.value ?? "empty"

        let myEmailRow: EmailRow? = form.rowBy(tag: "emailAddress")
        let emailVal = myEmailRow?.value
        
        let streetRow: TextRow? = form.rowBy(tag: "address")
        let myStreet = streetRow?.value
        
        let cityStateRow: TextRow? = form.rowBy(tag: "cityState")
        let myCity = cityStateRow?.value
        let myState = cityStateRow?.value
        
        let zipCodeRow: ZipCodeRow? = form.rowBy(tag: "zipCode")
        let myPostalCode = zipCodeRow?.value

        let myDateTimeRow: DateTimeInlineRow? = form.rowBy(tag: "dateTime")
        let myDateTime = myDateTimeRow?.value?.description

        let myImageRow: ImageRow? = form.rowBy(tag: "images")
        let myImage = myImageRow?.value
        var encodedData = [String]()
        if myImage != nil {
            let imageData = UIImageJPEGRepresentation(myImage!, 0.25)
            encodedData.append((imageData?.base64EncodedString())!)
        }

        let feedbackTextRow: TextAreaRow? = form.rowBy(tag: "feedbackText")
        let feedbackTextVal: String? = feedbackTextRow?.value

        if reportTypeVal == "Tap to Select" {
            SVProgressHUD.showError(withStatus: "Must Select Report Type!")
        } else if emailVal == nil {
            SVProgressHUD.showError(withStatus: "Must Provide Valid Email Address!")
        } else if myStreet == nil || myCity == nil || myState == nil || myPostalCode == nil {
            SVProgressHUD.showError(withStatus: "Must Provide Valid Address!")
        } else if feedbackTextVal == nil {
            SVProgressHUD.showError(withStatus: "Must Provide Feedback Text!")
        } else {
            let formFields: [String: AnyObject] = [
                "report_name": "Damage Report" as AnyObject,
                "report_dropdown": reportTypeVal! as AnyObject,
                "user_firstName": firstNameVal as AnyObject,
                "user_lastName": lastNameVal as AnyObject,
                "user_defaultPhone": myPhoneVal as AnyObject,
                "email_address": emailVal! as AnyObject,
                "report_addAddress": myStreet! as AnyObject,
                "report_addCityState": "\(myCity!), \(myState!)" as AnyObject,
                "report_date": myDateTime! as AnyObject,
                "report_time": myDateTime! as AnyObject,
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
