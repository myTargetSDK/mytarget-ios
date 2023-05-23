//
//  CustomAdvertisment.swift
//  myTargetDemo
//
//  Created by Alexander Vorobyev on 25.08.2022.
//  Copyright © 2022 Mail.ru Group. All rights reserved.
//

import Foundation

struct CustomAdvertisment: Codable, Equatable {
    let title: String
    let description: String
    let type: AdvertismentType
    let slotId: UInt
    let query: [String: String]?
}

final class CustomAdvertismentProvider {
    private let userDefaultsKey: String = "customAdvertismentKey"

    private lazy var userDefaults: UserDefaults = .standard
    private lazy var decoder: JSONDecoder = .init()
    private lazy var encoder: JSONEncoder = .init()
    private lazy var customAdvertisments: [CustomAdvertisment] = {
        guard let customsAdsData = userDefaults.object(forKey: userDefaultsKey) as? Data,
              let customsAds = try? decoder.decode([CustomAdvertisment].self, from: customsAdsData)
        else {
            return []
        }

        return customsAds
    }()

    func receive() -> [CustomAdvertisment] {
        customAdvertisments
    }

    func add(_ advertisment: CustomAdvertisment) {
        customAdvertisments.append(advertisment)
        save()
    }

    func remove(_ advertisment: CustomAdvertisment) {
        guard let index = customAdvertisments.firstIndex(of: advertisment) else {
            return
        }

        customAdvertisments.remove(at: index)
        save()
    }

    private func save() {
        guard let encodedCustomAds = try? encoder.encode(customAdvertisments) else {
            return
        }

        userDefaults.set(encodedCustomAds, forKey: userDefaultsKey)
    }
}
