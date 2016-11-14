//
//  OCVOffenderController.swift
//  OCVSwift
//
//  Created by Eddie Seay on 6/17/16.
//  Copyright © 2016 OCV,LLC. All rights reserved.
//

import UIKit

class OCVOffenderController: OCVBaseTable {

    let url: String!
    let dataProvider: OCVOffenderDataProvider!
    let searchController = UISearchController(searchResultsController: nil)

    init(url: String) {
        self.url = url
        dataProvider = OCVOffenderDataProvider(url: url)
        super.init(nibName: nil, bundle: nil)
        self.title = "Offenders"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableViewDataCoordinator = OCVOffenderTableViewDataCoordinator(tableView: self.tableView, dataProvider: dataProvider, search: searchController)

        extendedLayoutIncludesOpaqueBars = true

        definesPresentationContext = true
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search by name or address"
        tableView.tableHeaderView = searchController.searchBar

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Map", style: .plain, target: self, action: #selector(OCVOffenderController.goToMap))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if let selectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedRow, animated: true)
        }
    }

    // MARK: UITableViewDelegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(dataProvider.objectAtIndexPath(indexPath)?.requiredCellHeight ?? 44.0)
    }

    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        if searchController.isActive && searchController.searchBar.text != "" {
            if let offender = dataProvider.filteredObjectAtIndexPath(indexPath) {
                navigationController?.pushViewController(OCVOffenderDetail(offender: offender), animated: true)
            }
        } else {
            if let offender = dataProvider.objectAtIndexPath(indexPath) {
                navigationController?.pushViewController(OCVOffenderDetail(offender: offender), animated: true)
            }
        }
    }

    func goToMap() {
        navigationController?.pushViewController(OCVOffenderMapView(offenders: dataProvider.allObjects), animated: true)
    }
}
