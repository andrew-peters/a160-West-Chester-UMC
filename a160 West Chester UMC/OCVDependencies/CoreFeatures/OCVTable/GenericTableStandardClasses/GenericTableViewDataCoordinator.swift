//
//  GenericTableViewDataCoordinator.swift
//  DataArchitectureSample
//
//  Created by Luciano Marisi on 26/03/2016.
//  Copyright © 2016 Luciano Marisi. All rights reserved.
//

import UIKit

class GenericTableViewDataCoordinator < DataProviderType: DataProvider, CellType: UITableViewCell>: NSObject, UITableViewDataSource, DataCoordinator where CellType: ConfigurableCell, CellType.ObjectViewModel == DataProviderType.ObjectViewModel  {

    fileprivate let tableView: UITableView
    let dataProvider: DataProviderType

    init(tableView: UITableView, dataProvider: DataProviderType) {
        self.dataProvider = dataProvider
        self.tableView = tableView
        super.init()
        tableView.dataSource = self
        self.dataProvider.refresh(showProgress: true) { tableView.reloadData() }
    }

    func refresh(_ completion: @escaping (Void) -> Void) {
        self.dataProvider.refresh(showProgress: true) {
            self.tableView.reloadData()
            completion()
        }
    }

    // MARK: UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataProvider.numberOfSections
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataProvider.numberOfItemsInSection(section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellType.reuseIdentifier()) as? CellType else {
            fatalError("Could not dequeue cell of type: \(CellType.self) with identifier: \(CellType.reuseIdentifier())")
        }

        if let object = dataProvider.objectAtIndexPath(indexPath) { cell.configure(object) }

        return cell
    }

}
