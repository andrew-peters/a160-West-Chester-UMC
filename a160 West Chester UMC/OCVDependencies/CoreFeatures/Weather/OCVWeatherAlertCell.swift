//
//  OCVWeatherAlertCell.swift
//  OCVSwift
//
//  Created by Eddie Seay on 6/6/16.
//  Copyright © 2016 OCV,LLC. All rights reserved.
//

import UIKit

class OCVWeatherAlertCell: UITableViewCell {
    let titleLabel: UILabel = {
        $0.font = AppFonts.SemiboldText.font(14)
        $0.textColor = WeatherColors.standardWhite.color
        $0.numberOfLines = 2
        $0.textAlignment = .left
        $0.lineBreakMode = .byTruncatingTail
        return $0
    }(OCVCellLabel())

    let descLabel: UILabel = {
        $0.font = AppFonts.RegularText.font(12)
        $0.textColor = WeatherColors.standardWhite.color
        $0.numberOfLines = 0
        $0.lineBreakMode = .byTruncatingMiddle
        $0.textAlignment = .left
        return $0
    }(OCVCellLabel())

    let dateLabel: UILabel = {
        $0.font = AppFonts.LightItalicText.font(10)
        $0.textColor = WeatherColors.standardWhite.color
        $0.numberOfLines = 1
        $0.textAlignment = .right
        $0.setContentCompressionResistancePriority(1000, for: .vertical)
        return $0
    }(OCVCellLabel())

    override func prepareForReuse() {
        titleLabel.text = nil
        descLabel.text = nil
        dateLabel.text = nil
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.backgroundColor = WeatherColors.primary.alpha(0.35)

        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(descLabel)
        self.contentView.addSubview(dateLabel)

        let superview = self.contentView

        titleLabel.snp.remakeConstraints { make in
            make.left.equalTo(superview).offset(10)
            make.right.equalTo(superview).offset(-10)
            make.top.equalTo(superview).offset(5)
            make.bottom.equalTo(descLabel.snp.top).offset(-2)
        }

        descLabel.snp.remakeConstraints { make in
            make.left.equalTo(superview).offset(10)
            make.right.equalTo(superview).offset(-10)
            make.bottom.lessThanOrEqualTo(dateLabel.snp.top).offset(-2)
        }

        dateLabel.snp.remakeConstraints { make in
            make.left.equalTo(superview).offset(10)
            make.right.equalTo(superview).offset(-10)
            make.bottom.equalTo(superview.snp.bottom).offset(-5).priority(1000)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
