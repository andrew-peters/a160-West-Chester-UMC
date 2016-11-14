//
//  Stylesheet.swift
//  OCVSwift
//
//  Created by Eddie Seay on 5/30/16.
//  Copyright © 2016 OCV,LLC. All rights reserved.
//

import UIKit
import ChameleonFramework
import SVProgressHUD
import SafariServices

struct Config {
    
    /** These values must be set to the appropriate values
     in order for the app to function correctly.
     applicationID = the app's appID from the OCV Control Panel
     applicationSecret = the app's appSecret from the OCV Control Panel
     primaryColor = a UIColor or FlatColor that represents the color of
     UINavigationControllers, toolbars, etc.
     secondaryColor = a UIColor or FlatColor that represents an accenting
     color complementary to primaryColor for occasional use
     backgroundColor = a UIColor or Flatcolor to be used to fill in empty
     background areas throughout the app.
     */
    
    static let applicationID = "a16019382"
    static let applicationSecret = "b17f46bd9d5029f6847f0e3b076c8b7d"
    static let appName = "West Chester UMC"
    static let itunesConnectLink = ""
    static let AWSAnalyticsIdentifier = "99193bbd835940bf8694e309f7fce1d0"
    static let shareLink = "https://apps.myocv.com/share/\(applicationID)"
    
    static let transparentNavBar = false
    static let autoBuildMainMenu = false
    static let mainMenuLayoutScheme: OCVMenuLayoutScheme = .threeByFour
    static let mainMenuSliderURL: String? = "https://apps.myocv.com/feed/int/\(applicationID)/slider"
    static let addTickerTape = false
    static let addTickerButton = false
    static let addBackgroundImage = false
    static let backgroundImage = UIImage(named: "")
    
    static let containsOffenders = false
    
    static let addWeatherWidget = false
    static let weatherCountyAndState = ""
    
    static let offenderType = ""
    // Either Florida or Alabama
    
    static let usesDrawerController = true
    static let primaryMenuHeader = ""
    static let secondaryMenuHeader = ""
    
    static let primaryColor = UIColor.flatRedColorDark()//UIColor.flatNavyBlueColorDark() // This can be any UIColor. I choose to use Chameleon to generate flat colors.
    static let secondaryColor = UIColor(hexString: "#8A7C63")//UIColor.flatGrayColorDark()
    static let backgroundColor = UIColor.flatRedColorDark()
}

struct MenuOutline {
    
    static let menuButtons = [
        // THREE-BY-TWO
        ["asset": "ASSET_NAME", "selectorName": ""],
        ["asset": "ASSET_NAME", "selectorName": ""],
        ["asset": "ASSET_NAME", "selectorName": ""],
        ["asset": "ASSET_NAME", "selectorName": ""],
        ["asset": "ASSET_NAME", "selectorName": ""],
        
        // SEVEN BUTTON
        // ["asset": "ASSET_NAME", "selectorName": ""],
        
        // // EIGHT BUTTON
        // ["asset": "ASSET_NAME", "selectorName": ""],
        //
        // // THREE-BY-THREE
        // ["asset": "ASSET_NAME", "selectorName": ""],
        //
        // // ELEVEN BUTTON
        // ["asset": "ASSET_NAME", "selectorName": ""],
        // ["asset": "ASSET_NAME", "selectorName": ""],
        //
        // // THREE-BY-FOUR
        // ["asset": "ASSET_NAME", "selectorName": ""],
        
        // DO NOT REMOVE
        ["asset": "ASSET_NAME", "selectorName": ""]]
    
    static let hybridTopButtons = [
        ["asset": "ASSET_NAME", "selectorName": ""],
        ["asset": "ASSET_NAME", "selectorName": ""],
        ["asset": "ASSET_NAME", "selectorName": ""],
        ["asset": "ASSET_NAME", "selectorName": ""],
        ["asset": "ASSET_NAME", "selectorName": ""]]
    
    static let hybridTableObjects = [
        ["asset": "ASSET_NAME", "text": "PLACEHOLDER", "selectorName": ""],
        ["asset": "ASSET_NAME", "text": "PLACEHOLDER", "selectorName": ""],
        ["asset": "ASSET_NAME", "text": "PLACEHOLDER", "selectorName": ""],
        ["asset": "ASSET_NAME", "text": "PLACEHOLDER", "selectorName": ""],
        ["asset": "ASSET_NAME", "text": "PLACEHOLDER", "selectorName": ""]]
    
    /**
     Set up drawer menu items in the below array. Each item in the array corresponds
     to a cell in the drawer. Each key in the objects corresponds to a core component
     of the cell itself. The "textLabel" key takes the value that is desired to be
     inside the cell's text field. "imageName" is the name of the asset from which
     you want the cell's icon to be pulled. "selector" is the name of the method that
     is to be called when the cell is pressed.
     */
    static let drawerMenu = [["textLabel": "Home", "imageName": "", "selector": "goToMainMenu"],
                             ["textLabel": "Welcome", "imageName": "", "selector": "goToWelcome"],
                             ["textLabel": "Notes From On HIGH", "imageName": "", "selector": "goToNfOH"],
                             ["textLabel": "Children", "imageName": "", "selector": "goToChildren"],
                             ["textLabel": "Youth", "imageName": "", "selector": "goToYouth"],
                             ["textLabel": "Adult", "imageName": "", "selector": "goToAdult"],
                             ["textLabel": "Music", "imageName": "", "selector": "goToMusic"],
                             ["textLabel": "Wednesday Night Out", "imageName": "", "selector": "wedNightOut"],
                             ["textLabel": "Get Involved", "imageName": "", "selector": "getInvolved"],
                             ["textLabel": "Children's Center", "imageName": "", "selector": "childrensCenter"],
                             ["textLabel": "Contact Us", "imageName": "", "selector": "goToContacts"],
                             ["textLabel": "Parking", "imageName": "", "selector": "goToParking"],
                             ["textLabel": "West Chester Borough", "imageName": "", "selector": "westChestBorough"],
                             ["textLabel": "UMCOR", "imageName": "", "selector": ""],
                             ["textLabel": "United Methodist News", "imageName": "", "selector": ""],
                             ["textLabel": "Share Our App", "imageName": "", "selector": ""],
                             ["textLabel": "Social Media", "imageName": "", "selector": "socialMediaFunc"]]
//                             ["textLabel": "Twitter", "imageName": "", "selector": ""],
//                             ["textLabel": "Youtube", "imageName": "", "selector": ""]]
}

// *************************** //
// DO NOT EDIT BELOW THIS LINE //
// *************************** //
enum AppColors {
    case primary
    case secondary
    case background
    case text
    case oppositeOfPrimary
    case alertRed
    case standardWhite
    case standardBlack
    
    var color: UIColor {
        switch self {
        case .primary: return Config.primaryColor!
        case .secondary: return Config.secondaryColor!
        case .background: return Config.backgroundColor!
        case .text: return UIColor.white//ContrastColorOf(Config.primaryColor!, returnFlat: true)
        case .oppositeOfPrimary: return UIColor.white//ContrastColorOf(Config.primaryColor!, returnFlat: false)
        case .alertRed: return UIColor.flatRedColorDark()
        case .standardWhite: return UIColor.flatWhite()
        case .standardBlack: return UIColor.flatBlackColorDark()
        }
    }
    
    func alpha(_ alpha: Double) -> UIColor {
        return color.withAlphaComponent(CGFloat(alpha))
    }
}

enum AppFonts: String {
    case LightText = "OpenSans-Light"
    case LightItalicText = "OpenSansLight-Italic"
    case RegularText = "OpenSans"
    case ItalicText = "OpenSans-Italic"
    case BoldText = "OpenSans-Bold"
    case BoldItalicText = "OpenSans-BoldItalic"
    case SemiboldText = "OpenSans-Semibold"
    case SemiboldItalicText = "OpenSans-SemiboldItalic"
    case ExtraBoldText = "OpenSans-Extrabold"
    case ExtraBoldItalicText = "OpenSans-ExtraboldItalic"
    
    func font(_ size: Float) -> UIFont {
        return UIFont(name: rawValue, size: CGFloat(size))!
    }
}

struct AppStylizer {
    /**
     Sets all default colors of app-wide features.
     Also makes call to set up coloration of UINavigationController.
     */
    static func setupAppStyle() {
        UIApplication.shared.statusBarStyle = .lightContent
        SVProgressHUD.setDefaultStyle(.custom)
        SVProgressHUD.setBackgroundColor(UIColor.init(white: 0.0, alpha: 0.6))
        SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.setFont(AppFonts.RegularText.font(14))
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.backgroundColor = AppColors.background.color
        UINavigationBar.appearance().barTintColor = AppColors.primary.color
        UINavigationBar.appearance().tintColor = AppColors.text.color
        UINavigationBar.appearance().titleTextAttributes = [
            NSFontAttributeName: AppFonts.SemiboldText.font(20),
            NSForegroundColorAttributeName: AppColors.text.color
        ]
        
        UINavigationBar.appearance().isTranslucent = false
        UIBarButtonItem.appearance().setTitleTextAttributes(
            [NSFontAttributeName: AppFonts.RegularText.font(17)],
            for: UIControlState()
        )
        
        UIToolbar.appearance().barTintColor = AppColors.primary.color
        UIToolbar.appearance().tintColor = AppColors.text.color
        UIToolbar.appearance().isTranslucent = false
        
        UISearchBar.appearance().barTintColor = AppColors.primary.color
        UISearchBar.appearance().tintColor = AppColors.oppositeOfPrimary.color
        
        if #available(iOS 9.0, *) {
            UINavigationBar.appearance(whenContainedInInstancesOf: [SFSafariViewController.self]).tintColor = AppColors.primary.color
            UIToolbar.appearance(whenContainedInInstancesOf: [SFSafariViewController.self]).tintColor = nil
        }
    }
}
