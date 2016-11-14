//
//  OCVMessageHistory.swift
//  OCVSwift
//
//  Created by Eddie Seay on 3/28/16.
//  Copyright © 2016 OCV,LLC. All rights reserved.
//

import UIKit

class OCVMessageHistory: OCVResizingTable {

    fileprivate let tableCellIdentifier = "OCVDefaultCell"
    var messageHistoryModel: OCVMessageModel?
    let messageURL: String!

    init() {
        messageURL = "https://api.myocv.com/apps/push/2/history/\(Config.applicationID)?\(OCVAppUtilities.SharedInstance.apiString())"
        super.init(dataSourceURL: messageURL, navTitle: "Messages")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        messageHistoryModel = createViewModel(messageURL)
        viewModel = messageHistoryModel

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "options"), style: .plain, target: self, action: #selector(OCVMessageHistory.openNotificationSettings))

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        self.tableView.register(OCVResizingCell.self, forCellReuseIdentifier: tableCellIdentifier)

        self.setupInitialFunctionality()
    }

    override func createViewModel(_ dataSourceURL: String) -> OCVMessageModel {
        return OCVMessageModel(dataSourceURL: dataSourceURL, sendingTable: self)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: tableCellIdentifier) as? OCVResizingCell else {
            fatalError("Could not dequeue cell with identifier: \(tableCellIdentifier)")
        }
        cell.shouldShowDate = true

        cell.setupRegularConstraints()

        cell.titleLabel.text = viewModel!.titleForCellAtIndexPath(indexPath)
        cell.descLabel.text = viewModel!.descForCellAtIndexPath(indexPath)
        cell.dateLabel.text = viewModel!.dateForCellAtIndexPath(indexPath)

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let detail = messageHistoryModel?.detailViewFromIndexPath(indexPath) {
            self.navigationController?.pushViewController(detail, animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func openNotificationSettings() {
        navigationController?.pushViewController(OCVNotificationSettings(), animated: true)
    }
}
