//
//  NotificationSettingsDemo.swift
//  OCVSwift
//
//  Created by Eddie Seay on 2/9/16.
//  Copyright © 2016 OCV,LLC. All rights reserved.
//

import UIKit
import SnapKit

class OCVNotificationSettings: UITableViewController {
    
    let viewModel = OCVNotificationModel(asViewModel: true)
    fileprivate let tableCellIdentifier = "cell"
    
    init() {
        if #available(iOS 9, *) {
            super.init(style: .grouped)
        } else {
            super.init(nibName: nil, bundle: nil)
        }
    }
    
    deinit {
        print("Notification Settings Deinitialized")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        navigationItem.title = "Notifications"
        viewModel.sendingTable = self
        self.tableView.tableFooterView = UIView()
        self.tableView.register(NotificationCell.self, forCellReuseIdentifier: tableCellIdentifier)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.titleForSectionHeader(section)
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSectionsInTable()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInSection(section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: tableCellIdentifier) as? NotificationCell else {
            fatalError("Could not dequeue cell with identifier: \(tableCellIdentifier)")
        }
        
        if viewModel.registeredForIndexPath(indexPath) {
            cell.onOff.setOn(true, animated: false)
        }
        if viewModel.protectedForIndexPath(indexPath) == false {
            cell.lockIcon.isHidden = true
        }
        
        cell.onOff.switchIndex = indexPath
        cell.onOff.addTarget(self, action: #selector(OCVNotificationSettings.switchedRegistrationAtIndexPath(_: )), for: UIControlEvents.valueChanged)
        cell.titleLabel.text = viewModel.titleForCellAtIndexPath(indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let switchCell = tableView.cellForRow(at: indexPath) as? NotificationCell else {
            fatalError("Could not dequeue NotificationCell at index path")
        }
        switchCell.onOff.setOn(!switchCell.onOff.isOn, animated: true)
        switchedRegistrationAtIndexPath(switchCell.onOff)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func switchedRegistrationAtIndexPath(_ sender: NotificationSwitch) {
        if let sentFromIndexPath = sender.switchIndex as IndexPath? {
            viewModel.updateRegistrationAtIndexPath(sentFromIndexPath, sendingSwitch: sender)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
}

//MARK: Custom Cells and UI Elements
class NotificationCell: UITableViewCell {
    
    let titleLabel: OCVCellLabel = {
        $0.font = AppFonts.RegularText.font(16)
        $0.numberOfLines = 1
        return $0
    }(OCVCellLabel())
    
    let lockIcon: UIImageView = {
        $0.contentMode = .scaleToFill
        $0.tintColor = UIColor(hexString: "#6D797A")
        $0.image = UIImage(named: "lock")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        return $0
    }(UIImageView())
    
    let onOff = NotificationSwitch()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(lockIcon)
        self.contentView.addSubview(onOff)
        
        titleLabel.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(self.contentView.snp.left).offset(10)
            make.top.equalTo(self.contentView.snp.top)
            make.bottom.equalTo(self.contentView.snp.bottom)
            make.right.equalTo(lockIcon.snp.left).offset(-10)
        }
        
        lockIcon.snp.makeConstraints { (make) -> Void in
            make.centerY.equalTo(self.contentView.snp.centerY)
            make.right.equalTo(onOff.snp.left).offset(-10)
            make.width.equalTo(12.0)
            make.height.equalTo(12.0)
        }
        
        onOff.snp.makeConstraints { (make) -> Void in
            make.right.equalTo(self.contentView.snp.right).offset(-10)
            make.centerY.equalTo(self.contentView.snp.centerY)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class NotificationSwitch: UISwitch {
    var switchIndex = IndexPath()
}
