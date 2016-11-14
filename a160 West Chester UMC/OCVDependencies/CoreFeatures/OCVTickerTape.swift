//
//  OCVTickerTape.swift
//  OCVSwift
//
//  Created by Eddie Seay on 5/27/16.
//  Copyright © 2016 OCV,LLC. All rights reserved.
//

import UIKit
import SnapKit

class OCVTickerTape: UIView {

    let tickerLabel: MarqueeLabel = {
        $0.backgroundColor = AppColors.alertRed.color
        $0.textColor = AppColors.standardWhite.color
        $0.textAlignment = .center
        $0.trailingBuffer = 30.0
        $0.font = AppFonts.RegularText.font(18)
        return $0
    }(MarqueeLabel(frame: CGRect.zero, rate: 50, fadeLength: 0))

    let dateFormatter = DateFormatter()

    init() {
        super.init(frame: CGRect.zero)

        dateFormatter.dateStyle = .long

        addSubview(tickerLabel)
        tickerLabel.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(OCVTickerTape.updateLabel), name: NSNotification.Name(rawValue: "RecentAlertsUpdated"), object: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // swiftlint:disable legacy_constructor
    func updateLabel() {
        let now = Date()
        let recentMessages = OCVAppUtilities.SharedInstance.getRecentAlerts()
        if recentMessages.isEmpty {
            let attributedText = NSMutableAttributedString(string: "There are currently no active alerts.")
            attributedText.addAttribute(NSFontAttributeName, value: AppFonts.RegularText.font(18), range: NSMakeRange(0, attributedText.length))
            tickerLabel.attributedText = attributedText
        } else {
            let tickerString = NSMutableAttributedString(string: " ")

            for message in recentMessages {
                let attributedTitle = NSMutableAttributedString(string: "\(message.title) ")
                attributedTitle.addAttribute(NSFontAttributeName, value: AppFonts.SemiboldText.font(18), range: NSMakeRange(0, attributedTitle.length))

                let timeSincePost = now.timeAgoSinceDate(message.date, numericDates: true)
                let attributedDate = NSMutableAttributedString(string: "\(timeSincePost)  |  ")
                attributedDate.addAttribute(NSFontAttributeName, value: AppFonts.LightItalicText.font(16), range: NSMakeRange(0, attributedDate.length))

                attributedTitle.append(attributedDate)

                tickerString.append(attributedTitle)
            }

            tickerString.replaceCharacters(in: NSMakeRange(tickerString.length-3, 3), with: "")
            tickerLabel.attributedText = tickerString
        }
        NotificationCenter.default.post(name: Notification.Name(rawValue: "TickerTapeUpdated"), object: nil)
    }
}
