//
//  NativeBannerViewModel.swift
//  myTargetDemo
//
//  Created by Andrey Seredkin on 04.10.2022.
//  Copyright © 2022 VK. All rights reserved.
//

import Foundation
import MyTargetSDK

enum NativeBannerCell {
    case ad(NativeBannerAd)
    case general
}

extension NativeBannerCell: Hashable, Identifiable {
    var id: Self { self }
}

final class NativeBannerViewModel: ObservableObject {
    @Published private(set) var cells = [NativeBannerCell]()

    private let slotId: UInt
    private var nativeBannerAdLoader: MTRGNativeBannerAdLoader?

    init(slotId: UInt) {
        self.slotId = slotId
    }

    @available(*, unavailable)
    required init() {
        fatalError("init() has not been implemented")
    }

    func loadAdvertisements() {
        let count: UInt = 3
        nativeBannerAdLoader = MTRGNativeBannerAdLoader(forCount: count, slotId: slotId)
        nativeBannerAdLoader?.load { [weak self] nativeBannerAds, error in
            guard let self = self else {
                return
            }
            if let error = error {
                print("Loading error: \(error.localizedDescription)")
            } else {
                print("MTRGNativeBannerAdLoader loaded items: \(nativeBannerAds.count)")
                nativeBannerAds.forEach { self.addAdvertisement($0) }
            }
        }
    }

    private func addAdvertisement(_ advertisement: MTRGNativeBannerAd) {
        let nativeBannerAd = NativeBannerAd(nativeBannerAd: advertisement)
        let batchCount = 16
        for index in 0..<batchCount {
            // every third cell in a batch will be an ad
            let cell: NativeBannerCell = index % batchCount - 2 == 0 ? .ad(nativeBannerAd) : .general
            cells.append(cell)
        }
    }
}
