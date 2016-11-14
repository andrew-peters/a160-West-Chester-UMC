//
//  ConfigurableCell.swift
//  OCVSwift
//
//  Created by Eddie Seay on 5/16/16.
//  Copyright © 2016 OCV,LLC. All rights reserved.
//

protocol ConfigurableCell {
    associatedtype ObjectViewModel
    func configure(_ object: ObjectViewModel)
    static func reuseIdentifier() -> String
}
