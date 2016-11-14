//
//  OCVWebview.swift
//  OCVSwift
//
//  Created by Eddie Seay on 2/8/16.
//  Copyright © 2016 OCV,LLC. All rights reserved.
//

import UIKit
import WebKit
import STPopup
import SVProgressHUD
import SafariServices

class OCVWebview: UIViewController, WKNavigationDelegate, UIScrollViewDelegate {

    var webURL: URL?
    let webView = WKWebView()
    var navTitle = ""
    var navigationBarItems: [UIBarButtonItem] = []
    var shouldShowToolbar = true

    init(url: String, navTitle: String?, showToolBar: Bool) {
        super.init(nibName: nil, bundle: nil)
        self.navTitle = navTitle ?? ""

        webView.navigationDelegate = self
        webView.scrollView.delegate = self

        if let urlIn = URL(string: url) {
            if UIApplication.shared.canOpenURL(urlIn) {
                webURL = urlIn
            }
        }

        shouldShowToolbar = showToolBar
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    deinit {
        OCVAppUtilities.finishTask()
        webView.loadHTMLString("", baseURL: nil)
        webView.navigationDelegate = nil
        webView.scrollView.delegate = nil
        webView.stopLoading()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = webView
        navigationItem.title = navTitle

        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            contentSizeInPopup = CGSize(width: UIScreen.main.bounds.size.width * 0.90, height: UIScreen.main.bounds.size.height * 0.90)
            landscapeContentSizeInPopup = CGSize(width: UIScreen.main.bounds.size.width * 0.90, height: UIScreen.main.bounds.size.height * 0.65)
        } else {
            contentSizeInPopup = CGSize(width: UIScreen.main.bounds.size.width * 0.90, height: UIScreen.main.bounds.size.height * 0.85)
            landscapeContentSizeInPopup = CGSize(width: UIScreen.main.bounds.size.width * 0.90, height: UIScreen.main.bounds.size.height * 0.90)
        }

        toolbarItems = createNavigationToolBarItems()
        loadOrFailWithError(webURL)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if shouldShowToolbar {
            navigationController?.isToolbarHidden = false
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        if shouldShowToolbar {
            navigationController?.isToolbarHidden = true
        }
    }

    func loadOrFailWithError(_ urlIn: URL?) {
        guard let urlToLoad = urlIn else {
            let htmlFile = Bundle.main.path(forResource: "InvalidURLError", ofType: "html")
            var htmlString: String?
            do {
                htmlString = try String(contentsOfFile: htmlFile!, encoding: String.Encoding.utf8)
                webView.loadHTMLString(htmlString!, baseURL: nil)
            } catch _ {
                htmlString = nil
            }
            return
        }

        SVProgressHUD.show(withStatus: "Loading")

        let req = URLRequest(url: urlToLoad)
        webView.load(req)
    }

    func reloadWebview() {
        OCVAppUtilities.finishTask()
        SVProgressHUD.show(withStatus: "Loading")
        webView.reload()
    }

    func openInSafari() {
        guard let urlToOpen = webURL else {
            return
        }

        if #available(iOS 9.0, *) {
            let safariBrowser = SFSafariViewController(url: urlToOpen)
            present(safariBrowser, animated: true, completion: nil)
        } else {
            UIApplication.shared.openURL(urlToOpen)
        }
    }

    func actionButtonTapped(_ sender: UIBarButtonItem) {
        var activityItems = [AnyObject]()
        if let urlString = webURL?.absoluteString {
            activityItems.append(urlString as AnyObject)
            activityItems.append(webURL! as AnyObject)
        }

        let activityController: UIActivityViewController = {
            $0.modalPresentationStyle = .popover
            $0.popoverPresentationController?.barButtonItem = sender
            $0.popoverPresentationController?.sourceView = self.view
            return $0
        }(UIActivityViewController(activityItems: activityItems, applicationActivities: nil))

        self.present(activityController, animated: true, completion: nil)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        OCVAppUtilities.finishTask()
    }

    func createNavigationToolBarItems() -> [UIBarButtonItem] {
        let back = UIBarButtonItem(image: UIImage(named: "backArrow"), style: .plain, target: webView, action: #selector(UIWebView.goBack))
        let forward = UIBarButtonItem(image: UIImage(named: "forwardArrow"), style: .plain, target: webView, action: #selector(UIWebView.goForward))
        let reload = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(OCVWebview.reloadWebview))
        let action = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(OCVWebview.actionButtonTapped(_:)))
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let safari = UIBarButtonItem(image: UIImage(named: "compass"), style: .plain, target: self, action: #selector(OCVWebview.openInSafari))

        let buttonArray = [back, flex, forward, flex, flex, flex, action, flex, safari, flex, reload]

        return buttonArray
    }
}
