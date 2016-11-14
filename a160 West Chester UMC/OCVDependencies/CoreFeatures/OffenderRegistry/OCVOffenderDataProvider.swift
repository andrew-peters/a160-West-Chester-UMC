//
//  OCVOffenderDataProvider.swift
//  OCVSwift
//
//  Created by Eddie Seay on 6/17/16.
//  Copyright © 2016 OCV,LLC. All rights reserved.
//

import UIKit

final class OCVOffenderDataProvider: DataProvider {
    var url: String!

    var allObjects: [[OCVOffenderObjectViewModel]] = [[]]
    var filteredObjects: [[OCVOffenderObjectViewModel]] = [[]]

    var sectionTitles = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]

    init(url: String) {
        self.url = url
    }

    func refresh(showProgress progressIndicator: Bool, completion: @escaping () -> Void) {
        OCVNetworkClient().downloadFrom(url: url, showProgress: true) { resultData, _ in
            let objects = OCVOffenderParser().parseFloridaOffenderSet(resultData)
            self.allObjects = objects.flatMap { $0.flatMap {OCVOffenderObjectViewModel(model: $0) } }
            self.filteredObjects = self.allObjects
            completion()
        }
    }

    func objectAtIndexPath(_ indexPath: IndexPath) -> OCVOffenderObjectViewModel? {
        return allObjects.indices.contains((indexPath as NSIndexPath).section) ? allObjects[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]: nil
    }

    func filteredObjectAtIndexPath(_ indexPath: IndexPath) -> OCVOffenderObjectViewModel? {
        return filteredObjects.indices.contains((indexPath as NSIndexPath).section) ? filteredObjects[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]: nil
    }

    func numberOfItemsInSection(_ section: Int) -> Int {
        return allObjects[section].count
    }

    func filteredNumberOfItemsInSection(_ section: Int) -> Int {
        return filteredObjects[section].count
    }

    var numberOfSections: Int {
        return allObjects.count
    }

    var filteredNumberOfSections: Int {
        return filteredObjects.count
    }

}
