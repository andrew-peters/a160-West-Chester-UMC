//
//  CalendarCell.swift
//  OCVSwift
//
//  Created by Eddie Seay on 6/1/16.
//  Copyright © 2016 OCV,LLC. All rights reserved.
//

import UIKit

class OCVCalendarCell: UITableViewCell {

    let dayLabel: UILabel = {
        $0.font = AppFonts.RegularText.font(18)
        $0.textColor = UIColor.black
        $0.textAlignment = .center
        return $0
    }(UILabel())

    let numericDateLabel: UILabel = {
        $0.font = AppFonts.BoldText.font(18)
        $0.textColor = UIColor.black
        $0.textAlignment = .center
        return $0
    }(UILabel())

    let yearLabel: UILabel = {
        $0.font = AppFonts.RegularText.font(18)
        $0.textColor = UIColor.black
        $0.textAlignment = .center
        return $0
    }(UILabel())

    let summaryLabel: UILabel = {
        $0.font = AppFonts.SemiboldText.font(16)
        $0.textColor = UIColor.black
        $0.numberOfLines = 2
        $0.lineBreakMode = .byTruncatingMiddle
        return $0
    }(UILabel())

    let descLabel: UILabel = {
        $0.font = AppFonts.LightText.font(14)
        $0.textColor = UIColor.black
        $0.lineBreakMode = .byTruncatingMiddle
        return $0
    }(UILabel())

//    let locationLabel: MarqueeLabel = {
//        $0.font = AppFonts.SemiboldText.font(12)
//        $0.textColor = UIColor.blackColor()
//        $0.lineBreakMode = .ByTruncatingMiddle
//        $0.trailingBuffer = 15.0
//        return $0
//    }(MarqueeLabel(frame: CGRect(), rate: 50, fadeLength: 0))

    let locationLabel: UILabel = {
        $0.font = AppFonts.SemiboldText.font(12)
        $0.textColor = UIColor.black
        $0.lineBreakMode = .byTruncatingMiddle
        $0.numberOfLines = 3
        return $0
    }(UILabel())

    let detailLabel: UILabel = {
        $0.font = AppFonts.SemiboldText.font(10)
        $0.textColor = UIColor.black
        $0.text = "TAP FOR MORE DETAILS"
        $0.isHidden = true
        $0.textAlignment = .right
        return $0
    }(UILabel())

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupRegularConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        dayLabel.text = nil
        numericDateLabel.text = nil
        yearLabel.text = nil
        summaryLabel.text = nil
        descLabel.text = nil
        locationLabel.text = nil
        detailLabel.isHidden = true
    }

    // swiftlint:disable function_body_length
    func setupRegularConstraints() {
        let superview = self.contentView

        let dateView = UIView()
        dateView.setContentCompressionResistancePriority(UILayoutPriority(1000), for: .horizontal)
        dateView.addSubview(dayLabel)
        dayLabel.setContentCompressionResistancePriority(UILayoutPriority(1000), for: .horizontal)
        dateView.addSubview(numericDateLabel)
        numericDateLabel.setContentCompressionResistancePriority(UILayoutPriority(1000), for: .horizontal)
        dateView.addSubview(yearLabel)
        yearLabel.setContentCompressionResistancePriority(UILayoutPriority(1000), for: .horizontal)
        superview.addSubview(dateView)
        superview.addSubview(summaryLabel)
        superview.addSubview(descLabel)
        superview.addSubview(locationLabel)
        superview.addSubview(detailLabel)

        dayLabel.snp.makeConstraints { (make) in
            make.top.equalTo(dateView)
            make.left.equalTo(dateView)
            make.right.equalTo(dateView)
            make.height.equalTo(dateView.snp.height).dividedBy(4)
            make.bottom.equalTo(numericDateLabel.snp.top)
        }

        numericDateLabel.snp.makeConstraints { (make) in
            make.left.equalTo(dateView)
            make.right.equalTo(dateView)
            make.height.equalTo(dateView.snp.height).dividedBy(2)
            make.bottom.equalTo(yearLabel.snp.top)
        }

        yearLabel.snp.makeConstraints { (make) in
            make.left.equalTo(dateView)
            make.right.equalTo(dateView)
            make.height.equalTo(dateView.snp.height).dividedBy(4)
            make.bottom.equalTo(dateView)
        }

        dateView.snp.makeConstraints { (make) in
            make.left.equalTo(superview).offset(10)
            make.top.equalTo(superview).offset(10)
            make.right.equalTo(summaryLabel.snp.left).offset(-10)
            make.width.equalTo(75)
            make.height.equalTo(75)
        }

        summaryLabel.snp.makeConstraints { (make) in
            make.top.equalTo(superview).offset(5).priority(1000)
            make.right.equalTo(superview).offset(-5)
            make.bottom.equalTo(descLabel.snp.top).offset(-2)
        }

        descLabel.snp.makeConstraints { (make) in
            make.left.equalTo(summaryLabel)
            make.right.equalTo(summaryLabel)
            make.bottom.equalTo(locationLabel.snp.top).offset(-2)
        }

        locationLabel.snp.makeConstraints { (make) in
            make.left.equalTo(summaryLabel)
            make.right.equalTo(summaryLabel)
            make.bottom.lessThanOrEqualTo(detailLabel.snp.top).offset(-2).priority(1000)
        }

        detailLabel.snp.makeConstraints { (make) in
            make.left.equalTo(summaryLabel)
            make.right.equalTo(summaryLabel).offset(-5)
            make.bottom.equalTo(superview).offset(-2).priority(1000)
        }

    }

}
