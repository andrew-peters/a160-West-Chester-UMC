//
//  OCVSocialPopupTable.swift
//  OCVSwift
//
//  Created by Eddie Seay on 4/8/16.
//  Copyright © 2016 OCV,LLC. All rights reserved.
//

import UIKit
import STPopup

enum SupportedSocialPlatform {
    case facebook
    case twitter
    case youTube
    case instagram
}

class OCVSocialPopup: STPopupController {

    override init() {
        super.init()
    }

    init(items: [[String: String]]) {
        let popupView = OCVSocialPopupView(items: items)
        super.init(rootViewController: popupView)
        STPopupNavigationBar.appearance().barTintColor = AppColors.primary.color
        STPopupNavigationBar.appearance().tintColor = AppColors.text.color
        STPopupNavigationBar.appearance().isTranslucent = false
        STPopupNavigationBar.appearance().barStyle = UIBarStyle.default
        self.transitionStyle = .slideVertical
        self.containerView.layer.cornerRadius = 4.0
    }

}

class OCVSocialPopupView: UITableViewController {

    let tableCellIdentifier = "cellIdentifier"

    var tableTitles: [String] = []
    var tableLinks: [String] = []
    var tableIDs: [String] = []

    init(items: [[String: String]]) {
        super.init(nibName: nil, bundle: nil)
        self.title = "Social Media"
        self.contentSizeInPopup = CGSize(width: 300, height: 200)
        self.landscapeContentSizeInPopup = CGSize(width: 400, height: 200)
        self.seprateItems(items)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: tableCellIdentifier)
    }

    func seprateItems(_ items: [[String: String]]) {
        for socialPlatform in items {
            tableTitles.append(socialPlatform["platform"]!)
            tableLinks.append(socialPlatform["link"]!)
            tableIDs.append(socialPlatform["identifier"]!)
        }
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableTitles.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: tableCellIdentifier, for: indexPath)

        cell.textLabel?.text = tableTitles[(indexPath as NSIndexPath).row]
        cell.textLabel?.font = AppFonts.RegularText.font(16)

        cell.imageView?.image = imageForPlatform(tableTitles[(indexPath as NSIndexPath).row])
        cell.imageView?.contentMode = .scaleAspectFit

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var selectedPlatform: SupportedSocialPlatform = .facebook
        switch tableTitles[(indexPath as NSIndexPath).row] {
        case "Facebook":
            break
        case "Twitter":
            selectedPlatform = .twitter
        case "YouTube":
            selectedPlatform = .youTube
        case "Instagram":
            selectedPlatform = .instagram
        default :
            break
        }
        openPlatform(selectedPlatform, iden: tableIDs[(indexPath as NSIndexPath).row], link: tableLinks[(indexPath as NSIndexPath).row])
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func openPlatform(_ platform: SupportedSocialPlatform, iden: String, link: String) {
        if platform == .twitter {
            self.popupController?.push(OCVTwitter(username: iden), animated: true)
        } else {
            var socialString = ""
            switch platform {
            case .facebook:
                socialString = "fb://profile/\(iden)"
            case .twitter:
                break
            case .youTube:
                socialString = "youtube://user/\(iden)"
            case .instagram:
                socialString = "instagram://user?username=\(iden)"
            }

            let socialURL = URL(string: socialString)

            if UIApplication.shared.canOpenURL(socialURL!) {
                UIApplication.shared.openURL(socialURL!)
            } else {
                UIApplication.shared.openURL(URL(string: link)!)
            }
        }
    }

    func imageForPlatform(_ name: String) -> UIImage {
        switch name {
        case "Facebook":
            return UIImage(named: "facebookLogo-blue")!
        case "Twitter":
            return UIImage(named: "twitterLogo-blue")!
        case "YouTube":
            return UIImage(named: "youtubeLogo")!
        default:
            return UIImage()
        }
    }
}
