//
//  OCVOffenderTableViewDataCoordinator.swift
//  OCVSwift
//
//  Created by Eddie Seay on 6/17/16.
//  Copyright © 2016 OCV,LLC. All rights reserved.
//

import UIKit

final class OCVOffenderTableViewDataCoordinator: GenericTableViewDataCoordinator<OCVOffenderDataProvider, OCVOffenderCell>, UISearchResultsUpdating {

    let searchController: UISearchController!
    let offenderTable: UITableView!

    init(tableView: UITableView, dataProvider: OCVOffenderDataProvider, search: UISearchController) {
        self.searchController = search
        self.offenderTable = tableView
        tableView.register(OCVOffenderCell.self, forCellReuseIdentifier: OCVOffenderCell.reuseIdentifier())
        super.init(tableView: tableView, dataProvider: dataProvider)
        self.searchController.searchResultsUpdater = self
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if searchController.isActive && searchController.searchBar.text != "" {
            return nil
        }
        return dataProvider.sectionTitles[section]
    }

    func sectionIndexTitlesForTableView(_ tableView: UITableView) -> [String]? {
        return dataProvider.sectionTitles
    }

    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return dataProvider.sectionTitles.index(of: title) ?? 0
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return dataProvider.numberOfSections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return dataProvider.filteredNumberOfItemsInSection(section)
        }
        return dataProvider.numberOfItemsInSection(section)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: OCVOffenderCell.reuseIdentifier()) as? OCVOffenderCell else {
            fatalError("Could not dequeue cell of type: \(OCVOffenderCell.self) with identifier: \(OCVOffenderCell.reuseIdentifier())")
        }

        if searchController.isActive && searchController.searchBar.text != "" {
            if let object = dataProvider.filteredObjectAtIndexPath(indexPath) { cell.configure(object) }
        } else {
            if let object = dataProvider.objectAtIndexPath(indexPath) { cell.configure(object) }
        }

        return cell
    }

    // MARK: Search
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        dataProvider.filteredObjects = dataProvider.allObjects.flatMap { $0.filter { $0.displayName.contains(searchText) || $0.address.contains(searchText) } }
        offenderTable.reloadData()
    }

    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
