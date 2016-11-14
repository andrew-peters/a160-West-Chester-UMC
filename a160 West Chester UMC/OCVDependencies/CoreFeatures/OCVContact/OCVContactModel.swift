//
//  OCVContactModel.swift
//  OCVSwift
//
//  Created by Eddie Seay on 2/3/16.
//  Copyright © 2016 OCV,LLC. All rights reserved.
//

import SVProgressHUD
import SafariServices
import CoreLocation
import MapKit

class OCVContactModel: OCVTableModel {
    let parser = OCVFeedParser()
    let geoCoder = CLGeocoder()
    var headersArray: [String] = [] {
        didSet {
            sendingTable?.tableView.reloadData()
        }
    }
    var entriesArray: [[OCVContactObject]] = [] {
        didSet {
            sendingTable?.tableView.reloadData()
        }
    }

    override func setDataSource(_ data: Data) {
        headersArray = parser.parseContactHeadersFromData(data)
        if !headersArray.isEmpty {
            entriesArray = parser.getAllContactArraysFromData(data, order: headersArray)
        }
    }

    override func numberOfSections() -> Int {
        return !headersArray.isEmpty ? headersArray.count : 1
    }

    override func numberOfRowsInSection(_ section: Int) -> Int {
        return entriesArray.indices.contains(section) ? entriesArray[section].count: 0
    }

    func titleForSection(_ section: Int) -> String? {
        if headersArray.indices.contains(section) {
            let title = String(headersArray[section])

            if title == "default" {
                return nil
            }

            return title
        }
        return nil
    }

    override func titleForCellAtIndexPath(_ indexPath: IndexPath) -> String {
        if entriesArray.indices.contains((indexPath as NSIndexPath).section) && entriesArray[(indexPath as NSIndexPath).section].indices.contains((indexPath as NSIndexPath).row) {
            return String(entriesArray[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row].title)
        }
        return ""
    }

    override func descForCellAtIndexPath(_ indexPath: IndexPath) -> String {
        if entriesArray.indices.contains((indexPath as NSIndexPath).section) && entriesArray[(indexPath as NSIndexPath).section].indices.contains((indexPath as NSIndexPath).row) {
            var description = ""

            let object = entriesArray[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]

            if let jobtitle = object.jobTitle {
                description = "\(description)\(jobtitle)\n"
            }

            if let email = object.email {
                description = "\(description)Email: \(email)\n"
            }

            if let phone = object.phone {
                description = "\(description)Phone: \(phone)\n"
            }

            if let fax = object.fax {
                description = "\(description)Fax: \(fax)\n"
            }

            if let address = object.address {
                description = "\(description)Address: \(address)\n"
            }

            if let website = object.website {
                description = "\(description)Website: \(website)\n"
            }

            if let contactDescription = object.description {
                description = "\(description)Description: \(contactDescription)\n"
            }

            return String(description.characters.dropLast())
        }
        return ""
    }

    func imageStringForCellAtIndexPath(_ indexPath: IndexPath) -> String? {
        if entriesArray.indices.contains((indexPath as NSIndexPath).section) && entriesArray[(indexPath as NSIndexPath).section].indices.contains((indexPath as NSIndexPath).row) {
            if let imageString = entriesArray[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row].image {
                return imageString
            }
        }
        return nil
    }

    // swiftlint:disable function_body_length
    // swiftlint:disable:next cyclomatic_complexity
    func actionsForObjectAtIndexPath(_ indexPath: IndexPath) -> [UIAlertAction] {
        var actionArray = [UIAlertAction]()

        guard let contactTable = self.sendingTable as? OCVContact else {
            return []
        }

        if entriesArray.indices.contains((indexPath as NSIndexPath).section) && entriesArray[(indexPath as NSIndexPath).section].indices.contains((indexPath as NSIndexPath).row) {
            let object = entriesArray[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]

            if let email = object.email {
                actionArray.append(UIAlertAction(title: "Email: \(email)", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                    contactTable.sendEmailButtonTapped(email)
                    }))
            }

            if let phone = object.phone , UIDevice.current.userInterfaceIdiom != UIUserInterfaceIdiom.pad {
                let phoneAddr = phone.lowercased().replacingOccurrences(of: "ext", with: "pp").replacingOccurrences(of: " ", with: "")
                actionArray.append(UIAlertAction(title: "Call: \(phone)", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                    if let phoneURL = URL(string: "tel://\(phoneAddr)") {
                        UIApplication.shared.openURL(phoneURL)
                    }
                    }))
            }

            if var address = object.address {
                var mapItem: MKMapItem?
                geoCoder.geocodeAddressString(address, completionHandler: { (placemarks: [CLPlacemark]?, error: Error?) -> Void in
                    if let p1 = placemarks?.first {
                        let place = MKPlacemark(placemark: p1)
                        mapItem = MKMapItem(placemark: place)
                    }
                } as! CLGeocodeCompletionHandler)
                actionArray.append(UIAlertAction(title: "Directions - Apple", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                    if let _ = mapItem {
                        mapItem?.openInMaps(launchOptions: nil)
                    } else {
                        address = address.replacingOccurrences(of: " ", with: "+").replacingOccurrences(of: ",", with: "").replacingOccurrences(of: ".", with: "")
                        if let directionURL = URL(string: "http:/maps.apple.com/?daddr=\(address)") {
                            if UIApplication.shared.canOpenURL(directionURL) {
                                UIApplication.shared.openURL(directionURL)
                            }
                        }
                    }
                    }))

                actionArray.append(UIAlertAction(title: "Directions - Google", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                    address = address.replacingOccurrences(of: " ", with: "+").replacingOccurrences(of: ",", with: "").replacingOccurrences(of: ".", with: "")
                    if let directionURL = URL(string: "http://maps.google.com/maps?f=d&daddr=\(address)") {
                        if UIApplication.shared.canOpenURL(URL(string: "comgooglemaps://")!) {
                            UIApplication.shared.openURL(URL(string: "comgooglemaps://?daddr=\(address)")!)
                        } else {
                            if #available(iOS 9.0, *) {
                                let safariBrowser = SFSafariViewController(url: directionURL)
                                contactTable.present(safariBrowser, animated: true, completion: nil)
                            } else {
                                UIApplication.shared.openURL(directionURL)
                            }
                        }
                    }
                    }))
            }

            if var website = object.website {
                if (website.range(of: "http://") == nil) && (website.range(of: "https://") == nil) {
                    website = "http://\(website)"
                }

                if let url = URL(string: website) {
                    if UIApplication.shared.canOpenURL(url) {
                        actionArray.append(UIAlertAction(title: "Go To Website", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                            if #available(iOS 9.0, *) {
                                let safariBrowser = SFSafariViewController(url: url)
                                contactTable.present(safariBrowser, animated: true, completion: nil)
                            } else {
                                UIApplication.shared.openURL(url)
                            }
                            }))
                    }
                }
            }

            actionArray.append(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))

            return actionArray
        }

        return []
    }
    // swiftlint:enable function_body_length
}
