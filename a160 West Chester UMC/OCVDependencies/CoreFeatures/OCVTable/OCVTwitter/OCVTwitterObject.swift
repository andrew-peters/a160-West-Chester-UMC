//
//  OCVTwitterObject.swift
//  OCVSwift
//
//  Created by Eddie Seay on 2/29/16.
//  Copyright © 2016 OCV,LLC. All rights reserved.
//

import Foundation

struct OCVTwitterObject {
    let id: String
    let userTitle: String
    let profPicURL: String
    let content: String
    let contentURL: URL
    let fromDate: String
    let userID: String
    let userURL: URL

    init(id: String?, title: String?, content: String?, contentURLstring: String?, fromDate: String?, userID: String?, userURLstring: String?, profURLstring: String?) {
        self.id = id ?? ""
        self.userTitle = title ?? ""
        self.content = content?.stringByDecodingHTMLEntities ?? ""

        let curlstr = contentURLstring ?? ""
        self.contentURL = URL(string: curlstr) ?? URL(string: "https://www.twitter.com")!

        self.fromDate = fromDate ?? ""
        self.userID = userID ?? ""

        let usrurlstr = userURLstring ?? ""
        self.userURL = URL(string: usrurlstr) ?? URL(string: "https://www.twitter.com")!

        self.profPicURL = profURLstring ?? "https://pbs.twimg.com/profile_images/2284174872/7df3h38zabcvjylnyfe3_normal.png"
    }
}
