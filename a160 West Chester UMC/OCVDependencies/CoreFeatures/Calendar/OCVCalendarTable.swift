//
//  CalendarTable.swift
//  OCVSwift
//
//  Created by Eddie Seay on 6/1/16.
//  Copyright © 2016 OCV,LLC. All rights reserved.
//

import UIKit
import EventKit
import SVProgressHUD

class OCVCalendarTable: OCVTable {

    let tableCellIdentifier = "CalendarCell"
    var calModel: OCVCalendarViewModel!

    init(gmailUsername: String) {
        
//        let today = Date()
//        let gregorian = Calendar.current;
//        let unitFlags: Calendar.Unit = [.hour, .minute, .day, .month, .year]
//        var yearAgoComps = (gregorian as NSCalendar).components(unitFlags, from: today)
//        var yearAheadComps = (gregorian as NSCalendar).components(unitFlags, from: today)
//        
//        yearAgoComps.year = yearAgoComps.year! - 1;
//        yearAheadComps.year = yearAheadComps.year! + 1;
//        yearAheadComps.month = yearAheadComps.month! + 1;
//        if yearAheadComps.month == 13 {
//            yearAheadComps.month = 1
//        }
        
//        let yearAgo = gregorian.date(from: yearAgoComps)
//        let thirteenAhead = gregorian.date(from: yearAheadComps)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'hh:mm:ssZZZ"
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        
//        let yearAgoString = dateFormatter.string(from: yearAgo!)
//        let thirteenAheadString = dateFormatter.string(from: thirteenAhead!)
        
        let source = "https://www.googleapis.com/calendar/v3/calendars/\(gmailUsername)/events?key=AIzaSyDgHUQbc9SLRq_SI9rIWN4voT2-j0K4_6M&singleEvents=true&orderBy=startTime"
        super.init(dataSourceURL: source, navTitle: "Calendar", circleImages: false, showsDates: false)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        if let currentURL = url {
            calModel = createViewModel(currentURL)
        }

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Today", style: .plain, target: self, action: #selector(OCVCalendarTable.scrollToNextFutureEvent))

        viewModel = calModel
        self.setupInitialFunctionality()
        calModel?.sendingTable = self
        self.tableView.register(OCVCalendarCell.self, forCellReuseIdentifier: tableCellIdentifier)
    }

    override func createViewModel(_ dataSourceURL: String) -> OCVCalendarViewModel {
        return OCVCalendarViewModel(dataSourceURL: dataSourceURL, sendingTable: self)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return calModel.eventArray.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return calModel.eventArray[section].count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:  return nil
        case 1:  return "Future Events"
        default: return nil
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: tableCellIdentifier) as? OCVCalendarCell else {
            fatalError("Could not dequeue cell with identifier: \(tableCellIdentifier)")
        }

        let event = calModel.eventAtIndexPath(indexPath)

        cell.dayLabel.text = calModel.day(indexPath)
        cell.numericDateLabel.text = "\(calModel.month(indexPath)), \(calModel.numericDate(indexPath))"
        cell.yearLabel.text = calModel.year(indexPath)

        cell.summaryLabel.text = event.summary
        
        //Verify that if starttime and endtime are both 12AM then change text to "All Day Event"
        if calModel.startTime(indexPath) == "12:00 AM" && calModel.endTime(indexPath) == "12:00 AM" {
            cell.descLabel.text = "All Day Event"
        }
        else {
            cell.descLabel.text = "Start: \(calModel.startTime(indexPath)) | End: \(calModel.endTime(indexPath))"
        }

        if let locString = event.location {
            cell.locationLabel.text = "Location: \(locString)"
        }

        if event.description != nil {
            cell.detailLabel.isHidden = false
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let event = calModel.eventAtIndexPath(indexPath)
        let cell = tableView.cellForRow(at: indexPath)

        let activityItems = ["\(event.summary)\n\(event.description ?? "")\n\(self.calModel.startTime(indexPath))-\(self.calModel.endTime(indexPath))\n\(event.location ?? "")"]

        let actionView = UIAlertController(title: event.summary, message: event.description ?? "Select an option below.", preferredStyle: .actionSheet)

        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let addToCal = UIAlertAction(title: "Add To My Calendar", style: .default) { (action) in
            OCVAppUtilities.addEventToCalendar(title: event.summary, description: event.description, location: event.location, startDate: event.startDate, endDate: event.endDate)
        }
        let shareEvent = UIAlertAction(title: "Share Event", style: .default) { (action) in

            let activityController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)

            if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
                OCVAppUtilities.setupForPopOver(activityController, view: cell!)
            }

            self.present(activityController, animated: true, completion: nil)
        }
        let webview = UIAlertAction(title: "Open in Safari", style: .default) { (action) in
            if let url = URL(string: event.htmlLink) {
                UIApplication.shared.openURL(url)
            }
        }

        if let locString = event.location {
            let copyLocation = UIAlertAction(title: "Open in Maps", style: .default, handler: { (action) in
                let address = locString.replacingOccurrences(of: " ", with: "+").replacingOccurrences(of: ",", with: "").replacingOccurrences(of: ".", with: "")
                if let directionURL = URL(string: "http:/maps.apple.com/?daddr=\(address)") {
                    if UIApplication.shared.canOpenURL(directionURL) {
                        UIApplication.shared.openURL(directionURL)
                    }
                }
            })
            actionView.addAction(copyLocation)
        }

        actionView.addAction(cancel)
        actionView.addAction(addToCal)
        actionView.addAction(shareEvent)
        actionView.addAction(webview)

        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            OCVAppUtilities.setupForPopOver(actionView, view: cell!)
        }
        present(actionView, animated: true, completion: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }

    func scrollToNextFutureEvent() {
        if !calModel.eventArray[1].isEmpty {
            let indexPath = IndexPath(item: 0, section: 1)
            tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        } else if !calModel.eventArray[0].isEmpty {
            let lastItem = calModel.eventArray[0].count
            let indexPath = IndexPath(item: lastItem, section: 0)
            tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }
}
