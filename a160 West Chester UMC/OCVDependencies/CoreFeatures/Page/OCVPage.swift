//
//  OCVPageNew.swift
//  OCVSwift
//
//  Created by Eddie Seay on 6/22/16.
//  Copyright © 2016 OCV,LLC. All rights reserved.
//

import UIKit

class OCVPage {
    init(sourceURL: String, sourceNavigationController: UINavigationController) {
        if isValidURL(sourceURL) {
            createDetailAndPushToNav(sourceURL, nav: sourceNavigationController)
        } else { print("Invalid Page URL") }
    }
    
    init(sourceURL: String, sourceNavigationController: UINavigationController, isSettingsAbout: Bool) {
        if isValidURL(sourceURL)  {
            //Parse the settings about from the internal feed (requires different pearsing method)
            if (isSettingsAbout) {
                createSettingsDetailAndPushToNav(sourceURL, nav: sourceNavigationController)
            }
            else {
                createDetailAndPushToNav(sourceURL, nav: sourceNavigationController)
            }
        } else { print("Invalid Page URL") }
    }


    deinit { print("Page control deinitialized") }

    func isValidURL(_ url: String) -> Bool {
        if let validURL = URL(string: url) {
            if UIApplication.shared.canOpenURL(validURL) { return true }
        }
        return false
    }

    func createDetailAndPushToNav(_ url: String, nav: UINavigationController) {
        OCVNetworkClient().downloadFrom(url: url, showProgress: true) { resultData, _ in
            OCVAppUtilities.finishTask()
            if let pageObject = OCVFeedParser().parsePageFromData(resultData) {
                let pageViewModel = OCVPageObjectViewModel(model: pageObject)
                nav.pushViewController(OCVStandardDetail(object: pageViewModel), animated: true)
            } else { return }
        }
    }
    
    func createSettingsDetailAndPushToNav(_ url: String, nav: UINavigationController) {
        OCVNetworkClient().downloadFrom(url: url, showProgress: true) { resultData, _ in
            OCVAppUtilities.finishTask()
            if let pageObject = OCVFeedParser().parseSettingsAboutFromData(resultData) {
                let pageViewModel = OCVPageObjectViewModel(model: pageObject)
                nav.pushViewController(OCVStandardDetail(object: pageViewModel), animated: true)
            } else { return }
        }
    }

}
