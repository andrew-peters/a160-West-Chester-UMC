//
//  OCVBaseTable2.swift
//  OCVSwift

import UIKit

class OCVBaseTable: UITableViewController { //, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {

    var tableViewDataCoordinator: DataCoordinator!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupInitialFunctionality()
    }

    /**
     Sets up all of the standard functionality that will be inherited throughout
     all classes that based themselves around a UITableView in the OCV library.
     */
    func setupInitialFunctionality() {
        // NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("presentDownloadErrorOccurredAlert:"), name: "DownloadFailure", object: nil)

        tableView.sectionIndexBackgroundColor = UIColor.clear
        tableView.sectionIndexTrackingBackgroundColor = UIColor.clear
        tableView.sectionIndexColor = AppColors.primary.color
        /**
         Sets the empty state of the table.
         */
        tableView.backgroundColor = AppColors.background.color
        tableView.separatorColor = AppColors.secondary.color

        if #available(iOS 9.0, *) {
            tableView.cellLayoutMarginsFollowReadableWidth = false
        }

//        tableView.emptyDataSetDelegate = self
//        tableView.emptyDataSetSource = self
        tableView.tableFooterView = UIView()

        /**
         Sets up UITableView's refreshControl for pull-to-refresh
         */
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.backgroundColor = AppColors.background.color
        self.refreshControl?.tintColor = AppColors.oppositeOfPrimary.color
        self.refreshControl?.addTarget(self,
                                       action: #selector(handlePullToRefresh),
                                       for: .valueChanged)
    }

    func handlePullToRefresh() {
        tableViewDataCoordinator.refresh {
            self.endRefreshing()
        }
    }

    /**
     Displays an alert informing the user that the data download has failed.
     If there is saved data, then options are presented to allow it to be
     either viewed or tried again.

     - parameter cachedData: Whether or not there is cached data.
     */
    func presentDownloadErrorAlert(_ cachedData: Bool) {
        let alertTitle = "Download Error"
        var alertMessage: String?
        var actionArray: [UIAlertAction] = []

        let actionReload = UIAlertAction(title: "Try Again", style: .default) { (action) -> Void in
            self.tableViewDataCoordinator.refresh {}
        }

        actionArray.append(actionReload)

        if cachedData == false {
            alertMessage = "There is no data available to display"
            let actionDismiss = UIAlertAction(title: "Dismiss", style: .cancel, handler: { (action) -> Void in
                _ = self.navigationController?.popViewController(animated: true)
            })
            actionArray.append(actionDismiss)
        } else {
            alertMessage = "Cached data being displayed"
            let actionOk = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            actionArray.append(actionOk)
        }

        let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)

        for action: UIAlertAction in actionArray {
            alertController.addAction(action)
        }

        OCVAppUtilities.finishTask()
        self.present(alertController, animated: true, completion: nil)
    }

    // MARK: DZNEmptyDataSetSource Methods
    func titleForEmptyDataSet(_ scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "No Entries Available"
        let font = AppFonts.LightText.font(30)

        let attrs = [NSFontAttributeName: font,
            // Chameleon - FlatGray()
            NSForegroundColorAttributeName: UIColor(red: 132 / 255.0, green: 148 / 255.0, blue: 149 / 255.0, alpha: 1)]

        return NSAttributedString.init(string: text, attributes: attrs)
    }

    func descriptionForEmptyDataSet(_ scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "Pull down to check for updates."
        let font = AppFonts.RegularText.font(16)

        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byWordWrapping
        paragraph.alignment = .center
        paragraph.lineSpacing = 4.0

        let attrs = [NSFontAttributeName: font,
            // Chameleon - FlatGray()
            NSForegroundColorAttributeName: UIColor(red: 132 / 255.0, green: 148 / 255.0, blue: 149 / 255.0, alpha: 1),
            NSParagraphStyleAttributeName: paragraph]

        return NSAttributedString(string: text, attributes: attrs)
    }

    func imageForEmptyDataSet(_ scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "empty_blog_placeholder")
    }

    func backgroundColorForEmptyDataSet(_ scrollView: UIScrollView!) -> UIColor! {
        // Chameleon - FlatWhite() in traditional UIKit
        return UIColor(red: 232 / 255.0, green: 236 / 255.0, blue: 238 / 255.0, alpha: 1)
    }

    func spaceHeightForEmptyDataSet(_ scrollView: UIScrollView!) -> CGFloat {
        return 15.0
    }

    // MARK: DZNEmptyDataSetDelegate Methods
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        return true
    }

    func emptyDataSetShouldAllowTouch(_ scrollView: UIScrollView!) -> Bool {
        return true
    }

    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return true
    }

    /**
     Terminates refreshControl action and updates the most recently
     updated times.
     */
    func endRefreshing() {
        if self.refreshControl != nil {
            let df = DateFormatter()
            df.dateFormat = "MMM d, h:mm a"
            let title = "Last update: \(df.string(from: Date()))"
            let attrsDict = [NSForegroundColorAttributeName: AppColors.oppositeOfPrimary.color]
            let attributedTitle = NSAttributedString(string: title, attributes: attrsDict)
            self.refreshControl?.attributedTitle = attributedTitle

            self.refreshControl?.endRefreshing()
        }
    }
}
