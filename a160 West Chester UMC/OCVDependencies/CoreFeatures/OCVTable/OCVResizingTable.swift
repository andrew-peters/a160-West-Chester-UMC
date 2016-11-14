//
//  OCVResizingTable.swift
//  OCVSwift
//
//  Created by Eddie Seay on 1/15/16.
//  Copyright © 2016 OCV,LLC. All rights reserved.
//

import UIKit

class OCVResizingTable: OCVTable {

    fileprivate let tableCellIdentifier = "OCVResizingCell"

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        self.tableView.register(OCVResizingCell.self, forCellReuseIdentifier: tableCellIdentifier)

        viewModel!.sendingTable = self
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: tableCellIdentifier) as? OCVResizingCell else {
            fatalError("Could not dequeue cell with identifier: \(tableCellIdentifier)")
        }

        cell.shouldShowDate = showsDates

        if viewModel!.hasImagesForCellAtIndexPath(indexPath) {
            cell.setupConstraintsWithImageArray(viewModel!.imageArrayForCellAtIndexPath(indexPath))
        } else {
            cell.setupRegularConstraints()
        }

        cell.titleLabel.text = viewModel!.titleForCellAtIndexPath(indexPath)
        cell.descLabel.text = viewModel!.descForCellAtIndexPath(indexPath)
        cell.dateLabel.text = viewModel!.dateForCellAtIndexPath(indexPath)

        cell.setNeedsUpdateConstraints()

        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}
