//
//  OCVExtensions.swift
//  OCVSwift
//
//  Created by Eddie Seay on 2/29/16.
//  Copyright © 2016 OCV,LLC. All rights reserved.
//

import UIKit

extension String {
    func between(_ left: String, _ right: String) -> String? {
        guard let leftRange = range(of: left),
            let rightRange = range(of: right, options: .backwards),
            left != right && leftRange.upperBound != rightRange.lowerBound
        else { return nil }

        let lo = self.index(leftRange.upperBound, offsetBy: 0)
        let hi = self.index(rightRange.lowerBound, offsetBy: 0)
        
        return self[lo ..< hi]
    }
}

extension Date {
    // swiftlint:disable cyclomatic_complexity
    // swiftlint:disable function_body_length
    func timeAgoSinceDate(_ date: Date, numericDates: Bool) -> String {
        let calendar = Calendar.current
        let now = Date()
        let earliest = (now as NSDate).earlierDate(date)
        let latest = (earliest == now) ? date : now
        let components: DateComponents = (calendar as NSCalendar).components([NSCalendar.Unit.minute, NSCalendar.Unit.hour, NSCalendar.Unit.day, NSCalendar.Unit.weekOfYear, NSCalendar.Unit.month, NSCalendar.Unit.year, NSCalendar.Unit.second], from: earliest, to: latest, options: NSCalendar.Options())

        if components.year! >= 2 {
            return "\(components.year) years ago"
        } else if components.year! >= 1 {
            if numericDates {
                return "1 year ago"
            } else {
                return "Last year"
            }
        } else if components.month! >= 2 {
            return "\(components.month) months ago"
        } else if components.month! >= 1 {
            if numericDates {
                return "1 month ago"
            } else {
                return "Last month"
            }
        } else if components.weekOfYear! >= 2 {
            return "\(components.weekOfYear) weeks ago"
        } else if components.weekOfYear! >= 1 {
            if numericDates {
                return "1 week ago"
            } else {
                return "Last week"
            }
        } else if components.day! >= 2 {
            return "\(components.day) days ago"
        } else if components.day! >= 1 {
            if numericDates {
                return "1 day ago"
            } else {
                return "Yesterday"
            }
        } else if components.hour! >= 2 {
            return "\(components.hour) hours ago"
        } else if components.hour! >= 1 {
            if numericDates {
                return "1 hour ago"
            } else {
                return "An hour ago"
            }
        } else if components.minute! >= 2 {
            return "\(components.minute) minutes ago"
        } else if components.minute! >= 1 {
            if numericDates {
                return "1 minute ago"
            } else {
                return "A minute ago"
            }
        } else if components.second! >= 3 {
            return "\(components.second) seconds ago"
        } else {
            return "Just now"
        }
    }
    // swiftlint:enable cyclomatic_complexity
}

extension UIDevice {

    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8 , value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }

        switch identifier {
        case "iPod5,1": return "iPod Touch 5"
        case "iPod7,1": return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3": return "iPhone 4"
        case "iPhone4,1": return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2": return "iPhone 5"
        case "iPhone5,3", "iPhone5,4": return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2": return "iPhone 5s"
        case "iPhone7,2": return "iPhone 6"
        case "iPhone7,1": return "iPhone 6 Plus"
        case "iPhone8,1": return "iPhone 6s"
        case "iPhone8,2": return "iPhone 6s Plus"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4": return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3": return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6": return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3": return "iPad Air"
        case "iPad5,3", "iPad5,4": return "iPad Air 2"
        case "iPad2,5", "iPad2,6", "iPad2,7": return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6": return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9": return "iPad Mini 3"
        case "iPad5,1", "iPad5,2": return "iPad Mini 4"
        case "iPad6,7", "iPad6,8": return "iPad Pro"
        case "AppleTV5,3": return "Apple TV"
        case "i386", "x86_64": return "Simulator"
        default: return identifier
        }
    }
}

extension UIResponder {
    func getParentViewController() -> UIViewController? {
        if self.next is UIViewController {
            return self.next as? UIViewController
        } else {
            if self.next != nil {
                return (self.next!).getParentViewController()
            } else { return nil }
        }
    }
}

extension UIView {
    func parallax() {
        let amount = 20

        let horizontal = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        horizontal.minimumRelativeValue = -amount
        horizontal.maximumRelativeValue = amount

        let vertical = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
        vertical.minimumRelativeValue = -amount
        vertical.maximumRelativeValue = amount

        let group = UIMotionEffectGroup()
        group.motionEffects = [horizontal, vertical]
        self.addMotionEffect(group)
    }
}

extension String {
    var asName: String {
        let wordArray = self.lowercased().components(separatedBy: " ").map { $0.capitalized }
        if !wordArray.isEmpty {
            return properNameSuffix(wordArray.filter { $0 != "" }).joined(separator: " ")
        }
        return self.lowercased().capitalized
    }

    fileprivate func properNameSuffix(_ words: [String]) -> [String] {
        guard let potentialSuffix = words.last else { return words }
        var mutatingWords = words
        let lastIndex = words.count - 1
        switch potentialSuffix {
        case "Ii": mutatingWords[lastIndex] = "II"
        case "Iii": mutatingWords[lastIndex] = "III"
        case "Iv": mutatingWords[lastIndex] = "IV"
        case "Vi": mutatingWords[lastIndex] = "VI"
        default: break
        }
        return mutatingWords
    }
}

//MARK: Array Shuffle
extension Collection {
    // Return a copy of `self` with its elements shuffled
    func shuffle() -> [Iterator.Element] {
        var list = Array(self)
        list.shuffleInPlace()
        return list
    }
}

extension MutableCollection where Index == Int {
    /// Shuffle the elements of `self` in-place.
    mutating func shuffleInPlace() {
        // empty and single-element collections don't shuffle
        if count < 2 { return }

        for i in 0 ..< count.hashValue - 1 {
            let j = Int(arc4random_uniform(UInt32(count.hashValue - i))) + i
            guard i != j else { continue }
            swap(&self[i], &self[j])
        }
    }
}
