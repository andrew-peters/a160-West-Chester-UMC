//
//  OCVDigestCell.swift
//  OCVSwift
//
//  Created by Eddie Seay on 6/3/16.
//  Copyright © 2016 OCV,LLC. All rights reserved.
//

import UIKit

class OCVDigestCell: UITableViewCell {

    let titleLabel: UILabel = {
        $0.font = AppFonts.SemiboldText.font(18)
        $0.numberOfLines = 2
        $0.textAlignment = .left
        $0.lineBreakMode = .byTruncatingTail
        return $0
    }(OCVCellLabel())

    let descLabel: UILabel = {
        $0.font = AppFonts.RegularText.font(14)
        $0.numberOfLines = 3
        $0.lineBreakMode = .byTruncatingMiddle
        $0.textAlignment = .left
        return $0
    }(OCVCellLabel())

    let dateLabel: UILabel = {
        $0.font = AppFonts.LightItalicText.font(12)
        $0.numberOfLines = 1
        $0.textAlignment = .right
        return $0
    }(OCVCellLabel())

    let imageItem: UIImageView = {
        $0.clipsToBounds = true
        $0.contentMode = .scaleAspectFill
        return $0
    }(UIImageView())

    override func prepareForReuse() {
        titleLabel.text = nil
        descLabel.text = nil
        dateLabel.text = nil
        imageItem.image = nil
        imageItem.tintColor = nil
    }


    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(descLabel)
        self.contentView.addSubview(dateLabel)
        self.contentView.addSubview(imageItem)

        let superview = self.contentView

        imageItem.snp.remakeConstraints { (make) -> Void in
            make.top.equalTo(superview).offset(5)
            make.left.equalTo(superview).offset(10)
            make.height.equalTo(20)
            make.width.equalTo(20)
        }
        titleLabel.snp.remakeConstraints { make in
            make.left.equalTo(imageItem.snp.right).offset(10)
            make.right.equalTo(superview).offset(-5)
            make.top.equalTo(superview).offset(5)
            make.bottom.equalTo(descLabel.snp.top).offset(-2)
        }
        descLabel.snp.remakeConstraints { make in
            make.top.equalTo(imageItem.snp.bottom).offset(5)
            make.left.equalTo(superview).offset(10)
            make.right.equalTo(superview).offset(-10)
            make.bottom.lessThanOrEqualTo(dateLabel.snp.top).offset(-2)
        }
        dateLabel.snp.remakeConstraints { make in
            make.left.equalTo(superview).offset(10)
            make.right.equalTo(superview).offset(-10)
            make.bottom.equalTo(superview.snp.bottom).offset(-10)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
