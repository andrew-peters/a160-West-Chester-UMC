//
//  AppDelegate.swift
//  OCVSwift
//
//  Created by Eddie Seay on 1/11/16.
//  Copyright © 2016 OCV,LLC. All rights reserved.
//


// swiftlint:disable function_body_length

import UIKit
import CoreData
import Alamofire
import DrawerController
import Whisper

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var drawerController: DrawerController!
    var rootController: OCVMainMenu!

    var mostRecentNotification: [AnyHashable: Any]?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        AWSAnalytics.SharedInstance.appOpened()

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = rootNavigationController()

        registerInitialSetup(UserDefaults.standard, appID: Config.applicationID, appSecret: Config.applicationSecret)
        OCVAppUtilities.SharedInstance.setRecentAlerts(24)
        AppStylizer.setupAppStyle()

        if Config.usesDrawerController {
            setupAppAsDrawerController()
        }

        return true
    }

    func rootNavigationController() -> UINavigationController {
        rootController = OCVMainMenu()
        return UINavigationController(rootViewController: rootController)
    }

    /**
     Sets appID and appSecret into NSUserDefaults and does any other
     necessary setup that should be done for shared instance objects.

     - parameter userDefaults: The NSUserDefaults object to be written to
     - parameter appID:        Application's appID
     - parameter appSecret:    Application's appSecret
     */
    fileprivate func registerInitialSetup(_ userDefaults: UserDefaults, appID: String, appSecret: String) {
        if userDefaults.object(forKey: "appID") == nil {
            userDefaults.set(appID, forKey: "appID")
        }
        if userDefaults.object(forKey: "appSecret") == nil {
            userDefaults.set(appSecret, forKey: "appSecret")
        }

        registerForPushNotifications()
    }

    fileprivate func registerForPushNotifications() {
        let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        UIApplication.shared.registerUserNotificationSettings(settings)

        // This is an asynchronous method to retrieve a Device Token
        // Callbacks are in AppDelegate.swift
        // Success = didRegisterForRemoteNotificationsWithDeviceToken
        // Fail = didFailToRegisterForRemoteNotificationsWithError
        UIApplication.shared.registerForRemoteNotifications()
    }

    /**
     Called when a notification is received and the app is in the foreground, or called when
     the user clicks a notification if the app is in the background.
     Deals with taking in the received notification and handling it appropriately to display
     content to a user

     - parameter application:       default - does not change
     - parameter userInfo:          default - does not change
     - parameter completionHandler: default - does not change
     */

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("-----Push Notification Received-----")

        mostRecentNotification = userInfo

        /// Checks for valid keys within the notification object.
        // If those keys are not present, the method exits.
        guard let notification = userInfo["aps"] as? [String: AnyObject],
            let post = userInfo["post"] as? [String: AnyObject] else {
                completionHandler(UIBackgroundFetchResult.failed)
                return
        }
        guard let alertMsg = notification["alert"] as? String else {
            completionHandler(UIBackgroundFetchResult.failed)
            return
        }

        guard let appIDNum = post["appID"] as? String,
            let featureName = post["featureName"] as? String,
            let pushID = post["pushID"] as? String,
            let featureType = post["featureType"] as? String,
            let featureTitle = post["featureTitle"] as? String else {
                completionHandler(UIBackgroundFetchResult.failed)
                return
        }

        print("PAYLOAD: \n\(userInfo)")

        // Content updates functions as a standalone channel now
        // if !OCVAppUtilities.SharedInstance.getRegisteredChannels().contains(featureName) && featureName != "messages" {
        // completionHandler(UIBackgroundFetchResult.NoData)
        // return
        // }

        self.recordPushAnalytics("\(pushID)/onCreate")

        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.tableDataDownloadComplete(_:)), name: NSNotification.Name(rawValue: "ReadyToPushDetail"), object: nil)

        let rootView = createPushView(appIDNum, featName: featureName, navigationTitle: featureTitle, type: featureType)

        let state = application.applicationState
        if state == UIApplicationState.inactive || state == UIApplicationState.background {
            displayNotificationDestination(rootView)
            recordPushAnalytics(pushID)
            OCVAppUtilities.SharedInstance.setRecentAlerts(24)
            completionHandler(UIBackgroundFetchResult.newData)
        } else {
            // The below implementation allows for usage of an alertcontroller instead of the Whisper tool.
            // let alertCtrl = UIAlertController(title: featureTitle as String, message: alertMsg as String, preferredStyle: UIAlertControllerStyle.Alert)
            // alertCtrl.addAction(UIAlertAction(title: "Open", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            // self.displayNotificationDestination(rootView)
            // }))
            // alertCtrl.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
            //
            // if let rootView = self.window?.rootViewController as? DrawerController {
            // rootView.centerViewController!.presentViewController(alertCtrl, animated: true, completion: nil)
            // } else if let rootView = self.window?.rootViewController as? UINavigationController {
            // rootView.childViewControllers.last?.presentViewController(alertCtrl, animated: true, completion: nil)
            // }

            let announcement = Announcement(title: featureTitle, subtitle: alertMsg, image: UIImage(named: "logo_small"), duration: 5.0, action: {
                self.displayNotificationDestination(rootView)
                self.recordPushAnalytics(pushID)
            })

            ColorList.Shout.background = AppColors.secondary.color
            ColorList.Shout.title = AppColors.text.color
            ColorList.Shout.subtitle = AppColors.text.color
            ColorList.Shout.dragIndicator = AppColors.primary.color

            if let rootView = self.window?.rootViewController as? DrawerController {
                if let rootNav = rootView.centerViewController?.childViewControllers.last {
                    show(shout: announcement, to: rootNav, completion: nil)
                }
            } else if let rootView = self.window?.rootViewController as? UINavigationController {
                show(shout: announcement, to: rootView.childViewControllers.last!, completion: nil)
            }
            OCVAppUtilities.SharedInstance.setRecentAlerts(24)
            completionHandler(UIBackgroundFetchResult.newData)
        }
    }

    func displayNotificationDestination(_ rootView: UIViewController) {
        if let rootDrawer = self.window?.rootViewController as? DrawerController {
            if let rootNav = rootDrawer.centerViewController as? UINavigationController {
                rootNav.pushViewController(rootView, animated: false)
            }
        } else if let rootNav = self.window?.rootViewController as? UINavigationController {
            rootNav.pushViewController(rootView, animated: false)
        }
    }

    func createPushView(_ appID: String, featName: String, navigationTitle: String, type: String) -> UIViewController {
        let sourceURL = "https://apps.myocv.com/feed/\(type)/\(appID)/\(featName)"
        switch type {
        case "blog":
            return OCVTable(dataSourceURL: sourceURL, navTitle: navigationTitle, circleImages: true, showsDates: true)
        case "alertOrMessage":
            return OCVMessageHistory()
            default:
            return UIViewController()
        }
    }

    func recordPushAnalytics(_ pushID: String) {
        OCVNetworkClient().apiRequest(atPath: "/apps/push/2/analytics/ios/\(pushID)", httpMethod: .post, parameters: [:], showProgress: false) { resultData, code in
            if code == 200 { print("Analytics Received")
            } else { print("Analytics Record Failure") }
        }
    }

    /**
     Called when the app receives a global NSNotification that tells the AppDelegate that
     a received push notificaiton's respective feature class has finished downloading data
     and that the delegate is ready to push a detail view based on those contents.

     - parameter notification: The notification that is passed into the method.
     */
    dynamic func tableDataDownloadComplete(_ notification: Notification?) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ReadyToPushDetail"), object: nil)
        if let topView = notification?.object as? OCVTable {
            guard let post = self.mostRecentNotification?["post"] as? NSDictionary else {
                return
            }
            guard let blogIDNumber = post["itemID"] as? String else {
                return
            }
            topView.pushObjectFromNotificationWithID(blogIDNumber)
        }
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        OCVAppUtilities.SharedInstance.setDeviceToken(convertDeviceTokenToString(deviceToken))

        print(OCVAppUtilities.SharedInstance.currentDeviceToken())

        OCVNotificationModel().downloadAndSyncChannelsWithServer()

        // ...register device token with our Time Entry API server via REST
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Device token for push notifications: FAIL -- ")
        print(error.localizedDescription)
    }

    /**
     Converts an iOS device token from binary NSData into a valid String

     - parameter deviceToken: The device's unique token

     - returns: String value of device token
     */
    fileprivate func convertDeviceTokenToString(_ deviceToken: Data) -> String {
        // Convert binary Device Token to a String (and remove the <,> and white space charaters).
        var deviceTokenStr = deviceToken.description.replacingOccurrences(of: ">", with: "")
        deviceTokenStr = deviceTokenStr.replacingOccurrences(of: "<", with: "")
        deviceTokenStr = deviceTokenStr.replacingOccurrences(of: " ", with: "")

        // Our API returns token in all uppercase, regardless how it was originally sent.
        // To make the two consistent, I am uppercasing the token string here.
        deviceTokenStr = deviceTokenStr.lowercased()
        return deviceTokenStr
    }

    /**
     Sets up the application to use a side drawer-style menu.
     */
    fileprivate func setupAppAsDrawerController() {
        let leftSideDrawerViewController = OCVDrawerControllerTable()
        self.drawerController = DrawerController(centerViewController: rootNavigationController(), leftDrawerViewController: leftSideDrawerViewController, rightDrawerViewController: nil)

        let devicePlatform = UIDevice.current.modelName

        if (devicePlatform == "iPhone 4") || (devicePlatform == "iPhone 4s") {
            self.drawerController.maximumLeftDrawerWidth = 260.0
            self.drawerController.maximumRightDrawerWidth = 280.0
        } else if (devicePlatform == "iPhone 5") || (devicePlatform == "iPhone 5s") {
            self.drawerController.maximumLeftDrawerWidth = 260.0
            self.drawerController.maximumRightDrawerWidth = 280.0
        } else if devicePlatform.contains("Pad") {
            self.drawerController.maximumLeftDrawerWidth = 300.0
            self.drawerController.maximumRightDrawerWidth = 420.0
        } else {
            self.drawerController.maximumLeftDrawerWidth = 300.0
            self.drawerController.maximumRightDrawerWidth = 300.0
        }

        self.drawerController.showsShadows = true
        self.drawerController.restorationIdentifier = "Drawer"
        self.drawerController.openDrawerGestureModeMask = .all
        self.drawerController.closeDrawerGestureModeMask = .all

        OCVDrawerVisualStateManager.sharedManager.leftDrawerAnimationType = DrawerAnimationType.animatedBarButton
        // Other valid types include:
        // - .None
        // - .Slide
        // - .SlideAndScale
        // - .SwingingDoor
        // - .Parallax
        // - .AnimatedBarButton

        self.drawerController.drawerVisualStateBlock = { (drawerController, drawerSide, percentVisible) in
            let block = OCVDrawerVisualStateManager.sharedManager.drawerVisualStateBlockForDrawerSide(drawerSide)
            block?(drawerController, drawerSide, percentVisible)
        }

        window?.rootViewController = self.drawerController
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        AWSAnalytics.SharedInstance.appClosed()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        Alamofire.SessionManager.default.session.invalidateAndCancel()

        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "OCV-LLC.OCVSwift" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count - 1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "OCVSwift", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }

        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext() {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }

}
