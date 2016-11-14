//
//  OCVMessageObject.swift
//  OCVSwift
//
//  Created by Eddie Seay on 3/28/16.
//  Copyright © 2016 OCV,LLC. All rights reserved.
//

import Foundation

struct OCVMessageObject {
    let id: String
    let title: String
    let description: String
    let date: Date
    let channel: String
    let channelTitle: String

    init(id: String, title: String, description: String?, date: Date, channel: String, channelTitle: String) {
        self.id = id
        self.title = title
        self.description = description ?? ""
        self.date = date
        self.channel = channel
        self.channelTitle = channelTitle
    }
}
