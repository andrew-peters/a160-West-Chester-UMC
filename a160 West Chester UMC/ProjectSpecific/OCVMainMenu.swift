//
//  OCVMainMenu.swift
//  OCVSwift
//
//  Created by Eddie Seay on 1/12/16.
//  Copyright © 2016 OCV,LLC. All rights reserved.
//

import UIKit
import ChameleonFramework
import DrawerController
import SafariServices
import SnapKit
import STPopup
import Whisper
import MessageUI

// swiftlint:disable type_body_length
class OCVMainMenu: UIViewController, MFMessageComposeViewControllerDelegate {
    
    /******************************************************/
    // MARK: DO NOT MODIFY
    let menuNetworkManager = OCVAppUtilities.SharedInstance.manager
    private let internetMessage = Message(title: "No internet. Please check your connection", textColor: AppColors.standardWhite.color, backgroundColor: AppColors.alertRed.color, images: nil)
    
    let tableController: OCVMenuTableController?
    let ticker = OCVTickerTape()
    lazy var digestController = OCVDigestController(twitterUsername: "umcwc", fbID: "147932540522", facebookURL: "https://www.facebook.com/pages/West-Chester-United-Methodist-Church/147932540522")
    lazy var weatherWidget = OCVWeatherWidget(defaultLocation: Config.weatherCountyAndState, layoutDirection: .wide)
    
    var transparentNavSpacing = 0
    
    init() {
        if Config.autoBuildMainMenu == true {
            if Config.mainMenuLayoutScheme == .hybrid {
                self.tableController = OCVMenuTableController(objects: MenuOutline.hybridTableObjects)
            } else {
                self.tableController = nil
            }
        } else {
            self.tableController = nil
        }
        super.init(nibName: nil, bundle: nil)
        self.tableController?.parentVC = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.tableController = nil
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setTickerHeight()
    }
    
    // swiftlint:disable function_body_length
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(OCVMainMenu.setTickerHeight), name: NSNotification.Name(rawValue: "TickerTapeUpdated"), object: nil)
        
        self.setNavigationBar(self.menuNetworkManager?.isReachable ?? false)
        if Config.transparentNavBar {
            self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "OpenSans-Bold", size: 16)!, NSForegroundColorAttributeName: UIColor.white]
            self.navigationController?.navigationBar.isTranslucent = true
            
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            self.navigationController?.navigationBar.shadowImage = UIImage()
        } else {
            self.navigationController?.view.backgroundColor = AppColors.standardWhite.color
        }
        self.view.backgroundColor = AppColors.primary.color
        
        self.navigationItem.title = Config.appName
        
        if Config.usesDrawerController { setupLeftMenuButton() }
        
        if Config.autoBuildMainMenu {
            if Config.mainMenuLayoutScheme == .hybrid {
                let buttonView = OCVMenuBuilder(headerTitle: Config.appName, slider: Config.mainMenuSliderURL).mainMenuWithScheme(Config.mainMenuLayoutScheme, items: MenuOutline.hybridTopButtons)
                view.addSubview(buttonView)
                if Config.addWeatherWidget {
                    addWeatherWidget(view, buttonView: buttonView)
                } else {
                    buttonView.snp.makeConstraints { (make) in
                        make.top.equalTo(view.snp.top)
                        make.left.equalTo(view.snp.left)
                        make.right.equalTo(view.snp.right)
                        // make.height.equalTo(180)
                    }
                }
                
                let menuTable: UITableView = {
                    $0.backgroundColor = AppColors.primary.color
                    $0.delegate = self.tableController
                    $0.dataSource = self.tableController
                    $0.tableFooterView = UIView()
                    return $0
                }(UITableView(frame: CGRect.zero, style: .plain))
                view.addSubview(menuTable)
                menuTable.snp.makeConstraints { (make) in
                    make.top.equalTo(buttonView.snp.bottom)
                    make.bottom.equalTo(view.snp.bottom)
                    make.left.equalTo(view.snp.left)
                    make.right.equalTo(view.snp.right)
                }
            } else {
                let menuView = OCVMenuBuilder(headerTitle: Config.appName, slider: Config.mainMenuSliderURL).mainMenuWithScheme(Config.mainMenuLayoutScheme, items: MenuOutline.menuButtons)
                self.view.addSubview(menuView)
                if Config.addWeatherWidget {
                    addWeatherWidget(view, buttonView: menuView)
                } else {
                    menuView.snp.makeConstraints { (make) in
                        make.edges.equalTo(self.view)
                    }
                }
                if Config.addTickerTape {
                    self.view.addSubview(ticker)
                    menuView.snp.makeConstraints { (make) in
                        make.bottom.equalTo(ticker.snp.top)
                    }
                    ticker.snp.makeConstraints { (make) in
                        make.left.equalTo(self.view)
                        make.right.equalTo(self.view)
                        make.bottom.equalTo(self.view)
                    }
                    
                    setTickerHeight()
                    
                    if Config.addTickerButton {
                        let alertArrow: UIImageView = {
                            $0.image = UIImage(named: "forwardArrow")?.withRenderingMode(.alwaysTemplate)
                            $0.contentMode = .scaleAspectFit
                            $0.tintColor = AppColors.standardWhite.color
                            $0.backgroundColor = AppColors.alertRed.color
                            return $0
                        }(UIImageView())
                        
                        let tickerButton = UIButton(type: .custom)
                        tickerButton.addTarget(self, action: #selector(OCVMainMenu.messages), for: .touchUpInside)
                        self.view.addSubview(tickerButton)
                        self.view.addSubview(alertArrow)
                        
                        alertArrow.snp.makeConstraints { (make) in
                            make.centerY.equalTo(ticker)
                            make.height.equalTo(ticker)
                            make.right.equalTo(ticker)
                        }
                        
                        tickerButton.snp.makeConstraints { (make) in
                            make.edges.equalTo(ticker)
                        }
                        
                    }
                }
            }
            setupSettingsButton()
        } else {
            setupMainMenuViews()
        }
        
        menuNetworkManager?.listener = { status in
            self.setNavigationBar(self.menuNetworkManager?.isReachable ?? false)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if OCVAppUtilities.RecentAlertPollDate.timeIntervalSinceNow < -600 {
            OCVAppUtilities.SharedInstance.setRecentAlerts(24)
        }
    }
    
    func setNavigationBar(_ internet: Bool) {
        if internet {
            hide(whisperFrom: navigationController!, after: 0)
        } else {
            Whisper.show(whisper: internetMessage, to: self.navigationController!, action: .present)
        }
    }
    
    func setupLeftMenuButton() {
        let leftDrawerButton = DrawerBarButtonItem(target: self, action: #selector(OCVMainMenu.leftDrawerButtonPress(_:)), menuIconColor: AppColors.text.color)
        self.navigationItem.setLeftBarButton(leftDrawerButton, animated: true)
    }
    
    func setupRightMenuButton() {
        let rightDrawerButton = UIBarButtonItem(image: UIImage(named: "digestStream"), style: .plain, target: self, action: #selector(OCVMainMenu.rightDrawerButtonPress(_:)))
        self.navigationItem.setRightBarButton(rightDrawerButton, animated: true)
    }
    
    func setupSettingsButton() {
        let rightDrawerButton = UIBarButtonItem(image: UIImage(named: "options"), style: .plain, target: self, action: #selector(OCVMainMenu.goToSettings))
        self.navigationItem.setRightBarButton(rightDrawerButton, animated: true)
    }
    
    func goToSettings() { navigationController?.pushViewController(OCVSettings(), animated: true) }
    
    func leftDrawerButtonPress(_ sender: AnyObject?) {
        self.evo_drawerController?.toggleDrawerSide(.left, animated: true, completion: nil)
    }
    
    func rightDrawerButtonPress(_ sender: AnyObject?) {
        self.evo_drawerController?.toggleDrawerSide(.right, animated: true, completion: nil)
    }
    
    func messages() {
        navigationController?.pushViewController(OCVMessageHistory(), animated: true)
    }
    
    func sendText(message: String) {
        let phoneNumber = "274637"
        if MFMessageComposeViewController.canSendText() {
            let controller = MFMessageComposeViewController()
            controller.body = message
            controller.recipients = [phoneNumber]
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        //... handle sms screen actions
    }
    
    // MARK: NAVIGATION METHODS - ADD FUNCTIONALITY HERE
    /*###########################*/
    /*    NAVIGATION METHODS     */
    /*###########################*/
    func pushToPageWithURL(dataSourceURL: String) {
        let mainMenu = (UIApplication.shared.delegate as! AppDelegate).rootController as OCVMainMenu
        let nav = UINavigationController(rootViewController: mainMenu)
        
        nav.view.backgroundColor = UIColor.white
        
        let leftDrawerButton = DrawerBarButtonItem(target: self, action: #selector(OCVDrawerControllerTable.leftDrawerButtonPress(_:)), menuIconColor: AppColors.text.color)
        mainMenu.navigationItem.setLeftBarButton(leftDrawerButton, animated: true)
        
        self.evo_drawerController?.setCenter(nav, withCloseAnimation: true, completion: nil)
        
        _ = OCVPage(sourceURL: dataSourceURL, sourceNavigationController: mainMenu.navigationController!)
    }
    
    func openSafariView(url: String) {
//        let mainMenu = (UIApplication.shared.delegate as! AppDelegate).rootController as OCVMainMenu
//        let nav = UINavigationController(rootViewController: mainMenu)
//        
//        nav.view.backgroundColor = UIColor.white
//        
//        let leftDrawerButton = DrawerBarButtonItem(target: self, action: #selector(OCVDrawerControllerTable.leftDrawerButtonPress(_:)), menuIconColor: AppColors.text.color)
//        mainMenu.navigationItem.setLeftBarButton(leftDrawerButton, animated: true)
//        
//        self.evo_drawerController?.setCenter(nav, withCloseAnimation: true, completion: nil)
//        
        let url1 = URL(string: url)
        let safariBrowser = SFSafariViewController(url: url1!)
        present(safariBrowser, animated: true, completion: nil)
    }
    
//    func setupNewCenterView(_ rootVC: UIViewController) {
//        let nav = UINavigationController(rootViewController: rootVC)
//        
//        nav.view.backgroundColor = UIColor.flatWhite()
//        
//        let leftDrawerButton = DrawerBarButtonItem(target: self, action: #selector(OCVDrawerControllerTable.leftDrawerButtonPress(_:)), menuIconColor: AppColors.text.color)
//        rootVC.navigationItem.setLeftBarButton(leftDrawerButton, animated: true)
//        
//        self.evo_drawerController?.setCenter(nav, withCloseAnimation: true, completion: nil)
//    }
    
    
    
    func goToNews() {
        let newsFeed = OCVTable(dataSourceURL: "https://apps.myocv.com/feed/blog/a16019382/news", navTitle: "News")
//        self.setupNewCenterView(newsFeed)
        //pushToPageWithURL(dataSourceURL: "https://apps.myocv.com/feed/blog/a16019382/news")
        self.navigationController?.pushViewController(newsFeed, animated: true)
    }
    
    func goToCalendar() {
        let calendarUrl = "http://umcwc.org/calendar"
        openSafariView(url: calendarUrl)
    }
    
    func goToPrayerReq() {
        let request = PrayerRequest(formID: "prayerRequest")
        self.navigationController?.pushViewController(request, animated: true)
    }
    
    func goToLiveStream() {
        let streamUrl = "http://www.westchesterumc.com/worship/sermons/live"
        openSafariView(url: streamUrl)
    }
    
    func goToDonate() {
        let donateUrl = "http://umcwc.org/giving"
        openSafariView(url: donateUrl)
    
    }
    
    
    func submitATipFunc() {
        let submenu = OCVSubmenuView(items: ["Online Tip":"https://www.tipsubmit.com/WebTips.aspx?AgencyID=782", "Call In A Tip":"7127373307", "Text A Tip": "scso%@"], navTitle: "Submit A Tip", parentVC: self)
        self.navigationController?.pushViewController(submenu, animated: true)
    }
    
    func socialMediaFunc() {
        let urlsAndTitles = [["platform": "Facebook", "link": "https://www.facebook.com/Sioux.County.Sheriff", "identifier": "170469789667716"], ["platform": "Twitter", "link": "", "identifier": "siouxcosheriff"]]
        let socialPopUp = OCVSocialPopup(items: urlsAndTitles)
        socialPopUp.present(in: self)
    }
    
    // MARK: MANUAL VIEW SETUP
    /*###########################*/
    /*   VIEW METHODS METHODS    */
    /*###########################*/
    func setupMainMenuViews() {
        let slider = OCVSlideshow(url: "https://apps.myocv.com/feed/int/a11451041/slider", shuffle: true)
        
        let digestHeader: UILabel = {
            $0.text = "Recent Activity"
            $0.textColor = UIColor.white
            $0.backgroundColor = UIColor.black
            $0.textAlignment = .center
            return $0
        }(UILabel())
        
        digestController.parentVC = self
        let digestTable = OCVDigestTable(controller: digestController)
        
        
        let tickerButton = UIButton()
        tickerButton.backgroundColor = UIColor.clear
        tickerButton.addTarget(self, action: #selector(messages), for: .touchUpInside)
        
        let buttonView = UIView()
        let imageView = UIImageView()
        imageView.image = UIImage(named: "")
        imageView.backgroundColor = UIColor.flatRedColorDark()
        self.view.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        
        let newsLbl: UILabel = {
            $0.text = "News"
            $0.font = AppFonts.RegularText.font(18)
            $0.textColor = UIColor.white
            $0.textAlignment = .center
            return $0
        }(UILabel())
        
        let newsButton = UIButton()
        newsButton.backgroundColor = UIColor.white.withAlphaComponent(0.10)
        newsButton.addTarget(self, action: #selector(goToNews), for: .touchUpInside)
        //newsButton.layer.cornerRadius = 8.0
        
        let separator1 = UIView()
        separator1.backgroundColor = UIColor.white
        
        let calendarLbl: UILabel = {
            $0.text = "Calendar"
            $0.font = AppFonts.RegularText.font(18)
            $0.textColor = UIColor.white
            $0.textAlignment = .center
            return $0
        }(UILabel())
        
        let calendarButton = UIButton()
        calendarButton.backgroundColor = UIColor.white.withAlphaComponent(0.10)
        calendarButton.addTarget(self, action: #selector(goToCalendar), for: .touchUpInside)
        
        let separator2 = UIView()
        separator2.backgroundColor = UIColor.white
        
        let liveStreamingLbl: UILabel = {
            $0.text = "Live Streaming"
            $0.font = AppFonts.RegularText.font(18)
            $0.textColor = UIColor.white
            $0.textAlignment = .center
            return $0
        }(UILabel())
        
        let liveStreamButton = UIButton()
        liveStreamButton.backgroundColor = UIColor.white.withAlphaComponent(0.10)
        liveStreamButton.addTarget(self, action: #selector(goToLiveStream), for: .touchUpInside)
        
        let donateLbl: UILabel = {
            $0.text = "Donate"
            $0.font = AppFonts.RegularText.font(18)
            $0.textColor = UIColor.white
            $0.textAlignment = .center
            return $0
        }(UILabel())
        
        let donateButton = UIButton()
        donateButton.backgroundColor = UIColor.white.withAlphaComponent(0.10)
        donateButton.addTarget(self, action: #selector(goToDonate), for: .touchUpInside)
        
        let prayerRequestLbl: UILabel = {
            $0.text = "Prayer Request"
            $0.font = AppFonts.RegularText.font(18)
            $0.textColor = UIColor.white
            $0.textAlignment = .center
            //$0.backgroundColor = UIColor.
            return $0
        }(UILabel())
        
        let prayerReqButton = UIButton()
        prayerReqButton.backgroundColor = UIColor.white.withAlphaComponent(0.10)
        prayerReqButton.addTarget(self, action: #selector(goToPrayerReq), for: .touchUpInside)
        
        let alertLbl: UILabel = {
            $0.text = "Alerts"
            $0.font = AppFonts.RegularText.font(18)
            $0.textColor = UIColor.white
            $0.textAlignment = .center
            //$0.backgroundColor = UIColor.black
            return $0
        }(UILabel())
        
        let alertButton = UIButton()
        alertButton.backgroundColor = UIColor.white.withAlphaComponent(0.10)
        alertButton.addTarget(self, action: #selector(messages), for: .touchUpInside)
        
        
        buttonView.addSubview(newsLbl)
        buttonView.addSubview(newsButton)
        //buttonView.addSubview(separator1)
        buttonView.addSubview(calendarLbl)
        buttonView.addSubview(calendarButton)
        //buttonView.addSubview(separator2)
        buttonView.addSubview(liveStreamingLbl)
        buttonView.addSubview(liveStreamButton)
        buttonView.addSubview(donateLbl)
        buttonView.addSubview(donateButton)
        buttonView.addSubview(prayerRequestLbl)
        buttonView.addSubview(prayerReqButton)
        buttonView.addSubview(alertLbl)
        buttonView.addSubview(alertButton)
        
        //news button
        newsLbl.snp.makeConstraints { (make) in
            make.left.equalTo(buttonView).offset(-5)
            make.top.equalTo(buttonView).offset(-5)
            //make.bottom.equalTo(buttonView)
            make.height.equalTo(40)
            make.width.equalTo(buttonView).dividedBy(2)
        }
        
        newsButton.snp.makeConstraints { (make) in
            make.edges.equalTo(newsLbl)
        }
        
       /* separator1.snp.makeConstraints { (make) in
            make.left.equalTo(contactUs.snp.right)
            make.height.equalTo(buttonView)
            make.top.equalTo(buttonView)
            make.bottom.equalTo(buttonView)
            make.width.equalTo(1)
        }*/
        
        //calendar button
        calendarLbl.snp.makeConstraints { (make) in
            make.left.equalTo(newsButton.snp.right).offset(5)
            make.height.equalTo(40)
            make.top.equalTo(buttonView).offset(-5)
           // make.bottom.equalTo(buttonView)
            make.width.equalTo(newsLbl)
        }
        
        calendarButton.snp.makeConstraints { (make) in
            make.edges.equalTo(calendarLbl)
        }
        
        /*separator2.snp.makeConstraints { (make) in
            make.left.equalTo(submitATip.snp.right)
            make.height.equalTo(buttonView)
            make.top.equalTo(buttonView)
            make.bottom.equalTo(buttonView)
            make.width.equalTo(1)
        }*/
        
        
        liveStreamingLbl.snp.makeConstraints { (make) in
            make.left.equalTo(buttonView).offset(-5)
            make.height.equalTo(40)
            make.top.equalTo(newsLbl.snp.bottom).offset(5)
            //make.bottom.equalTo(buttonView)
            make.width.equalTo(newsLbl)
            //make.right.equalTo(buttonView)
        }
        
        liveStreamButton.snp.makeConstraints { (make) in
            make.edges.equalTo(liveStreamingLbl)
        }
        
        donateLbl.snp.makeConstraints { (make) in
            make.left.equalTo(liveStreamButton.snp.right).offset(5)
            make.height.equalTo(40)
            make.top.equalTo(calendarLbl.snp.bottom).offset(5)
            //make.bottom.equalTo(buttonView)
            make.width.equalTo(newsLbl)
            //make.right.equalTo(buttonView)
        }
        
        donateButton.snp.makeConstraints { (make) in
            make.edges.equalTo(donateLbl)
        }
        
        prayerRequestLbl.snp.makeConstraints { (make) in
            make.left.equalTo(buttonView).offset(-5)
            make.height.equalTo(40)
            make.top.equalTo(liveStreamingLbl.snp.bottom).offset(5)
            //make.bottom.equalTo(buttonView)
            make.width.equalTo(newsLbl)
            //make.right.equalTo(buttonView)
        }
        
        prayerReqButton.snp.makeConstraints { (make) in
            make.edges.equalTo(prayerRequestLbl)
        }
        
        alertLbl.snp.makeConstraints { (make) in
            make.left.equalTo(prayerReqButton.snp.right).offset(5)
            make.height.equalTo(40)
            make.top.equalTo(donateLbl.snp.bottom).offset(5)
            //make.bottom.equalTo(buttonView)
            make.width.equalTo(newsLbl)
            //make.right.equalTo(buttonView)
        }
        
        alertButton.snp.makeConstraints { (make) in
            make.edges.equalTo(alertLbl)
        }
        
        //self.view.addSubview(weatherWidget)
        //self.view.addSubview(slider)
        self.view.addSubview(buttonView)
        self.view.addSubview(digestHeader)
        self.view.addSubview(digestTable)
        self.view.addSubview(ticker)
        self.view.addSubview(tickerButton)
        
       /* weatherWidget.snp.makeConstraints { (make) in
            make.top.equalTo(view)
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.height.equalTo(44)
        }
        
        let height = 1468 * self.view.frame.width / 3260
        
        slider.snp.makeConstraints { (make) in
            make.top.equalTo(weatherWidget.snp.bottom)
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.height.equalTo(height)
        }*/
        
        buttonView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view)
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.height.equalTo(120)
        }
        
        digestHeader.snp.makeConstraints { (make) in
            make.top.equalTo(buttonView.snp.bottom)
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.height.equalTo(20)
        }
        
        digestTable.snp.makeConstraints { (make) in
            make.top.equalTo(digestHeader.snp.bottom)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
        }
        
        ticker.snp.makeConstraints { (make) in
            make.top.equalTo(digestTable.snp.bottom)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.height.equalTo(30)
            make.bottom.equalTo(self.view)
        }
        
//        setTickerHeight()
        
        tickerButton.snp.makeConstraints { (make) in
            make.edges.equalTo(ticker)
        }
    }
    
    func setTickerHeight() {
        var tickerHeight = 0
        if ticker.tickerLabel.text == "There are currently no active alerts." || ticker.tickerLabel.text == nil {
            tickerHeight = 0
        } else {
            tickerHeight = 30
        }
        
        ticker.snp.makeConstraints { (make) in
            make.height.equalTo(tickerHeight)
        }
    }
    
    func addWeatherWidget(_ view: UIView, buttonView: UIView) {
        view.addSubview(weatherWidget)
        
        if Config.transparentNavBar {
            transparentNavSpacing = 64
        }
        
        weatherWidget.snp.makeConstraints({ (make) in
            make.top.equalTo(self.view).offset(transparentNavSpacing)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.height.equalTo(45)
        })
        
        buttonView.snp.makeConstraints { (make) in
            make.top.equalTo(weatherWidget.snp.bottom)
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
            //make.height.equalTo(180)
        }
    }
}

class TitleBarImageView: UIImageView {
    override init(image: UIImage?) {
        super.init(image: image)
        self.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        self.contentMode = .scaleAspectFit
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
