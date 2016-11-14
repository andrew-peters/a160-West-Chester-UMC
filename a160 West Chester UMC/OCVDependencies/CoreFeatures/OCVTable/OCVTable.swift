//
//  OCVTable.swift
//  OCVSwift
//
//  Created by Eddie Seay on 1/12/16.
//  Copyright © 2016 OCV,LLC. All rights reserved.
//

import UIKit
import STPopup

class OCVTable: UITableViewController { //, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {

    fileprivate let tableCellIdentifier = "OCVDefaultTableCell"
    var dateFormatter = DateFormatter()
    let url: String?
    let navTitle: String?
    var viewModel: OCVTableModel?
    var circleImages: Bool?
    var showsDates = true

    // MARK: - Lifecycle
    init(dataSourceURL: String, navTitle: String) {
        url = dataSourceURL
        self.navTitle = navTitle
        super.init(nibName: nil, bundle: nil)
    }

    init(dataSourceURL: String, navTitle: String, grouped: Bool) {
        url = dataSourceURL
        self.navTitle = navTitle
        if #available(iOS 9, *) {
            if grouped == true {
                super.init(style: .grouped)
            } else {
                super.init(style: .plain)
            }
        } else {
            super.init(nibName: nil, bundle: nil)
        }
    }

    init(dataSourceURL: String, navTitle: String, circleImages: Bool?, showsDates: Bool?) {
        url = dataSourceURL
        self.navTitle = navTitle
        self.circleImages = circleImages
        if showsDates != nil {
            self.showsDates = showsDates!
        }
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        print("Deinit called")
    }

    func createViewModel(_ dataSourceURL: String) -> OCVTableModel {
        return OCVTableModel(dataSourceURL: dataSourceURL, sendingTable: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel = createViewModel(url!)
        viewModel!.sendingTable = self

        self.setupInitialFunctionality()
    }

    /**
     Sets up all of the standard functionality that will be inherited throughout
     all classes that based themselves around a UITableView in the OCV library.
     */
    func setupInitialFunctionality() {
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("presentDownloadErrorOccurredAlert:"), name: "DownloadFailure", object: nil)

        self.navigationItem.title = navTitle

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
        tableView.register(OCVDefaultTableCell.self, forCellReuseIdentifier: tableCellIdentifier)

        /**
         Sets up UITableView's refreshControl for pull-to-refresh
         */
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.backgroundColor = AppColors.background.color
        self.refreshControl?.tintColor = AppColors.text.color
        self.refreshControl?.addTarget(self,
            action: #selector(OCVTable.refreshControlTriggered),
            for: .valueChanged)
    }

    override func viewDidDisappear(_ animated: Bool) {
        OCVAppUtilities.finishTask()

        if self.isMovingFromParentViewController {
            if !(viewModel!.dataRetriever?.taskQueue.isEmpty ?? true) {
                viewModel!.dataRetriever?.cancelAllRequests()
            }
            viewModel!.dataRetriever = nil
            viewModel = nil
            NotificationCenter.default.removeObserver(self)
        }
    }

    func refreshControlTriggered() {
        viewModel!.downloadSourceData(url!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel!.numberOfSections()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel!.numberOfRowsInSection(section)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: tableCellIdentifier) as? OCVDefaultTableCell else {
            fatalError("Could not dequeue cell with identifier: \(tableCellIdentifier)")
        }

        cell.shouldShowDate = showsDates

        if viewModel!.hasImagesForCellAtIndexPath(indexPath) {
            cell.setupConstraintsWithImage(viewModel!.thumbnailForCellAtIndexPath(indexPath))
            if circleImages == true {
                cell.circlizeImage()
            }
        } else {
            cell.imageView?.image = nil
            cell.setupRegularConstraints()
        }

        cell.titleLabel.text = viewModel!.titleForCellAtIndexPath(indexPath)
        cell.descLabel.text = viewModel!.descForCellAtIndexPath(indexPath)
        cell.dateLabel.text = viewModel!.dateForCellAtIndexPath(indexPath)

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let detail = viewModel?.detailViewFromIndexPath(indexPath) {
            self.navigationController?.pushViewController(detail, animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // GOOD
    func pushObjectFromNotificationWithID(_ identifier: String) {
        if let detail = viewModel?.detailViewWithBlogID(identifier) {
            self.navigationController?.pushViewController(detail, animated: true)
        }
    }

    /**
     Standard height for a cell in an OCVTable

     - parameter tableView: UITableView in which the cells exist
     - parameter indexPath: Location of cell in tableview

     - returns: Numerical height of the row
     */
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88
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
            self.viewModel!.downloadSourceData(self.url!)
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
            NSForegroundColorAttributeName: UIColor(hexString: "#849495")] as [String : Any]

        return NSAttributedString.init(string: text, attributes: attrs)
    }

    func descriptionForEmptyDataSet(_ scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "Pull down to check for updates."
        let font = AppFonts.RegularText.font(16)

        let paragraph: NSMutableParagraphStyle = {
            $0.lineBreakMode = .byWordWrapping
            $0.alignment = .center
            $0.lineSpacing = 4.0
            return $0
        }(NSMutableParagraphStyle())

        let attrs = [NSFontAttributeName: font,
            NSForegroundColorAttributeName: UIColor(hexString: "#849495"),
            NSParagraphStyleAttributeName: paragraph]

        return NSAttributedString(string: text, attributes: attrs)
    }

    func imageForEmptyDataSet(_ scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "empty_blog_placeholder")
    }

    func backgroundColorForEmptyDataSet(_ scrollView: UIScrollView!) -> UIColor! {
        return AppColors.standardWhite.color
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
            dateFormatter.dateFormat = "MMM d, h:mm a"
            let title = "Last update: \(dateFormatter.string(from: Date()))"

            let textColor = AppColors.text.color
            let attrsDict = [NSForegroundColorAttributeName: textColor]
            let attributedTitle = NSAttributedString(string: title, attributes: attrsDict)
            self.refreshControl?.attributedTitle = attributedTitle

            self.refreshControl?.endRefreshing()
        }
    }

//    @available(iOS 9.0, *)
//    func safariViewControllerDidFinish(controller: SFSafariViewController) {
//        controller.dismissViewControllerAnimated(true, completion: nil)
//    }
}
