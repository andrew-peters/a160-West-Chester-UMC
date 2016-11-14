//
//  OCVNotificationModel.swift
//  OCVSwift
//
//  Created by Eddie Seay on 2/15/16.
//  Copyright © 2016 OCV,LLC. All rights reserved.
//

import UIKit
import SVProgressHUD

class OCVNotificationModel {
    weak var sendingTable: OCVNotificationSettings?
    var localArray: [[OCVNotificationChannelObject]] = []
    var localData = Data()
    
    init() { }
    
    init(asViewModel: Bool?) {
        OCVNetworkClient().apiRequest(atPath: "/apps/push/2/channels/list", httpMethod: .get, parameters: [:], showProgress: true) { (data, code) in
            guard let jsonData = data else { return }
            self.syncChannels(jsonData)
            self.sendingTable!.tableView.reloadData()
            OCVAppUtilities.finishTask()
        }
    }
    
    deinit {
        let registeredChannels = localArray.flatMap {
            $0.filter { $0.register }.map { $0.channelName }
        }
        
        OCVAppUtilities.SharedInstance.setRegisteredchannels(registeredChannels)
        
        //  Content updates functions as standalone channel
        //        if localArray.count == 3 {
        //            localArray.removeFirst()
        //            OCVAppUtilities.SharedInstance.registerPushChannelsWithServer(localArray)
        //        }
        OCVAppUtilities.SharedInstance.registerPushChannelsWithServer(localArray)
    }
    
    func downloadAndSyncChannelsWithServer() {
        OCVNetworkClient().apiRequest(atPath: "/apps/push/2/channels/list", httpMethod: .get, parameters: [:], showProgress: true) { (data, code) in
            guard let jsonData = data else { return }
            self.syncChannels(jsonData)
            print("Notification Channels Successfully Synced")
        }
    }
    
    func syncChannels(_ downloadData: Data) {
        if let localSettings = UserDefaults.standard.object(forKey: "localNotificationSettings") as? Data {
            let updatedLocalSettingsData = OCVNotificationParser().updatedNotificationSettings(localSettings, downloadedData: downloadData)
            UserDefaults.standard.set(updatedLocalSettingsData, forKey: "localNotificationSettings")
            self.localData = updatedLocalSettingsData
        } else {
            self.localData = downloadData
            UserDefaults.standard.set(downloadData, forKey: "localNotificationSettings")
        }
        
        generateArraysFromData(self.localData)
        updateProtectedChannels(self.localData)
    }
    
    func updateProtectedChannels(_ data: Data) {
        
        let parser = OCVNotificationParser()
        
        var channels = [OCVNotificationChannelObject]()
        channels += parser.createMessageOrMassIncludingHidden(data, category: "messages")
        channels += parser.createMessageOrMassIncludingHidden(data, category: "mass")
        channels += parser.createContentObjects(data)
        
        //        let channels = OCVJSONParser().createMessageOrMassIncludingHidden(data, category: "messages") + OCVJSONParser().createMessageOrMassIncludingHidden(data, category: "mass") + OCVJSONParser().createContentObjects(data)
        
        let protectedChannels = channels.filter { $0.protection != "" }.map { $0.channelName }
        let registeredChannels = channels.filter { $0.register }.map { $0.channelName }
        
        OCVAppUtilities.SharedInstance.setProtectedChannels(protectedChannels)
        OCVAppUtilities.SharedInstance.setRegisteredchannels(registeredChannels)
    }
    
    func generateArraysFromData(_ data: Data) {
        var contentArray = OCVNotificationParser().createContentObjects(data)
        var messagesArray = OCVNotificationParser().createMessageOrMassObjects(data, category: "messages")
        var massArray = OCVNotificationParser().createMessageOrMassObjects(data, category: "mass")
        
        contentArray.sort { (channel1: OCVNotificationChannelObject, channel2: OCVNotificationChannelObject) -> Bool in
            channel1.title < channel2.title
        }
        
        messagesArray.sort { (channel1: OCVNotificationChannelObject, channel2: OCVNotificationChannelObject) -> Bool in
            channel1.order < channel2.order
        }
        massArray.sort { (channel1: OCVNotificationChannelObject, channel2: OCVNotificationChannelObject) -> Bool in
            channel1.order < channel2.order
        }
        
        if !contentArray.isEmpty { localArray.append(contentArray) }
        if !messagesArray.isEmpty { localArray.append(messagesArray) }
        if !massArray.isEmpty { localArray.append(massArray) }
        
        self.sendingTable?.tableView.reloadData()
        OCVAppUtilities.finishTask()
    }
    
    func numberOfSectionsInTable() -> Int {
        return localArray.count 
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        return localArray[section].count 
    }
    
    func titleForSectionHeader(_ section: Int) -> String {
        switch section {
        case 0:
            return "App Feature Content Updates"
        case 1:
            return "Message Channels & Alert Groups"
        case 2:
            return "Mass Notification Channels"
        default:
            return ""
        }
    }
    
    func objectForIndexPath(_ indexPath: IndexPath) -> OCVNotificationChannelObject {
        return localArray[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
    }
    
    func protectedForIndexPath(_ indexPath: IndexPath) -> Bool {
        return localArray[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row].protection != ""
    }
    
    func protectionTypeForIndexPath(_ indexPath: IndexPath) -> String {
        return localArray[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row].protection
    }
    
    func registeredForIndexPath(_ indexPath: IndexPath) -> Bool {
        return localArray[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row].register
    }
    
    func titleForCellAtIndexPath(_ indexPath: IndexPath) -> String {
        return localArray[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row].title
    }
    
    func updateRegistrationAtIndexPath(_ indexPath: IndexPath, sendingSwitch: NotificationSwitch) {
        guard let currentObject = objectForIndexPath(indexPath) as OCVNotificationChannelObject? else {
            print("INVALID INDEXPATH")
        }
        
        // Checks to see if the field is protected, and if so, presents a dialogue to authenticate within.
        if self.protectedForIndexPath(indexPath) == true && currentObject.register == false {
            DispatchQueue.main.async {
                let authenticationAlert = self.protectionAuthenticator(self.protectionTypeForIndexPath(indexPath), object: currentObject, indexPath: indexPath, indexSwitch: sendingSwitch)
                self.sendingTable?.present(authenticationAlert, animated: true, completion: nil)
            }
        } else {
            setSwitchAndUpdateLocalSettings(true, sendingSwitch: sendingSwitch, indexPath: indexPath, currentObject: currentObject)
        }
    }
    
    func protectionAuthenticator(_ protectionType: String, object: OCVNotificationChannelObject, indexPath: IndexPath, indexSwitch: NotificationSwitch) -> UIAlertController {
        var authTextField = UITextField()
        
        var placeHolderString = ""
        
        if protectionType == "pin" {
            placeHolderString = "Enter PIN"
        } else {
            placeHolderString = "Enter Password"
        }
        
        let authController = UIAlertController(title: "Unlock Channel", message: "You must enter valid credentials to register for this notification channel", preferredStyle: .alert)
        let submitButton = UIAlertAction(title: "Submit", style: .default) { (action) -> Void in
            print(authTextField.text)
            print("Doing Stuff....")
            _ = EZLoadingActivity.show("Registering...", disableUI: true)
            OCVNetworkClient().apiRequest(atPath: "/apps/push/2/authenticate", httpMethod: .post, parameters: ["channel": object.channelName, "authcode": authTextField.text ?? "", ], showProgress: true, completion: { (data, code) in
                if code == 200 {
                    self.setSwitchAndUpdateLocalSettings(true, sendingSwitch: indexSwitch, indexPath: indexPath, currentObject: object)
                } else {
                    self.setSwitchAndUpdateLocalSettings(false, sendingSwitch: indexSwitch, indexPath: indexPath, currentObject: object)
                }
            })
        }
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
            print("Cancel Pressed")
            self.setSwitchAndUpdateLocalSettings(false, sendingSwitch: indexSwitch, indexPath: indexPath, currentObject: object)
        }
        
        authController.addAction(submitButton)
        authController.addAction(cancelButton)
        authController.addTextField { (textField) -> Void in
            authTextField = textField
            authTextField.isSecureTextEntry = true
            authTextField.textAlignment = .center
            authTextField.placeholder = placeHolderString
            if protectionType == "pin" {
                authTextField.keyboardType = .numberPad
            }
        }
        return authController
    }
    
    func setSwitchAndUpdateLocalSettings(_ success: Bool, sendingSwitch: NotificationSwitch, indexPath: IndexPath, currentObject: OCVNotificationChannelObject) {
        if success != true {
            //            SVProgressHUD.showErrorWithStatus("Channel Registration Failed")
            _ = EZLoadingActivity.hide(false, animated: false)
            sendingSwitch.setOn(!sendingSwitch.isOn, animated: true)
        } else {
            if currentObject.protection != "" && sendingSwitch.isOn {
                //                SVProgressHUD.showSuccessWithStatus("Channel Registered")
                _ = EZLoadingActivity.hide(true, animated: false)
            }
            
            currentObject.register = !currentObject.register
            localArray[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row] = currentObject
            localData = OCVNotificationParser().switchRegistrationForChannel(localData, name: currentObject.channelName, section: (indexPath as NSIndexPath).section)
            UserDefaults.standard.set(localData, forKey: "localNotificationSettings")
        }
    }
}

class OCVNotificationChannelObject {
    let channelName: String
    let title: String
    let protection: String
    var register: Bool
    let order: Int
    
    init(channelName: String, title: String, protection: String, register: Bool, order: Int) {
        self.channelName = channelName
        self.title = title
        self.protection = protection
        self.register = register
        self.order = order
    }
}
