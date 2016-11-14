//
//  CalendarViewModel.swift
//  OCVSwift
//
//  Created by Eddie Seay on 6/1/16.
//  Copyright © 2016 OCV,LLC. All rights reserved.
//

import Foundation

class OCVCalendarViewModel: OCVTableModel {

    var eventArray = [[OCVCalendarEvent]]() {
        didSet {
            sendingTable?.tableView.reloadData()
            if !eventArray[1].isEmpty {
                let indexPath = IndexPath(item: 0, section: 1)
                sendingTable?.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
            } else if !eventArray[0].isEmpty {
                let lastItem = eventArray[0].count - 1
                let indexPath = IndexPath(item: lastItem, section: 0)
                sendingTable?.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
            }
        }
    }
    let dateFormatter = DateFormatter()

    override func setDataSource(_ data: Data) {
        eventArray = OCVFeedParser().parseCalendarEvents(data)
    }

    override func numberOfSections() -> Int {
        return 1
    }

    override func numberOfRowsInSection(_ section: Int) -> Int {
        return eventArray.count
    }

    func eventAtIndexPath(_ indexPath: IndexPath) -> OCVCalendarEvent {
        return eventArray[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
    }

    func month(_ indexPath: IndexPath) -> String {
        dateFormatter.dateFormat = "MMM"
        return dateFormatter.string(from: eventArray[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row].startDate as Date)
    }

    func day(_ indexPath: IndexPath) -> String {
        dateFormatter.dateFormat = "E"
        return dateFormatter.string(from: eventArray[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row].startDate as Date)
    }

    func numericDate(_ indexPath: IndexPath) -> String {
        dateFormatter.dateFormat = "dd"
        return dateFormatter.string(from: eventArray[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row].startDate as Date)
    }

    func year(_ indexPath: IndexPath) -> String {
        dateFormatter.dateFormat = "yyyy"
        return dateFormatter.string(from: eventArray[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row].startDate as Date)
    }

    func startTime(_ indexPath: IndexPath) -> String {
        dateFormatter.dateFormat = "h:mm a"
        return dateFormatter.string(from: eventArray[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row].startDate as Date)
    }

    func endTime(_ indexPath: IndexPath) -> String {
        dateFormatter.dateFormat = "h:mm a"
        return dateFormatter.string(from: eventArray[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row].endDate as Date)
    }
}
