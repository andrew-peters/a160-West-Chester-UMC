//
//  OCVSettings.swift
//  OCVSwift
//
//  Created by Eddie Seay on 1/27/16.
//  Copyright © 2016 OCV,LLC. All rights reserved.
//

import UIKit
import SnapKit
import SafariServices

class OCVSettings: UITableViewController {
    var viewModel = OCVSettingsModel()

    init() {
        if #available(iOS 9, *) {
            super.init(style: .grouped)
        } else {
            super.init(nibName: nil, bundle: nil)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Settings"

        tableView.backgroundColor = AppColors.background.color
        tableView.separatorColor = AppColors.secondary.color
        tableView.tableFooterView = UIView()

        let devLogin = UITapGestureRecognizer(target: self, action: #selector(OCVSettings.promptDevLogin))
        devLogin.numberOfTapsRequired = 7
        navigationController?.navigationBar.addGestureRecognizer(devLogin)
        navigationController?.navigationBar.isUserInteractionEnabled = true

        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        let appByLabel: UILabel = {
            $0.frame = CGRect(x: 0, y: 0, width: 60, height: 14)
            $0.text = "Designed by"
            $0.font = AppFonts.RegularText.font(10)
            $0.textColor = AppColors.text.color
            $0.textAlignment = .right
            return $0
        }(UILabel())

        let theSheriffAppIconImageView = UIImageView(image: UIImage(named: "ocv_logo"))
        theSheriffAppIconImageView.contentMode = .scaleAspectFit

        let theSheriffAppIcon: UIButton = {
            $0.frame = theSheriffAppIconImageView.frame
            $0.setImage(theSheriffAppIconImageView.image, for: UIControlState())
            $0.addTarget(self, action: #selector(OCVSettings.toOCV), for: .touchUpInside)
            return $0
        }(UIButton(type: .custom))

        let fixedWidth = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixedWidth.width = 8
        toolbarItems = [UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(customView: appByLabel),
            fixedWidth,
            UIBarButtonItem(customView: theSheriffAppIcon),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)]
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(false, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setToolbarHidden(true, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numRowsInSection(section)
    }

    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.clear

        if let header: UITableViewHeaderFooterView = view as? UITableViewHeaderFooterView {
            header.textLabel?.textColor = AppColors.text.color
            header.textLabel?.font = AppFonts.SemiboldText.font(14)
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if let subtitle = viewModel.subtitleAtIndexPath(indexPath) {
            let cellSub: UITableViewCell = {
                $0.detailTextLabel!.text = subtitle
                $0.detailTextLabel!.font = AppFonts.RegularText.font(10)
                $0.textLabel?.text = viewModel.titleAtIndexPath(indexPath)
                $0.textLabel?.font = AppFonts.SemiboldText.font(14)
                $0.accessoryType = .disclosureIndicator
                return $0
            }(UITableViewCell(style: .subtitle, reuseIdentifier: "subCell"))

            return cellSub
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as UITableViewCell
        cell.textLabel?.text = viewModel.titleAtIndexPath(indexPath)
        cell.textLabel?.font = AppFonts.SemiboldText.font(14)

        cell.accessoryType = .disclosureIndicator

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        guard let currentCell = self.tableView.cellForRow(at: indexPath) else {
            return
        }

        guard let cellTitle = currentCell.textLabel!.text else {
            return
        }

        if cellTitle == "Notification Settings" {
            navigationController?.pushViewController(OCVNotificationSettings(), animated: true)
        }

        if cellTitle == "Access Controls" {
            if let appSettings = URL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.shared.openURL(appSettings)
            }
        }

        if cellTitle == "Share Our App" {
            present(viewModel.shareController(Config.shareLink, cell: currentCell), animated: true, completion: nil)
        }

        if cellTitle == "Review On App Store" {
            // itms-apps://itunes.apple.com/app/viewContentsUserReviews?id=AppID  --> iTunes link as of 3/25/16
            UIApplication.shared.openURL(URL(string: "itms-apps://itunes.apple.com/app/viewContentsUserReviews?id=\(OCVAppUtilities.SharedInstance.appStoreID())")!)
        }

        if cellTitle == "Developer Feedback" {
            navigationController?.pushViewController(OCVDeveloperFeedbackForm(), animated: true)
        }
        
        if cellTitle == "Default Offender View" {
            let popup = OCVSubmenuPopup(items: ["Map":"", "List":""], navTitle: "Default Offender View")
            popup.present(in: self)
        }

        if cellTitle == "Licenses" {
            navigationController?.pushViewController(viewModel.textViewController(cellTitle, type: "txt"), animated: true)
        }
        
        if cellTitle == "About" {
            _ = OCVPage(sourceURL: "https://apps.myocv.com/feed/int/\(Config.applicationID)/settingsAbout", sourceNavigationController: self.navigationController!, isSettingsAbout: true)
        }
    }

    func promptDevLogin() {
//        let devLogin = UIAlertController(title: "Developer Login", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
//        devLogin.addTextFieldWithConfigurationHandler {
//            $0.placeholder = "Username"
//        }
//
//        devLogin.addTextFieldWithConfigurationHandler {
//            $0.placeholder = "Password"
//            $0.secureTextEntry = true
//        }
//
//        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (action) -> Void in
////            let uName = devLogin.textFields?.first
////            let pw = devLogin.textFields?.last
//
//            // if viewModel.credentialsValid ...
//
//            self.dismissViewControllerAnimated(true, completion: nil)
//        }
//
//        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (action) -> Void in
//            self.dismissViewControllerAnimated(true, completion: nil)
//        }
//
//        devLogin.addAction(okAction)
//        devLogin.addAction(cancelAction)
//
//        presentViewController(devLogin, animated: true, completion: nil)
        let deviceToken = OCVAppUtilities.SharedInstance.currentDeviceToken()
        let shareDescription = "Device Token: \(deviceToken)"
        
        let myActivityController = UIActivityViewController(activityItems: [shareDescription], applicationActivities: nil)
        myActivityController.modalPresentationStyle = .popover
        myActivityController.popoverPresentationController?.sourceView = self.view
        myActivityController.popoverPresentationController?.permittedArrowDirections = .any
        
        self.present(myActivityController, animated: true, completion: nil)
    }

    func toOCV() {
        if let url = URL(string: "https://www.myocv.com") {
            if #available(iOS 9.0, *) {
                let safariBrowser = SFSafariViewController(url: url)
                present(safariBrowser, animated: true, completion: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
}
