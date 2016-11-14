//
//  DigestObject.swift
//  OCVSwift
//
//  Created by Eddie Seay on 6/3/16.
//  Copyright © 2016 OCV,LLC. All rights reserved.
//

import Foundation

struct OCVDigestObject {
    let date: Date
    let mediaType: Int // 1: OCV Blog, 2: Twitter, 3: Facebook, 4: ??, 5: Messages/Alert
    let feedID: Int // Dont know what this does
    let origin: Int
    let title: String
    let content: String
    let summary: String
//    let link: String
//    let updatedTime: NSDate?
    let fbStatusType: String?
    let tweetID: String?
}
