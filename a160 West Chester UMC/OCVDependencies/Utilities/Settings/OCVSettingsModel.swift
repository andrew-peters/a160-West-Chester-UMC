//
//  OCVSettingsModel.swift
//  OCVSwift
//
//  Created by Eddie Seay on 1/27/16.
//  Copyright © 2016 OCV,LLC. All rights reserved.
//

import UIKit

class OCVSettingsModel {

    var settingsGroups: [[OCVSettingsObject]] = []

    init() {
        var settingsObjects: Array<Array<Dictionary<String, String>>>
        if Config.containsOffenders == true {
            settingsObjects = [
                [["title": "Notification Settings",
                    "description": "Register and deregister channels"],
                    ["title": "Access Controls",
                        "description": "Location services, camera, etc."],
                    ["title": "Default Offender View", "description": "Please choose which sex offender view to see first."]],
                [["title": "Share Our App",
                    "description": ""],
                    ["title": "Review On App Store",
                        "description": ""],
                    ["title": "Developer Feedback",
                        "description": "Suggestions, bugs, ideas, etc."]],
                [["title": "About",
                    "description": getAppVersion()],
                    ["title": "Licenses",
                        "description": ""]]
            ]
        } else {
            settingsObjects = [
                [["title": "Notification Settings",
                    "description": "Register and deregister channels"],
                    ["title": "Access Controls",
                        "description": "Location services, camera, etc."]],
                [["title": "Share Our App",
                    "description": ""],
                    ["title": "Review On App Store",
                        "description": ""],
                    ["title": "Developer Feedback",
                        "description": "Suggestions, bugs, ideas, etc."]],
                [["title": "About",
                    "description": getAppVersion()],
                    ["title": "Licenses",
                        "description": ""]]
            ]
            
        }

        settingsGroups = populateSettingsArray(settingsObjects)
    }

    deinit {
//        print("Settings model deinit called")
    }

    func populateSettingsArray(_ fromArray: [[[String: String]]]) -> [[OCVSettingsObject]] {
        var retArray: [[OCVSettingsObject]] = []
        for item in fromArray {
            retArray.append(createGroup(item))
        }
        return retArray
    }

    func createGroup(_ fromItems: [[String: String]]) -> [OCVSettingsObject] {
        return fromItems.flatMap {
            parseCellObject($0)
        }
    }

    func parseCellObject(_ dict: [String: String]) -> OCVSettingsObject? {
        guard let title = dict["title"] else {
            return nil
        }

        let desc = dict["description"]

        return OCVSettingsObject(titleIn: title, description: desc, accessoryType: .disclosureIndicator)
    }

    func numberOfSections() -> Int {
        return settingsGroups.count
    }

    func titleAtIndexPath(_ indexPath: IndexPath) -> String {
        return settingsGroups[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row].title
    }

    func subtitleAtIndexPath(_ indexPath: IndexPath) -> String? {
        return settingsGroups[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row].subtitle
    }

    func cellTypeAtIndexPath(_ indexPath: IndexPath) -> UITableViewCellStyle {
        return settingsGroups[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row].cellType
    }

    func numRowsInSection(_ section: Int) -> Int {
        return settingsGroups[section].count
    }

    func shareController(_ link: String, cell: UITableViewCell) -> UIActivityViewController {
        let appLinkString = "Check out the \(Config.appName) mobile app at: \(link)!"
        let myActivityController = UIActivityViewController(activityItems: [appLinkString], applicationActivities: nil)
        myActivityController.modalPresentationStyle = .popover
        myActivityController.popoverPresentationController?.sourceRect = cell.bounds
        myActivityController.popoverPresentationController?.sourceView = cell
        myActivityController.popoverPresentationController?.permittedArrowDirections = .any

        return myActivityController
    }

    func getAppVersion() -> String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                return "App Version \(version), Build \(build)"
            }
            return "App Version\(version)"
        }
        return "no version info"
    }

    func textViewController(_ resourceName: String, type: String) -> UIViewController {
        let textViewVC = UIViewController()
        textViewVC.title = resourceName
        let myTextView = UITextView()
        myTextView.isEditable = false
        if resourceName == "Licenses" {
            myTextView.font = UIFont(name: "Menlo-Regular", size: 12)
        } else {
            myTextView.font = AppFonts.RegularText.font(12)
        }
        textViewVC.view = myTextView

        if let filepath = Bundle.main.path(forResource: resourceName.uppercased(), ofType: type) {
            do {
                let contents = try NSString(contentsOfFile: filepath, usedEncoding: nil) as String
                myTextView.text = contents

            } catch {
                // contents could not be loaded
            }
        } else {
            // example.txt not found!
        }

        return textViewVC
    }
}

struct OCVSettingsObject {
    let title: String
    let subtitle: String?
    let accessory: UITableViewCellAccessoryType
    let cellType: UITableViewCellStyle

    init(titleIn: String, description: String?, accessoryType: UITableViewCellAccessoryType) {
        self.accessory = accessoryType
        self.title = titleIn
        self.subtitle = description ?? ""

        if subtitle != "" {
            cellType = .subtitle
        } else {
            cellType = .default
        }
    }
}
