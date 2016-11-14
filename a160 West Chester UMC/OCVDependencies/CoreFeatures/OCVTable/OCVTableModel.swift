//
//  OCVTableModel.swift
//  OCVSwift
//
//  Created by Eddie Seay on 1/12/16.
//  Copyright © 2016 OCV,LLC. All rights reserved.
//

import Foundation
import DrawerController

class OCVTableModel {

    var dataRetriever: OCVNetworkClient? = OCVNetworkClient()
    weak var sendingTable: OCVTable?
    var feedArray: [Any] = [] {
        didSet {
            sendingTable?.tableView.reloadData()
        }
    }

    /**
     Initializes the viewModel with the URL of it's data source
     and a reference to it's controlling table.

     - parameter dataSourceURL: String of URL from where to retrieve data
     - parameter sendingTable:  Table that is requesting information from the viewModel

     */
    init(dataSourceURL: String, sendingTable: OCVTable) {
        self.sendingTable = sendingTable
        downloadSourceData(dataSourceURL)
    }

    /**
     Indicates that the model has been deinitialized and does general cleanup.
     */
    deinit {
        print("Table Model Deinit Called")
        sendingTable = nil
        dataRetriever = nil
        feedArray = []
    }
    /**
     Begins listening for notitications to that it knows whether or not
     the download completed successfully.
     */
//    func beginListeningForNotifications() {
//        NSNotificationCenter.defaultCenter().removeObserver(self)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("receiveResponse:"), name: "CompleteDownloadNotification", object: nil)
//    }

    /**
     Initiates download of data from the given data source

     - parameter url: String of URL from where to retrieve data.
     */
    func downloadSourceData(_ url: String) {

//        let progressIndicator = true

//        if let sourceNav = sendingTable?.parentViewController as? UINavigationController {
//            if let _ = sourceNav.parentViewController as? DrawerController {
//                progressIndicator = false
//            }
//        }

//        dataRetriever?.downloadDataWithURLCompletionHandler(url, showProgress: progressIndicator) { responseData in
//            if self.completedProperly(responseData) == true {
//                guard let data = responseData["data"] as? NSData else {
//                    return
//                }
//                self.setDataSource(data)
//                self.handleReceivedData(data)
//                OCVAppUtilities.finishTask()
//            }
//        }
        dataRetriever?.downloadFrom(url: url, showProgress: true) { resultData, code in
            if self.completedProperly(resultData, code: code) {
                guard let data = resultData else { return }
                self.setDataSource(data)
                self.handleReceivedData(data)
                OCVAppUtilities.finishTask()
            }
        }
    }

    /**
     Default table value of 1 section

     - returns: 1
     */
    func numberOfSections() -> Int {
        return 1
    }

    /**
     Default table value of items.count rows

     - parameter section: The section for which to determine row count

     - returns: items.count
     */
    func numberOfRowsInSection(_ section: Int) -> Int {
        return feedArray.count
    }

    /**
     Creates an OCVDetail object from a specific index path

     - parameter indexPath: The index path in the data collection of the item
     for which an OCVDetail needs to be created

     - returns: OCVDetail object
     */
    func detailViewFromIndexPath(_ indexPath: IndexPath) -> OCVDetail {
        return OCVDetail(object: objectForCellAtIndexPath(indexPath))
    }

    /**
     Cretes an OCVDetail object from a specific passed blog ID.
     This is used specifically to opening directly to a blog posting
     from push notifications that are received.

     - parameter id: ID number of blog post to open

     - returns: OCVDetail object
     */
    func detailViewWithBlogID(_ id: String) -> OCVDetail {
        for item in feedArray {
            if let tableObject = item as? OCVTableObject {
                if tableObject.identifier == id {
                    return OCVDetail(object: tableObject)
                }
            } else if let msgObject = item as? OCVMessageObject {
                if msgObject.id == id {
                    return OCVDetail(object: msgObject)
                }
            }
        }

        let defaultObject = OCVTableObject(id: "1234567890", title: "Error", content: "There is no content available for the designated identifier. Please contact our support team from the 'Developer Feedback' feature in the Settings menu. Thank you.", creator: "OCV Developer", date: "", imageArr: [])
        return OCVDetail(object: defaultObject)
    }

    /**
     Returns an object from the feedArray at a given index path.
     This method is CRITICAL because it is how the viewModel is able to
     interact with various properties of a given object since
     the feedArray allows generic types.

     - parameter indexPath: The index path in the feedArray of the object to be returned

     - returns: Generic OCVTableObject
     */
    func objectForCellAtIndexPath(_ indexPath: IndexPath) -> OCVTableObject {
        if let objAt = feedArray[(indexPath as NSIndexPath).row] as? OCVTableObject {
            return objAt
        }
        return OCVTableObject(id: "1234567890", title: "Error", content: "There is no content available for the designated identifier. Please contact our support team from the 'Developer Feedback' feature in the Settings menu. Thank you.", creator: "OCV Developer", date: "", imageArr: [])
    }

    /**
     Returns title for cell at a given index path

     - parameter indexPath: Index path of object

     - returns: Cell title
     */
    func titleForCellAtIndexPath(_ indexPath: IndexPath) -> String {
        return objectForCellAtIndexPath(indexPath).title
    }

    /**
     Returns description for cell at a given index path

     - parameter indexPath: Index path of object

     - returns: Cell description
     */
    func descForCellAtIndexPath(_ indexPath: IndexPath) -> String {
        return objectForCellAtIndexPath(indexPath).description
    }

    /**
     Returns date for cell at a given index path

     - parameter indexPath: Index path of object

     - returns: Cell date value
     */
    func dateForCellAtIndexPath(_ indexPath: IndexPath) -> String {
        return objectForCellAtIndexPath(indexPath).date
    }

    /**
     Returns image Boolean for cell at a given index path

     - parameter indexPath: Index path of object

     - returns: true or false for if images exist in object
     */
    func hasImagesForCellAtIndexPath(_ indexPath: IndexPath) -> Bool {
        return objectForCellAtIndexPath(indexPath).hasImages()
    }

    /**
     Returns thumbnail image for cell at a given index path

     - parameter indexPath: Index path of object

     - returns: Cell thumbnail image URL string
     */
    func thumbnailForCellAtIndexPath(_ indexPath: IndexPath) -> String {
        if let thumbString = objectForCellAtIndexPath(indexPath).firstThumbnail() {
            return thumbString
        }
        return ""
    }

    /**
     Returns images for cell at a given index path

     - parameter indexPath: Index path of object

     - returns: Array of images for cell
     */
    func imageArrayForCellAtIndexPath(_ indexPath: IndexPath) -> [AnyObject] {
        return objectForCellAtIndexPath(indexPath).images
    }

    /**
     Utilizes OCVJSONParser to take raw data and parse it into objects
     in the feedArray

     - parameter data: Raw data of JSON response
     */
    func setDataSource(_ data: Data) {
        self.feedArray = OCVFeedParser().parseArrayOfTableObjectsFromData(data)
    }

    /**
     Determines if any valid data was returned and whether or not the code
     is one that represents a successful retrieval.

     - parameter data: Raw data of JSON response. Could be nil
     - parameter code: The response code

     - returns: True if data has a value
     */
    func completedProperly(_ data: Data?, code: Int) -> Bool {
        guard let _ = data else {
            self.sendingTable?.presentDownloadErrorAlert(false)
            return false
        }
        if code != 200 {
            self.sendingTable?.presentDownloadErrorAlert(true)
        }

        return true
    }

    func handleReceivedData(_ data: Data) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "ReadyToPushDetail"), object: self.sendingTable)
        if sendingTable?.refreshControl?.isRefreshing == true {
            sendingTable?.endRefreshing()
        }
        OCVAppUtilities.finishTask()
    }
}
