//
//  OCVMenuBuilder.swift
//  OCVSwift
//
//  Created by Eddie Seay on 3/7/16.
//  Copyright © 2016 OCV,LLC. All rights reserved.
//

import UIKit
import SnapKit

enum OCVMenuLayoutScheme {
    case threeByTwo
    case threeByThree
    case threeByFour
    case sevenButton
    case eightButton
    case elevenButton
    case hybrid
}

// swiftlint:disable cyclomatic_complexity
// swiftlint:disable function_body_length
// swiftlint:disable type_body_length
// swiftlint:disable file_length
class OCVMenuBuilder: UIView {
    var headerTitle = ""
    let sliderString: String?

    let parentMenu = OCVMainMenu()

    var transparentSpacing = 0
    
    var sliderMultiplier = 0.375
    var spacing = 15
    let devicePlatform = UIDevice.current.modelName

    init(headerTitle: String, slider: String?) {
        self.headerTitle = headerTitle
        sliderString = slider
        super.init(frame: CGRect.zero)

        if (devicePlatform == "iPhone 4") || (devicePlatform == "iPhone 4s") {
            spacing = 5
            sliderMultiplier = 0.25
        } else if (devicePlatform == "iPhone 5") || (devicePlatform == "iPhone 5s") {
            spacing = 5
            sliderMultiplier = 0.3
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func mainMenuWithScheme(_ scheme: OCVMenuLayoutScheme, items: [[String: String]]) -> UIView {
        var returnView = UIView()

        if scheme == .threeByTwo {
            if items.count != 6 {
                return UIView()
            }
            returnView = setupThreeByTwo(items)
        }

        if scheme == .threeByThree {
            if items.count != 9 {
                return UIView()
            }
            returnView = setupThreeByThree(items)
        }

        if scheme == .threeByFour {
            if items.count != 12 {
                return UIView()
            }
            returnView = setupThreeByFour(items)
        }

        if scheme == .sevenButton {
            if items.count != 7 {
                return UIView()
            }
            returnView = setupSevenButton(items)
        }

        if scheme == .eightButton {
            if items.count != 8 {
                return UIView()
            }
            returnView = setupEightButton(items)
        }

        if scheme == .elevenButton {
            if items.count != 11 {
                return UIView()
            }
            returnView = setupElevenButton(items)
        }

        if scheme == .hybrid {
            if items.count != 5 {
                return UIView()
            }
            returnView = setupHybridTop(items)
        }

        return returnView
    }

    fileprivate func setupHybridTop(_ items: [[String: String]]) -> UIView {
        var buttons: [UIButton] = []
        let buttonView = UIView()
        let returnView = UIView()

        let topRowAspect = 0.403
        let bottomRowAspect = 0.483

        returnView.addSubview(buttonView)
        
        setupSlider(returnView, buttonView: buttonView)

        for item in items {
            let newButton = OCVMainMenuButton(assetName: item["asset"]!, selectorName: item["selectorName"]!, parentMenu: parentMenu)
            buttons.append(newButton)
        }

        let topLeftButton = buttons[0]
        let topRightButton = buttons[1]
        let bottomLeftButton = buttons[2]
        let bottomMiddleButton = buttons[3]
        let bottomRightButton = buttons[4]

        buttonView.addSubview(topLeftButton)
        buttonView.addSubview(topRightButton)
        buttonView.addSubview(bottomLeftButton)
        buttonView.addSubview(bottomMiddleButton)
        buttonView.addSubview(bottomRightButton)

        if !UIDevice().modelName.contains("iPad") {
            topLeftButton.snp.makeConstraints { (make) in
                make.top.equalTo(buttonView.snp.top).priority(1000)
                make.width.equalTo(topRightButton.snp.width).priority(900)
                make.left.greaterThanOrEqualTo(buttonView.snp.left)
                make.height.equalTo(topLeftButton.snp.width).multipliedBy(topRowAspect).priority(250)
            }

            topRightButton.snp.makeConstraints { (make) in
                make.top.equalTo(buttonView.snp.top).priority(1000)
                make.left.greaterThanOrEqualTo(topLeftButton.snp.right).priority(1000)
                make.right.lessThanOrEqualTo(buttonView.snp.right)
                make.width.equalTo(topLeftButton.snp.width).priority(1000)
                make.height.equalTo(topLeftButton.snp.height).priority(1000)
            }

            bottomLeftButton.snp.makeConstraints { (make) in
                make.top.equalTo(topLeftButton.snp.bottom).priority(1000)
                make.left.greaterThanOrEqualTo(buttonView.snp.left)
                make.width.equalTo(bottomMiddleButton.snp.width).priority(900)
                make.height.equalTo(bottomLeftButton.snp.width).multipliedBy(bottomRowAspect).priority(1000)
                make.bottom.equalTo(buttonView.snp.bottom).priority(900)
            }

            bottomMiddleButton.snp.makeConstraints { (make) in
                make.top.equalTo(topLeftButton.snp.bottom).priority(1000)
                make.left.greaterThanOrEqualTo(bottomLeftButton.snp.right)
                make.width.equalTo(bottomLeftButton.snp.width).priority(1000)
                make.height.equalTo(bottomLeftButton.snp.height).priority(1000)
                make.bottom.equalTo(buttonView.snp.bottom).priority(900)
            }

            bottomRightButton.snp.makeConstraints { (make) in
                make.top.equalTo(topLeftButton.snp.bottom).priority(1000)
                make.width.equalTo(bottomLeftButton.snp.width).priority(900)
                make.left.greaterThanOrEqualTo(bottomMiddleButton.snp.right)
                make.right.lessThanOrEqualTo(buttonView.snp.right)
                make.height.equalTo(bottomLeftButton.snp.height).priority(1000)
                make.bottom.equalTo(buttonView.snp.bottom).priority(900)
            }
        } else {
            topLeftButton.contentHorizontalAlignment = .right
            topLeftButton.contentVerticalAlignment =  .center
            topLeftButton.setImage(UIImage(named: "menuNews-ipad"), for: UIControlState())
            topLeftButton.snp.makeConstraints { (make) in
                make.top.equalTo(buttonView.snp.top).priority(1000)
                make.right.equalTo(topRightButton.snp.left).priority(1000)
                make.width.equalTo(buttonView.snp.width).multipliedBy(0.2)

                make.height.equalTo(topLeftButton.snp.width).multipliedBy(topRowAspect).priority(1000)
                make.bottom.equalTo(buttonView.snp.bottom).priority(900)
            }

            topRightButton.contentHorizontalAlignment = .right
            topRightButton.contentVerticalAlignment =  .center
            topRightButton.setImage(UIImage(named: "calendar-ipad"), for: UIControlState())
            topRightButton.snp.makeConstraints { (make) in
                make.top.equalTo(buttonView.snp.top).priority(1000)
                //                make.left.equalTo(topLeftButton.snp.right).priority(1000)()
                make.right.equalTo(bottomLeftButton.snp.left).priority(1000)
                make.width.equalTo(buttonView.snp.width).multipliedBy(0.2)

                make.height.equalTo(bottomLeftButton.snp.width).multipliedBy(topRowAspect).priority(1000)
                make.bottom.equalTo(buttonView.snp.bottom).priority(900)
            }

            bottomLeftButton.contentHorizontalAlignment = .fill
            bottomLeftButton.contentVerticalAlignment =  .center
            bottomLeftButton.snp.makeConstraints { (make) in
                make.top.equalTo(buttonView.snp.top).priority(1000)
                make.left.equalTo(topRightButton.snp.right).priority(1000)
                make.right.equalTo(bottomMiddleButton.snp.left).priority(1000)
                make.centerX.equalTo(buttonView.snp.centerX)
                make.width.equalTo(buttonView.snp.width).multipliedBy(0.2)

                make.height.equalTo(bottomLeftButton.snp.width).multipliedBy(topRowAspect).priority(1000)
                make.bottom.equalTo(buttonView.snp.bottom).priority(900)
            }

            bottomMiddleButton.contentHorizontalAlignment = .left
            bottomMiddleButton.contentVerticalAlignment =  .center
            bottomMiddleButton.snp.makeConstraints { (make) in
                make.top.equalTo(buttonView.snp.top).priority(1000)
                make.left.equalTo(bottomLeftButton.snp.right).priority(1000)
                make.width.equalTo(buttonView.snp.width).multipliedBy(0.2)

                make.height.equalTo(bottomLeftButton.snp.width).multipliedBy(topRowAspect).priority(1000)
                make.bottom.equalTo(buttonView.snp.bottom).priority(900)
            }

            bottomRightButton.contentHorizontalAlignment = .left
            bottomRightButton.contentVerticalAlignment =  .center
            bottomRightButton.snp.makeConstraints { (make) in
                make.top.equalTo(buttonView.snp.top).priority(1000)
                make.left.equalTo(bottomMiddleButton.snp.right).priority(1000)
                make.width.equalTo(buttonView.snp.width).multipliedBy(0.2)

                make.height.equalTo(bottomLeftButton.snp.width).multipliedBy(topRowAspect).priority(1000)
                make.bottom.equalTo(buttonView.snp.bottom).priority(900)
            }
        }

        return returnView
    }

    fileprivate func setupThreeByTwo(_ items: [[String: String]]) -> UIView {
        var buttons = [UIButton]()
        let buttonView = UIView()
        let returnView = UIView()

        for item in items {
            let newButton = OCVMainMenuButton(assetName: item["asset"]!, selectorName: item["selectorName"]!, parentMenu: parentMenu)
            newButton.imageView?.contentMode = .scaleAspectFit
            buttons.append(newButton)
        }
        
        if Config.addBackgroundImage {
            let bgImageView: UIImageView = {
                $0.image = Config.backgroundImage
                $0.contentMode = .scaleAspectFill
                return $0
            }(UIImageView())
            
            buttonView.addSubview(bgImageView)
            
            bgImageView.snp.makeConstraints { (make) in
                make.edges.equalTo(buttonView)
            }
        }


        let button1 = buttons[0]
        buttonView.addSubview(button1)
        let button2 = buttons[1]
        buttonView.addSubview(button2)
        let button3 = buttons[2]
        buttonView.addSubview(button3)
        let button4 = buttons[3]
        buttonView.addSubview(button4)
        let button5 = buttons[4]
        buttonView.addSubview(button5)
        let button6 = buttons[5]
        buttonView.addSubview(button6)

        returnView.addSubview(buttonView)

        setupSlider(returnView, buttonView: buttonView)

        button1.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(buttonView.snp.left).offset(spacing)
            make.right.equalTo(button2.snp.left).offset(-spacing)
            make.top.equalTo(buttonView.snp.top).offset(spacing)
            make.bottom.equalTo(button4.snp.top).offset(-spacing)

            make.height.equalTo(button1.snp.width).multipliedBy(1.4).priority(900)
        }
        button2.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(button1.snp.right).offset(spacing)
            make.right.equalTo(button3.snp.left).offset(-spacing)
            make.top.equalTo(buttonView.snp.top).offset(spacing)
            make.bottom.equalTo(button5.snp.top).offset(-spacing)

            make.size.equalTo(button1).priority(900)
        }
        button3.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(button2.snp.right).offset(spacing)
            make.right.equalTo(buttonView.snp.right).offset(-spacing)
            make.top.equalTo(buttonView.snp.top).offset(spacing)
            make.bottom.equalTo(button6.snp.top).offset(-spacing)

            make.size.equalTo(button1).priority(900)
        }

        button4.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(buttonView.snp.left).offset(spacing)
            make.right.equalTo(button5.snp.left).offset(-spacing)
            make.bottom.equalTo(buttonView.snp.bottom).offset(-spacing)

            make.size.equalTo(button1).priority(900)
        }
        button5.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(button4.snp.right).offset(spacing)
            make.right.equalTo(button6.snp.left).offset(-spacing)
            make.bottom.equalTo(buttonView.snp.bottom).offset(-spacing)

            make.size.equalTo(button1).priority(900)
        }
        button6.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(button5.snp.right).offset(spacing)
            make.right.equalTo(buttonView.snp.right).offset(-spacing)
            make.bottom.equalTo(buttonView.snp.bottom).offset(-spacing)

            make.size.equalTo(button1).priority(900)
        }

        return returnView
    }

    fileprivate func setupThreeByThree(_ items: [[String: String]]) -> UIView {
        var buttons = [UIButton]()
        let buttonView = UIView()
        let returnView = UIView()

        for item in items {
            let newButton = OCVMainMenuButton(assetName: item["asset"]!, selectorName: item["selectorName"]!, parentMenu: parentMenu)
            newButton.imageView?.contentMode = .scaleAspectFit
            buttons.append(newButton)
        }
        
        if Config.addBackgroundImage {
            let bgImageView: UIImageView = {
                $0.image = Config.backgroundImage
                $0.contentMode = .scaleAspectFill
                return $0
            }(UIImageView())
            
            buttonView.addSubview(bgImageView)
            
            bgImageView.snp.makeConstraints { (make) in
                make.edges.equalTo(buttonView)
            }
        }

        let button1 = buttons[0]
        buttonView.addSubview(button1)
        let button2 = buttons[1]
        buttonView.addSubview(button2)
        let button3 = buttons[2]
        buttonView.addSubview(button3)
        let button4 = buttons[3]
        buttonView.addSubview(button4)
        let button5 = buttons[4]
        buttonView.addSubview(button5)
        let button6 = buttons[5]
        buttonView.addSubview(button6)
        let button7 = buttons[6]
        buttonView.addSubview(button7)
        let button8 = buttons[7]
        buttonView.addSubview(button8)
        let button9 = buttons[8]
        buttonView.addSubview(button9)

        returnView.addSubview(buttonView)

        setupSlider(returnView, buttonView: buttonView)

        button1.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(buttonView.snp.left).offset(spacing)
            make.right.equalTo(button2.snp.left).offset(-spacing)
            make.top.equalTo(buttonView.snp.top).offset(spacing)
            make.bottom.equalTo(button4.snp.top).offset(-spacing)

            make.height.equalTo(button1.snp.width).multipliedBy(1.4).priority(900)
        }
        button2.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(button1.snp.right).offset(spacing)
            make.right.equalTo(button3.snp.left).offset(-spacing)
            make.top.equalTo(buttonView.snp.top).offset(spacing)
            make.bottom.equalTo(button5.snp.top).offset(-spacing)

            make.size.equalTo(button1).priority(900)
        }
        button3.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(button2.snp.right).offset(spacing)
            make.right.equalTo(buttonView.snp.right).offset(-spacing)
            make.top.equalTo(buttonView.snp.top).offset(spacing)
            make.bottom.equalTo(button6.snp.top).offset(-spacing)

            make.size.equalTo(button1).priority(900)
        }

        button4.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(buttonView.snp.left).offset(spacing)
            make.right.equalTo(button5.snp.left).offset(-spacing)

            make.size.equalTo(button1).priority(900)
        }
        button5.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(button4.snp.right).offset(spacing)
            make.right.equalTo(button6.snp.left).offset(-spacing)

            make.size.equalTo(button1).priority(900)
        }
        button6.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(button5.snp.right).offset(spacing)
            make.right.equalTo(buttonView.snp.right).offset(-spacing)

            make.size.equalTo(button1).priority(900)
        }

        button7.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(buttonView.snp.left).offset(spacing)
            make.right.equalTo(button8.snp.left).offset(-spacing)
            make.top.equalTo(button4.snp.bottom).offset(spacing)
            make.bottom.equalTo(buttonView.snp.bottom).offset(-spacing)

            make.size.equalTo(button1).priority(900)
        }
        button8.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(button7.snp.right).offset(spacing)
            make.right.equalTo(button9.snp.left).offset(-spacing)
            make.top.equalTo(button5.snp.bottom).offset(spacing)
            make.bottom.equalTo(buttonView.snp.bottom).offset(-spacing)

            make.size.equalTo(button1).priority(900)
        }
        button9.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(button8.snp.right).offset(spacing)
            make.right.equalTo(buttonView.snp.right).offset(-spacing)
            make.top.equalTo(button6.snp.bottom).offset(spacing)
            make.bottom.equalTo(buttonView.snp.bottom).offset(-spacing)

            make.size.equalTo(button1).priority(900)
        }

        return returnView
    }

    fileprivate func setupThreeByFour(_ items: [[String: String]]) -> UIView {
        var buttons = [UIButton]()
        let buttonView = UIView()
        let returnView = UIView()

        for item in items {
            let newButton = OCVMainMenuButton(assetName: item["asset"]!, selectorName: item["selectorName"]!, parentMenu: parentMenu)
            newButton.imageView?.contentMode = .scaleAspectFit
            buttons.append(newButton)
        }
        
        if Config.addBackgroundImage {
            let bgImageView: UIImageView = {
                $0.image = Config.backgroundImage
                $0.contentMode = .scaleAspectFill
                return $0
            }(UIImageView())
            
            buttonView.addSubview(bgImageView)
            
            bgImageView.snp.makeConstraints { (make) in
                make.edges.equalTo(buttonView)
            }
        }

        let button1 = buttons[0]
        buttonView.addSubview(button1)
        let button2 = buttons[1]
        buttonView.addSubview(button2)
        let button3 = buttons[2]
        buttonView.addSubview(button3)
        let button4 = buttons[3]
        buttonView.addSubview(button4)
        let button5 = buttons[4]
        buttonView.addSubview(button5)
        let button6 = buttons[5]
        buttonView.addSubview(button6)
        let button7 = buttons[6]
        buttonView.addSubview(button7)
        let button8 = buttons[7]
        buttonView.addSubview(button8)
        let button9 = buttons[8]
        buttonView.addSubview(button9)
        let button10 = buttons[9]
        buttonView.addSubview(button10)
        let button11 = buttons[10]
        buttonView.addSubview(button11)
        let button12 = buttons[11]
        buttonView.addSubview(button12)

        returnView.addSubview(buttonView)

        setupSlider(returnView, buttonView: buttonView)

        button1.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(buttonView.snp.left).offset(spacing)
            make.right.equalTo(button2.snp.left).offset(-spacing)
            make.top.equalTo(buttonView.snp.top).offset(spacing)
            make.bottom.equalTo(button4.snp.top).offset(-spacing)

            make.height.equalTo(button1.snp.width).multipliedBy(1.4).priority(900)
        }
        button2.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(button1.snp.right).offset(spacing)
            make.right.equalTo(button3.snp.left).offset(-spacing)
            make.top.equalTo(buttonView.snp.top).offset(spacing)
            make.bottom.equalTo(button5.snp.top).offset(-spacing)

            make.size.equalTo(button1).priority(900)
        }
        button3.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(button2.snp.right).offset(spacing)
            make.right.equalTo(buttonView.snp.right).offset(-spacing)
            make.top.equalTo(buttonView.snp.top).offset(spacing)
            make.bottom.equalTo(button6.snp.top).offset(-spacing)

            make.size.equalTo(button1).priority(900)
        }

        button4.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(buttonView.snp.left).offset(spacing)
            make.right.equalTo(button5.snp.left).offset(-spacing)

            make.size.equalTo(button1).priority(900)
        }
        button5.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(button4.snp.right).offset(spacing)
            make.right.equalTo(button6.snp.left).offset(-spacing)

            make.size.equalTo(button1).priority(900)
        }
        button6.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(button5.snp.right).offset(spacing)
            make.right.equalTo(buttonView.snp.right).offset(-spacing)

            make.size.equalTo(button1).priority(900)
        }

        button7.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(buttonView.snp.left).offset(spacing)
            make.right.equalTo(button8.snp.left).offset(-spacing)
            make.top.equalTo(button4.snp.bottom).offset(spacing)

            make.size.equalTo(button1).priority(900)
        }
        button8.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(button7.snp.right).offset(spacing)
            make.right.equalTo(button9.snp.left).offset(-spacing)
            make.top.equalTo(button5.snp.bottom).offset(spacing)

            make.size.equalTo(button1).priority(900)
        }
        button9.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(button8.snp.right).offset(spacing)
            make.right.equalTo(buttonView.snp.right).offset(-spacing)
            make.top.equalTo(button6.snp.bottom).offset(spacing)

            make.size.equalTo(button1).priority(900)
        }

        button10.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(buttonView.snp.left).offset(spacing)
            make.right.equalTo(button8.snp.left).offset(-spacing)
            make.top.equalTo(button7.snp.bottom).offset(spacing)
            make.bottom.equalTo(buttonView.snp.bottom).offset(-spacing)

            make.size.equalTo(button1).priority(900)
        }
        button11.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(button7.snp.right).offset(spacing)
            make.right.equalTo(button9.snp.left).offset(-spacing)
            make.top.equalTo(button8.snp.bottom).offset(spacing)
            make.bottom.equalTo(buttonView.snp.bottom).offset(-spacing)

            make.size.equalTo(button1).priority(900)
        }
        button12.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(button8.snp.right).offset(spacing)
            make.right.equalTo(buttonView.snp.right).offset(-spacing)
            make.top.equalTo(button9.snp.bottom).offset(spacing)
            make.bottom.equalTo(buttonView.snp.bottom).offset(-spacing)

            make.size.equalTo(button1).priority(900)
        }

        return returnView
    }

    fileprivate func setupSevenButton(_ items: [[String: String]]) -> UIView {
        var buttons = [UIButton]()
        let buttonView = UIView()
        let returnView = UIView()

        for item in items {
            let newButton = OCVMainMenuButton(assetName: item["asset"]!, selectorName: item["selectorName"]!, parentMenu: parentMenu)
            newButton.imageView?.contentMode = .scaleAspectFit
            buttons.append(newButton)
        }
        
        if Config.addBackgroundImage {
            let bgImageView: UIImageView = {
                $0.image = Config.backgroundImage
                $0.contentMode = .scaleAspectFill
                return $0
            }(UIImageView())
            
            buttonView.addSubview(bgImageView)
            
            bgImageView.snp.makeConstraints { (make) in
                make.edges.equalTo(buttonView)
            }
        }

        let button1 = buttons[0]
        buttonView.addSubview(button1)
        let button2 = buttons[1]
        buttonView.addSubview(button2)
        let button3 = buttons[2]
        buttonView.addSubview(button3)
        let button4 = buttons[3]
        buttonView.addSubview(button4)
        let button5 = buttons[4]
        buttonView.addSubview(button5)
        let button6 = buttons[5]
        buttonView.addSubview(button6)
        let button7 = buttons[6]
        buttonView.addSubview(button7)

        returnView.addSubview(buttonView)

        setupSlider(returnView, buttonView: buttonView)

        button1.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(buttonView.snp.left).offset(spacing)
            make.right.equalTo(button2.snp.left).offset(-spacing)
            make.top.equalTo(buttonView.snp.top).offset(spacing)
            make.bottom.equalTo(button4.snp.top).offset(-spacing)

            make.height.equalTo(button1.snp.width).multipliedBy(1.4).priority(900)
        }
        button2.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(button1.snp.right).offset(spacing)
            make.right.equalTo(button3.snp.left).offset(-spacing)
            make.top.equalTo(buttonView.snp.top).offset(spacing)
            make.bottom.equalTo(button5.snp.top).offset(-spacing)

            make.width.equalTo(button1).priority(900)
            make.height.equalTo(button7).priority(1000)
        }
        button3.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(button2.snp.right).offset(spacing)
            make.right.equalTo(buttonView.snp.right).offset(-spacing)
            make.top.equalTo(buttonView.snp.top).offset(spacing)
            make.bottom.equalTo(button6.snp.top).offset(-spacing)

            make.width.equalTo(button1).priority(900)
            make.height.equalTo(button7).priority(1000)
        }

        button4.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(buttonView.snp.left).offset(spacing)
            make.right.equalTo(button5.snp.left).offset(-spacing)
            make.top.equalTo(button1.snp.bottom).offset(spacing)

            make.width.equalTo(button1).priority(900)
            make.height.equalTo(button7).priority(1000)
        }
        button5.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(button4.snp.right).offset(spacing)
            make.right.equalTo(button6.snp.left).offset(-spacing)
            make.top.equalTo(button2.snp.bottom).offset(spacing)

            make.width.equalTo(button1).priority(900)
            make.height.equalTo(button7).priority(1000)
        }
        button6.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(button5.snp.right).offset(spacing)
            make.right.equalTo(buttonView.snp.right).offset(-spacing)
            make.top.equalTo(button3.snp.bottom).offset(spacing)

            make.width.equalTo(button1).priority(900)
            make.height.equalTo(button7).priority(1000)
        }

        button7.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(buttonView.snp.left).offset(spacing)
            make.right.equalTo(buttonView.snp.right).offset(-spacing)
            make.bottom.equalTo(buttonView.snp.bottom).offset(-spacing)
            make.top.equalTo(button5.snp.bottom).offset(spacing)

            make.height.equalTo(button1).priority(1000)
        }

        return returnView
    }

    fileprivate func setupEightButton(_ items: [[String: String]]) -> UIView {
        var buttons = [UIButton]()
        let buttonView = UIView()
        let returnView = UIView()

        for item in items {
            let newButton = OCVMainMenuButton(assetName: item["asset"]!, selectorName: item["selectorName"]!, parentMenu: parentMenu)
            buttons.append(newButton)
        }
        
        if Config.addBackgroundImage {
            let bgImageView: UIImageView = {
                $0.image = Config.backgroundImage
                $0.contentMode = .scaleAspectFill
                return $0
            }(UIImageView())
            
            buttonView.addSubview(bgImageView)
            
            bgImageView.snp.makeConstraints { (make) in
                make.edges.equalTo(buttonView)
            }
        }

        let button1 = buttons[0]
        buttonView.addSubview(button1)
        let button2 = buttons[1]
        buttonView.addSubview(button2)
        let button3 = buttons[2]
        buttonView.addSubview(button3)
        let button4 = buttons[3]
        buttonView.addSubview(button4)
        let button5 = buttons[4]
        buttonView.addSubview(button5)
        let button6 = buttons[5]
        buttonView.addSubview(button6)
        let button7 = buttons[6]
        buttonView.addSubview(button7)
        let button8 = buttons[7]
        buttonView.addSubview(button8)

        returnView.addSubview(buttonView)

        setupSlider(returnView, buttonView: buttonView)

        button1.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(buttonView.snp.left).offset(spacing)
            make.right.equalTo(button2.snp.left).offset(-spacing)
            make.top.equalTo(buttonView.snp.top).offset(spacing)
            make.bottom.equalTo(button4.snp.top).offset(-spacing)

            make.height.equalTo(button1.snp.width).multipliedBy(1.4).priority(900)
        }
        button2.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(button1.snp.right).offset(spacing)
            make.right.equalTo(button3.snp.left).offset(-spacing)
            make.top.equalTo(buttonView.snp.top).offset(spacing)
            make.bottom.equalTo(button5.snp.top).offset(-spacing)

            make.width.equalTo(button1).priority(900)
            make.height.equalTo(button7).priority(1000)
        }
        button3.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(button2.snp.right).offset(spacing)
            make.right.equalTo(buttonView.snp.right).offset(-spacing)
            make.top.equalTo(buttonView.snp.top).offset(spacing)
            make.bottom.equalTo(button6.snp.top).offset(-spacing)

            make.width.equalTo(button1).priority(900)
            make.height.equalTo(button7).priority(1000)
        }

        button4.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(buttonView.snp.left).offset(spacing)
            make.right.equalTo(button5.snp.left).offset(-spacing)
            make.top.equalTo(button1.snp.bottom).offset(spacing)

            make.width.equalTo(button1).priority(900)
            make.height.equalTo(button7).priority(1000)
        }
        button5.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(button4.snp.right).offset(spacing)
            make.right.equalTo(button6.snp.left).offset(-spacing)
            make.top.equalTo(button2.snp.bottom).offset(spacing)

            make.width.equalTo(button1).priority(900)
            make.height.equalTo(button7).priority(1000)
        }
        button6.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(button5.snp.right).offset(spacing)
            make.right.equalTo(buttonView.snp.right).offset(-spacing)
            make.top.equalTo(button3.snp.bottom).offset(spacing)

            make.width.equalTo(button1).priority(900)
            make.height.equalTo(button7).priority(1000)
        }

        button7.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(buttonView.snp.left).offset(spacing)
            make.right.equalTo(button8.snp.left).offset(-spacing)
            make.bottom.equalTo(buttonView.snp.bottom).offset(-spacing)
            make.top.equalTo(button5.snp.bottom).offset(spacing)

            make.height.equalTo(button1).priority(1000)
            make.width.equalTo(button8).priority(900)
        }
        button8.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(button7.snp.right).offset(spacing)
            make.right.equalTo(buttonView.snp.right).offset(-spacing)
            make.bottom.equalTo(buttonView.snp.bottom).offset(-spacing)
            make.top.equalTo(button5.snp.bottom).offset(spacing)

            make.height.equalTo(button1).priority(1000)
            make.width.equalTo(button7).priority(900)
        }

        return returnView
    }

    fileprivate func setupElevenButton(_ items: [[String: String]]) -> UIView {
        var buttons = [UIButton]()
        let buttonView = UIView()
        let returnView = UIView()

        for item in items {
            let newButton = OCVMainMenuButton(assetName: item["asset"]!, selectorName: item["selectorName"]!, parentMenu: parentMenu)
            newButton.imageView?.contentMode = .scaleAspectFit
            buttons.append(newButton)
        }
        
        if Config.addBackgroundImage {
            let bgImageView: UIImageView = {
                $0.image = Config.backgroundImage
                $0.contentMode = .scaleAspectFill
                return $0
            }(UIImageView())
            
            buttonView.addSubview(bgImageView)
            
            bgImageView.snp.makeConstraints { (make) in
                make.edges.equalTo(buttonView)
            }
        }

        let button1 = buttons[0]
        buttonView.addSubview(button1)
        let button2 = buttons[1]
        buttonView.addSubview(button2)
        let button3 = buttons[2]
        buttonView.addSubview(button3)
        let button4 = buttons[3]
        buttonView.addSubview(button4)
        let button5 = buttons[4]
        buttonView.addSubview(button5)
        let button6 = buttons[5]
        buttonView.addSubview(button6)
        let button7 = buttons[6]
        buttonView.addSubview(button7)
        let button8 = buttons[7]
        buttonView.addSubview(button8)
        let button9 = buttons[8]
        buttonView.addSubview(button9)
        let button10 = buttons[9]
        buttonView.addSubview(button10)
        let button11 = buttons[10]
        buttonView.addSubview(button11)

        returnView.addSubview(buttonView)

        setupSlider(returnView, buttonView: buttonView)

        button1.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(buttonView.snp.left).offset(spacing)
            make.right.equalTo(button2.snp.left).offset(-spacing)
            make.top.equalTo(buttonView.snp.top).offset(spacing)
            make.bottom.equalTo(button4.snp.top).offset(-spacing)

            make.height.equalTo(button1.snp.width).multipliedBy(1.4).priority(900)
        }
        button2.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(button1.snp.right).offset(spacing)
            make.right.equalTo(button3.snp.left).offset(-spacing)
            make.top.equalTo(buttonView.snp.top).offset(spacing)
            make.bottom.equalTo(button5.snp.top).offset(-spacing)

            make.size.equalTo(button1).priority(900)
        }
        button3.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(button2.snp.right).offset(spacing)
            make.right.equalTo(buttonView.snp.right).offset(-spacing)
            make.top.equalTo(buttonView.snp.top).offset(spacing)
            make.bottom.equalTo(button6.snp.top).offset(-spacing)

            make.size.equalTo(button1).priority(900)
        }

        button4.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(buttonView.snp.left).offset(spacing)
            make.right.equalTo(button5.snp.left).offset(-spacing)

            make.size.equalTo(button1).priority(900)
        }
        button5.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(button4.snp.right).offset(spacing)
            make.right.equalTo(button6.snp.left).offset(-spacing)

            make.size.equalTo(button1).priority(900)
        }
        button6.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(button5.snp.right).offset(spacing)
            make.right.equalTo(buttonView.snp.right).offset(-spacing)

            make.size.equalTo(button1).priority(900)
        }

        button7.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(buttonView.snp.left).offset(spacing)
            make.right.equalTo(button8.snp.left).offset(-spacing)
            make.top.equalTo(button4.snp.bottom).offset(spacing)

            make.size.equalTo(button1).priority(900)
        }
        button8.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(button7.snp.right).offset(spacing)
            make.right.equalTo(button9.snp.left).offset(-spacing)
            make.top.equalTo(button5.snp.bottom).offset(spacing)

            make.size.equalTo(button1).priority(900)
        }
        button9.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(button8.snp.right).offset(spacing)
            make.right.equalTo(buttonView.snp.right).offset(-spacing)
            make.top.equalTo(button6.snp.bottom).offset(spacing)

            make.size.equalTo(button1).priority(900)
        }

        button10.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(buttonView.snp.left).offset(spacing)
            make.right.equalTo(button11.snp.left).offset(-spacing)
            make.top.equalTo(button7.snp.bottom).offset(spacing)
            make.bottom.equalTo(buttonView.snp.bottom).offset(-spacing)

            make.width.equalTo(button11).priority(900)
            make.height.equalTo(button1).priority(900)
        }
        button11.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(button10.snp.right).offset(spacing)
            make.right.equalTo(buttonView.snp.right).offset(-spacing)
            make.top.equalTo(button8.snp.bottom).offset(spacing)
            make.bottom.equalTo(buttonView.snp.bottom).offset(-spacing)

            make.width.equalTo(button10).priority(900)
            make.height.equalTo(button1).priority(900)
        }

        return returnView
    }

    fileprivate func setupSlider(_ returnView: UIView, buttonView: UIView) {
        if sliderString != nil {
            let slider = OCVSlideshow(url: sliderString!, shuffle: true)
            returnView.addSubview(slider)

            if Config.transparentNavBar && !Config.addWeatherWidget {
                transparentSpacing = 64
            }
            
            slider.snp.makeConstraints({ (make) -> Void in
                make.top.equalTo(returnView).offset(transparentSpacing)
                make.left.equalTo(returnView.snp.left)
                make.right.equalTo(returnView.snp.right)
                make.height.equalTo(returnView.snp.width).multipliedBy(sliderMultiplier)
            })

            buttonView.snp.makeConstraints({ (make) -> Void in
                make.top.equalTo(slider.snp.bottom)
                make.left.equalTo(returnView.snp.left)
                make.right.equalTo(returnView.snp.right)
                make.bottom.equalTo(returnView.snp.bottom)
            })
        } else {
            
            if Config.transparentNavBar && !Config.addWeatherWidget {
                transparentSpacing = 64
            }
            
            buttonView.snp.makeConstraints({ (make) -> Void in
                make.top.equalTo(returnView).offset(transparentSpacing)
                make.left.equalTo(returnView.snp.left)
                make.right.equalTo(returnView.snp.right)
                make.bottom.equalTo(returnView.snp.bottom)
            })
        }
    }
}

class OCVMainMenuButton: UIButton {
    init(assetName: String, selectorName: String, parentMenu: UIViewController) {
        super.init(frame: CGRect.zero)

        self.imageView?.contentMode = .scaleAspectFit

        if let buttonImage = UIImage(named: assetName) {
            self.setImage(buttonImage, for: UIControlState())
        }

        if parentMenu.responds(to: Selector(selectorName)) {
            self.addTarget(superview?.superview?.superview?.superview, action: Selector(selectorName), for: .touchUpInside)
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
