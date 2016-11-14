//
//  OCVMessageModel.swift
//  OCVSwift
//
//  Created by Eddie Seay on 3/28/16.
//  Copyright © 2016 OCV,LLC. All rights reserved.
//

import Foundation

class OCVMessageModel: OCVTableModel {

    override func setDataSource(_ data: Data) {
        feedArray = OCVNotificationParser().getMessageHistory(data).flatMap { $0 as Any }
    }

    func messageObjectForCellAtIndexPath(_ indexPath: IndexPath) -> OCVMessageObject {
        if let objAt = feedArray[(indexPath as NSIndexPath).row] as? OCVMessageObject {
            return objAt
        }

        return OCVMessageObject(id: "1234567890", title: "ERROR", description: "Invalid object at index", date: Date(), channel: "default", channelTitle: "Error Placeholder")
    }

    override func titleForCellAtIndexPath(_ indexPath: IndexPath) -> String {
        let msgObj = messageObjectForCellAtIndexPath(indexPath)
        let chan = msgObj.channelTitle.uppercased()
        if chan == "DEFAULT" {
            return msgObj.title
        }
        return "[\(chan)] \(msgObj.title)"
    }

    override func descForCellAtIndexPath(_ indexPath: IndexPath) -> String {
        let desc = messageObjectForCellAtIndexPath(indexPath).description
        if desc.characters.count > 200 {
            return desc.substring(to: desc.characters.index(desc.startIndex, offsetBy: 200)) + "..."
        }
        return desc
    }

    override func dateForCellAtIndexPath(_ indexPath: IndexPath) -> String {
        return DateFormatter.localizedString(from: messageObjectForCellAtIndexPath(indexPath).date as Date, dateStyle: .long, timeStyle: .short)
    }

    func channelForCellAtIndexPath(_ indexPath: IndexPath) -> String {
        return messageObjectForCellAtIndexPath(indexPath).channel
    }

    override func detailViewFromIndexPath(_ indexPath: IndexPath) -> OCVDetail {
        return OCVDetail(object: messageObjectForCellAtIndexPath(indexPath))
    }
}
