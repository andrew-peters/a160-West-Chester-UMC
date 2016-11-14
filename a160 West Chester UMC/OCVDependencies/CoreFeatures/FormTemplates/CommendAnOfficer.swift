//
//  CommendAnOfficer.swift
//  OCVSwift
//
//  Created by Eddie Seay on 5/25/16.
//  Copyright © 2016 OCV,LLC. All rights reserved.
//

// swiftlint:disable function_body_length

import UIKit
import Eureka
import SVProgressHUD

class CommendAnOfficer: FormViewController {

    var fromDrawer = false

    let formID: String!

    init(formID: String) {
        self.formID = formID
        super.init(style: .grouped)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Commend an Officer"

        form =
            Section("Contact Information")
            <<< NameRow("name") {
                $0.title = "Name"
                $0.placeholder = "Optional"
            }

            <<< EmailRow("emailAddress") {
                $0.title = "Email Address"
                $0.placeholder = "Optional"
            }

            +++ Section("Commendation Information")
            <<< NameRow("officername") {
                $0.title = "Officer's Name"
            }

            <<< TextAreaRow("feedbackText") {
                $0.placeholder = "Please provide your commendation for the officer here. Include the officer's badge number if possible."
            }

            +++ Section(footer: "PLACEHOLDER FOOTER")
            <<< ButtonRow("Submit") {
                $0.title = $0.tag
                $0.onCellSelection({ (cell, row) in
                    self.submitForm()
                })
        }
    }

    func submitForm() {

        let nameRow: NameRow? = form.rowBy(tag: "name")
        let nameVal = nameRow?.value ?? "empty"

        let myEmailRow: EmailRow? = form.rowBy(tag: "emailAddress")
        let emailVal = myEmailRow?.value ?? "empty"

        let officerNameRow: NameRow? = form.rowBy(tag: "officername")
        let officerNameVal = officerNameRow?.value

        let feedbackTextRow: TextAreaRow? = form.rowBy(tag: "feedbackText")
        let feedbackTextVal: String? = feedbackTextRow?.value

        if officerNameVal == nil {
            SVProgressHUD.showError(withStatus: "Must Provide Name of The Officer!")
        } else if feedbackTextVal == nil {
            SVProgressHUD.showError(withStatus: "Must Provide Feedback Text!")
        } else {
            let formFields: [String: AnyObject] = ["user_name": nameVal as AnyObject,
                                                   "user_email": emailVal as AnyObject,
                                                   "tip_officerName": officerNameVal! as AnyObject,
                                                   "tip_text": feedbackTextVal! as AnyObject]

            _ = EZLoadingActivity.show("Submitting...", disableUI: true)
            OCVNetworkClient().apiRequest(atPath: "/forms/submit/\(Config.applicationID)/\(formID)", httpMethod: .post, parameters: formFields, showProgress: false) { resultData, code in
                if code == 200 {
                    _ = EZLoadingActivity.hide(true, animated: false)
                    self.perform(#selector(self.dismissView), with: self, afterDelay: 1.0)
                } else {
                    _ = EZLoadingActivity.hide()
                    let alertController = UIAlertController(title: "Submission Failure", message: "Error Code: \(code)", preferredStyle: .alert)
                    let actionReload = UIAlertAction(title: "Try Again", style: .default) { (action) -> Void in
                        self.submitForm()
                    }
                    let actionDismiss = UIAlertAction(title: "Dismiss", style: .cancel, handler: { (action) -> Void in
                        _ = self.navigationController?.popViewController(animated: true)
                    })
                    alertController.addAction(actionReload)
                    alertController.addAction(actionDismiss)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }

    func dismissView() {
        if !fromDrawer {
            _ = self.navigationController?.popViewController(animated: true)
        } else {
            self.evo_drawerController?.toggleDrawerSide(.left, animated: true, completion: nil)
        }
    }
}
