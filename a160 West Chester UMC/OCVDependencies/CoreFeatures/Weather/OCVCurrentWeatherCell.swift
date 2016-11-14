//
//  OCVCurrentWeatherCell.swift
//  OCVSwift
//
//  Created by Eddie Seay on 6/7/16.
//  Copyright © 2016 OCV,LLC. All rights reserved.
//

import UIKit

class OCVCurrentWeatherCell: UITableViewCell {

    let imageItem: UIImageView = {
        $0.clipsToBounds = true
        $0.contentMode = .scaleAspectFill
        return $0
    }(UIImageView())

    let currentTempLabel: UILabel = {
        $0.font = AppFonts.SemiboldText.font(42)
        $0.textColor = WeatherColors.standardWhite.color
        $0.textAlignment = .center
        return $0
    }(UILabel())

    let locationLabel: UILabel = {
        $0.font = AppFonts.RegularText.font(20)
        $0.textColor = WeatherColors.standardWhite.color
        $0.textAlignment = .center
        return $0
    }(UILabel())

    let conditionLabel: UILabel = {
        $0.font = AppFonts.LightText.font(18)
        $0.textColor = WeatherColors.standardWhite.color
        $0.numberOfLines = 2
        $0.textAlignment = .center
        return $0
    }(UILabel())

    let hiLoValueLabel: UILabel = {
        $0.font = AppFonts.RegularText.font(16)
        $0.textColor = WeatherColors.standardWhite.color
        $0.textAlignment = .center
        return $0
    }(UILabel())

    let feelsLikeLabel: UILabel = {
        $0.font = AppFonts.ItalicText.font(16)
        $0.textColor = WeatherColors.standardWhite.color
        $0.textAlignment = .center
        return $0
    }(UILabel())

    let humidityLabel: UILabel = {
        $0.font = AppFonts.RegularText.font(16)
        $0.textColor = WeatherColors.standardWhite.color
        $0.textAlignment = .center
        return $0
    }(UILabel())

    let sunriseLabel: UILabel = {
        $0.font = AppFonts.RegularText.font(16)
        $0.textColor = WeatherColors.standardWhite.color
        $0.textAlignment = .center
        $0.numberOfLines = 2
        return $0
    }(UILabel())

    let separatorView: UIView = {
        $0.backgroundColor = WeatherColors.standardWhite.color
        return $0
    }(UIView())

    let sunsetLabel: UILabel = {
        $0.font = AppFonts.RegularText.font(16)
        $0.textColor = WeatherColors.standardWhite.color
        $0.textAlignment = .center
        $0.numberOfLines = 2
        return $0
    }(UILabel())

    let windspeedLabel: UILabel = {
        $0.font = AppFonts.ItalicText.font(14)
        $0.textColor = WeatherColors.standardWhite.color
        $0.textAlignment = .center
        return $0
    }(UILabel())

    override func prepareForReuse() {
        imageItem.image = nil
        currentTempLabel.text = nil
        locationLabel.text = nil
        conditionLabel.text = nil
        feelsLikeLabel.text = nil
        humidityLabel.text = nil
        hiLoValueLabel.text = nil
        windspeedLabel.text = nil
        sunriseLabel.text = nil
        sunsetLabel.text = nil
    }

    // swiftlint:disable function_body_length
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.backgroundColor = WeatherColors.primary.alpha(0.35)

        self.contentView.addSubview(imageItem)
        self.contentView.addSubview(currentTempLabel)
        self.contentView.addSubview(locationLabel)
        self.contentView.addSubview(conditionLabel)
        self.contentView.addSubview(humidityLabel)
        self.contentView.addSubview(hiLoValueLabel)
        self.contentView.addSubview(feelsLikeLabel)
        self.contentView.addSubview(windspeedLabel)
        self.contentView.addSubview(sunriseLabel)
        self.contentView.addSubview(separatorView)
        self.contentView.addSubview(sunsetLabel)

        let superview = self.contentView

        imageItem.snp.makeConstraints { (make) in
            make.edges.equalTo(superview)
        }

        currentTempLabel.snp.makeConstraints { (make) in
            make.left.equalTo(superview).offset(2)
            make.top.equalTo(superview).offset(2)
            make.width.equalTo(90)
            make.height.equalTo(50)
        }

        locationLabel.snp.makeConstraints { (make) in
            make.top.equalTo(currentTempLabel)
            make.left.equalTo(currentTempLabel.snp.right).offset(4)
            make.right.equalTo(superview).offset(-2)
        }

        conditionLabel.snp.makeConstraints { (make) in
            make.left.equalTo(locationLabel)
            make.right.equalTo(locationLabel)
            make.top.equalTo(locationLabel.snp.bottom)
        }

        feelsLikeLabel.snp.makeConstraints { (make) in
            make.top.greaterThanOrEqualTo(currentTempLabel.snp.bottom)
            make.left.equalTo(currentTempLabel)
            make.right.equalTo(humidityLabel)
        }

        hiLoValueLabel.snp.makeConstraints { (make) in
            make.top.equalTo(feelsLikeLabel.snp.bottom)
            make.left.equalTo(currentTempLabel)
            make.right.equalTo(humidityLabel)
        }

        humidityLabel.snp.makeConstraints { (make) in
            make.left.equalTo(currentTempLabel)
            make.top.equalTo(hiLoValueLabel.snp.bottom)
            make.bottom.equalTo(superview.snp.bottom).offset(-5)
        }

        windspeedLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(conditionLabel.snp.centerX)
            make.top.equalTo(conditionLabel.snp.bottom)
        }

        sunriseLabel.snp.makeConstraints { (make) in
            make.right.equalTo(separatorView).offset(-8)
            make.centerY.equalTo(hiLoValueLabel).priority(250)
            make.top.greaterThanOrEqualTo(windspeedLabel.snp.bottom).priority(900)
            make.bottom.lessThanOrEqualTo(superview.snp.bottom).offset(2).priority(900)
        }

        sunsetLabel.snp.makeConstraints { (make) in
            make.left.equalTo(separatorView).offset(8)
            make.centerY.equalTo(sunriseLabel)
            make.bottom.lessThanOrEqualTo(superview.snp.bottom).offset(2).priority(900)
        }

        separatorView.snp.makeConstraints { (make) in
            make.centerX.equalTo(conditionLabel.snp.centerX)
            make.width.equalTo(1)
            make.top.equalTo(sunriseLabel.snp.top).offset(10)
            make.bottom.equalTo(sunriseLabel.snp.bottom).offset(-5)
            make.bottom.lessThanOrEqualTo(superview.snp.bottom).offset(2).priority(900)
        }

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
