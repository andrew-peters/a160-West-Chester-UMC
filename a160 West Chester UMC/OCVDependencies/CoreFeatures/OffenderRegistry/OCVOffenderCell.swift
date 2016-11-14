//
//  OCVOffenderCell.swift
//  OCVSwift
//
//  Created by Eddie Seay on 6/17/16.
//  Copyright © 2016 OCV,LLC. All rights reserved.
//

import UIKit
import AlamofireImage

class OCVOffenderCell: UITableViewCell, ConfigurableCell {
    let nameLabel: UILabel = {
        $0.font = AppFonts.SemiboldText.font(16)
        $0.textColor = AppColors.standardBlack.color
        return $0
    }(UILabel())

    let statusLabel: UILabel = {
        $0.font = AppFonts.LightText.font(14)
        $0.textColor = AppColors.standardBlack.color
        return $0
    }(UILabel())

    let addressLabel: UILabel = {
        $0.font = AppFonts.RegularText.font(13)
        $0.textColor = AppColors.standardBlack.color
        $0.numberOfLines = 2
        return $0
    }(UILabel())

    let typeLabel: UILabel = {
        $0.font = AppFonts.LightItalicText.font(12)
        $0.textColor = AppColors.standardBlack.color
        $0.textAlignment = .center
        return $0
    }(UILabel())

    let imageItem: UIImageView = {
        $0.clipsToBounds = true
        $0.contentMode = .scaleAspectFill
        return $0
    }(UIImageView())
    
    let genderLabel: UILabel = {
        $0.font = AppFonts.RegularText.font(14)
        $0.textColor = AppColors.standardBlack.color
        return $0
    }(UILabel())
    
    let raceLabel: UILabel = {
        $0.font = AppFonts.RegularText.font(14)
        $0.textColor = AppColors.standardBlack.color
        return $0
    }(UILabel())
    
    let chargesLabel: UILabel = {
        $0.font = AppFonts.RegularText.font(14)
        $0.textAlignment = .left
        $0.numberOfLines = 1
        return $0
    }(UILabel())

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(nameLabel)
        contentView.addSubview(statusLabel)
        contentView.addSubview(addressLabel)
        contentView.addSubview(typeLabel)
        contentView.addSubview(imageItem)
        contentView.addSubview(genderLabel)
        contentView.addSubview(raceLabel)
        contentView.addSubview(chargesLabel)

        if Config.offenderType == "Florida" {
            setupFloridaConstraints()
        } else if Config.offenderType == "Alabama" {
            setupAlabamaConstraints()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        nameLabel.text = nil
        statusLabel.text = nil
        addressLabel.text = nil
        typeLabel.text = nil
        imageItem.image = nil
    }

    static func reuseIdentifier() -> String { return "OCVOffenderCell" }

    func configure(_ object: OCVOffenderObjectViewModel) {
        nameLabel.text = object.displayName
        statusLabel.text = object.status
        addressLabel.text = object.address
        typeLabel.text = object.type
        imageItem.af_setImage(withURL: object.imageURL, placeholderImage: UIImage(named: object.placeholderName))
        genderLabel.text = "Gender: \(object.sex)"
        raceLabel.text = "Race: \(object.race)"
        chargesLabel.text = "Charges: \(object.status)"
    }

    func setupFloridaConstraints() {
        let superview = contentView
        imageItem.snp.makeConstraints { (make) in
            make.top.equalTo(superview).offset(10)
            make.left.equalTo(superview).offset(10)
            make.width.equalTo(70)
            make.height.equalTo(70)
        }
        typeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(imageItem.snp.bottom)
            make.left.equalTo(imageItem)
            make.right.equalTo(imageItem)
            make.bottom.lessThanOrEqualTo(superview).offset(-2)
        }
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(superview).offset(10)
            make.left.equalTo(superview).offset(10)
            make.right.equalTo(superview).offset(-5)
        }
        statusLabel.snp.makeConstraints { (make) in
            make.top.equalTo(nameLabel.snp.bottom).offset(2)
            make.left.equalTo(nameLabel)
            make.right.equalTo(nameLabel)
        }
        addressLabel.snp.makeConstraints { (make) in
            make.top.equalTo(statusLabel.snp.bottom).offset(2)
            make.left.equalTo(nameLabel)
            make.right.equalTo(nameLabel)
            make.bottom.lessThanOrEqualTo(superview).offset(-2)
        }

    }
    
    func setupAlabamaConstraints() {
        let superview = contentView
        
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(superview).offset(5)
            make.left.equalTo(superview).offset(10)
            make.right.equalTo(superview)
        }
        
        addressLabel.snp.makeConstraints { (make) in
            make.top.equalTo(nameLabel.snp.bottom)
            make.left.equalTo(superview).offset(10)
            make.right.equalTo(superview)
        }
        
        genderLabel.snp.makeConstraints { (make) in
            make.top.equalTo(addressLabel.snp.bottom)
            make.left.equalTo(superview).offset(10)
            make.right.equalTo(superview.snp.centerX)
        }
        
        raceLabel.snp.makeConstraints { (make) in
            make.top.equalTo(genderLabel)
            make.left.equalTo(genderLabel.snp.right)
            make.right.equalTo(superview)
        }
        
        chargesLabel.snp.makeConstraints { (make) in
            make.top.equalTo(raceLabel.snp.bottom)
            make.left.equalTo(superview).offset(10)
            make.right.equalTo(superview)
            make.bottom.lessThanOrEqualTo(superview)
        }
        
        
    }
}
