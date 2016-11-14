//
//  OCVDeveloperFeedbackForm.swift
//  OCVSwift
//
//  Created by Eddie Seay on 3/24/16.
//  Copyright © 2016 OCV,LLC. All rights reserved.
//

import UIKit
import CoreTelephony
import WatchConnectivity
import Eureka
import SVProgressHUD

class OCVDeveloperFeedbackForm: FormViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Feedback"
        
        form =
            Section(header: "Contact Information", footer: "We may not contact you, but it can be very helpful in our development process if we are able to.")
            <<< NameRow("name") {
                $0.placeholder = "Name (optional)"
            }
            
            <<< EmailRow("emailAddress") {
                $0.placeholder = "Email Address (optional)"
            }
            
            <<< SwitchRow("contact_me") {
                $0.title = "Allow Contact"
                $0.value = true
                $0.hidden = Condition.function(["emailAddress"], { (form) -> Bool in
                    let row: EmailRow! = form.rowBy(tag: "emailAddress")
                    return row.value == nil
                })
            }
            
            +++ Section("Feedback for Developer")
            <<< AlertRow<String>("feedbackType") {
                $0.title = "Feedback Type"
                $0.selectorTitle = "Select Feedback Type"
                $0.options = ["Bug Report", "General Suggestions", "Compliments & Kudos"]
                $0.value = "Tap to Select"
            }
            
            <<< TextAreaRow("feedbackText") {
                $0.placeholder = "Type feedback information here for developer."
            }
            
            +++ Section(header: "How would you rate this app?", footer: "Note: 5 = Highest / 1 = Lowest")
            <<< SegmentedRow<String>("appRating") {
                $0.options = ["1", "2", "3", "4", "5"]
                $0.value = "5"
            }
            
            +++ Section(footer: "All information submitted will remain confidential with OCV, LLC and is used for the sole purpose of improving our user experiences.")
            <<< ButtonRow("Submit Feedback") {
                $0.title = $0.tag
                $0.onCellSelection({ (cell, row) in
                    self.submitForm()
                })
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
    }
    
    func submitForm() {
        let myNameRow: NameRow? = form.rowBy(tag: "name")
        let nameVal = myNameRow?.value ?? "empty"
        
        let myEmailRow: EmailRow? = form.rowBy(tag: "emailAddress")
        let emailVal = myEmailRow?.value ?? "empty"
        
        let contactMeRow: SwitchRow? = form.rowBy(tag: "contact_me")
        let contactMeVal = emailVal != "empty" ? contactMeRow?.value ?? true : false
        
        let feedbackTypeRow: AlertRow<String>? = form.rowBy(tag: "feedbackType")
        let feedbackTypeVal: String? = feedbackTypeRow?.value
        
        let feedbackTextRow: TextAreaRow? = form.rowBy(tag: "feedbackText")
        let feedbackTextVal: String? = feedbackTextRow?.value
        
        let appRatingRow: SegmentedRow<String>? = form.rowBy(tag: "appRating")
        let appRatingVal = appRatingRow?.value
        
        if feedbackTypeVal == "Tap to Select" {
            SVProgressHUD.showError(withStatus: "Must Provide Feedback Type!")
        } else if feedbackTextVal == nil {
            SVProgressHUD.showError(withStatus: "Must Provide Feedback Text!")
        } else {
            let formFields: [String: AnyObject] = ["name": nameVal as AnyObject,
                                                   "email": emailVal as AnyObject,
                                                   "contactMe": contactMeVal as AnyObject,
                                                   "type": feedbackTypeVal! as AnyObject,
                                                   "feedback": feedbackTextVal! as AnyObject,
                                                   "rating": appRatingVal! as AnyObject]
            let deviceInfo = getDeviceAndAppInfo()
            
            let feedbackSubmission = ["formFields": formFields, "deviceInfo": deviceInfo]
            print(feedbackSubmission)
            
            _ = EZLoadingActivity.show("Submitting...", disableUI: true)
            
            OCVNetworkClient().apiRequest(atPath: "/apps/feedback", httpMethod: .post, parameters: feedbackSubmission as [String : AnyObject], showProgress: true) { resultData, code in
                if code == 200 {
                    _ = EZLoadingActivity.hide(true, animated: false)
                    print("Successful Submission")
                } else {
                    _ = EZLoadingActivity.hide(false, animated: false)
                    print("An Error Has Occurred")
                }
                self.perform(#selector(self.dismissView), with: self, afterDelay: 1.5)
            }
        }
    }
    
    func getDeviceAndAppInfo() -> [String: AnyObject] {
        var deviceInfoDict = [String: AnyObject]()
        deviceInfoDict["appVersion"] = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String as AnyObject?? ?? "no version info" as AnyObject?
        deviceInfoDict["buildNumber"] = Bundle.main.infoDictionary?["CFBundleVersion"] as? String as AnyObject?? ?? "no build info" as AnyObject?
        
        let os = ProcessInfo().operatingSystemVersion
        deviceInfoDict["operatingSystem"] = "\(os.majorVersion).\(os.minorVersion).\(os.patchVersion)" as AnyObject?
        deviceInfoDict["deviceName"] = UIDevice.current.modelName as AnyObject?
        deviceInfoDict["carrierName"] = CTTelephonyNetworkInfo().subscriberCellularProvider?.carrierName as AnyObject?
        deviceInfoDict["timezone"] = TimeZone.autoupdatingCurrent.identifier as AnyObject?
        deviceInfoDict["deviceLocalization"] = Locale.current.identifier as AnyObject?
        
        //determine if there is a watch
        if #available(iOS 9.0, *) {
            deviceInfoDict["pairedWatch"] = WCSession.default().isPaired as AnyObject?
        } else {
            deviceInfoDict["pairedWatch"] = false as AnyObject?
        }
        
        //add the device token
        deviceInfoDict["deviceToken"] = OCVAppUtilities.SharedInstance.currentDeviceToken() as AnyObject?
        
        //is app testflight
        if Platform.isSimulator {
            /////////////////////////////////////////////////
            // Need to verify that this section is working //
            /////////////////////////////////////////////////
            let isRunningTestFlightBeta = Bundle.main.appStoreReceiptURL?.lastPathComponent
            if isRunningTestFlightBeta == "sandboxReceipt" {
                deviceInfoDict["isRunnningTestflight"] = "Testflight Version" as AnyObject?
            }
            else {
                deviceInfoDict["isRunnningTestflight"] = "AppStore Version" as AnyObject?
            }
        }
        else {
            deviceInfoDict["isRunnningTestflight"] = "iPhone Simulator" as AnyObject?
        }
        
        //determine if notifications are enabled
        let notificationType = UIApplication.shared.currentUserNotificationSettings!.types
        if notificationType == UIUserNotificationType() {
            //            print("OFF")
            deviceInfoDict["notifications"] = "Push Notifications Off" as AnyObject?
        } else {
            //            print("ON")
            deviceInfoDict["notifications"] = "Push Notifications On" as AnyObject?
        }
        
        return deviceInfoDict
    }
    
    func dismissView() {
        _ = self.navigationController?.popViewController(animated: true)
    }
}

struct Platform {
    
    static var isSimulator: Bool {
        return TARGET_OS_SIMULATOR != 0 // Use this line in Xcode 7 or newer
        //        return TARGET_IPHONE_SIMULATOR != 0 // Use this line in Xcode 6
    }
    
}
