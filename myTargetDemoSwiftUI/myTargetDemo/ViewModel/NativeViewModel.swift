//
//  NativeViewModel.swift
//  myTargetDemo
//
//  Created by Andrey Seredkin on 17.10.2022.
//  Copyright © 2022 VK. All rights reserved.
//

import Foundation
import MyTargetSDK

enum NativeCell {
    case ad(NativeAd)
    case general
}

extension NativeCell: Hashable, Identifiable {
    var id: Self { self }
}

final class NativeViewModel: ObservableObject {
    @Published private(set) var cells = [NativeCell]()

    private let slotId: UInt
    private var nativeAdLoader: MTRGNativeAdLoader?

    init(slotId: UInt) {
        self.slotId = slotId
    }

    @available(*, unavailable)
    required init() {
        fatalError("init() has not been implemented")
    }

    func loadAdvertisements() {
        let count: UInt = 3
        nativeAdLoader = MTRGNativeAdLoader(forCount: count, slotId: slotId)
        nativeAdLoader?.load { [weak self] nativeAds, error in
            guard let self = self else {
                return
            }
            if let error = error {
                print("Loading error: \(error.localizedDescription)")
            } else {
                print("MTRGNativeAdLoader loaded items: \(nativeAds.count)")
                nativeAds.forEach { self.addAdvertisement($0) }
            }
        }
    }

    private func addAdvertisement(_ advertisement: MTRGNativeAd) {
        let nativeAd = NativeAd(nativeAd: advertisement)
        let batchCount = 16
        for index in 0..<batchCount {
            // every third cell in a batch will be an ad
            let cell: NativeCell = index % batchCount - 2 == 0 ? .ad(nativeAd) : .general
            cells.append(cell)
        }
    }
}
