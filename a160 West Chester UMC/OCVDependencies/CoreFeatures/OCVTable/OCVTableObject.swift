//
//  OCVTableObject.swift
//  OCVSwift
//
//  Created by Eddie Seay on 1/15/16.
//  Copyright © 2016 OCV,LLC. All rights reserved.
//

struct OCVTableObject {
    let identifier: String
    let title: String
    let content: String
    let creator: String
    let date: String
    let description: String
    let images: [AnyObject]

    init(id: String?, title: String?, content: String?, creator: String?, date: String?, imageArr: [AnyObject]?) {
        self.identifier = id ?? ""
        self.title = title ?? ""
        self.content = content ?? ""
        self.creator = creator ?? ""
        self.date = date ?? ""
        self.images = imageArr ?? []

        self.description = (self.content.replacingOccurrences(of: "<[^>]+>",
            with: "",
            options: .regularExpression,
            range: nil))
            .stringByDecodingHTMLEntities
    }

    func hasImages() -> Bool {
        return !self.images.isEmpty
    }

    func firstThumbnail() -> String? {
        if let first = self.images.first as? [String: String] {
            return first["small"]
        }

        return nil
    }
}
