//
//  OCVDefaultTableCell.swift
//  OCVSwift
//
//  Created by Eddie Seay on 1/15/16.
//  Copyright © 2016 OCV,LLC. All rights reserved.
//

import UIKit
import SnapKit
import AlamofireImage

class OCVDefaultTableCell: UITableViewCell {

    let titleLabel: OCVCellLabel = {
        $0.font = AppFonts.SemiboldText.font(16)
        $0.numberOfLines = 1
        return $0
    }(OCVCellLabel())

    let descLabel: OCVCellLabel = {
        $0.numberOfLines = 2
        $0.lineBreakMode = .byTruncatingMiddle
        return $0
    }(OCVCellLabel())

    let dateLabel: OCVCellLabel = {
        $0.font = AppFonts.LightItalicText.font(10)
        $0.numberOfLines = 1
        return $0
    }(OCVCellLabel())

    let imageItem: UIImageView = {
        $0.clipsToBounds = true
        $0.contentMode = .scaleAspectFill
        return $0
    }(UIImageView())

    let placeholderImg = UIImage(named: "logo")
    var shouldShowDate = true

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(descLabel)
        self.contentView.addSubview(dateLabel)

        setupRegularConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        titleLabel.text = nil
        descLabel.text = nil
        dateLabel.text = nil
        imageItem.image = nil
    }

    func circlizeImage() {
        imageItem.layer.cornerRadius = 25
        imageItem.layer.masksToBounds = true
        imageItem.layer.borderWidth = 0.0
    }

    func setupRegularConstraints() {
        let superview = self.contentView

        imageItem.removeFromSuperview()

        titleLabel.snp.remakeConstraints { make in
            make.left.equalTo(superview.snp.left).offset(10)
            make.trailing.equalTo(superview.snp.trailingMargin)

            make.top.equalTo(superview.snp.top).offset(5)
            make.bottom.equalTo(descLabel.snp.top)
        }

        if shouldShowDate == true {
            descLabel.snp.remakeConstraints { make in
                make.left.equalTo(superview.snp.left).offset(10)
                make.trailing.equalTo(superview.snp.trailingMargin)
                make.bottom.equalTo(dateLabel.snp.top).offset(-5)
            }

            dateLabel.snp.remakeConstraints { make in
                make.left.equalTo(superview.snp.left).offset(10)
                make.trailing.equalTo(superview.snp.trailingMargin)
                make.bottom.equalTo(superview.snp.bottom).offset(-5)
            }
        } else {
            dateLabel.removeFromSuperview()

            descLabel.snp.remakeConstraints { make in
                make.left.equalTo(superview.snp.left).offset(10)
                make.trailing.equalTo(superview.snp.trailingMargin)
                make.bottom.equalTo(superview.snp.bottom).offset(-5)
            }
        }
    }

    func setupConstraintsWithImage(_ imageURL: String) {
        if imageItem.superview != self.contentView {
            self.contentView.addSubview(imageItem)
        }

        if let url = URL(string: imageURL) {
            imageItem.af_setImage(withURL: url, placeholderImage: placeholderImg)
        }

        let superview = self.contentView

        imageItem.snp.remakeConstraints { (make) -> Void in
            make.top.equalTo(superview.snp.top).offset(10).priority(1000)
            make.bottom.lessThanOrEqualTo(superview).offset(-10).priority(900)
            make.left.equalTo(superview.snp.left).offset(10).priority(1000)
            make.height.equalTo(50).priority(1000)
            make.width.equalTo(50).priority(1000)
        }

        titleLabel.snp.remakeConstraints { make in
            make.left.equalTo(imageItem.snp.right).offset(10)
            make.trailing.equalTo(superview.snp.trailingMargin)

            make.top.equalTo(superview.snp.top).offset(5)
            make.bottom.equalTo(descLabel.snp.top)
        }

        if shouldShowDate == true {
            descLabel.snp.remakeConstraints { make in
                make.left.equalTo(imageItem.snp.right).offset(10)
                make.trailing.equalTo(superview.snp.trailingMargin)
                make.bottom.equalTo(dateLabel.snp.top).offset(-5)
            }

            dateLabel.snp.remakeConstraints { make in
                make.left.equalTo(imageItem.snp.right).offset(10)
                make.trailing.equalTo(superview.snp.trailingMargin)
                make.bottom.equalTo(superview.snp.bottom).offset(-5)
            }
        } else {
            dateLabel.removeFromSuperview()

            descLabel.snp.remakeConstraints { make in
                make.top.equalTo(titleLabel.snp.bottom)
                make.left.equalTo(imageItem.snp.right).offset(10)
                make.trailing.equalTo(superview.snp.trailingMargin)
                make.bottom.lessThanOrEqualTo(superview.snp.bottom).offset(-5)
            }
        }
    }
}

class OCVCellLabel: UILabel {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup() {
        self.font = AppFonts.RegularText.font(12)
        self.textAlignment = .left
        self.numberOfLines = 1
        self.lineBreakMode = .byTruncatingTail
    }
}
