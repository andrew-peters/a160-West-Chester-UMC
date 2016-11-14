//
//  WeatherStylesheet.swift
//  OCVSwift
//
//  Created by Eddie Seay on 6/9/16.
//  Copyright © 2016 OCV,LLC. All rights reserved.
//

import UIKit
//import Chameleon

enum WeatherColors {
    case primary
    case text
    case oppositeOfPrimary
    case standardWhite
    case standardBlack

    var color: UIColor {
        switch self {
        case .primary: return UIColor.flatNavyBlueColorDark()
        case .text: return UIColor.white//ContrastColorOf(UIColor.flatNavyBlueColorDark(), returnFlat: true)
        case .oppositeOfPrimary: return UIColor.white//ContrastColorOf(UIColor.flatNavyBlueColorDark(), returnFlat: false)
        case .standardWhite: return UIColor.flatWhite()
        case .standardBlack: return UIColor.flatBlackColorDark()
        }
    }

    func alpha(_ alpha: Double) -> UIColor {
        return color.withAlphaComponent(CGFloat(alpha))
    }
}
