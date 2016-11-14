//
//  DataProvider.swift
//  OCVSwift
//
//  Created by Eddie Seay on 5/16/16.
//  Copyright © 2016 OCV,LLC. All rights reserved.
//

import Foundation

protocol DataProvider {
    associatedtype ObjectViewModel
    func refresh(showProgress progressIndicator: Bool, completion: @escaping () -> Void)
    var numberOfSections: Int { get }
    func numberOfItemsInSection(_ section: Int) -> Int
    func objectAtIndexPath(_ indexPath: IndexPath) -> ObjectViewModel?
}
