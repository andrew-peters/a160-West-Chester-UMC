//
//  OCVDigestTable.swift
//  OCVSwift
//
//  Created by Eddie Seay on 6/3/16.
//  Copyright © 2016 OCV,LLC. All rights reserved.
//

import UIKit

class OCVDigestTable: UITableView {

    init(controller: OCVDigestController) {
        super.init(frame: CGRect(), style: .plain)
        self.delegate = controller
        self.dataSource = controller
        controller.tableView = self
        self.rowHeight = UITableViewAutomaticDimension
        self.estimatedRowHeight = 120
        self.register(OCVDigestCell.self, forCellReuseIdentifier: "DigestCell")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
