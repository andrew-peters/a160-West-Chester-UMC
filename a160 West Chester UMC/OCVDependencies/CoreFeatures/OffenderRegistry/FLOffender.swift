//
//  FLOffender.swift
//  OCVSwift
//
//  Created by Eddie Seay on 6/16/16.
//  Copyright © 2016 OCV,LLC. All rights reserved.
//

import Foundation

struct FLOffender {
    let personNumber: Int
    let dcNumber: String
    let status: String

    let firstName: String
    let lastName: String
    let middleName: String?
    let suffixName: String?

    let birthDate: Date
    let hair: String
    let eye: String
    let sex: String
    let race: String
    let weight: Int
    let height: Int

    let victimMinor: Bool
    let subjectType: String
    let imageURL: String
    let latitiude: Double
    let longitude: Double

    let address: String
}
