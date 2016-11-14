//
//  AWSAnalytics.swift
//  OCVSwift
//
//  Created by Eddie Seay on 6/15/16.
//  Copyright © 2016 OCV,LLC. All rights reserved.
//

import Foundation
import AWSCore
import AWSMobileAnalytics

class AWSAnalytics {

    static let SharedInstance = AWSAnalytics()

    private var openTime = NSDate()
    private var isFeatureOpen = false
    private var currentFeature = ""

    private let eventClient: AWSMobileAnalyticsEventClient!
    private let mobileAnalytics = AWSMobileAnalytics.init(forAppId: "\(Config.AWSAnalyticsIdentifier)",
                                                    identityPoolId: "us-east-1:2793e471-e8b3-4dba-8270-d1a4192c0d17")

    private init() {
        AWSLogger.default().logLevel = .none
        eventClient = mobileAnalytics?.eventClient
    }

    func openFeature(name: String) {
        if !isFeatureOpen {
            isFeatureOpen = !isFeatureOpen
            currentFeature = name
            openTime = NSDate()

            let openEvent = eventClient.createEvent(withEventType: name)
            openEvent?.addAttribute(name, forKey: "openFeature")
            eventClient.record(openEvent)
            print("AWS Analytics Recorded: openApp(\(name))")
        } else {
            print("\(currentFeature) not previously closed")
        }
    }

    func closeFeature() {
        if isFeatureOpen {
            isFeatureOpen = !isFeatureOpen

            let closeEvent = eventClient.createEvent(withEventType: currentFeature)
            let timeElapsed = NSNumber(value: round(100.0 * abs(openTime.timeIntervalSinceNow)) / 100.0)
            closeEvent?.addMetric(timeElapsed, forKey: "secondsInUse")
            eventClient.record(closeEvent)
            print("AWS Analytics Recorded: \"closeApp\" on feature: \(currentFeature)")
        } else {
            print("No feature currently open")
        }
    }

    func appOpened() {
        let appOpen = eventClient.createEvent(withEventType: "OpenApp")
        eventClient.record(appOpen)
        print("AWS Analytics Recorded: \"appOpened\"")
    }

    func appClosed() {
        if isFeatureOpen { closeFeature() }
        let appClose = eventClient.createEvent(withEventType: "CloseApp")
        eventClient.record(appClose)
        print("AWS Analytics Recorded: \"appClosed\"")
    }

}
