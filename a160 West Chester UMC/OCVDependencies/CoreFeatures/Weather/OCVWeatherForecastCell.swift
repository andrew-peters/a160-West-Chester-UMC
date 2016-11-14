//
//  OCVWeatherForecastCell.swift
//  OCVSwift
//
//  Created by Eddie Seay on 6/6/16.
//  Copyright © 2016 OCV,LLC. All rights reserved.
//

import UIKit
import SnapKit

class OCVWeatherForecastCell: UITableViewCell {

    let imageItem: UIImageView = {
        $0.clipsToBounds = true
        $0.contentMode = .scaleAspectFill
        $0.tintColor = WeatherColors.standardWhite.color
        return $0
    }(UIImageView())

    let dayLabel: UILabel = {
        $0.font = AppFonts.SemiboldText.font(16)
        $0.textColor = WeatherColors.standardWhite.color
        return $0
    }(UILabel())

    let conditionLabel: UILabel = {
        $0.font = AppFonts.RegularText.font(13)
        $0.textColor = WeatherColors.standardWhite.color
        $0.numberOfLines = 2
        return $0
    }(UILabel())

    let precipLabel: UILabel = {
        $0.font = AppFonts.RegularText.font(12)
        $0.textColor = WeatherColors.standardWhite.color
        return $0
    }(UILabel())

    let hiMarkerLabel: UILabel = {
        $0.font = AppFonts.SemiboldText.font(14)
        $0.textColor = WeatherColors.standardWhite.color
        $0.text = "High: "
        return $0
    }(UILabel())

    let hiValueLabel: UILabel = {
        $0.font = AppFonts.LightText.font(16)
        $0.textColor = WeatherColors.standardWhite.color
        $0.textAlignment = .right
        return $0
    }(UILabel())

    let loMarkerLabel: UILabel = {
        $0.font = AppFonts.SemiboldText.font(14)
        $0.textColor = WeatherColors.standardWhite.color
        $0.text = "Low: "
        return $0
    }(UILabel())

    let loValueLabel: UILabel = {
        $0.font = AppFonts.LightText.font(16)
        $0.textColor = WeatherColors.standardWhite.color
        $0.textAlignment = .right
        return $0
    }(UILabel())

    override func prepareForReuse() {
        imageItem.image = nil
        dayLabel.text = nil
        conditionLabel.text = nil
        precipLabel.text = nil
        hiValueLabel.text = nil
        loValueLabel.text = nil
    }

    // swiftlint:disable function_body_length
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.backgroundColor = WeatherColors.primary.alpha(0.35)

        self.contentView.addSubview(imageItem)
        self.contentView.addSubview(dayLabel)
        self.contentView.addSubview(conditionLabel)
        self.contentView.addSubview(precipLabel)
        self.contentView.addSubview(hiMarkerLabel)
        self.contentView.addSubview(hiValueLabel)
        self.contentView.addSubview(loMarkerLabel)
        self.contentView.addSubview(loValueLabel)

        let superview = self.contentView

        imageItem.snp.makeConstraints { (make) in
            make.left.equalTo(superview).offset(10)
            make.height.equalTo(50)
            make.width.equalTo(50)
            make.centerY.equalTo(superview)
        }

        dayLabel.snp.makeConstraints { (make) in
            make.left.equalTo(imageItem.snp.right).offset(10)
            make.top.equalTo(superview).offset(5)
        }

        conditionLabel.snp.makeConstraints { (make) in
            make.left.equalTo(imageItem.snp.right).offset(10)
            make.top.equalTo(dayLabel.snp.bottom).offset(2)
            make.right.equalTo(hiMarkerLabel.snp.left).offset(-5).priority(1000)
        }

        precipLabel.snp.makeConstraints { (make) in
            make.left.equalTo(imageItem.snp.right).offset(10)
            make.top.greaterThanOrEqualTo(conditionLabel.snp.bottom).offset(2)
            make.bottom.equalTo(superview).offset(-5)
        }

        hiValueLabel.snp.makeConstraints { (make) in
            make.top.equalTo(superview).offset(20)
            make.right.equalTo(superview).offset(-10)
            make.width.equalTo(35)
        }

        hiMarkerLabel.snp.makeConstraints { (make) in
            make.top.equalTo(hiValueLabel)
            make.right.equalTo(hiValueLabel.snp.left)
            make.width.equalTo(40)
        }

        loValueLabel.snp.makeConstraints { (make) in
            make.right.equalTo(hiValueLabel)
            make.top.greaterThanOrEqualTo(hiValueLabel.snp.bottom).offset(2)
            make.bottom.equalTo(superview).offset(-20)
            make.width.equalTo(35)
        }

        loMarkerLabel.snp.makeConstraints { (make) in
            make.top.equalTo(loValueLabel)
            make.left.equalTo(hiMarkerLabel)
            make.right.equalTo(loValueLabel.snp.left)
            make.width.equalTo(40)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
