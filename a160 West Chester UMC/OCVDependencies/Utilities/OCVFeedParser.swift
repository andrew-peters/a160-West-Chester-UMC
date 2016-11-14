//
//  OCVFeedParser.swift
//  OCVSwift
//
//  Created by Eddie Seay on 5/2/16.
//  Copyright © 2016 OCV,LLC. All rights reserved.
//

import Foundation
import JASON

// swiftlint:disable type_body_length
class OCVFeedParser {

    let dateFormatter = DateFormatter()

    // MARK: Table
    func parseArrayOfTableObjectsFromData(_ data: Data?) -> [Any] {
        guard let dataIn = data,
            let tableItems = JSON(dataIn).jsonArray else { return [] }
        return tableItems.flatMap { parseTableObject($0) }
    }

    fileprivate func parseTableObject(_ item: JSON) -> OCVTableObject {
        let id = item["_id"]["$id"].string
        let title = item["title"].string
        let content = item["content"].string
        let creator = item["creator"].string
        let epochDate = item["date"]["sec"].doubleValue
        let imagesArray: [AnyObject]? = item["images"].array
        let epochNSDate = Date(timeIntervalSince1970: epochDate)
        let dateString = DateFormatter.localizedString(from: epochNSDate, dateStyle: .long, timeStyle: .short)
        return OCVTableObject(id: id,
            title: title,
            content: content,
            creator: creator,
            date: dateString,
            imageArr: imagesArray)
    }

    // MARK: Page
    func parsePageFromData(_ data: Data?) -> OCVPageObject? {
        guard let dataIn = data else { return nil }
        let item = JSON(dataIn)
        guard let id = item["_id"]["$id"].string,
            let title = item["data"]["title"].string,
            let content = item["data"]["content"].string,
        let imagesArray = item["data"]["images"].array as? [[String: String]] else { return nil }
        return OCVPageObject(identifier: id,
            title: title,
            content: content,
            images: imagesArray)
    }

    // DO NOT USE. Currently parsing in OCVNotificationParser
//    // MARK: Messages
//    func getMessageHistory(data: NSData?) -> [OCVMessageObject] {
//        guard let dataIn = data,
//            let messageItems = JSON(dataIn)["data"].jsonArray else { return [] }
//        let protectedChannels = OCVAppUtilities.SharedInstance.getProtectedChannels()
//        let registeredChannels = OCVAppUtilities.SharedInstance.getRegisteredChannels()
//        return messageItems.flatMap { parsePushHistoryMessage($0, protectedChannels: protectedChannels, registeredChannels: registeredChannels) }
//    }
//
//    private func parsePushHistoryMessage(item: JSON, protectedChannels: [String], registeredChannels: [String]) -> OCVMessageObject? {
//        guard let channel = item["channel"].string else { return nil }
//        guard !protectedChannels.contains(channel) && registeredChannels.contains(channel) else { return nil }
//        guard let id = item["_id"]["$id"].string,
//            let title = item["push"].string,
//            let channelTitle = item["channelTitle"].string,
//            let epochDate = item["epoch"].double else { return nil }
//        let date = NSDate(timeIntervalSince1970: epochDate)
//        let description = item["description"].stringValue
//        return OCVMessageObject(id: id,
//            title: title,
//            description: description,
//            date: date,
//            channel: channel,
//            channelTitle: channelTitle)
//    }

    // MARK: Twitter
    func getAllTweets(_ data: Data?) -> [Any] {
        guard let dataIn = data,
            let tweets = JSON(dataIn)["data"].jsonArray else { return [] }
        dateFormatter.dateFormat = "EEE MMM dd HH:mm:ss yyyy"
        return tweets.flatMap { parseTweet($0) }
    }

    fileprivate func parseTweet(_ item: JSON) -> OCVTwitterObject? {
        guard let post_date = dateFormatter.date(from: item["created_at"].stringValue.replacingOccurrences(of: " +0000", with: "")) else { return nil }
        let fromDate = Date().timeAgoSinceDate(post_date, numericDates: true)
        guard let id = item["id_str"].string,
            let content = item["text"].string,
            let user_id = item["user"]["id_str"].string,
            let user_url = item["user"]["url"].string else { return nil }

        var content_urlstring = ""
        if let mediaURL = item["entities"]["media"][0]["url"].string {
            content_urlstring = mediaURL
        } else {
            content_urlstring = item["entities"]["urls"][0]["url"].stringValue
        }

        var userTitle = ""
        var profile_picstr = ""
        if let _ = item["retweeted_status"].dictionary {
            userTitle = item["retweeted_status"]["user"]["name"].stringValue
            profile_picstr = item["retweeted_status"]["user"]["profile_image_url_https"].stringValue.replacingOccurrences(of: "normal", with: "bigger")            
        } else {
            userTitle = item["user"]["name"].stringValue
            profile_picstr = item["user"]["profile_image_url_https"].stringValue.replacingOccurrences(of: "normal", with: "bigger")
        }

        return OCVTwitterObject(id: id,
            title: userTitle,
            content: content,
            contentURLstring: content_urlstring,
            fromDate: fromDate,
            userID: user_id,
            userURLstring: user_url,
            profURLstring: profile_picstr)
    }
    
    // MARK: Settings
    func parseSettingsAboutFromData(_ data: Data?) -> OCVPageObject? {
        guard let dataIn = data else { return nil }
        let item = JSON(dataIn)
        guard let id = item["_id"]["$id"].string,
            let content = item["data"]["content"].string,
            let iOSChangelog = item["data"]["iOSChangeLog"].string
            else {
                return nil
        }
        
        let fullContent = "\(content)<p></p>\(iOSChangelog)"
        //create empty dictionary
        let emptyDic = [[String: String]]()
        
        return OCVPageObject(identifier: id,
                             title: "About this app",
                             content: fullContent,
                             images: emptyDic)
    }


    // MARK: Contacts
    func parseContactHeadersFromData(_ data: Data?) -> [String] {
        guard let dataIn = data,
            let contactHeaders = JSON(dataIn)["headers"].jsonArray else { return [] }
        return contactHeaders.flatMap { $0.string }
    }

    func getAllContactArraysFromData(_ data: Data?, order: [String]) -> [[OCVContactObject]] {
        guard let dataIn = data,
            let entries = JSON(dataIn)["entries"].jsonDictionary else { return [] }
        return order.flatMap {
            guard let groupArr = entries[$0]?.jsonArray else { return nil }
            return groupArr.flatMap { parseContactObject($0) }
        }
    }

    fileprivate func parseContactObject(_ item: JSON) -> OCVContactObject? {
        guard let title = item["title"].string else { return nil }
        let jobTitle = item["jobtitle"].string
        let email = item["email"].string
        let phone = item["phone"].string
        let fax = item["fax"].string
        let address = item["address"].string
        let website = item["website"].string
        let description = item["description"].string
        let image = item["image"].string
        return OCVContactObject(title: title,
            jobTitle: jobTitle,
            email: email,
            phone: phone,
            fax: fax,
            address: address,
            website: website,
            description: description,
            image: image)
    }

    // MARK: Slider
    func parseImageLinks(_ data: Data?) -> [URL] {
        guard let strings = JSON(data)["data"].jsonArray else { return [] }
        return strings.flatMap { URL(string: $0.stringValue) }
    }

    // MARK: Calendar
    func parseCalendarEvents(_ data: Data?) -> [[OCVCalendarEvent]] {
        guard let dataIn = data else { return [[]] }
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        let dateAllDayFormatter = DateFormatter()
        dateAllDayFormatter.dateFormat = "yyyy-MM-dd"
        let allEvents = JSON(dataIn)["items"].jsonArrayValue.flatMap { parseEvent($0) }
        let pastEvents = allEvents.filter { $0.startDate.timeIntervalSinceNow < 0.0 }
        let futureEvents = allEvents.filter { $0.startDate.timeIntervalSinceNow >= 0.0 }
        return [pastEvents, futureEvents]
    }

    fileprivate func parseEvent(_ item: JSON) -> OCVCalendarEvent? {
        
        let dateAllDayFormatter = DateFormatter()
        dateAllDayFormatter.dateFormat = "yyyy-MM-dd"
        
        let id = item["id"].string ?? ""
        let htmlLink = item["htmlLink"].string ?? ""
        let summary = item["summary"].string ?? ""
        let icaluid = item["iCalUID"].string ?? ""
        var start = item["start"]["dateTime"].string ?? ""
        var end = item["end"]["dateTime"].string ?? ""
        
        if start == "" {
            start = item["start"]["date"].string ?? ""
        }
        
        if end == "" {
            end = item["end"]["date"].string ?? ""
        }
        
        var startDate = dateFormatter.date(from: start)
        var endDate = dateFormatter.date(from: end)
        
        if startDate == nil {
            startDate = dateAllDayFormatter.date(from: start)
        }
        
        if endDate == nil {
            endDate = dateAllDayFormatter.date(from: end)
        }
        
        if startDate == nil || endDate == nil {
            return nil
        }
        
        let description = item["description"].string ?? ""
        let location = item["location"].string ?? ""
        return OCVCalendarEvent(identifier: id,
            htmlLink: htmlLink,
            summary: summary,
            description: description,
            location: location,
            startDate: startDate!,
            endDate: endDate!,
            iCalUID: icaluid)
    }

    // MARK: Digest
    func parseDigestObjects(_ data: Data?) -> [OCVDigestObject] {
        guard let dataIn = data,
            let objects = JSON(dataIn).jsonArray else { return [] }
        return objects.flatMap { parseDigestObject($0) }
    }

    fileprivate func parseDigestObject(_ item: JSON) -> OCVDigestObject? {
        guard let epoch = item["epoch"].double,
            let type = item["type"].int,
            let title = item["title"].string,
            let feedID = item["feedID"].int,
            let origin = item["origin"].int,
            let content = item["content"].string,
            let summary = item["summary"].string else { return nil }
        let epochDate = Date(timeIntervalSince1970: epoch)
        let fbStatusType = item["status_type"].string
        let tweetID = item["id_str"].string
//        return OCVDigestObject(date: epochDate,
//            mediaType: type,
//            feedID: feedID,
//            origin: origin,
//            title: title,
//            content: content,
//            summary: summary,
//            fbStatusType: fbStatusType,
//            tweetID: tweetID)
        
    return OCVDigestObject(date: epochDate, mediaType: type, feedID: feedID, origin: origin, title: title, content: content, summary: summary, fbStatusType: fbStatusType, tweetID: tweetID)
        
    }

    // MARK: Weather
    func parseCurrentWeather(_ data: Data, local: Bool) -> CurrentWeatherForecast? {
        var currently = JSON(data)
        if local { currently = currently["data"]["currently"] } else { currently = currently["forecast"]["currently"] }

        let epoch = currently["time"].double ?? 000000
        let summary = currently["summary"].string ?? "N/A"
        let icon = currently["icon"].string ?? "N/A"
        let precipIntensity = currently["precipIntensity"].double ?? 100000
        let precipProbability = currently["precipProbability"].double ?? 100000
        let temperature = currently["temperature"].double ?? 100000
        let apparentTemperature = currently["apparentTemperature"].double ?? 100000
        let dewPoint = currently["dewPoint"].double ?? 100000
        let humidity = currently["humidity"].double ?? 100000
        let windSpeed = currently["windSpeed"].double ?? 100000
        let windBearing = currently["windBearing"].double ?? 100000
        let visibility = currently["visibility"].double ?? 100000
        let cloudCover = currently["cloudCover"].double ?? 100000
        var pressure = currently["pressure"].double ?? 100000
        // Convert from Hectopascals to inches of mercury
        pressure = pressure * 0.02953
        let ozone = currently["ozone"].double ?? 100000
        let date = Date(timeIntervalSince1970: epoch)
        return CurrentWeatherForecast(date: date, summary: summary, icon: icon, precipIntensity: precipIntensity, precipProbability: precipProbability, temperatureF: temperature, apparentTemperatureF: apparentTemperature, dewPoint: dewPoint, humidity: humidity, windSpeedMPH: windSpeed, windBearing: windBearing, visibility: visibility, cloudCover: cloudCover, pressure: pressure, ozone: ozone)
    }

    func parseHourlyWeather(_ data: Data, local: Bool) -> [HourlyForecast] {
        let weatherRoot = JSON(data)
        if local {
            let hours = weatherRoot["data"]["hourly"]["data"].jsonArrayValue
            return hours.flatMap { parseHour($0) }
        } else {
            let hours = weatherRoot["forecast"]["hourly"]["data"].jsonArrayValue
            return hours.flatMap { parseHour($0) }
        }
    }

    fileprivate func parseHour(_ hour: JSON) -> HourlyForecast? {
        let epoch = hour["time"].double ?? 000000
        let summary = hour["summary"].string ?? "N/A"
        let icon = hour["icon"].string ?? "N/A"
        let precipIntensity = hour["precipIntensity"].double ?? 100000
        let precipProbability = hour["precipProbability"].double ?? 100000
        let temperature = hour["temperature"].double ?? 100000
        let apparentTemperature = hour["apparentTemperature"].double ?? 100000
        let dewPoint = hour["dewPoint"].double ?? 100000
        let humidity = hour["humidity"].double ?? 100000
        let windSpeed = hour["windSpeed"].double ?? 100000
        let windBearing = hour["windBearing"].double ?? 100000
        let visibility = hour["visibility"].double ?? 100000
        let cloudCover = hour["cloudCover"].double ?? 100000
        var pressure = hour["pressure"].double ?? 100000
        // Convert from Hectopascals to inches of mercury
        pressure = pressure * 0.02953
        let ozone = hour["ozone"].double ?? 100000
        let timeDate = Date(timeIntervalSince1970: epoch)
        return HourlyForecast(date: timeDate, summary: summary, icon: icon, precipIntensity: precipIntensity, precipProbability: precipProbability, temperatureF: temperature, apparentTemperatureF: apparentTemperature, dewPoint: dewPoint, humidity: humidity, windSpeedMPH: windSpeed, windBearing: windBearing, visibility: visibility, cloudCover: cloudCover, pressure: pressure, ozone: ozone)
    }

    func parseWeeksForecast(_ data: Data, local: Bool) -> [DailyForecast] {
        let weatherRoot = JSON(data)
        if local {
            let week = weatherRoot["data"]["daily"]["data"].jsonArrayValue
            return week.flatMap { parseWeatherDay($0) }
        } else {
            let week = weatherRoot["forecast"]["daily"]["data"].jsonArrayValue
            return week.flatMap { parseWeatherDay($0) }
        }
    }

    fileprivate func parseWeatherDay(_ day: JSON) -> DailyForecast? {
        let epoch = day["time"].double ?? 000000
        let summary = day["summary"].string ?? "N/A"
        let icon = day["icon"].string ?? "N/A"
        let sunriseTime = day["sunriseTime"].double ?? 100000
        let sunsetTime = day["sunsetTime"].double ?? 100000
        let moonPhase = day["moonPhase"].double ?? 100000
        let precipIntensity = day["precipIntensity"].double ?? 100000
        let precipIntensityMax = day["precipIntensityMax"].double ?? 100000
        let precipProbability = day["precipProbability"].double ?? 100000
        let temperatureMin = day["temperatureMin"].double ?? 100000
        let temperatureMinTime = day["temperatureMinTime"].double ?? 100000
        let temperatureMax = day["temperatureMax"].double ?? 100000
        let temperatureMaxTime = day["temperatureMaxTime"].double ?? 100000
        let apparentTemperatureMin = day["apparentTemperatureMin"].double ?? 100000
        let apparentTemperatureMinTime = day["apparentTemperatureMinTime"].double ?? 100000
        let apparentTemperatureMax = day["apparentTemperatureMax"].double ?? 100000
        let apparentTemperatureMaxTime = day["apparentTemperatureMaxTime"].double ?? 100000
        let dewPoint = day["dewPoint"].double ?? 100000
        let humidity = day["humidity"].double ?? 100000
        let windSpeed = day["windSpeed"].double ?? 100000
        let windBearing = day["windBearing"].double ?? 100000
        let cloudCover = day["cloudCover"].double ?? 100000
        var pressure = day["pressure"].double ?? 100000
        // Convert from Hectopascals to inches of mercury
        pressure = pressure * 0.02953
        let ozone = day["ozone"].double ?? 100000
        let timeDate = Date(timeIntervalSince1970: epoch)
        let sunriseDate = Date(timeIntervalSince1970: sunriseTime)
        let sunsetDate = Date(timeIntervalSince1970: sunsetTime)
        let tempMinDate = Date(timeIntervalSince1970: temperatureMinTime)
        let tempMaxDate = Date(timeIntervalSince1970: temperatureMaxTime)
        let appTempMinDate = Date(timeIntervalSince1970: apparentTemperatureMinTime)
        let appTempMaxDate = Date(timeIntervalSince1970: apparentTemperatureMaxTime)
        return DailyForecast(date: timeDate, summary: summary, icon: icon, sunriseTime: sunriseDate, sunsetTime: sunsetDate, moonPhase: moonPhase, precipIntensity: precipIntensity, precipIntensityMax: precipIntensityMax, precipProbability: precipProbability, temperatureMinF: temperatureMin, temperatureMinTime: tempMinDate, temperatureMaxF: temperatureMax, temperatureMaxTime: tempMaxDate, apparentTemperatureMinF: apparentTemperatureMin, apparentTemperatureMinTime: appTempMinDate, apparentTemperatureMaxF: apparentTemperatureMax, apparentTemperatureMaxTime: appTempMaxDate, dewPoint: dewPoint, humidity: humidity, windSpeedMPH: windSpeed, windBearing: windBearing, cloudCover: cloudCover, pressure: pressure, ozone: ozone)
    }

    func parseRadarLinks(_ data: Data) -> RadarLinks? {
        let radarData = JSON(data)["radar"]["data"]
        guard let localLink = radarData[0]["link"].string,
            let stateLink = radarData[1]["link"].string,
            let regionalLink = radarData[2]["link"].string,
            let nationalLink = radarData[3]["link"].string else { return nil }
        return RadarLinks(local: localLink, state: stateLink, regional: regionalLink, national: nationalLink)
    }

    func parseWeatherAlertsArray(_ data: Data) -> [WeatherAlert] {
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        let alertsArray = JSON(data)["alerts"]["feed"]["entry"].jsonArrayValue
        return alertsArray.flatMap { parseWeatherAlert($0) }
    }

    fileprivate func parseWeatherAlert(_ json: JSON) -> WeatherAlert? {
        guard let identifier = json["id"].string,
            let updated = json["updated"].string,
            let title = json["title"].string else { return nil }
        let summary = json["summary"].string
        guard let updatedDate = dateFormatter.date(from: updated) else { return nil }
        return WeatherAlert(alertID: identifier, updatedTime: updatedDate, title: title, summary: summary)
    }
}
