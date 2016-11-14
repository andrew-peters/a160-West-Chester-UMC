//
//  OCVAPNSDataCoordinator.swift
//  OCVSwift
//
//  Created by Eddie Seay on 6/16/16.
//  Copyright © 2016 OCV,LLC. All rights reserved.
//

import Foundation
import SwiftyJSON

class OCVAPNSDataCoordinator {
    // MARK: Push Notifications
    func updatedNotificationSettings(_ localData: Data?, downloadedData: Data?) -> Data {
        guard let lData = localData else {
            guard let dData = downloadedData else { return Data() }
            return dData
        }
        guard let dData = downloadedData else { return lData }

        let localJSON = JSON(data: lData)
        var networkJSON = JSON(data: dData)

        networkJSON["content"] = compareSettings(localJSON["content"], downloaded: networkJSON["content"])
        networkJSON["messages"] = compareSettings(localJSON["messages"], downloaded: networkJSON["messages"])
        networkJSON["mass"] = compareSettings(localJSON["mass"], downloaded: networkJSON["mass"])

        do { return try networkJSON.rawData() } catch let jsonError { print(jsonError) }
        return Data()
    }

    fileprivate func compareSettings(_ local: JSON?, downloaded: JSON?) -> JSON {
        guard let loc = local else {
            guard let dl = downloaded else {
                print("Error: Both local and downloaded content feeds are Nil")
                return JSON(1)
            }
            return dl
        }
        guard var dl = downloaded else { return loc }
        for (key, subJson): (String, JSON) in dl {
            if let localVersion = loc[key]["register"].bool {
                if subJson["register"].boolValue != localVersion {
                    dl[key]["register"].bool = localVersion
                }
            }
        }
        return dl
    }

    func switchRegistrationForChannel(_ localData: Data, name: String, section: Int) -> Data {
        var sectionTitle = ""
        switch section {
        case 0: sectionTitle = "content"
        case 1: sectionTitle = "messages"
        case 2: sectionTitle = "mass"
        default: break
        }

        var json = JSON(data: localData)
        json[sectionTitle][name]["register"].bool = !(json[sectionTitle][name]["register"].boolValue)
        do { return try json.rawData() } catch let jsonError { print(jsonError) }
        return Data()
    }

    func createContentObjects(_ data: Data) -> [OCVNotificationChannelObject] {
        var returnArray: [OCVNotificationChannelObject] = []
        for (key, subJson): (String, JSON) in JSON(data)["content"] {
            guard let chanName = key as String?,
                let title = subJson["title"].string,
                let register = subJson["register"].bool else { continue }
            returnArray.append(OCVNotificationChannelObject(channelName: chanName,
                title: title,
                protection: "",
                register: register,
                order: 0))
        }
        return returnArray
    }

    func createMessageOrMassObjects(_ data: Data, category: String) -> [OCVNotificationChannelObject] {
        var returnArray = [OCVNotificationChannelObject]()
        let json = JSON(data: data)
        for (key, subJson): (String, JSON) in json[category] {
            if let newObject = parseNotificationChannelObject(subJson, chanName: key, parseHidden: false) {
                returnArray.append(newObject)
            }
        }
        return returnArray
    }

    func createMessageOrMassIncludingHidden(_ data: Data, category: String) -> [OCVNotificationChannelObject] {
        var returnArray = [OCVNotificationChannelObject]()
        let json = JSON(data: data)
        for (key, subJson): (String, JSON) in json[category] {
            if let newObject = parseNotificationChannelObject(subJson, chanName: key, parseHidden: true) {
                returnArray.append(newObject)
            }
        }
        return returnArray
    }

    fileprivate func parseNotificationChannelObject(_ item: JSON, chanName: String, parseHidden: Bool) -> OCVNotificationChannelObject? {
        guard let title = item["title"].string,
            let register = item["register"].bool,
            let protection = item["protection"].string,
            let order = item["order"].int,
            let hidden = item["hidden"].bool else { return nil }
        if !hidden || parseHidden {
            return OCVNotificationChannelObject(channelName: chanName,
                title: title,
                protection: protection,
                register: register,
                order: order)
        }
        return nil
    }
}
