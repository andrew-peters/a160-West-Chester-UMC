//
//  OCVDrawerVisualStateManager.swift
//  OCVSwift
//
//  Created by Eddie Seay on 3/2/16.
//  Copyright © 2016 OCV,LLC. All rights reserved.
//
//  BASED ON: ExampleDrawerVisualStateManager by evolved.io

import UIKit
import DrawerController

enum CenterViewControllerSection: Int {
    case leftViewState
    case leftDrawerAnimation
    case rightViewState
    case rightDrawerAnimation
}

enum DrawerAnimationType: Int {
    case none
    case slide
    case slideAndScale
    case swingingDoor
    case parallax
    case animatedBarButton
}

class OCVDrawerVisualStateManager: NSObject {
    var leftDrawerAnimationType: DrawerAnimationType = .parallax
    var rightDrawerAnimationType: DrawerAnimationType = .parallax

    class var sharedManager: OCVDrawerVisualStateManager {
        struct Static {
            static let Instance: OCVDrawerVisualStateManager = OCVDrawerVisualStateManager()
        }

        return Static.Instance
    }

    // swiftlint:disable:next cyclomatic_complexity
    func drawerVisualStateBlockForDrawerSide(_ drawerSide: DrawerSide) -> DrawerControllerDrawerVisualStateBlock? {
        var animationType: DrawerAnimationType

        if drawerSide == DrawerSide.left {
            animationType = self.leftDrawerAnimationType
        } else {
            animationType = self.rightDrawerAnimationType
        }

        var visualStateBlock: DrawerControllerDrawerVisualStateBlock?

        switch animationType {
        case .slide:
            visualStateBlock = DrawerVisualState.slideVisualStateBlock
        case .slideAndScale:
            visualStateBlock = DrawerVisualState.slideAndScaleVisualStateBlock
        case .parallax:
            visualStateBlock = DrawerVisualState.parallaxVisualStateBlock(parallaxFactor: 2.0)
        case .swingingDoor:
            visualStateBlock = DrawerVisualState.swingingDoorVisualStateBlock
        case .animatedBarButton:
            visualStateBlock = DrawerVisualState.animatedHamburgerButtonVisualStateBlock
        default:
            visualStateBlock = { drawerController, drawerSide, percentVisible in
                var sideDrawerViewController: UIViewController?
                var transform = CATransform3DIdentity
                var maxDrawerWidth: CGFloat = 0.0

                if drawerSide == .left {
                    sideDrawerViewController = drawerController.leftDrawerViewController
                    maxDrawerWidth = drawerController.maximumLeftDrawerWidth
                } else if drawerSide == .right {
                    sideDrawerViewController = drawerController.rightDrawerViewController
                    maxDrawerWidth = drawerController.maximumRightDrawerWidth
                }

                if percentVisible > 1.0 {
                    transform = CATransform3DMakeScale(percentVisible, 1.0, 1.0)

                    if drawerSide == .left {
                        transform = CATransform3DTranslate(transform, maxDrawerWidth * (percentVisible - 1.0) / 2, 0.0, 0.0)
                    } else if drawerSide == .right {
                        transform = CATransform3DTranslate(transform, -maxDrawerWidth * (percentVisible - 1.0) / 2, 0.0, 0.0)
                    }
                }

                sideDrawerViewController?.view.layer.transform = transform
            }
        }

        return visualStateBlock
    }
}
