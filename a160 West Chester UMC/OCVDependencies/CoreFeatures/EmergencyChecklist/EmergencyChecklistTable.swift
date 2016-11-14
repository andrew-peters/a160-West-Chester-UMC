//
//  EmergencyChecklistTable.swift
//  a188
//
//  Created by Christina Holmes on 7/27/16.
//  Copyright © 2016 OCV, LLC. All rights reserved.
//

import Foundation
import UIKit

private let tableCellIdentifier = "EmergencyChecklistCell"

class EmergencyChecklistTable: UITableViewController {

    var actionToEnable: UIAlertAction?
    let checklistItems: [String: String] = ["Water":"One gallon per person, per day (3-day supply for evacuation, 2-week supply for home)",
                                            "Food":"Non-perishable, easy-to-prepare items (3-day supply for evacuation, 2-week supply for home)",
                                            "Flashlight":"Battery operated",
                                            "Radio":"Battery-powered or hand-cranked radio (NOAA Weather Radio, if possible)",
                                            "Extra Batteries":"Disposable (not rechargable)",
                                            "First Aid Kit":"For a family of four, the Red Cross recommends:\n2 absorbent compress dressings\n25 adhesive bandages\n1 adhesive cloth tape\n5 antibiotic ointment packets\n5 antiseptic wipe packets\n2 packets of aspirin\n1 breathing barrier\n1 instant cold compress\n2 pair of nonlatex gloves\n2 hydrocrtison ointment packets\nscissors\n1 roller bandage\n5 sterile gauze pads\nOral thermometer(non-mercury/nonglass)\n2 triangular bandages\ntweezers\n\nMore information at: http://www.redcross.org/prepare/location/home-family/get-kit/anatomy",
                                            "Medications":"7-day supply",
                                            "Medical Supplies":"Hearing aids with extra batteries, glasses, contact lenses, syringes, etc.",
                                            "Multi-Purpose Tool":"One that can act as a knife, file, pliers, and screwdriver",
                                            "Personal Hygiene Items":"Moist towelettes, feminine hygiene items, soap, toothbrush and toothpaste, etc",
                                            "Personal Documents":"Medical information, proof of address, deed to home, passports, birth certificates, insurance",
                                            "Cell Phone with Chargers":"Inverter or solar charger",
                                            "Emergency Contact":"Choose an out-of-area emergency contact person. It may be easier to text or call long distance if local phone lines are overloaded or out of service. Everyone should have emergency contact information in writing or saved on their cell phones.",
                                            "Extra Cash":"No additional information",
                                            "Blankets/Sleeping Bags":"One for each person. Consider additional bedding if you live in a cold weather climate.",
                                            "Maps of Area":"No additional information",
                                            "Baby Supplies":"Bottles, formula, baby food, diapers",
                                            "Pet Supplies":"Collar, leash, ID, food, carrier, bowl",
                                            "Two-Way Radios":"No additional information",
                                            "Extra Set of Keys":"House, car, etc.",
                                            "Can-Opener":"Non-electric",
                                            "Whistle":"To signal for help",
                                            "Matches":"In a waterproof container",
                                            "Extra Clothing":"Complete change of clothing including a long sleeved shirt, long pants, and sturdy shoes. Consider additional clothing if you live in a cold weather climate.",
                                            "Duct Tape":"No additional information"]
    
    // Used to set the order of items in recommended checklist since checklistItems dictionary has no order
    let checklistKeys: [String] = ["Water", "Food", "Flashlight", "Radio", "Extra Batteries", "First Aid Kit", "Medications", "Medical Supplies", "Multi-Purpose Tool", "Personal Hygiene Items", "Personal Documents", "Cell Phone with Chargers", "Emergency Contact", "Extra Cash", "Blankets/Sleeping Bags", "Maps of Area","Baby Supplies", "Pet Supplies", "Two-Way Radios", "Extra Set of Keys", "Can-Opener", "Whistle", "Matches", "Extra Clothing", "Duct Tape"]
    
    let defaults = UserDefaults.standard
    
    // User inputted items
    var userItems = [String:[String:String]]()
    var userItemsArray = [String]()
    
    // Recommended Checklist Items
    var saveditems = [String:String]()
    
    var editPressed: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Emergency Checklist"
        tableView.backgroundColor = AppColors.standardWhite.color
        tableView.separatorColor = AppColors.background.color
        
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.register(EmergencyChecklistCell.self, forCellReuseIdentifier: tableCellIdentifier)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareChecklist))
        self.navigationController?.toolbar.tintColor = AppColors.standardWhite.color
        
        self.navigationController?.isToolbarHidden = false
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addToMyChecklist))
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let edit = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(deleteRow))
        let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshChecklist))
        toolbarItems = [refresh, flex, edit, flex, add]
        
        
        //Load defaults
        if (defaults.object(forKey: "userItems") != nil) {
            userItems = defaults.object(forKey: "userItems") as! [String:[String:String]]
        }
        
        if (defaults.object(forKey: "savedItems") != nil) {
            saveditems = defaults.object(forKey: "savedItems") as!  [String:String]
        }
        
        initalUse(checklistItems)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    func initalUse(_ items: [String: String]) {
        var savedItems0Dict: [String:String] = [:]
        
        // Initially set all values to 0
        for (key, _) in items {
            savedItems0Dict[key] = "0"
        }
        
        // If it is the first time opening feature, set the values in default to 0
        if (saveditems.count == 0) {
            saveditems = savedItems0Dict
            defaults.set(saveditems, forKey: "savedItems")
        }
        
        //Get user items keys and sort them alphabetically
        for (key, _) in userItems {
            userItemsArray.append(key)
        }
        userItemsArray = userItemsArray.sorted { return $0 < $1 }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "My Checklist"
        }
        else {
            return " Red Cross Recommended Checklist"
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if userItems.count == 0 {
                return 1
            }
            return userItems.count
        }
        else {
            return checklistItems.count
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedRowHeight indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath as NSIndexPath).section == 0 && userItems.count == 0 {
            let cell = UITableViewCell()
            cell.selectionStyle = .none
            
            cell.textLabel?.text = "Add custom items to your emergency checklist"
            
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: tableCellIdentifier) as? EmergencyChecklistCell else {
                fatalError("Could not dequeue cell with identifier: \(tableCellIdentifier)")
            }
            cell.selectionStyle = .none
            var title: String = ""
            var quantity: Int = 0
            
            // My Checklist Section
            if (indexPath as NSIndexPath).section == 0 {
                let curDict = userItems[userItemsArray[(indexPath as NSIndexPath).row]]
                title = curDict!["title"]!
                let quantityString = curDict!["count"]
                quantity = Int(quantityString!)!
            }
                
            // Recommended Checklist Section
            else {
                title = checklistKeys[(indexPath as NSIndexPath).row]
                let quantityString = saveditems[title]
                quantity = Int(quantityString!)!
            }
        
            cell.titleLabel.text = title
            cell.quantityLabel.text = "\(quantity)"
            
            if quantity == 0 {
                cell.quantityLabel.textColor = UIColor.red
            } else {
                cell.quantityLabel.textColor = UIColor.black
            }
            
            // Cannot pass parameters into a selector so tag is set to the cell's row and the buttons "title" is set to the cell's section to know which detail needs to be shown. The "title" color is set to clear so that it cannot be seen
            cell.infoButton.tag = (indexPath as NSIndexPath).row
            cell.infoButton.setTitle("\((indexPath as NSIndexPath).section)", for: UIControlState())
            cell.infoButton.setTitleColor(UIColor.clear, for: UIControlState())
            cell.infoButton.addTarget(self, action: #selector(showDetail), for: .touchUpInside)
            
            // Tag is set to cell's row, but now title is now set to the cell's section and item's title so that we know which cell we're on and can know what key to look for to change the quantity
            cell.plusButton.tag = (indexPath as NSIndexPath).row
            cell.plusButton.setTitle("\((indexPath as NSIndexPath).section)\(title)", for: UIControlState())
            cell.plusButton.setTitleColor(UIColor.clear, for: UIControlState())
            cell.plusButton.titleLabel?.text = "\((indexPath as NSIndexPath).section)"
            cell.plusButton.addTarget(self, action: #selector(incrementNumber), for: .touchUpInside)
            
            cell.minusButton.tag = (indexPath as NSIndexPath).row
            cell.minusButton.setTitle("\((indexPath as NSIndexPath).section)\(title)", for: UIControlState())
            cell.minusButton.setTitleColor(UIColor.clear, for: UIControlState())
            cell.minusButton.addTarget(self, action: #selector(decrementNumber), for: .touchUpInside)

            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if (indexPath as NSIndexPath).section == 0 && userItems.count != 0 {
            return .delete
        } else {
            return .none
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).section == 0 && userItems.count != 0 {
            if editingStyle == .delete {
                
                let title = userItemsArray[(indexPath as NSIndexPath).row]
                userItemsArray.remove(at: (indexPath as NSIndexPath).row)
                userItems.removeValue(forKey: title)
                defaults.set(userItems, forKey: "userItems")
                let section = IndexSet(integer: 0)
                tableView.reloadSections(section, with: .automatic)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if (indexPath as NSIndexPath).section == 0 && userItems.count != 0 {
            return true
        }
        return false
    }
    
    // Shares Recommended Checklist and quantities and if present, my checklist items and quantities
    func shareChecklist() {
        var shareDescription = "RED CROSS CHECKLIST:\n"
        for (key, value) in saveditems {
            shareDescription.append("\(key):\t\(value)\n")
        }
        
        if userItems.count != 0 {
            shareDescription.append("\nMY CHECKLIST:\n")
            for (_, value) in userItems {
                let title = value["title"]!
                let count = value["count"]!
                shareDescription.append("\(title):\t\(count)\n")
            }
        }
        
        shareDescription.append("\nShared from the \(Config.appName) app\n\(Config.shareLink)")
        
        let myActivityController = UIActivityViewController(activityItems: [shareDescription], applicationActivities: nil)
        myActivityController.modalPresentationStyle = .popover
        myActivityController.popoverPresentationController?.sourceView = self.view
        myActivityController.popoverPresentationController?.permittedArrowDirections = .any
        
        self.present(myActivityController, animated: true, completion: nil)
    }
    
    // Restores all values on recommended checklist to 0 and deletes everything out of my checklist
    func refreshChecklist() {
        // Check to make sure user wants to reset
        let alertController = UIAlertController(title: "Reset to default", message: "Are you sure you want to reset your checklist to its default setting? This will delete all added items and reset your item counts to 0.", preferredStyle: .alert)
        let reset = UIAlertAction(title: "Reset", style: .default) { (action) in
            
            // Reset value for saved key to 0 and save to default
            var savedItems0Dict: [String:String] = [:]
            for (key, _) in self.checklistItems {
                savedItems0Dict[key] = "0"
            }
            self.saveditems = savedItems0Dict
            self.defaults.set(self.saveditems, forKey: "savedItems")
            
            // If user has inputed items to My Checklist, delete them
            if self.userItems.count != 0 {
                self.userItemsArray.removeAll()
                self.userItems.removeAll()
                self.defaults.set(self.userItems, forKey: "userItems")
                
            }
            
            self.tableView.reloadData()
            
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(reset)
        alertController.addAction(cancel)
        
        self.navigationController?.present(alertController, animated: true, completion: nil)
    }
    
    // Delete row at index path
    func deleteRow() {
        // Check to see if there are any items to delete
        if userItems.count != 0 {
            //Toggle edit button to show/not show delete button
            if editPressed == false {
                editPressed = true
                tableView.isEditing = true
            } else {
                editPressed = false
                tableView.isEditing = false
            }
            
        } else {
            tableView.isEditing = false
            let alert = UIAlertController(title: "You do not have any items to edit.", message: "Please add items to My Checklist to be able to edit them.", preferredStyle: .alert)
            let OK = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(OK)
            self.navigationController?.present(alert, animated: true, completion: nil)
        }
        
    }
    
    func showDetail(_ sender: UIButton) {
        let section = sender.currentTitle
        let row = sender.tag
        var title: String! = ""
        var detail: String! = ""
        
        // My Checklist Section
        if section == "0" {
            let curDict = userItems[userItemsArray[row]]
            title = curDict!["title"]
            detail = curDict!["description"]
        }
        
        // Recommended Checklist Section
        else {
            title = checklistKeys[row]
            detail = checklistItems[title]
        }
        
        // Show detail
        let alertController = UIAlertController(title: title, message: detail, preferredStyle: .alert)
        let actionDismiss = UIAlertAction(title: "OK", style: .cancel, handler: { (action) -> Void in
            _ = self.parent!.navigationController?.popViewController(animated: true)
        })
        
        alertController.addAction(actionDismiss)
        self.parent!.present(alertController, animated: true, completion: nil)
    }
    
    func incrementNumber(_ sender: UIButton) {
        // Parse through the current title set for plusButton and get title and section
        let index = sender.currentTitle?.characters.index((sender.currentTitle?.startIndex)!, offsetBy: 1)
        let title = sender.currentTitle?.substring(from: index!)
        let section = sender.currentTitle?.substring(to: index!)
        let row = sender.tag
        var quantity = 0
        
        // My Checklist Section
        if section == "0" {
            var curDict = userItems[userItemsArray[row]]
            quantity = Int(curDict!["count"]!)!
            
            // Don't let quantity go to three digits
            if quantity < 99 {
                curDict!["count"] = "\(quantity + 1)"
                userItems[curDict!["title"]!] = curDict
                
                // Reset quantity value
                defaults.set(userItems, forKey: "userItems")
                
                // Reload row
                let indexPath = IndexPath(row: row, section: 0)
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            else {
                let alertController = UIAlertController(title: "You have reached the maximum quantity allowed for this item", message: "", preferredStyle: .alert)
                let actionDismiss = UIAlertAction(title: "OK", style: .cancel, handler: { (action) -> Void in
                    _ = self.parent!.navigationController?.popViewController(animated: true)
                })
                
                alertController.addAction(actionDismiss)
                self.parent!.present(alertController, animated: true, completion: nil)
            }

        }
        // Recommended Checklist Section
        else {
            quantity = Int(saveditems[title!]!)!
            
            // Don't let quantity go to three digits
            if quantity < 99 {
                saveditems[title!] = "\(quantity + 1)"
                
                // Reset quantity value
                defaults.set(saveditems, forKey: "savedItems")
                
                // Reload row
                let indexPath = IndexPath(row: row, section: 1)
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            else {
                let alertController = UIAlertController(title: "You have reached the maximum quantity allowed for this item", message: "", preferredStyle: .alert)
                let actionDismiss = UIAlertAction(title: "OK", style: .cancel, handler: { (action) -> Void in
                    _ = self.parent!.navigationController?.popViewController(animated: true)
                })
                
                alertController.addAction(actionDismiss)
                self.parent!.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    func decrementNumber(_ sender: UIButton) {
        let index = sender.currentTitle?.characters.index((sender.currentTitle?.startIndex)!, offsetBy: 1)
        let title = sender.currentTitle?.substring(from: index!)
        let section = sender.currentTitle?.substring(to: index!)
        let row = sender.tag
        var quantity: Int
        
        // My Checklist Section
        if section == "0" {
            var curDict = userItems[userItemsArray[row]]
            quantity = Int(curDict!["count"]!)!
            
            // Check to make sure quantity is at least 0 because we don't want negative values
            if quantity > 0 {
                curDict!["count"] = "\(quantity - 1)"
                userItems[curDict!["title"]!] = curDict
                
                // Reset quantity value
                defaults.set(userItems, forKey: "userItems")
                
                // Reload row
                let indexPath = IndexPath(row: row, section: 0)
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            else {
                let alertController = UIAlertController(title: "You have reached the minimum quantity allowed for this item", message: "", preferredStyle: .alert)
                let actionDismiss = UIAlertAction(title: "OK", style: .cancel, handler: { (action) -> Void in
                    _ = self.parent!.navigationController?.popViewController(animated: true)
                })
                
                alertController.addAction(actionDismiss)
                self.parent!.present(alertController, animated: true, completion: nil)
            }
        }
        // Recommended Checklist Section
        else {
            quantity = Int(saveditems[title!]!)!
            
            // Check to make sure quantity is at least zero
            if quantity > 0 {
                saveditems[title!] = "\(quantity - 1)"
                
                // Reset quantity value
                defaults.set(saveditems, forKey: "savedItems")
                
                // Reload row
                let indexPath = IndexPath(row: sender.tag, section: 1)
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            else {
                let alertController = UIAlertController(title: "You have reached the minimum quantity allowed for this item", message: "", preferredStyle: .alert)
                let actionDismiss = UIAlertAction(title: "OK", style: .cancel, handler: { (action) -> Void in
                    _ = self.parent!.navigationController?.popViewController(animated: true)
                })
                
                alertController.addAction(actionDismiss)
                self.parent!.present(alertController, animated: true, completion: nil)
            }
        }
    }

//Needed for the next two methods
    var itemTitle = ""
    var itemDetail = ""
    
    func addToMyChecklist() {
        let inputController = UIAlertController(title: "Add Item to My Checklist", message: "Please enter the item's title and details.", preferredStyle: .alert)
        let add = UIAlertAction(title: "Add Item", style: .default) { (action) in
            // Create local dictionary of title, count (defaulted to 0), and the detail
            var curDict:[String:String] = [:]
            curDict["title"] = self.itemTitle
            curDict["count"] = "0"
            curDict["detail"] = self.itemDetail
            
            //Save this dict with the title key to the userItems dict
            self.userItems[self.itemTitle] = curDict
            self.defaults.set(self.userItems, forKey: "userItems")
            
            //Get user items keys and sort them alphabetically
            self.userItemsArray.removeAll()
            for (key, _) in self.userItems {
                self.userItemsArray.append(key)
            }
            self.userItemsArray = self.userItemsArray.sorted { return $0 < $1 }
            
            //Reload My Checklist Section
            let indexSet = IndexSet(integer: 0)
            self.tableView.isEditing = false
            self.tableView.reloadSections(indexSet, with: .automatic)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        inputController.addAction(add)
        inputController.addAction(cancel)
        // Add title text field
        inputController.addTextField { (titleField) in
            titleField.placeholder = "Title:"
            titleField.isSecureTextEntry = false
            // Check if title was changed
            titleField.addTarget(self, action: #selector(self.titleChanged), for: .editingChanged)
        }
        // Add details text field
        inputController.addTextField { (detailField) in
            detailField.placeholder = "Details:"
            detailField.isSecureTextEntry = false
            // Check if detail was changed
            detailField.addTarget(self, action: #selector(self.detailChanged), for: .editingChanged)
        }
        
        self.actionToEnable = add
        add.isEnabled = false
        
        self.present(inputController, animated: true, completion: nil)
    }
    
    func titleChanged(_ sender: UITextField) {
        self.actionToEnable?.isEnabled = true
        var text = ""
        if let titleText = sender.text {
            text = titleText
        }
        self.itemTitle = text
    }
    
    func detailChanged(_ sender: UITextField) {
        self.actionToEnable?.isEnabled = true
        var text = ""
        if let detailText = sender.text {
            text = detailText
        }
        self.itemDetail = text
    }
}

