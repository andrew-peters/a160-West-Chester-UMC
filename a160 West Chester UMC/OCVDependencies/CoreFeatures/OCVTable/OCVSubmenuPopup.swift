//
//  OCVSubmenuPopup.swift
//
//  Created by Eddie Seay on 5/23/16.
//  Copyright © 2016 OCV, LLC. All rights reserved.
//

import UIKit
import STPopup

class OCVSubmenuPopup: STPopupController {

    override init() {
        super.init()
    }

    init(items: [String: String], navTitle: String) {
        let popupView = OCVSubmenuView(items: items, navTitle: navTitle)
        super.init(rootViewController: popupView)
        STPopupNavigationBar.appearance().barTintColor = AppColors.primary.color
        STPopupNavigationBar.appearance().tintColor = AppColors.text.color
        STPopupNavigationBar.appearance().isTranslucent = false
        STPopupNavigationBar.appearance().barStyle = UIBarStyle.default
        self.transitionStyle = .slideVertical
        self.containerView.layer.cornerRadius = 4.0
    }
    
    // If you need the parent view controller to push a new view from the submenu
    init(items: [String: String], navTitle: String, parentVC: UIViewController) {
        let popupView = OCVSubmenuView(items: items, navTitle: navTitle, parentVC: parentVC)
        super.init(rootViewController: popupView)
        STPopupNavigationBar.appearance().barTintColor = AppColors.primary.color
        STPopupNavigationBar.appearance().tintColor = AppColors.text.color
        STPopupNavigationBar.appearance().isTranslucent = false
        STPopupNavigationBar.appearance().barStyle = UIBarStyle.default
        self.transitionStyle = .slideVertical
        self.containerView.layer.cornerRadius = 4.0
    }
    
    // In case table information is not in [String: String] form
    init(titles: [String], content: [String], navTitle: String, parentVC: UIViewController) {
        let popupView = OCVSubmenuView(titles: titles, content: content, navTitle: navTitle, parentVC: parentVC)
        super.init(rootViewController: popupView)
        STPopupNavigationBar.appearance().barTintColor = AppColors.primary.color
        STPopupNavigationBar.appearance().tintColor = AppColors.text.color
        STPopupNavigationBar.appearance().isTranslucent = false
        STPopupNavigationBar.appearance().barStyle = UIBarStyle.default
        self.transitionStyle = .slideVertical
        self.containerView.layer.cornerRadius = 4.0
    }
}

class OCVSubmenuView: UITableViewController {

    let tableCellIdentifier = "cellIdentifier"

    var tableTitles: [String] = []
    var tableLinks: [String] = []
    let navTitle: String!
    var parentVC: UIViewController?
    var content: [String] = []

    init(items: [String: String], navTitle: String) {
        self.navTitle = navTitle
        super.init(nibName: nil, bundle: nil)
        self.contentSizeInPopup = CGSize(width: 300, height: 200)
        self.landscapeContentSizeInPopup = CGSize(width: 400, height: 200)
        self.seprateItems(items)
    }
    
    // Again, in case you need the parent view controller
    init(items: [String: String], navTitle: String, parentVC: UIViewController) {
        self.navTitle = navTitle
        self.parentVC = parentVC
        super.init(nibName: nil, bundle: nil)
        self.contentSizeInPopup = CGSize(width: 300, height: 200)
        self.landscapeContentSizeInPopup = CGSize(width: 400, height: 200)
        self.seprateItems(items)
    }
    
    // In case items are not in [String: String] form
    init(titles: [String], content: [String], navTitle: String, parentVC: UIViewController) {
        self.navTitle = navTitle
        self.parentVC = parentVC
        tableTitles = titles
        self.content = content
        super.init(nibName: nil, bundle: nil)
        self.contentSizeInPopup = CGSize(width: 300, height: 200)
        self.landscapeContentSizeInPopup = CGSize(width: 400, height: 200)
    }


    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = navTitle
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: tableCellIdentifier)
    }

    func seprateItems(_ items: [String: String]) {
        for (key, value) in items {
            tableTitles.append(key)
            tableLinks.append(value)
        }
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int { return 1 }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableTitles.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: tableCellIdentifier, for: indexPath)

        cell.textLabel?.text = tableTitles[(indexPath as NSIndexPath).row]
        cell.textLabel?.font = AppFonts.RegularText.font(14)
        cell.accessoryType = .disclosureIndicator

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let webview = OCVWebview(url: tableLinks[(indexPath as NSIndexPath).row], navTitle: tableTitles[(indexPath as NSIndexPath).row], showToolBar: true)
        self.popupController?.push(webview, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
        
        // CHANGE TO WHAT YOU NEED
    }
}
