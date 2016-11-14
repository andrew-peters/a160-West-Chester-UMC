//
//  OCVDrawerControllerTable.swift
//  OCVSwift
//
//  Created by Eddie Seay on 3/2/16.
//  Copyright © 2016 OCV,LLC. All rights reserved.
//

import UIKit
import ChameleonFramework
import DrawerController
import SnapKit
import SafariServices

class OCVDrawerControllerTable: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var tableView: UITableView!
    fileprivate let tableCellIdentifier = "OCVDefaultDrawerCell"
    fileprivate var selectedIndexPath = IndexPath(row: 0, section: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitialFunctionality()
        setupSubviews()
    }
    
    /**
     Sets up all of the standard functionality that will be inherited throughout
     all classes that based themselves around a UITableView in the OCV library.
     */
    func setupInitialFunctionality() {
        tableView = UITableView(frame: self.view.bounds, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.separatorColor = AppColors.secondary.color
        tableView.backgroundColor = UIColor.black//AppColors.primary.color
        tableView.tableFooterView = UIView()
        tableView.register(OCVSideTableCell.self, forCellReuseIdentifier: tableCellIdentifier)
    }
    
    func pushToPageWithURL(dataSourceURL: String) {
        let mainMenu = (UIApplication.shared.delegate as! AppDelegate).rootController as OCVMainMenu
        let nav = UINavigationController(rootViewController: mainMenu)
        
        nav.view.backgroundColor = UIColor.white
        
        let leftDrawerButton = DrawerBarButtonItem(target: self, action: #selector(OCVDrawerControllerTable.leftDrawerButtonPress(_:)), menuIconColor: AppColors.text.color)
        mainMenu.navigationItem.setLeftBarButton(leftDrawerButton, animated: true)
        
        self.evo_drawerController?.setCenter(nav, withCloseAnimation: true, completion: nil)
        
        _ = OCVPage(sourceURL: dataSourceURL, sourceNavigationController: mainMenu.navigationController!)
    }
    
    func pushToSocialSubmenu() {
        let mainMenu = (UIApplication.shared.delegate as! AppDelegate).rootController as OCVMainMenu
        let nav = UINavigationController(rootViewController: mainMenu)
        
        nav.view.backgroundColor = UIColor.white
        
        let leftDrawerButton = DrawerBarButtonItem(target: self, action: #selector(OCVDrawerControllerTable.leftDrawerButtonPress(_:)), menuIconColor: AppColors.text.color)
        mainMenu.navigationItem.setLeftBarButton(leftDrawerButton, animated: true)
        
        self.evo_drawerController?.setCenter(nav, withCloseAnimation: true, completion: nil)
        
        /*let social = OCVSocialPopup(items: [["platform": "Facebook", "link": "https://www.facebook.com/Sioux.County.Sheriff", "identifier": "170469789667716"], ["platform": "Twitter", "link": "", "identifier": "siouxcosheriff"]])
        social.present(in: mainMenu)*/
    }
    
    func openSafariView(url: String) {
        let mainMenu = (UIApplication.shared.delegate as! AppDelegate).rootController as OCVMainMenu
        let nav = UINavigationController(rootViewController: mainMenu)
        
        nav.view.backgroundColor = UIColor.white
        
        let leftDrawerButton = DrawerBarButtonItem(target: self, action: #selector(OCVDrawerControllerTable.leftDrawerButtonPress(_:)), menuIconColor: AppColors.text.color)
        mainMenu.navigationItem.setLeftBarButton(leftDrawerButton, animated: true)
        
        self.evo_drawerController?.setCenter(nav, withCloseAnimation: true, completion: nil)
        
        let url1 = URL(string: url)
        let safariBrowser = SFSafariViewController(url: url1!)
        present(safariBrowser, animated: true, completion: nil)
    }
    
    // MARK: Drawer Navigation Methods
    func testFunction() {
        print("TEST FUNCTION CALLED")
    }
    
    func goToWelcome() {
        pushToPageWithURL(dataSourceURL: "https://apps.myocv.com/feed/page/a16019382/welcome")
    }
    
    func goToNfOH() {
        let nfOH = OCVTable(dataSourceURL: "https://apps.myocv.com/feed/blog/a16019382/notesFromOnHigh", navTitle: "Notes from On High")
        self.setupNewCenterView(nfOH)
    }
    
    func goToChildren() {
        let childrenBlog = OCVTable(dataSourceURL: "https://apps.myocv.com/feed/blog/a16019382/children", navTitle: "Children")
        self.setupNewCenterView(childrenBlog)
    }
    
    func goToYouth() {
        let url = "http://youth.umcwc.org"
        openSafariView(url: url)
    }
    
    func goToAdult() {
        let adultBlog = OCVTable(dataSourceURL: "https://apps.myocv.com/feed/blog/a16019382/adult", navTitle: "Adults")
        setupNewCenterView(adultBlog)
    }
    
    func goToMusic() {
        let musicBlog = OCVTable(dataSourceURL: "https://apps.myocv.com/feed/blog/a16019382/music", navTitle: "Music")
        setupNewCenterView(musicBlog)
    }
    
    func wedNightOut() {
        pushToPageWithURL(dataSourceURL: "https://apps.myocv.com/feed/page/a16019382/wednesdayNightOut")
    }
    
    func getInvolved() {
        let getInvolvedBlog = OCVTable(dataSourceURL: "https://apps.myocv.com/feed/blog/a16019382/getInvolved", navTitle: "GetInvloved")
        setupNewCenterView(getInvolvedBlog)
    }
    
    func childrensCenter() {
        let url = "http://www.unitedmethodistchildrenscenter.com"
        openSafariView(url: url)
    }
    
    func goToContacts() {
        let contact = OCVContact(dataSourceURL: "https://apps.myocv.com/feed/contacts/a16019382/contacts/3", navTitle: "Contact Us")
        setupNewCenterView(contact)
        //self.navigationController?.pushViewController(contact, animated: true)
    }
    
    func goToParking() {
        let url = "http://www.westchesterumc.com/about-us/welcome-visitor"
        openSafariView(url: url)
        
    }
    
    func westChestBorough() {
        let url = "http://west-chester.com"
        openSafariView(url: url)
    }
    
    func socialMediaFunc() {
        let urlsAndTitles = [["platform": "Facebook", "link": "https://www.facebook.com/pages/West-Chester-United-Methodist-Church/147932540522", "identifier": "147932540522"], ["platform": "Twitter", "link": "", "identifier": "umcwc"], ["platform": "YouTube", "link": "https://www.youtube.com/user/WestChesterUMC", "identifier": ""]]
        let socialPopUp = OCVSocialPopup(items: urlsAndTitles)
        socialPopUp.present(in: self)
    }
    
//    func goToFacebook() {
//        let url = "https://www.facebook.com/pages/West-Chester-United-Methodist-Church/147932540522"
//        openSafariView(url: url)
//    }
    
    
//    func goToInmateLookup() {
//        let url = "https://www.vinelink.com/#/home"
//        openSafariView(url: url)
//        //        if UIApplication.shared.canOpenURL(NSURL(string: url) as! URL) {
//        //            UIApplication.shared.openURL(NSURL(string: url) as! URL)
//        //        }
//    }
//    
//    func goToSexOffenders() {
//        let sexOffender = OCVTable(dataSourceURL: "https://apps.myocv.com/feed/blog/a11451041/sexOffender", navTitle: "Sex Offenders")
//        self.setupNewCenterView(sexOffender)
//    }
//    
//    func goToSheriffEvents() {
//        let events = OCVTable(dataSourceURL: "https://apps.myocv.com/feed/blog/a11451041/events", navTitle: "Sheriff's Events")
//        self.setupNewCenterView(events)
//    }
//    
//    func goToCurrentInmates() {
//        let url = "http://siouxcountysheriff.com/jail%20inmates.pdf"
//        openSafariView(url: url)
//    }
    
    func goToSettings() {
        self.setupNewCenterView(OCVSettings())
    }
    
    func messages() {
        self.setupNewCenterView(OCVMessageHistory())
    }
    
    func socialMedia() {
        pushToSocialSubmenu()
    }
    
    func submitATip() {
        let submenu = OCVSubmenuView(items: ["Online Tip":"https://www.tipsubmit.com/WebTips.aspx?AgencyID=782", "Call In A Tip":"7127373307", "Text A Tip": "scso%@"], navTitle: "Submit A Tip", parentVC: OCVMainMenu())
        setupNewCenterView(submenu)
    }
    
    // MARK: UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MenuOutline.drawerMenu.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: tableCellIdentifier) as? OCVSideTableCell else {
            fatalError("Could not dequeue cell with identifier: \(tableCellIdentifier)")
        }
        
        setCellDeselected(cell)
        cell.titleLabel.text = nil
        cell.imageItem.image = nil
        
        if indexPath == selectedIndexPath {
            setCellSelected(cell)
        }
        
        if MenuOutline.drawerMenu.indices.contains((indexPath as NSIndexPath).row) {
            let item = MenuOutline.drawerMenu[(indexPath as NSIndexPath).row]
            cell.titleLabel.text = item["textLabel"] ?? ""
            cell.titleLabel.textColor = UIColor(hexString: "#8A7C63")
            if let cellImage = UIImage(named: item["imageName"] ?? "") {
                cell.imageItem.image = cellImage.withRenderingMode(.alwaysTemplate)
            }
        }
        
        cell.backgroundColor = UIColor.black
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if MenuOutline.drawerMenu.indices.contains((indexPath as NSIndexPath).row) {
            if let previouslySelectedCell = tableView.cellForRow(at: selectedIndexPath) as? OCVSideTableCell {
                setCellDeselected(previouslySelectedCell)
            }
            selectedIndexPath = indexPath
            guard let selectedCell = tableView.cellForRow(at: indexPath) as? OCVSideTableCell else {
                fatalError("Cell at selected index did not match expected type")
            }
            setCellSelected(selectedCell)
            
            if let selectorString = MenuOutline.drawerMenu[(indexPath as NSIndexPath).row]["selector"] {
                if self.responds(to: Selector(selectorString)) {
                    perform(Selector(selectorString))
                }
            }
            
            if (selectedCell.titleLabel.text == "Press Release" || selectedCell.titleLabel.text == "Recent Arrests" || selectedCell.titleLabel.text == "Inmate Lookup" || selectedCell.titleLabel.text == "Current Inmates") {
                self.setCellDeselected(selectedCell)
            }
        }
        
        self.evo_drawerController?.closeDrawer(animated: true, completion: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func goToMainMenu() {
        // swiftlint:disable:next force_cast
        let mainMenu = (UIApplication.shared.delegate as! AppDelegate).rootController
        setupNewCenterView(mainMenu!)
    }
    
    // MARK: View setup
    func setCellSelected(_ cell: OCVSideTableCell) {
        cell.backgroundColor = UIColor.gray//AppColors.text.color
        cell.titleLabel.textColor = UIColor.white//AppColors.primary.color
        cell.imageItem.tintColor = AppColors.primary.color
    }
    
    func setCellDeselected(_ cell: OCVSideTableCell) {
        cell.backgroundColor = UIColor.black//AppColors.primary.color
        cell.titleLabel.textColor = UIColor.white//AppColors.text.color
        cell.imageItem.tintColor = AppColors.text.color
    }
    
    func setupNewCenterView(_ rootVC: UIViewController) {
        let nav = UINavigationController(rootViewController: rootVC)
        
        nav.view.backgroundColor = UIColor.flatWhite()
        
        let leftDrawerButton = DrawerBarButtonItem(target: self, action: #selector(OCVDrawerControllerTable.leftDrawerButtonPress(_:)), menuIconColor: AppColors.text.color)
        rootVC.navigationItem.setLeftBarButton(leftDrawerButton, animated: true)
        
        self.evo_drawerController?.setCenter(nav, withCloseAnimation: true, completion: nil)
    }
    
    func leftDrawerButtonPress(_ sender: AnyObject?) {
        self.evo_drawerController?.toggleDrawerSide(.left, animated: true, completion: nil)
    }
    
    // swiftlint:disable:next function_body_length
    func setupSubviews() {
        let tableHeader = standardHeaderView()
        let topShadow = UIImageView(image: UIImage(named: "shadow_topdown"))
        let bottomShadow = UIImageView(image: UIImage(named: "shadow_bottomup"))
        
        let drawerToolbar = UIToolbar()
        drawerToolbar.backgroundColor = AppColors.primary.color
        
        let settingsButton = UIBarButtonItem(image: UIImage(named: "options"), style: .plain, target: self, action: #selector(OCVDrawerControllerTable.goToSettings))
        
        let settingsButtonItem = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(OCVDrawerControllerTable.goToSettings))
        
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: #selector(OCVDrawerControllerTable.goToSettings))
        
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.white]
        settingsButtonItem.setTitleTextAttributes(titleDict as? [String : AnyObject], for: UIControlState())
        drawerToolbar.setItems([settingsButton, settingsButtonItem, flex], animated: false)
        
        view.addSubview(tableHeader)
        view.addSubview(tableView)
        view.addSubview(topShadow)
        view.addSubview(drawerToolbar)
        view.addSubview(bottomShadow)
        
        tableHeader.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(view.snp.top)
            make.height.equalTo(66)
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
        }
        
        topShadow.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(tableHeader.snp.bottom)
            make.height.equalTo(10)
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
        }
        
        tableView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(tableHeader.snp.bottom)
            make.bottom.equalTo(drawerToolbar.snp.top)
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
        }
        
        drawerToolbar.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(tableView.snp.bottom)
            make.bottom.equalTo(view.snp.bottom)
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
        }
        
        bottomShadow.snp.makeConstraints { (make) -> Void in
            make.bottom.equalTo(drawerToolbar.snp.top)
            make.height.equalTo(8)
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
        }
    }
    
    func standardHeaderView() -> UIView {
        let sectionView = UIView(frame: CGRect(x: 0, y: 22, width: tableView.bounds.width, height: 44))
        sectionView.backgroundColor = AppColors.primary.color
        
        let logoImage = UIImageView(image: UIImage(named: ""))
        logoImage.frame = CGRect(x: 5, y: 22, width: 35, height: 35)
        
        let sectionLabelOne = UILabel(frame: CGRect(x: 45, y: 22, width: tableView.bounds.width - 45, height: 22))
        sectionLabelOne.backgroundColor = UIColor.clear
        sectionLabelOne.textColor = AppColors.text.color
        sectionLabelOne.textAlignment = .left
        sectionLabelOne.adjustsFontSizeToFitWidth = true
        sectionLabelOne.minimumScaleFactor = 0.5
        sectionLabelOne.font = AppFonts.SemiboldText.font(20)
        
        let sectionLabelTwo = UILabel(frame: CGRect(x: 45, y: 44, width: tableView.bounds.width - 45, height: 14))
        sectionLabelTwo.backgroundColor = UIColor.clear
        sectionLabelTwo.textColor = AppColors.text.color
        sectionLabelTwo.textAlignment = .left
        sectionLabelTwo.adjustsFontSizeToFitWidth = true
        sectionLabelTwo.minimumScaleFactor = 0.5
        sectionLabelTwo.font = AppFonts.RegularText.font(12)
        (sectionLabelOne.text, sectionLabelTwo.text) = OCVAppUtilities.SharedInstance.getMenuHeaders()
        
        sectionView.addSubview(logoImage)
        sectionView.addSubview(sectionLabelOne)
        sectionView.addSubview(sectionLabelTwo)
        
        logoImage.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(sectionView.snp.top).offset(22)
            make.height.equalTo(35)
            make.left.equalTo(sectionView.snp.left).offset(5)
            make.width.equalTo(35)
        }
        
        sectionLabelOne.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(sectionView.snp.top).offset(22)
            make.left.equalTo(logoImage.snp.right).offset(10)
            make.right.equalTo(sectionView.snp.right).offset(-8)
            make.height.equalTo(22)
        }
        
        sectionLabelTwo.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(sectionLabelOne.snp.bottom)
            make.left.equalTo(logoImage.snp.right).offset(10)
            make.right.equalTo(sectionView.snp.right).offset(-8)
            make.bottom.equalTo(sectionView.snp.bottom)
        }
        
        return sectionView
    }
}

class OCVSideTableCell: UITableViewCell {
    let titleLabel = OCVCellLabel()
    let imageItem = UIImageView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = UIColor.black//AppColors.primary.color
        
        titleLabel.font = AppFonts.RegularText.font(16)
        titleLabel.textColor = UIColor(hexString: "#8A7C63")//AppColors.text.color
        titleLabel.numberOfLines = 1
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.5
        
        imageItem.clipsToBounds = true
        imageItem.contentMode = .scaleAspectFit
        imageItem.tintColor = AppColors.text.color
        
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(imageItem)
        
        //        self.accessoryType = .disclosureIndicator
        
        setupCellConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCellConstraints() {
        let superview = self.contentView
        
        imageItem.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(superview.snp.top).offset(10)
            make.bottom.equalTo(superview.snp.bottom).offset(-10)
            make.left.equalTo(superview.snp.left).offset(2)
            make.width.equalTo(snp.height).priority(1000)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(superview).offset(10)
            make.trailing.equalTo(superview.snp.trailingMargin)
            make.centerY.equalTo(imageItem.snp.centerY)
            make.top.equalTo(superview.snp.top).offset(5)
            make.bottom.equalTo(superview.snp.bottom).offset(-5)
        }
    }
}
