//
//  Event.swift
//  OCVSwift
//
//  Created by Eddie Seay on 6/1/16.
//  Copyright © 2016 OCV,LLC. All rights reserved.
//

import Foundation

struct OCVCalendarEvent {
    let identifier: String      // "id"
    let htmlLink: String        // "htmlLink"
    let summary: String         // "summary"
    let description: String?    // "description"
    let location: String?       // "location"
    let startDate: Date       // "startDate"
    let endDate: Date         // "endDate"
    let iCalUID: String         // "iCalUID"

}
