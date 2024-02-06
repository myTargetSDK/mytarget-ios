//
//  MenuItem.swift
//  myTargetDemo
//
//  Created by Alexander Vorobyev on 14.02.2023.
//  Copyright © 2023 Mail.ru Group. All rights reserved.
//

import Foundation

struct MenuItem<Route> {
    let title: String
    let description: String
    let route: Route
}
