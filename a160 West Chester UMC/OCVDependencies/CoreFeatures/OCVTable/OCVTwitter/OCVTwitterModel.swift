//
//  OCVTwitterModel.swift
//  OCVSwift
//
//  Created by Eddie Seay on 2/29/16.
//  Copyright © 2016 OCV,LLC. All rights reserved.
//

import Foundation

class OCVTwitterModel: OCVTableModel {

    override func setDataSource(_ data: Data) {
        feedArray = OCVFeedParser().getAllTweets(data)
    }

    func twitterObjectForCellAtIndexPath(_ indexPath: IndexPath) -> OCVTwitterObject {
        if let objAt = feedArray[(indexPath as NSIndexPath).row] as? OCVTwitterObject {
            return objAt
        }

        return OCVTwitterObject(id: "1234567890", title: "Error", content: "Content unavailable", contentURLstring: nil, fromDate: "", userID: nil, userURLstring: nil, profURLstring: nil)
    }

    override func titleForCellAtIndexPath(_ indexPath: IndexPath) -> String {
        let title = twitterObjectForCellAtIndexPath(indexPath).userTitle
        return title != "" ? title : "No User Found"
    }

    override func descForCellAtIndexPath(_ indexPath: IndexPath) -> String {
        let desc = twitterObjectForCellAtIndexPath(indexPath).content
        return desc != "" ? desc : "Content unavailable"
    }

    override func dateForCellAtIndexPath(_ indexPath: IndexPath) -> String {
        return twitterObjectForCellAtIndexPath(indexPath).fromDate
    }

    override func thumbnailForCellAtIndexPath(_ indexPath: IndexPath) -> String {
        return twitterObjectForCellAtIndexPath(indexPath).profPicURL
    }
}
