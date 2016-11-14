//
//  OCVRadarCell.swift
//  OCVSwift
//
//  Created by Eddie Seay on 6/9/16.
//  Copyright © 2016 OCV,LLC. All rights reserved.
//

import UIKit

class OCVRadarCell: UITableViewCell {

    var radarLinks: RadarLinks? = nil
    let radarWebview = UIWebView()
    var webViewHidden = true
    var parentTableView = UITableView()
    var parentController = OCVDailyForecastAlertsController()

    let radarLabel: UILabel = {
        $0.text = "Radar"
        $0.font = AppFonts.SemiboldText.font(18)
        $0.textColor = WeatherColors.standardWhite.color
        $0.setContentCompressionResistancePriority(UILayoutPriority(1000), for: .horizontal)
        return $0
    }(UILabel())

    let radarSwitch: UISegmentedControl = {
        $0.tintColor = WeatherColors.text.color
        $0.selectedSegmentIndex = 3
        return $0
    }(UISegmentedControl(items: ["Local", "Regional", "National", "None"]))

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.selectionStyle = .none
        self.backgroundColor = WeatherColors.primary.alpha(0.35)
        radarSwitch.addTarget(self, action: #selector(OCVRadarCell.radarSwitched), for: .valueChanged)
        radarWebview.scalesPageToFit = true

        self.contentView.addSubview(radarLabel)
        self.contentView.addSubview(radarSwitch)
        self.contentView.addSubview(radarWebview)

        let superview = self.contentView

        radarLabel.snp.makeConstraints { (make) in
            make.top.equalTo(superview).offset(10)
            make.left.equalTo(superview).offset(5)
        }

        radarSwitch.snp.makeConstraints { (make) in
            make.centerY.equalTo(radarLabel)
            make.left.greaterThanOrEqualTo(radarLabel.snp.right).offset(8)
            make.right.lessThanOrEqualTo(superview).offset(-8)
        }

        radarWebview.snp.makeConstraints { (make) in
            make.top.equalTo(radarSwitch.snp.bottom).offset(10)
            make.left.equalTo(superview).offset(10)
            make.right.equalTo(superview).offset(-10)
            make.bottom.equalTo(radarWebview.snp.top)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func radarSwitched(_ sender: UISegmentedControl?) {
        if radarLinks != nil {
            if webViewHidden {
                showOrHideRadar()
            }

            var radarURL = radarLinks!.local
            if let seg = sender {
                switch seg.selectedSegmentIndex {
                case 0: radarURL = radarLinks!.local
                case 1: radarURL = radarLinks!.regional
                case 2: radarURL = radarLinks!.national
                case 3:
                    showOrHideRadar()
                    return
                default: return
                }
            }

            let request = URLRequest(url: URL(string: radarURL)!)
            radarWebview.loadRequest(request)
        }
    }

    func showOrHideRadar() {
        if webViewHidden {
            if UIDevice().modelName.contains("Pad") {
                parentController.openCellHeight = 630
            } else {
                parentController.openCellHeight = 430
            }
            parentTableView.beginUpdates()
            radarWebview.snp.remakeConstraints { (make) in
                make.top.equalTo(radarSwitch.snp.bottom).offset(10)
                make.left.equalTo(self.contentView).offset(10)
                make.right.equalTo(self.contentView).offset(-10)
                make.bottom.equalTo(self.contentView).offset(-10)
            }
            UIView.animate(withDuration: 0.5, animations: {
                self.contentView.layoutIfNeeded()
            }) 
            parentTableView.endUpdates()
            parentTableView.scrollToRow(at: IndexPath(row: 0, section: 4), at: .bottom, animated: true)
        } else {
            parentController.openCellHeight = 50
            parentTableView.beginUpdates()
            radarWebview.snp.remakeConstraints { (make) in
                make.top.equalTo(radarSwitch.snp.bottom).offset(10)
                make.left.equalTo(self.contentView).offset(10)
                make.right.equalTo(self.contentView).offset(-10)
                make.bottom.equalTo(radarWebview.snp.top)
            }
            UIView.animate(withDuration: 0.5, animations: {
                self.radarSwitch.selectedSegmentIndex = 3
                self.contentView.layoutIfNeeded()
            }) 
            parentTableView.endUpdates()
        }
        webViewHidden = !webViewHidden
    }

}
