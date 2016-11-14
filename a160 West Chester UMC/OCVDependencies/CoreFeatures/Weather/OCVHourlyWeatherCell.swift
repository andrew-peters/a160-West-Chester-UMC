//
//  OCVHourlyWeatherCell.swift
//  OCVSwift
//
//  Created by Eddie Seay on 6/8/16.
//  Copyright © 2016 OCV,LLC. All rights reserved.
//

import UIKit

class OCVHourlyWeatherCell: UICollectionViewCell {

    let imageItem: UIImageView = {
        $0.clipsToBounds = true
        $0.contentMode = .scaleAspectFit
        $0.tintColor = WeatherColors.oppositeOfPrimary.color
        return $0
    }(UIImageView())

    let timeLabel: UILabel = {
        $0.font = AppFonts.SemiboldText.font(16)
        $0.textColor = WeatherColors.oppositeOfPrimary.color
        $0.textAlignment = .center
        return $0
    }(UILabel())

    let temperatureLabel: UILabel = {
        $0.font = AppFonts.RegularText.font(16)
        $0.textColor = WeatherColors.oppositeOfPrimary.color
        $0.textAlignment = .center
        return $0
    }(UILabel())

    override func prepareForReuse() {
        imageItem.image = nil
        timeLabel.text = nil
        temperatureLabel.text = nil
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = WeatherColors.primary.alpha(0.35)

        contentView.addSubview(timeLabel)
        contentView.addSubview(imageItem)
        contentView.addSubview(temperatureLabel)

        timeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(contentView).priority(1000)
            make.left.equalTo(contentView)
            make.right.equalTo(contentView)
            make.height.equalTo(25)
        }

        imageItem.snp.makeConstraints { (make) in
            make.top.equalTo(timeLabel.snp.bottom)
            make.left.equalTo(contentView)
            make.right.equalTo(contentView)
        }

        temperatureLabel.snp.makeConstraints { (make) in
            make.top.equalTo(imageItem.snp.bottom)
            make.left.equalTo(contentView)
            make.right.equalTo(contentView)
            make.height.equalTo(25)
            make.bottom.equalTo(contentView)
        }

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
