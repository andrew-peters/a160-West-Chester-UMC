//
//  OCVOffenderObjectViewModel.swift
//  OCVSwift
//
//  Created by Eddie Seay on 6/17/16.
//  Copyright © 2016 OCV,LLC. All rights reserved.
//

import Foundation
import CoreLocation

struct OCVOffenderObjectViewModel {
    let displayName: String
    let status: String
    let address: String
    let type: String
    let imageURL: URL
    let placeholderName = "noimage-person"

    let personNumber: String
    let dcNumber: String
    let hair: String
    let eye: String
    let sex: String
    let race: String
    let weight: String
    let height: String
    let date: Date

    let coordinates: CLLocationCoordinate2D
    let requiredCellHeight: Float = 100.0

    init(model: FLOffender) {
        displayName = "\(model.firstName) \(model.middleName ?? "") \(model.lastName) \(model.suffixName ?? "")"
            .replacingOccurrences(of: "  ", with: " ").asName
        status = model.status
        address = model.address
        type = model.subjectType
        imageURL = URL(string: model.imageURL) ?? URL(string: "")!

        personNumber = "\(model.personNumber)"
        dcNumber = model.dcNumber
        hair = model.hair.capitalized
        eye = model.eye.capitalized
        if model.sex == "M" { sex = "Male"
        } else { sex = "Female" }

        if model.race == "W" { race = "White"
        } else if model.race == "B" { race = "Black"
        } else if model.race == "A" { race = "Asian"
        } else { race = "Other" }

        weight = "\(model.weight) lbs"
        let feet = model.height / 100
        let inches = model.height - feet * 100
        height = "\(feet)\' \(inches)\""

        coordinates = CLLocationCoordinate2D(latitude: model.latitiude, longitude: model.longitude)

        date = model.birthDate as Date
    }
    
    init(model: ALOffender) {
        displayName = model.name.asName
        status = model.charges
        address = model.address
        type = model.charges
        imageURL = URL(string: "")!
        
        personNumber = ""
        dcNumber = ""
        hair = model.hairColor.capitalized
        eye = model.eyeColor.capitalized
        sex = model.gender.capitalized
        
        race = model.race.capitalized
        
        weight = ""
        height = ""
        
        coordinates = CLLocationCoordinate2D(latitude: model.latitude, longitude: model.longitude)
        date = model.registrationDate as Date
    }
}
