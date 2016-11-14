//
//  OCVPageObjectViewModel.swift
//  OCVSwift
//
//  Created by Eddie Seay on 6/22/16.
//  Copyright © 2016 OCV,LLC. All rights reserved.
//

import Foundation

struct OCVPageObjectViewModel: StandardDetailDisplayable {
    let title: String
    let detailContent: String
    let htmlContent: String?
    let dateString: String
    let images: [String]?

    init(model: OCVPageObject) {
        self.title = model.title
        self.detailContent = model.content.replacingOccurrences(of: "<[^>]+>",
            with: "",
            options: .regularExpression,
            range: nil).stringByDecodingHTMLEntities
        self.htmlContent = model.content
        self.dateString = ""

        if !model.images.isEmpty { self.images = model.images.flatMap { $0["large"] }
        } else { self.images = nil }
    }
}
