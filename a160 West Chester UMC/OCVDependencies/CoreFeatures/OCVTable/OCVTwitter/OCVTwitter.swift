//
//  OCVTwitter.swift
//  OCVSwift
//
//  Created by Eddie Seay on 2/29/16.
//  Copyright © 2016 OCV,LLC. All rights reserved.
//

import SafariServices

class OCVTwitter: OCVResizingTable {

    let username: String!
    var twitterViewModel: OCVTwitterModel?
    fileprivate let tableCellIdentifier = "OCVDefaultCell"

    init(username: String) {
        self.username = username
        let twiURL = "http://api.myocv.com/twitter/tweets/\(username)?\(OCVAppUtilities.SharedInstance.apiString())"
        super.init(dataSourceURL: twiURL, navTitle: "@\(username)", circleImages: true, showsDates: true)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        if let currentURL = url {
            twitterViewModel = createViewModel(currentURL)
        }
        viewModel = twitterViewModel
        self.setupInitialFunctionality()
        twitterViewModel?.sendingTable = self

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        self.tableView.register(OCVResizingCell.self, forCellReuseIdentifier: tableCellIdentifier)

        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            contentSizeInPopup = CGSize(width: UIScreen.main.bounds.size.width * 0.80, height: UIScreen.main.bounds.size.height * 0.80)
            landscapeContentSizeInPopup = CGSize(width: UIScreen.main.bounds.size.width * 0.80, height: UIScreen.main.bounds.size.height * 0.80)
        } else {
            contentSizeInPopup = CGSize(width: UIScreen.main.bounds.size.width * 0.90, height: UIScreen.main.bounds.size.height * 0.85)
            landscapeContentSizeInPopup = CGSize(width: UIScreen.main.bounds.size.width * 0.90, height: UIScreen.main.bounds.size.height * 0.75)
        }

        if UIApplication.shared.canOpenURL(URL(string: "twitter://")!) {
            addTwitterIconToNavBar()
        }
    }

    override func createViewModel(_ dataSourceURL: String) -> OCVTwitterModel {
        return OCVTwitterModel(dataSourceURL: dataSourceURL, sendingTable: self)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: tableCellIdentifier) as? OCVResizingCell else {
            fatalError("Could not dequeue cell with identifier: \(tableCellIdentifier)")
        }

        cell.shouldShowDate = showsDates

        cell.setupConstraintsWithImage(twitterViewModel!.thumbnailForCellAtIndexPath(indexPath))
        cell.circlizeImage()

        cell.titleLabel.text = twitterViewModel!.titleForCellAtIndexPath(indexPath)
        cell.descLabel.text = twitterViewModel!.descForCellAtIndexPath(indexPath)
        cell.dateLabel.text = twitterViewModel!.dateForCellAtIndexPath(indexPath)

        cell.setNeedsUpdateConstraints()
        cell.layoutSubviews()

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tweet = twitterViewModel!.twitterObjectForCellAtIndexPath(indexPath)
        let cell = tableView.cellForRow(at: indexPath)

        let twitterAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        var actions = [UIAlertAction]()

        actions.append(UIAlertAction(title: "Open Tweet", style: .default) { (action) -> Void in
            guard let twitterDefaultURL = URL(string: "twitter://") else {
                tableView.deselectRow(at: indexPath, animated: true)
                return
            }
            if UIApplication.shared.canOpenURL(twitterDefaultURL) {
                guard let tweetURL = URL(string: "twitter://status?id=\(tweet.id)") else {
                    tableView.deselectRow(at: indexPath, animated: true)
                    return
                }
                UIApplication.shared.openURL(tweetURL)
            } else {
                self.openInSafari(tweet.contentURL)
            }
        })

        actions.append(UIAlertAction(title: "Share Tweet", style: .default, handler: { (action) -> Void in
            self.shareContentAtPopOver(tweet, view: cell!)
            }))

        actions.append(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            twitterAlertController.dismiss(animated: true, completion: nil)
            }))

        for action in actions {
            twitterAlertController.addAction(action)
        }

        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            OCVAppUtilities.setupForPopOver(twitterAlertController, view: cell!)
        }

        present(twitterAlertController, animated: true, completion: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func openInSafari(_ url: URL) {
        if #available(iOS 9.0, *) {
            let safariBrowser = SFSafariViewController(url: url)
//            safariBrowser.delegate = self
            safariBrowser.view.tintColor = AppColors.primary.color
            present(safariBrowser, animated: true, completion: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }

    func shareContentAtPopOver(_ object: Any, view: UIView) {
        if let tweet = object as? OCVTwitterObject {
            let activityItems = ["@\(tweet.userTitle) tweeted:\n\(tweet.content)"]
            let activityController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)

            if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
                OCVAppUtilities.setupForPopOver(activityController, view: view)
            }

            present(activityController, animated: true, completion: nil)
        }
    }

    func addTwitterIconToNavBar() {
        let twitterIcon = UIImage(named: "twitterNavIcon")?.withRenderingMode(.alwaysTemplate)
        let twitterBarButtonItem = UIBarButtonItem(image: twitterIcon, style: .plain, target: self, action: #selector(OCVTwitter.openInTwitter))
        twitterBarButtonItem.tintColor = AppColors.text.color
        self.navigationItem.rightBarButtonItem = twitterBarButtonItem
    }

    func openInTwitter() {
        UIApplication.shared.openURL(URL(string: "twitter://user?screen_name=\(username)")!)
    }
}
