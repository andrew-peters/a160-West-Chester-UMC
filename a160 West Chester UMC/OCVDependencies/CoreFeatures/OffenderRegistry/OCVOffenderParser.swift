//
//  OCVOffenderParser.swift
//  OCVSwift
//
//  Created by Eddie Seay on 6/16/16.
//  Copyright © 2016 OCV,LLC. All rights reserved.
//

import Foundation
import JASON

class OCVOffenderParser {

    let dateFormatter = DateFormatter()
    typealias FLOffenderSection = [FLOffender]
    typealias ALOffenderSection = [ALOffender]

    func parseFloridaOffenderSet(_ data: Data?) -> [FLOffenderSection] {
        guard let dataIn = data,
            let offenderDictionary = JSON(dataIn).jsonDictionary else { return [[]] }
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let sortedKeys = Array(offenderDictionary.keys).sorted(by: <)
        return sortedKeys.flatMap { offenderDictionary[$0]?.jsonArrayValue.flatMap { parseFLOffender($0) }.sorted { $0.lastName < $1.lastName } }
    }

    func parseFLOffender(_ item: JSON) -> FLOffender? {
        guard let personNumberString = item["PERSON_NBR"].string,
            let dcNumber = item["DC_NUMBER"].string,
            let status = item["STATUS"].string,
            let firstName = item["FIRST_NAME"].string,
            let lastName = item["LAST_NAME"].string,
            let hair = item["HAIR"].string,
            let eye = item["EYE_COLOR"].string,
            let sex = item["SEX"].string,
            let race = item["RACE"].string,
            let weightString = item["WEIGHT"].string,
            let heightString = item["HEIGHT"].string,
            let victimMinorString = item["VICTIM_MINOR"].string,
            let subjectType = item["SUBJECT_TYPE"].string,
            let imageURL = item["IMAGE_URL"].string,
            let address = item["address"].string,
            let latitude = item["latitude"].double,
            let longitude = item["longitude"].double else { return nil }
        guard let birthDateString = item["BIRTH_DATE"].string,
            let birthDate = dateFormatter.date(from: birthDateString) else { return nil }
        guard let personNumber = Int(personNumberString),
            let height = Int(heightString),
            let weight = Int(weightString) else { return nil }

        let middleName = item["MIDDLE_NAME"].string
        let suffixName = item["SUFFIX_NAME"].string
        var victimMinor = true
        if victimMinorString == "NO" { victimMinor = false }

        return FLOffender(personNumber: personNumber, dcNumber: dcNumber, status: status, firstName: firstName, lastName: lastName, middleName: middleName, suffixName: suffixName, birthDate: birthDate, hair: hair, eye: eye, sex: sex, race: race, weight: weight, height: height, victimMinor: victimMinor, subjectType: subjectType, imageURL: imageURL, latitiude: latitude, longitude: longitude, address: address)
    }
    
    func parseAlabamaOffenderSet(_ data: Data?) -> [ALOffenderSection] {
        guard let dataIn = data,
            let offenderDictionary = JSON(dataIn).jsonDictionary else { return [[]] }
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let sortedKeys = Array(offenderDictionary.keys).sorted(by: <)
        return sortedKeys.flatMap { offenderDictionary[$0]?.jsonArrayValue.flatMap { parseALOffender($0) }.sorted {$0.name < $1.name } }
    }
    
    func parseALOffender(_ item: JSON) -> ALOffender? {
        guard let name = item["name"].string,
            var charges = item["charges"].string,
            let gender = item["gender"].string,
            let eyeColor = item["eyeColor"].string,
            let race = item["race"].string,
            let address = item["address"].string,
            let hairColor = item["hairColor"].string,
            let registrationDateString = item["registrationDate"].string,
            let registrationDate = dateFormatter.date(from: registrationDateString)
            else {return nil}
        
        guard let longitude = item["longitude"].double,
            let latitude = item["latitude"].double
            else {return nil}
        
        if charges == "" {
            charges = "N/A"
        }
        
        return ALOffender(name: name, charges: charges, gender: gender, longitude: longitude, latitude: latitude, eyeColor: eyeColor, race: race, address: address.asName, hairColor: hairColor, registrationDate: registrationDate)
    }
    
    //func parseGAOffender(item: JSON) -> GAOffender? {
    
    //}
}
