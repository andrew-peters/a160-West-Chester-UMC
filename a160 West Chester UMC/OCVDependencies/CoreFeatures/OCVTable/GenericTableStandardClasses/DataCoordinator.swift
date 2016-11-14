//
//  DataCoordinator.swift
//  OCVSwift
//
//  Created by Eddie Seay on 5/19/16.
//  Copyright © 2016 OCV,LLC. All rights reserved.
//

protocol DataCoordinator {
    func refresh(_ completion: @escaping (Void) -> Void)
}
