//
//  OCVMenuTableController.swift
//  a76
//
//  Created by Eddie Seay on 4/26/16.
//  Copyright © 2016 OCV, LLC. All rights reserved.
//

import UIKit

class OCVMenuTableController: UITableViewController {

    let menuObjects: [[String: String]]!
    var parentVC = UIViewController()

    init(objects: [[String: String]]) {
        menuObjects = objects
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuObjects.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = {
            $0.backgroundColor = AppColors.primary.color
            $0.textLabel?.text = menuObjects[(indexPath as NSIndexPath).row]["text"]
            $0.textLabel?.textColor = AppColors.text.color
            $0.imageView?.tintColor = AppColors.text.color
            $0.imageView?.image = UIImage(named: menuObjects[(indexPath as NSIndexPath).row]["asset"]!)?.withRenderingMode(.alwaysTemplate)
            $0.imageView?.contentMode = .scaleAspectFit
            $0.accessoryType = .disclosureIndicator
            return $0
        }(UITableViewCell(style: .default, reuseIdentifier: nil))

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectorName = menuObjects[(indexPath as NSIndexPath).row]["selectorName"]!
        if parentVC.responds(to: Selector(selectorName)) {
            parentVC.perform(Selector(selectorName))
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
