//
//  OCVWhereAmIInfoCell.swift
//  OCVSwift
//
//  Created by Eddie Seay on 6/14/16.
//  Copyright © 2016 OCV,LLC. All rights reserved.
//

import UIKit

// swiftlint:disable legacy_constructor
class OCVWhereAmIInfoCell: UIView {

    let formatter = NumberFormatter()

    let latitudeLabel: UILabel = {
        $0.numberOfLines = 1
        $0.textAlignment = .center
        return $0
    }(UILabel())

    let longitudeLabel: UILabel = {
        $0.numberOfLines = 1
        $0.textAlignment = .center
        return $0
    }(UILabel())

    let approximate: UILabel = {
        $0.text = "Approximate Address"
        $0.font = AppFonts.SemiboldText.font(18)
        $0.numberOfLines = 1
        return $0
    }(UILabel())

    let addressLabel: UILabel = {
        $0.textAlignment = .center
        $0.numberOfLines = 2
        $0.font = AppFonts.RegularText.font(18)
        return $0
    }(UILabel())

    let countyLabel: UILabel = {
        $0.numberOfLines = 1
        return $0
    }(UILabel())

    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 320, height: 120))

        formatter.numberStyle = .decimal
        formatter.roundingMode = .down
        formatter.maximumFractionDigits = 5

        self.layer.cornerRadius = 10.0
        self.layer.masksToBounds = true

        self.backgroundColor = UIColor.clear
        let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        blurEffectView.frame = self.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(blurEffectView)

        addSubview(latitudeLabel)
        addSubview(longitudeLabel)
        addSubview(approximate)
        addSubview(addressLabel)
        addSubview(countyLabel)

        latitudeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(2)
            make.left.equalTo(self).offset(8)
            make.right.equalTo(self.snp.centerX).offset(-4)
        }
        longitudeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(2)
            make.left.equalTo(self.snp.centerX).offset(4)
            make.right.equalTo(self).offset(-8)
        }
        approximate.snp.makeConstraints { (make) in
            make.top.equalTo(longitudeLabel.snp.bottom)
            make.centerX.equalTo(self)
        }
        addressLabel.snp.makeConstraints { (make) in
            make.top.equalTo(approximate.snp.bottom)
            make.centerX.equalTo(self)
        }
        countyLabel.snp.makeConstraints { (make) in
            make.top.greaterThanOrEqualTo(addressLabel.snp.bottom)
            make.bottom.equalTo(self).offset(-2)
            make.centerX.equalTo(self)
        }

        refreshLocationInformationLabels(0.0, lon: -0.0, address: nil, county: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func refreshLocationInformationLabels(_ lat: Double, lon: Double, address: String?, county: String?) {
        
        let attributedLatitude = NSMutableAttributedString(string: "Lat: \(formatter.string(from: NSNumber.init(value: lat)))")
        attributedLatitude.addAttribute(NSFontAttributeName, value: AppFonts.SemiboldText.font(18), range: NSRange(location: 0, length: 4))
        attributedLatitude.addAttribute(NSFontAttributeName, value: AppFonts.RegularText.font(18), range: NSMakeRange(5, attributedLatitude.length-5))

        let attributedLongitude = NSMutableAttributedString(string: "Lon: \(formatter.string(from: NSNumber.init(value: lon)))")
        attributedLongitude.addAttribute(NSFontAttributeName, value: AppFonts.SemiboldText.font(18), range: NSRange(location: 0, length: 4))
        attributedLongitude.addAttribute(NSFontAttributeName, value: AppFonts.RegularText.font(18), range: NSMakeRange(5, attributedLongitude.length-5))

        latitudeLabel.attributedText = attributedLatitude
        longitudeLabel.attributedText = attributedLongitude

        addressLabel.text = address ?? "--- -------\n------, -- -----"

        let attributedCounty = NSMutableAttributedString(string: "County: \(county ?? "-----")")
        attributedCounty.addAttribute(NSFontAttributeName, value: AppFonts.SemiboldText.font(18), range: NSRange(location: 0, length: 7))
        attributedCounty.addAttribute(NSFontAttributeName, value: AppFonts.RegularText.font(18), range: NSMakeRange(8, attributedCounty.length-8))

        countyLabel.attributedText = attributedCounty
    }
}
