//
//  DigestController.swift
//  OCVSwift
//
//  Created by Eddie Seay on 6/3/16.
//  Copyright © 2016 OCV,LLC. All rights reserved.
//

import UIKit
import SVProgressHUD

private let tableCellIdentifier = "DigestCell"

class OCVDigestController: NSObject, UITableViewDelegate, UITableViewDataSource {

    let twitterUsername: String!
    let fbID: String!
    let facebookURL: String!

    var tableView = UITableView()
    var parentVC = UIViewController()
    var digestArray = [OCVDigestObject]() {
        didSet {
            tableView.reloadData()
        }
    }

    init(twitterUsername: String?, fbID: String?, facebookURL: String?) {
        self.twitterUsername = twitterUsername ?? ""
        self.fbID = fbID ?? ""
        self.facebookURL = facebookURL ?? ""

        super.init()
//        OCVNetworkClient().apiRequest(atPath: "/dynamic/digest/\(Config.applicationID)", httpMethod: .get, parameters: [:], showProgress: true) { resultData, _ in
//            self.digestArray = OCVFeedParser().parseDigestObjects(resultData)
//        }
        self.apiDigestRequest()
    }
    
    func apiDigestRequest() {
        SVProgressHUD.show(withStatus: "Loading Digest")
        let urlString = "https://api.myocv.com/dynamic/digest/\(Config.applicationID)?\(OCVAppUtilities.SharedInstance.apiString())"
        OCVNetworkClient().downloadFrom(url: urlString, showProgress: true) { resultData, code in
            if self.completedProperly(resultData, code: code) {
                
                self.digestArray = OCVFeedParser().parseDigestObjects(resultData)
                
                SVProgressHUD.dismiss()
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    func completedProperly(_ data: Data?, code: Int) -> Bool {
        guard let _ = data else {
            self.presentDownloadErrorAlert(false, data: data)
            return false
        }
        if code != 200 {
            self.presentDownloadErrorAlert(true, data: data)
        }
        
        return true
    }
    
    func presentDownloadErrorAlert(_ cachedData: Bool, data: Data?) {
        let alertTitle = "Download Error"
        let alertMessage: String = "The form could not download at this time. Please try again."
        var actionArray: [UIAlertAction] = []
        
        //try again
        let actionReload = UIAlertAction(title: "Try Again", style: .default) { (action) -> Void in
            self.digestArray = OCVFeedParser().parseDigestObjects(data)
        }
        actionArray.append(actionReload)
        
        //redownload
        let actionDismiss = UIAlertAction(title: "Dismiss", style: .cancel, handler: { (action) -> Void in
            _ = self.parentVC.navigationController?.popViewController(animated: true)
        })
        actionArray.append(actionDismiss)
        
        let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        
        for action: UIAlertAction in actionArray {
            alertController.addAction(action)
        }
        
        SVProgressHUD.dismiss()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        self.parentVC.present(alertController, animated: true, completion: nil)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return digestArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: tableCellIdentifier) as? OCVDigestCell else {
            fatalError("Could not dequeue cell with identifier: \(tableCellIdentifier)")
        }
        let item = digestArray[(indexPath as NSIndexPath).row]

        cell.titleLabel.text = item.title
        cell.descLabel.text = item.summary
        cell.dateLabel.text = Date().timeAgoSinceDate(item.date, numericDates: true)

        switch item.mediaType {
        case 1:
            cell.imageItem.image = UIImage(named: "digest-blog")?.withRenderingMode(.alwaysTemplate)
            cell.imageItem.tintColor = UIColor.gray
        case 2:
            cell.imageItem.image = UIImage(named: "twitterLogo-blue")
        case 3:
            cell.imageItem.image = UIImage(named: "facebookLogo-blue")
        default:
            cell.imageItem.image = UIImage(named: "digestStream")?.withRenderingMode(.alwaysTemplate)
            cell.imageItem.tintColor = UIColor.gray
        }

        return cell
    }

    // swiftlint:disable function_body_length
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = digestArray[(indexPath as NSIndexPath).row]
        tableView.deselectRow(at: indexPath, animated: true)
        guard let currentCell = tableView.cellForRow(at: indexPath) else {
            return
        }

        switch item.mediaType {
        case 2:
            var twitterURLString = ""
            if let tweetID = item.tweetID {
                twitterURLString = "twitter://status?id=\(tweetID)"
            } else {
                twitterURLString = "twitter://user?id=\(twitterUsername)"
            }

            let twitterURL = URL(string: twitterURLString)
            if UIApplication.shared.canOpenURL(twitterURL!) {
                let twitterAlertController = UIAlertController(title: "Open in Twitter",
                                                               message: "You can either open this tweet in the Twitter app, or you may shaire it via email, text, etc",
                                                               preferredStyle: UIAlertControllerStyle.actionSheet)
                let open = UIAlertAction(title: "Open Tweet", style: .default, handler: { (action) in
                    UIApplication.shared.openURL(twitterURL!)
                })
                let share = UIAlertAction(title: "Share Tweet", style: .default, handler: { (action) in
                    let activityItems = ["\(item.title) tweeted:\n\(item.content)"]
                    let activityController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)

                    if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
                        OCVAppUtilities.setupForPopOver(activityController, view: currentCell)
                    }
                    self.parentVC.present(activityController, animated: true, completion: nil)
                })
                let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                    twitterAlertController.dismiss(animated: true, completion: nil)
                })

                twitterAlertController.addAction(open)
                twitterAlertController.addAction(share)
                twitterAlertController.addAction(cancel)

                OCVAppUtilities.setupForPopOver(twitterAlertController, view: currentCell)
                parentVC.present(twitterAlertController, animated: true, completion: nil)
            }

        case 3:

            let fbURLString = "fb://profile/\(fbID!)"
            let fbURL = URL(string: fbURLString)
            if UIApplication.shared.canOpenURL(fbURL!) {
                let facebookAlertController = UIAlertController(title: "Open Facebook Post", message: "You may either open this post in the Facebook app, or you may view the post quickly inside our app.", preferredStyle: .actionSheet)
                let open = UIAlertAction(title: "Open in Facebook", style: .default, handler: { (action) in
                    UIApplication.shared.openURL(fbURL!)
                })
                let detail = UIAlertAction(title: "Show in Detail", style: .default, handler: { (action) in
                    self.parentVC.navigationController?.pushViewController(OCVDetail(object: item), animated: true)
                })
                let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                    facebookAlertController.dismiss(animated: true, completion: nil)
                })

                facebookAlertController.addAction(open)
                facebookAlertController.addAction(detail)
                facebookAlertController.addAction(cancel)

                OCVAppUtilities.setupForPopOver(facebookAlertController, view: currentCell)
                parentVC.present(facebookAlertController, animated: true, completion: nil)

            } else {
                UIApplication.shared.openURL(URL(string: facebookURL)!)
            }

        default:
            parentVC.navigationController?.pushViewController(OCVDetail(object: item), animated: true)
        }

    }
}
