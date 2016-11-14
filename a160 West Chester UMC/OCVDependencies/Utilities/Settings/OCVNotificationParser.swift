//
//  OCVJSONParser.swift
//  OCVSwift
//
//  Created by Eddie Seay on 1/14/16.
//  Copyright © 2016 OCV,LLC. All rights reserved.
//

import Foundation
import SwiftyJSON

class OCVNotificationParser {

    let dateFormatter = DateFormatter()

    deinit {
//        // Debug method to ensure that we are not creating
//        //  a strong reference cycle
//        print("JSON PARSER DEINIT CALLED")
    }

    // MARK: Messages
    func getMessageHistory(_ data: Data?) -> [Any] {
        guard let dataIn = data else {
            return []
        }

        let protectedChannels = OCVAppUtilities.SharedInstance.getProtectedChannels()
        let registeredChannels = OCVAppUtilities.SharedInstance.getRegisteredChannels()

        var feedArray = [Any]()
        let json = JSON(data: dataIn)
        for item in json["data"].arrayValue {
            let channel: String = item["channel"].stringValue
            if protectedChannels.contains(channel) && !registeredChannels.contains(channel) {
                continue
            }

            let id: String = item["_id"]["$id"].stringValue
            let title: String = item["push"].stringValue
            let description: String? = item["description"].string
            let channelTitle: String = item["channelTitle"].stringValue
            let date: Double = item["epoch"].doubleValue

                let epochNSDate = NSDate(timeIntervalSince1970: date)
            feedArray.append(OCVMessageObject(id: id, title: title, description: description, date: epochNSDate as Date, channel: channel, channelTitle: channelTitle))
        }

        return feedArray
    }


    // MARK: Push Notifications
    func updatedNotificationSettings(_ localData: Data?, downloadedData: Data?) -> Data {
        guard let lData = localData else {
            guard let dData = downloadedData else {
                return Data()
            }
            return dData
        }
        guard let dData = downloadedData else {
            return lData
        }

        let localJSON = JSON(data: lData)
        var networkJSON = JSON(data: dData)

        let updatedContents = compareContentSettings(localJSON["content"], downloaded: networkJSON["content"])
        let updatedMessages = compareMessageOrMassSettings(localJSON["messages"], downloaded: networkJSON["messages"])
        let updatedMass = compareMessageOrMassSettings(localJSON["mass"], downloaded: networkJSON["mass"])

        networkJSON["content"] = updatedContents
        networkJSON["messages"] = updatedMessages
        networkJSON["mass"] = updatedMass

        do {
            return try networkJSON.rawData()
        } catch let jsonError {
            print(jsonError)
        }

        return Data()
    }

    func compareContentSettings(_ local: JSON?, downloaded: JSON?) -> JSON {
        guard let loc = local else {
            guard let dl = downloaded else {
                print("Error: Both Local and Downloaded Content Feeds Nil")
                return JSON(1)
            }
            return dl
        }
        guard var dl = downloaded else {
            return loc
        }

        for (key, subJson): (String, JSON) in dl {
            if let localVersion = loc[key]["register"].bool {
                if subJson["register"].boolValue != localVersion {
                    dl[key]["register"].bool = localVersion
                }
            }
        }

        return dl
    }

    func compareMessageOrMassSettings(_ local: JSON?, downloaded: JSON?) -> JSON {
        guard let loc = local else {
            guard let dl = downloaded else {
                print("Error: Both Local and Downloaded Content Feeds Nil")
                return JSON(1)
            }
            return dl
        }
        guard var dl = downloaded else {
            return loc
        }

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
        case 0:
            sectionTitle = "content"
            break
        case 1:
            sectionTitle = "messages"
            break
        case 2:
            sectionTitle = "mass"
        default:
            break
        }

        var json = JSON(data: localData)

        json[sectionTitle][name]["register"].bool = !(json[sectionTitle][name]["register"].boolValue)

        do {
            return try json.rawData()
        } catch let jsonError {
            print(jsonError)
        }

        return Data()
    }

    func createContentObjects(_ data: Data) -> [OCVNotificationChannelObject] {
        var returnArray = [OCVNotificationChannelObject]()

        let json = JSON(data: data)
        for (key, subJson): (String, JSON) in json["content"] {
            guard let chanName = key as String?,
                let title = subJson["title"].string,
                let register = subJson["register"].bool else {
                    break
            }
            returnArray.append(OCVNotificationChannelObject(channelName: chanName, title: title, protection: "", register: register, order: 0))
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

    func parseNotificationChannelObject(_ dict: JSON, chanName: String, parseHidden: Bool) -> OCVNotificationChannelObject? {
        guard let title: String = dict["title"].string,
            let register: Bool = dict["register"].bool,
            let protection: String = dict["protection"].string,
            let order: Int = dict["order"].int,
            let hidden: Bool = dict["hidden"].bool else {
                return nil
        }

        if hidden == true && parseHidden == false {
            return nil
        } else if hidden == true && parseHidden == true {
            return OCVNotificationChannelObject(channelName: chanName, title: title, protection: protection, register: register, order: order)
        } else if hidden == false {
            return OCVNotificationChannelObject(channelName: chanName, title: title, protection: protection, register: register, order: order)
        }

        return nil
    }

}

