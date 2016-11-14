//
//  OCVContact.swift
//  OCVSwift
//
//  Created by Eddie Seay on 2/3/16.
//  Copyright © 2016 OCV,LLC. All rights reserved.
//

import UIKit
import MessageUI

class OCVContact: OCVResizingTable, MFMailComposeViewControllerDelegate {

    var contactViewModel: OCVContactModel?

    fileprivate let tableCellIdentifier = "OCVDefaultCell"

    override init(dataSourceURL: String, navTitle: String) {
        super.init(dataSourceURL: dataSourceURL, navTitle: navTitle, grouped: false)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        if let currentURL = url {
            contactViewModel = createViewModel(currentURL)
        }
        viewModel = contactViewModel
        self.setupInitialFunctionality()
        contactViewModel?.sendingTable = self

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        self.tableView.register(OCVResizingCell.self, forCellReuseIdentifier: tableCellIdentifier)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return contactViewModel?.numberOfSections() ?? 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactViewModel?.numberOfRowsInSection(section) ?? 0
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let title = contactViewModel?.titleForSection(section)
        if title == nil {
            return 0
        }
        return 30.0
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let title = contactViewModel?.titleForSection(section)
        if title != nil {
            
            let vw = UIView()
            vw.backgroundColor = AppColors.primary.color
            
            let titleLabel = UILabel()
            titleLabel.text = title
            titleLabel.textColor = AppColors.oppositeOfPrimary.color
            
            vw.addSubview(titleLabel)
            
            titleLabel.snp.makeConstraints({ (make) in
                make.left.equalTo(vw).offset(10)
                make.right.equalTo(vw).offset(-5)
                make.top.equalTo(vw).offset(5)
                make.bottom.equalTo(vw).offset(-5)
            })
            
            return vw
        }
        
        return nil
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: tableCellIdentifier, for: indexPath) as? OCVResizingCell else {
            fatalError("Could not dequeue cell with identifier: \(tableCellIdentifier)")
        }

        cell.shouldShowDate = false

        cell.titleLabel.text = contactViewModel?.titleForCellAtIndexPath(indexPath) ?? ""
        cell.descLabel.text = contactViewModel?.descForCellAtIndexPath(indexPath) ?? ""

        if let imageString = contactViewModel?.imageStringForCellAtIndexPath(indexPath) {
            cell.setupConstraintsWithImage(imageString)
            cell.circlizeImage()
        } else {
            cell.setupRegularConstraints()
        }

        cell.setNeedsUpdateConstraints()
        cell.layoutSubviews()

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let currentCell = tableView.cellForRow(at: indexPath),
            let actionArray = contactViewModel?.actionsForObjectAtIndexPath(indexPath),
            let alertTitle = contactViewModel?.titleForCellAtIndexPath(indexPath) else {
                return
        }

        if actionArray.count > 1 {
            let actionAlert: UIAlertController = {
                $0.modalPresentationStyle = .popover
                $0.popoverPresentationController?.sourceRect = currentCell.bounds
                $0.popoverPresentationController?.sourceView = currentCell
                $0.popoverPresentationController?.permittedArrowDirections = .any
                return $0
            }(UIAlertController(title: "Contact \(alertTitle)", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet))

            for action in actionArray {
                actionAlert.addAction(action)
            }

            self.present(actionAlert, animated: true, completion: nil)
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func createViewModel(_ dataSourceURL: String) -> OCVContactModel {
        return OCVContactModel(dataSourceURL: dataSourceURL, sendingTable: self)
    }

    func sendEmailButtonTapped(_ address: String) {
        let mailComposeViewController = configuredMailComposeViewController(address)
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }

    func configuredMailComposeViewController(_ address: String) -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients([address])
        mailComposerVC.setSubject("")

        if let bundleName = Bundle.main.infoDictionary?["CFBundleName"] as? String {
            mailComposerVC.setMessageBody("\n\nSent from the \(bundleName) mobile app.", isHTML: false)
        }

        return mailComposerVC
    }

    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertController(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", preferredStyle: UIAlertControllerStyle.alert)
        sendMailErrorAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: { (action) -> Void in
            self.dismiss(animated: true, completion: nil)
            }))
        self.present(sendMailErrorAlert, animated: true, completion: nil)
    }

    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
