//
//  OCVAppUtilities.swift
//  OCVSwift
//
//  Created by Eddie Seay on 2/21/16.
//  Copyright © 2016 OCV,LLC. All rights reserved.
//

import UIKit
import EventKit
import Alamofire
import CryptoSwift
import SVProgressHUD

class OCVAppUtilities {
    fileprivate let applicationIdentifier = Config.applicationID
    fileprivate let applicationSecret = Config.applicationSecret
    fileprivate let applicationName = Config.appName
    fileprivate let itunesStoreLink = Config.itunesConnectLink
    fileprivate var deviceToken = ""
    fileprivate var protectedChannels = [String]()
    fileprivate var registeredChannels = [String]()
    static  var RecentAlertPollDate = Date(timeIntervalSince1970: 1183075200)
    fileprivate var recentAlerts = [OCVMessageObject]() {
        didSet {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "RecentAlertsUpdated"), object: nil)
            OCVAppUtilities.RecentAlertPollDate = Date()
        }
    }

    let manager = NetworkReachabilityManager(host: "www.apple.com")

    static let SharedInstance = OCVAppUtilities()

    fileprivate init() { manager?.startListening() }

    // MARK: API Assist Methods

    func setDeviceToken(_ token: String) {
        deviceToken = token
    }

    func currentDeviceToken() -> String {
        return deviceToken
    }

    func setProtectedChannels(_ protChannels: [String]) {
        self.protectedChannels = protChannels
    }

    func getProtectedChannels() -> [String] {
        return self.protectedChannels
    }

    func setRegisteredchannels(_ regChans: [String]) {
        self.registeredChannels = regChans
    }

    func getRegisteredChannels() -> [String] {
        return self.registeredChannels
    }

    func setRecentAlerts(_ timeframe: Int) {
        OCVNetworkClient().apiRequest(atPath: "/apps/push/2/history/\(applicationIdentifier)", httpMethod: .get, parameters: ["limit": "\(timeframe)"], showProgress: false) { resultData, _ in
            self.recentAlerts = OCVNotificationParser().getMessageHistory(resultData).flatMap { $0 as? OCVMessageObject }
        }
    }

    func getRecentAlerts() -> [OCVMessageObject] {
        return recentAlerts
    }

    static func finishTask() {
        SVProgressHUD.dismiss()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }

    func appStoreID() -> String {
        if let storeID = itunesStoreLink.between("/id", "?ls") {
            return storeID
        }

        return "1092902502" // Swift Development Platform Page. This is juat a placeholder
    }

    /**
     Determines whether or not appID and appSecret have been set
     so that the class knows whether or not to move forward.

     - returns: true or false
     */
    func validCredentials() -> Bool {
        if applicationIdentifier == "" || applicationSecret == "" {
            print("APP_ID AND/OR APP_SECRET NOT SET UP PROPERLY PRIOR TO CALL")
            return false
        }
        return true
    }

    /**
     Gets the menu headers to be used in drawer controller set up

     - returns: A tuple containing the primary header and the secondary header.
     */
    func getMenuHeaders() -> (primaryHeader: String?, secondaryHeader: String?) {
        return (Config.primaryMenuHeader, Config.secondaryMenuHeader)
    }

    /**
     Generates an API string to authenticate with OCV servers
     when making various types of calls. This is used when
     the API parameters are being passed inline with the URL.

     - returns: API validation string to add to the end of a URL.
     */
    func apiString() -> String {
        if validCredentials() == false {
            return ""
        }

        let (hashValue, timeStamp) = generateHMAC(applicationIdentifier, key: applicationSecret)

        return "appID=\(applicationIdentifier)&hash=\(hashValue)&time=\(timeStamp)"
    }

    /**
     Generates an API dictionary to authenticate with OCV servers
     when making various types of calls. This is used when
     the API parameters are being passed as params in the request.

     - returns: Dictionary of API parameters
     */
    func apiParams() -> [String: Any] {
        if validCredentials() == false {
            return [:]
        }

        let (hashValue, timeStamp) = generateHMAC(applicationIdentifier, key: applicationSecret)

        let params = ["appID": applicationIdentifier,
            "hash": hashValue,
            "time": NSNumber(value: timeStamp as Int)] as [String : Any]
        return params as [String : Any]
    }

    /**
     Generates an API dictionary to authenticate with OCV servers
     when making various types of calls. This is used when
     the API parameters are being passed as params in the request.

     Also adds into the dictionary other parameters that may need
     to be passed with the API.

     - parameter dict: Dictionary of additional params to pass to API

     - returns: Dictionary of params and API authentication params
     */
    func apiParamsPlus(_ dict: [String: Any]) -> [String: Any] {
        if validCredentials() == false {
            return [:]
        }

        let (hashValue, timeStamp) = generateHMAC(applicationIdentifier, key: applicationSecret)

        let params = ["appID": applicationIdentifier,
            "hash": hashValue,
            "time": NSNumber(value: timeStamp as Int)] as [String : Any]

        return dict.merge(params as Dictionary<String, Any>)
    }

    /**
     Generates a SHA256 HMAC has of the application's appID combined
     with the current system clock time. It uses the application's
     appSecret as a salt for the hash. This return is used as part
     of the authentication necessary for interacting with out API.

     - parameter messageIn: The message to be hashed
     - parameter key:       The salt value to hash with

     - returns: A tuple containing both the appSecret hash and
     the timeStamp value that was used to generate the hash.
     */
    fileprivate func generateHMAC(_ messageIn: String, key: String) -> (hashValue: String, timeStamp: Int) {
        let timeStamp = Date().timeIntervalSince1970.hashValue

        let msgEncrypt = "\(timeStamp)\(messageIn)"

        var keyBuff = [UInt8]()
        keyBuff += key.utf8

        var msgBuff = [UInt8]()
        msgBuff += msgEncrypt.utf8

        do {
            let hmac = try HMAC(key: keyBuff, variant: .sha256).authenticate(msgBuff)
            return (Data(bytes: hmac).toHexString(), timeStamp)
        } catch let hmacError {
            print(hmacError)
            return ("", 0)
        }
    }

    /**
     This method is an app-wide setup call to make a UIAlertController
     or UIActivityViewController pop-over ready if the application is
     running on an iPad.

     - parameter viewController: The UIAlertController of UIActivityViewController to be displayed
     - parameter view:           The root view of the viewcontroller being displayed.
     */
    class func setupForPopOver(_ viewController: UIViewController, view: UIView) {
        viewController.modalPresentationStyle = .popover
        viewController.popoverPresentationController?.sourceRect = view.bounds
        viewController.popoverPresentationController?.sourceView = view
        viewController.popoverPresentationController?.permittedArrowDirections = .any
    }

    func registerPushChannelsWithServer(_ channels: [[OCVNotificationChannelObject]]) {
        var returnChannels = [String: Bool]()
        for channel in (channels.flatMap { $0 }) {
            returnChannels[channel.channelName] = channel.register
        }

        let apiParams: [String: [String: AnyObject]] = ["channels": returnChannels as Dictionary<String, AnyObject>]
        print("Device Token: \(OCVAppUtilities.SharedInstance.deviceToken)")
        OCVNetworkClient().apiRequest(atPath: "/apps/push/2/register/ios/\(OCVAppUtilities.SharedInstance.deviceToken)", httpMethod: .post, parameters: apiParams, showProgress: false) { _, code in
            print("Notification Channel Registration Code: \(code)")
        }
    }

    static func addEventToCalendar(title: String, description: String?, location: String?, startDate: Date, endDate: Date, completion: ((_ success: Bool, _ error: NSError?) -> Void)? = nil) {
        let eventStore = EKEventStore()

        eventStore.requestAccess(to: .event, completion: { (granted, error) in
            if (granted) && (error == nil) {
                let event = EKEvent(eventStore: eventStore)
                event.title = title
                event.startDate = startDate
                event.endDate = endDate
                if let desc = description {
                    event.notes = desc
                }
                if let loc = location {
                    event.location = loc
                }
                event.calendar = eventStore.defaultCalendarForNewEvents
                do {
                    try eventStore.save(event, span: .thisEvent)
                    SVProgressHUD.showSuccess(withStatus: "Event Added!")
                } catch let e as NSError {
                    SVProgressHUD.showError(withStatus: "Event Could Not Be Added")
                    completion?(false, e)
                    return
                }
                completion?(true, nil)
            } else {
                SVProgressHUD.showError(withStatus: "ERROR: Permissions Denied")
                completion?(false, error as NSError?)
            }
        })
    }

    // swiftlint:disable cyclomatic_complexity
    static func compassDirection(_ angle: Double, full: Bool) -> String {
        switch angle {
        case 338...360:
            if full {
                return "North"
            }
            return "N"
        case 0..<23:
            if full {
                return "North"
            }
            return "N"
        case 23..<68:
            if full {
                return "Northeast"
            }
            return "NE"
        case 68..<113:
            if full {
                return "East"
            }
            return "E"
        case 113..<158:
            if full {
                return "Southeast"
            }
            return "SE"
        case 158..<203:
            if full {
                return "South"
            }
            return "S"
        case 203..<248:
            if full {
                return "Southwest"
            }
            return "SW"
        case 248..<293:
            if full {
                return "West"
            }
            return "W"
        case 293..<338:
            if full {
                return "Northwest"
            }
            return "NW"
        default:
            return "Invalid"
        }
    }
}

extension Data {
    var hexString: String {
        let pointer = UnsafePointer<UInt8>(bytes)
        let array = getByteArray(pointer)

        return array.reduce("") { (result, byte) -> String in
            result + String(format: "%02x", byte)
        }
    }

    fileprivate func getByteArray(_ pointer: UnsafePointer<UInt8>) -> [UInt8] {
        let buffer = UnsafeBufferPointer<UInt8>(start: pointer, count: count)

        return [UInt8](buffer)
    }
}

extension Dictionary {
    func merge(_ dict: Dictionary<Key, Value>) -> Dictionary<Key, Value> {
        var mutableCopy = self
        for (key, value) in dict {
            // If both dictionaries have a value for same key, the value of the other dictionary is used.
            mutableCopy[key] = value
        }
        return mutableCopy
    }
}
