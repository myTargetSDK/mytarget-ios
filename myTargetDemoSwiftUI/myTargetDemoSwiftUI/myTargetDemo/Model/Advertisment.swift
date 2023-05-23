//
//  Advertisment.swift
//  myTargetDemo
//
//  Created by Andrey Seredkin on 05.09.2022.
//  Copyright © 2022 VK. All rights reserved.
//

import Foundation

struct Advertisment {
    let title: String
    let description: String?
    let type: AdvertismentType
    let slotId: UInt
    let items: [Advertisment]?

    init(title: String, description: String? = nil, type: AdvertismentType, slotId: UInt = 0, items: [Advertisment]? = nil) {
	    self.title = title
	    self.description = description
	    self.type = type
	    self.slotId = slotId
	    self.items = items
    }
}

extension Advertisment: Hashable, Equatable {
    static func == (lhs: Advertisment, rhs: Advertisment) -> Bool {
	    return lhs.title == rhs.title &&
    	       lhs.type == rhs.type &&
    	       lhs.description == rhs.description &&
    	       lhs.slotId == rhs.slotId &&
    	       lhs.items == rhs.items
    }

    func hash(into hasher: inout Hasher) {
	    hasher.combine(title)
	    hasher.combine(description)
	    hasher.combine(type)
	    hasher.combine(slotId)
	    hasher.combine(items)
    }
}

extension Advertisment: Identifiable {
    var id: String { title }
}
