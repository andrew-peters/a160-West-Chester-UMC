//
//  OCVDetail.swift
//  OCVSwift
//
//  Created by Eddie Seay on 1/18/16.
//  Copyright © 2016 OCV,LLC. All rights reserved.
//

import UIKit
import SnapKit
import STPopup

import WebKit

class OCVDetail: UIViewController {

    let detailTitle: String!
    let detailDesc: String!
    let detailContent: String!
    let detailDate: String!
    let detailImages: [AnyObject]!
    let detailTextLabel: UITextView = {
        $0.isEditable = false
        $0.isSelectable = true
        $0.dataDetectorTypes = .all
        $0.isScrollEnabled = true
        $0.backgroundColor = UIColor.clear
        return $0
    }(UITextView())

    let fontToolBar: UIToolbar = {
        $0.isTranslucent = false
        $0.tintColor = AppColors.text.color
        return $0
    }(UIToolbar())

    let fontSlider: UISlider = {
        $0.minimumValue = 14.0
        $0.maximumValue = 24.0
        return $0
    }(UISlider())

    var fontSliderButtonItem = UIBarButtonItem()
    let fontSizeLabel: UILabel = {
        $0.frame = CGRect(x: 0, y: 0, width: 22, height: 22)
        $0.font = AppFonts.RegularText.font(14)
        $0.textAlignment = .center
        $0.textColor = AppColors.text.color
        return $0
    }(UILabel())

    var fontSizeButtonItem = UIBarButtonItem()
    var currentFontSize: Float = 14.0

    var dateLabel: UILabel = {
        $0.font = AppFonts.RegularText.font(14)
        $0.textColor = AppColors.text.color
        $0.numberOfLines = 1
        return $0
    }(UILabel())

    let titleLabel: UILabel = {
        $0.font = AppFonts.SemiboldText.font(28)
        $0.numberOfLines = 0
        return $0
    }(UILabel())

    let imageStack = UIStackView()

    var runWebview = false

    init(object: OCVTableObject) {
        detailTitle = object.title
        detailDesc = object.description
        detailContent = object.content
        detailDate = object.date
        detailImages = object.images

        super.init(nibName: nil, bundle: nil)
    }

    convenience init(object: OCVTableObject, inWebView: Bool) {
        self.init(object: object)
        runWebview = inWebView
    }

    init(object: OCVMessageObject) {
        detailTitle = object.title
        detailDesc = "Channel: " + object.channelTitle + "\n\n" + object.description
        detailContent = ""
        detailDate = DateFormatter.localizedString(from: object.date as Date, dateStyle: .long, timeStyle: .short)
        detailImages = []

        super.init(nibName: nil, bundle: nil)
    }

    init(object: OCVDigestObject) {
        detailTitle = object.title
        detailDesc = object.summary
        detailContent = object.content
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        detailDate = dateFormatter.string(from: object.date as Date)
        detailImages = []

        super.init(nibName: nil, bundle: nil)
    }


    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = AppColors.standardWhite.color
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(OCVDetail.share))

        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            contentSizeInPopup = CGSize(width: UIScreen.main.bounds.size.width * 0.90, height: UIScreen.main.bounds.size.height * 0.90)
            landscapeContentSizeInPopup = CGSize(width: UIScreen.main.bounds.size.width * 0.90, height: UIScreen.main.bounds.size.height * 0.65)
        } else {
            contentSizeInPopup = CGSize(width: UIScreen.main.bounds.size.width * 0.90, height: UIScreen.main.bounds.size.height * 0.85)
            landscapeContentSizeInPopup = CGSize(width: UIScreen.main.bounds.size.width * 0.90, height: UIScreen.main.bounds.size.height * 0.90)
        }

        if runWebview == false {
            configureDetailView()
        } else {
            setupDetailAsWebview()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func share() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy"
        
        var shareDescription = "\(detailTitle)\n\n\(detailDesc)"
        if detailImages != nil && detailImages?.isEmpty == false {
            shareDescription.append("\nView Image(s) at:")
            for detail in detailImages {
                shareDescription.append("\n\(detail)")
            }
        }
        if detailDate != nil {
            shareDescription.append("\n\n\(detailDate)")
        }
        shareDescription.append("\n\nShared from the \(Config.appName) app at \(Config.shareLink)")
        let myActivityController = UIActivityViewController(activityItems: [shareDescription], applicationActivities: nil)
        myActivityController.modalPresentationStyle = .popover
        myActivityController.popoverPresentationController?.sourceView = self.view
        myActivityController.popoverPresentationController?.permittedArrowDirections = .any
        
        self.present(myActivityController, animated: true, completion: nil)
    }

    // swiftlint:disable:next function_body_length
    func configureDetailView() {
        titleLabel.text = detailTitle

        dateLabel.frame = CGRect(x: 0, y: 0, width: view.frame.size.width * 0.75, height: 22)
        dateLabel.text = detailDate

        fontSizeLabel.text = String(Int(fontSlider.value))

        let pageBreak: UIView = {
            $0.backgroundColor = AppColors.secondary.color
            return $0
        }(UIView())

        view.addSubview(titleLabel)
        view.addSubview(pageBreak)
        view.addSubview(detailTextLabel)
        view.addSubview(fontToolBar)

        titleLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(view.snp.top).offset(8)
            make.left.equalTo(view.snp.left).offset(5)
            make.right.equalTo(view.snp.rightMargin)
        }

        pageBreak.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(2)
            make.top.equalTo(titleLabel.snp.bottom).offset(2)
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right).offset(-20)
        }

        detailTextLabel.font = AppFonts.RegularText.font(currentFontSize)
        if detailContent != "" {
            if let html = detailContent {
                let detailAttributedTextString = attributedTextStringFromHTMLString(html.stringByDecodingHTMLEntities)
                detailTextLabel.attributedText = detailAttributedTextString
            }
        } else {
            detailTextLabel.text = detailDesc
        }

        detailTextLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(pageBreak.snp.bottom)
            make.left.equalTo(view.snp.left).offset(5)
            make.right.equalTo(view.snp.right).offset(-5)
        }

        fontToolBar.barTintColor = navigationController?.navigationBar.barTintColor
        fontSlider.addTarget(self, action: #selector(OCVDetail.changeFontToSliderValue), for: UIControlEvents.valueChanged)
        fontSliderButtonItem = UIBarButtonItem(customView: fontSlider)
        fontSliderButtonItem.width = self.view.frame.size.width * 0.75
        fontToolBar.items = toolBarItemsWithDate()
        fontSizeButtonItem = UIBarButtonItem(customView: fontSizeLabel)

        fontToolBar.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
            make.bottom.equalTo(view.snp.bottom)
            make.height.equalTo(44)
        }

        if !self.detailImages.isEmpty {
            imageStack.axis = .horizontal
            imageStack.distribution = .fillEqually
            imageStack.alignment = .fill
            imageStack.spacing = 5
            imageStack.translatesAutoresizingMaskIntoConstraints = false
            imageStack.backgroundColor = AppColors.background.color

            view.addSubview(imageStack)

            for i in 0 ..< self.detailImages!.count {
                var url: URL?
                if let imageURL = detailImages?[i]["large"] as? String {
                    url = URL(string: imageURL)

                    let imageButtonView = UIView(frame: CGRect(x: 0, y: 0, width: 135, height: 135))

                    let imageButton: CustomImageButton = {
                        $0.backgroundColor = UIColor.clear
                        $0.addTarget(self, action: #selector(OCVDetail.openWebviewToImage(_: )), for: .touchUpInside)
                        return $0
                    }(CustomImageButton(frame: imageButtonView.frame, urlToOpen: imageURL))

                    let newImageView: UIImageView = {
                        $0.frame = CGRect(x: 0, y: 0, width: 135, height: 135)
                        $0.contentMode = .scaleAspectFill
                        $0.clipsToBounds = true
                        $0.af_setImage(withURL: url!, placeholderImage: UIImage(named: "logo"))
                        return $0
                    }(UIImageView())

                    imageButtonView.addSubview(newImageView)
                    imageButtonView.addSubview(imageButton)

                    imageButton.snp.makeConstraints { (make) -> Void in
                        make.edges.equalTo(imageButtonView)
                    }
                    newImageView.snp.makeConstraints { (make) -> Void in
                        make.edges.equalTo(imageButtonView)
                    }

                    imageStack.addArrangedSubview(imageButtonView)
                }
            }

            imageStack.setContentCompressionResistancePriority(1000, for: UILayoutConstraintAxis.vertical)
            imageStack.snp.makeConstraints { (make) -> Void in
                make.top.equalTo(detailTextLabel.snp.bottom).offset(5)
                make.left.equalTo(self.view.snp.left).offset(5)
                make.right.equalTo(self.view.snp.right).offset(-5)
                make.bottom.equalTo(fontToolBar.snp.top).offset(-5).priority(900)
                make.height.equalTo(self.view).multipliedBy(0.15)
            }
        } else {
            detailTextLabel.snp.remakeConstraints { (make) -> Void in
                make.top.equalTo(pageBreak.snp.bottom)
                make.left.equalTo(self.view.snp.left).offset(5)
                make.right.equalTo(self.view.snp.right).offset(-5)
                make.bottom.equalTo(fontToolBar.snp.top).offset(-5).priority(900)
            }
        }

        self.view.layoutSubviews()
    }

    func setupDetailAsWebview() {
        let detailWebView = WKWebView()
        if let htmlString = detailContent {
            detailWebView.loadHTMLString(htmlString, baseURL: nil)
        }
        self.view = detailWebView
    }

    func changeFontToSliderValue() {
        detailTextLabel.isEditable = true
        currentFontSize = fontSlider.value
        detailTextLabel.font = AppFonts.RegularText.font(currentFontSize)
        fontSizeLabel.text = String(Int(currentFontSize))
        detailTextLabel.isEditable = false
        self.view.setNeedsLayout()
    }

    func showSlider() {
        fontToolBar.items = toolBarItemsWithSlider()
    }

    func showDate() {
        fontToolBar.items = toolBarItemsWithDate()
    }

    func toolBarItemsWithDate() -> [UIBarButtonItem] {
        let dateView = UIBarButtonItem(customView: dateLabel)
        let fontButton = UIBarButtonItem(image: UIImage(named: "fontSize"), style: .plain, target: self, action: #selector(OCVDetail.showSlider))
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        return [dateView, flex, fontButton]
    }

    func toolBarItemsWithSlider() -> [UIBarButtonItem] {
        let dateButton = UIBarButtonItem(image: UIImage(named: "dateTimeClock"), style: .plain, target: self, action: #selector(OCVDetail.showDate))
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        return [fontSizeButtonItem, flex, fontSliderButtonItem, flex, flex, dateButton]
    }

    func attributedTextStringFromHTMLString(_ htmlString: String) -> NSMutableAttributedString {

        var attrib = NSMutableAttributedString()
        do {
            attrib = try NSMutableAttributedString(data: htmlString.data(using: String.Encoding.unicode, allowLossyConversion: true)!, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil)
        } catch {
            print(error)
        }

        let fontSize: Float = 14.0

        attrib.beginEditing()
        // swiftlint:disable:next legacy_constructor
        attrib.enumerateAttribute(NSFontAttributeName, in: NSMakeRange(0, attrib.length), options: NSAttributedString.EnumerationOptions.longestEffectiveRangeNotRequired) { (fontValue, myRange, stop) -> Void in
            if fontValue != nil {
                let oldFont = fontValue
                attrib.removeAttribute(NSFontAttributeName, range: myRange)

                if (oldFont as AnyObject).fontName == "TimesNewRomanPSMT" {
                    attrib.addAttribute(NSFontAttributeName, value: AppFonts.RegularText.font(fontSize), range: myRange)
                } else if (oldFont as AnyObject).fontName == "TimesNewRomanPS-BoldMT" {
                    attrib.addAttribute(NSFontAttributeName, value: AppFonts.BoldText.font(fontSize), range: myRange)
                } else if (oldFont as AnyObject).fontName == "TimesNewRomanPS-ItalicMT" {
                    attrib.addAttribute(NSFontAttributeName, value: AppFonts.ItalicText.font(fontSize), range: myRange)
                } else if (oldFont as AnyObject).fontName == "TimesNewRomanPS-BoldItalicMT" {
                    attrib.addAttribute(NSFontAttributeName, value: AppFonts.BoldItalicText.font(fontSize), range: myRange)
                } else {
                    attrib.addAttribute(NSFontAttributeName, value: AppFonts.RegularText.font(fontSize), range: myRange)
                }
            }
        }
        attrib.endEditing()
        return attrib
    }

    func openWebviewToImage(_ sender: CustomImageButton) {
        navigationController?.pushViewController(OCVWebview(url: sender.urlString!, navTitle: "", showToolBar: false), animated: true)
    }
}

class CustomImageButton: UIButton {
    let urlString: String?

    init(frame: CGRect, urlToOpen: String) {
        urlString = urlToOpen
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
