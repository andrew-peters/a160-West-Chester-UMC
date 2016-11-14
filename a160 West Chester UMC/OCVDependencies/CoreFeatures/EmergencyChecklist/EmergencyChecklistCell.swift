//
//  EmergencyChecklistCell.swift
//  a188
//
//  Created by Christina Holmes on 8/2/16.
//  Copyright © 2016 OCV, LLC. All rights reserved.
//

import UIKit

class EmergencyChecklistCell: UITableViewCell {
    let infoButton = UIButton(type: .infoDark)
    
    let titleLabel: UILabel = {
        $0.font = AppFonts.RegularText.font(16)
        $0.numberOfLines = 0
        $0.textAlignment = .left
        return $0
    }(UILabel())
    
    let plusButton: UIButton = {
        $0.titleLabel?.font = AppFonts.RegularText.font(27)
        $0.setImage(UIImage(named: "plus2"), for: UIControlState())
        $0.tintColor = AppColors.primary.color
        $0.contentMode = .scaleAspectFill
        $0.contentHorizontalAlignment = .center
        $0.contentVerticalAlignment = .center
        return $0
    }(UIButton())
    
    let quantityLabel: UILabel = {
        $0.font = AppFonts.RegularText.font(18)
        $0.numberOfLines = 1
        $0.textAlignment = .center
        return $0
    }(UILabel())
    
    let minusButton: UIButton = {
        $0.titleLabel?.font = AppFonts.RegularText.font(27)
        $0.setImage(UIImage(named: "minus2"), for: UIControlState())
        $0.tintColor = AppColors.primary.color
        $0.contentMode = .scaleAspectFit
        $0.contentHorizontalAlignment = .center
        $0.contentVerticalAlignment = .center
        return $0
    }(UIButton(type: .custom))
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(infoButton)
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(plusButton)
        self.contentView.addSubview(quantityLabel)
        self.contentView.addSubview(minusButton)
        
        infoButton.snp.makeConstraints { (make) in
            make.left.equalTo(self.contentView).offset(10)
            make.top.equalTo(self.contentView).offset(5)
            make.bottom.equalTo(self.contentView).offset(-5)
            make.width.equalTo(40)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(infoButton.snp.right).offset(10)
            make.top.equalTo(self.contentView).offset(5)
            make.bottom.equalTo(self.contentView).offset(-5)
        }
    
        // Needed to make spacing work out since button's title is being set
        minusButton.titleLabel?.snp.makeConstraints({ (make) in
            make.width.equalTo(0)
        })
        
        minusButton.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel)
            make.left.equalTo(titleLabel.snp.right)
            make.width.equalTo(40)
            make.bottom.equalTo(titleLabel)
        }
        
        quantityLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel)
            make.left.equalTo(minusButton.snp.right).priority(900)
            make.width.equalTo(40)
            make.bottom.equalTo(titleLabel)
        }
        
        // Needed to make spacing work out since button's title is being set
        plusButton.titleLabel?.snp.makeConstraints({ (make) in
            make.width.equalTo(0)
        })
        
        plusButton.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel)
            make.left.equalTo(quantityLabel.snp.right)
            make.right.equalTo(self.contentView).offset(-10)
            make.width.equalTo(40)
            make.bottom.equalTo(titleLabel)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        titleLabel.text = nil
    }
}
