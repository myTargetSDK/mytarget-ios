//
//  UIImageView+Loading.swift
//  myTargetDemo
//
//  Created by Alexander Vorobyev on 14.02.2023.
//  Copyright © 2023 Mail.ru Group. All rights reserved.
//

import UIKit

private var tokenKey: Void?

extension UIImageView {

    private var token: UUID? {
        get {
            return objc_getAssociatedObject(self, &tokenKey) as? UUID
        }
        set {
            objc_setAssociatedObject(self, &tokenKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    private var loader: ImageLoader {
        ImageLoader.shared
    }

    func loadImage(url: URL) {
        let uuid = loader.loadImage(url: url) { [weak self] result in
            DispatchQueue.main.async {
                if let token = self?.token, token == uuid {
                    self?.image = try? result.get()
                }
            }
        }
        self.token = uuid
    }

    func cancelLoading() {
        token.map { loader.cancelLoading(by: $0) }
    }
}
