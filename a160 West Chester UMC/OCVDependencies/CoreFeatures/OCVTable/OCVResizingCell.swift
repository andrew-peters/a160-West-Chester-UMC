//
//  OCVResizingCell.swift
//  OCVSwift
//
//  Created by Eddie Seay on 1/15/16.
//  Copyright © 2016 OCV,LLC. All rights reserved.
//

import UIKit


class OCVResizingCell: OCVDefaultTableCell {

    var stackView: UIStackView?

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping

        descLabel.numberOfLines = 0
        descLabel.lineBreakMode = .byWordWrapping

        imageItem.removeFromSuperview()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setupRegularConstraints() {
        super.setupRegularConstraints()
        if stackView != nil {
            stackView?.removeFromSuperview()
        }
    }

    func setupConstraintsWithImageArray(_ images: [AnyObject]) {
        let superview = self.contentView

        if stackView != nil {
            stackView?.removeFromSuperview()
        }

        stackView = addImagesToStackView(images)
        superview.addSubview(stackView!)

        titleLabel.snp.remakeConstraints { make in
            make.left.equalTo(superview.snp.left).offset(10)
            make.trailing.equalTo(superview.snp.trailingMargin)

            make.top.equalTo(superview.snp.top).offset(5)
            make.bottom.equalTo(descLabel.snp.top)
        }

        descLabel.snp.remakeConstraints { make in
            make.left.equalTo(superview.snp.left).offset(10)
            make.trailing.equalTo(superview.snp.trailingMargin)
            make.bottom.equalTo(dateLabel.snp.top).offset(-5)
        }

        if shouldShowDate == true {
            dateLabel.snp.remakeConstraints { make in
                make.left.equalTo(superview.snp.left).offset(10)
                make.trailing.equalTo(superview.snp.trailingMargin)
                make.bottom.equalTo(stackView!.snp.top).offset(-5)
            }

            stackView!.snp.remakeConstraints { (make) -> Void in
                make.leading.equalTo(superview.snp.leadingMargin)
                make.trailing.equalTo(superview.snp.trailingMargin)
                make.height.equalTo(90).priority(999)
                make.bottom.equalTo(superview.snp.bottom).offset(-10)
            }
        } else {
            dateLabel.removeFromSuperview()

            descLabel.snp.remakeConstraints { make in
                make.left.equalTo(superview.snp.left).offset(10)
                make.trailing.equalTo(superview.snp.trailingMargin)
                make.bottom.equalTo(stackView!.snp.bottom).offset(-5)
            }

            stackView!.snp.remakeConstraints { (make) -> Void in
                make.top.equalTo(descLabel.snp.bottom).offset(5)
                make.leading.equalTo(superview.snp.leadingMargin)
                make.trailing.equalTo(superview.snp.trailingMargin)
                make.bottom.equalTo(superview.snp.bottom).offset(-10)
            }
        }

        self.setNeedsUpdateConstraints()
    }

    func addImagesToStackView(_ imageArray: [AnyObject]) -> UIStackView {
        let imageStack: UIStackView = {
            $0.axis = .horizontal
            $0.distribution = .fillEqually
            $0.alignment = .fill
            $0.spacing = 2
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = AppColors.standardWhite.color
            return $0
        }(UIStackView())

        for i in 0 ..< imageArray.count {
            var url: URL?
            if i == 0 || i == 1 {
                if let imageURL = imageArray[i]["large"] as? String {
                    url = URL(string: imageURL)
                }
            } else {
                if let imageURL = imageArray[i]["small"] as? String {
                    url = URL(string: imageURL)
                }
            }

            let newImageView: UIImageView = {
                $0.frame = CGRect(x: 0, y: 0, width: 85, height: 85)
                $0.contentMode = .scaleAspectFill
                $0.clipsToBounds = true
                $0.af_setImage(withURL: url!, placeholderImage: placeholderImg)
                return $0
            }(UIImageView())

            imageStack.addArrangedSubview(newImageView)
        }

        return imageStack
    }
}
