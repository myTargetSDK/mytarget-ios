//
//  UIImageView+Download.swift
//  myTargetDemo
//
//  Created by igor.sorokin on 03.02.2023.
//  Copyright © 2023 Mail.ru Group. All rights reserved.
//

import UIKit

extension UIImageView {

    func setImage(at url: URL, size: CGSize? = nil, completion: @escaping (_ success: Bool) -> Void) {

        func completeOnMain(_ image: UIImage?) {
            DispatchQueue.main.async {
                image.map { self.image = $0 }
                completion(image != nil)
            }
        }

        DispatchQueue.global().async {
            guard
                let data = try? Data(contentsOf: url),
                let image = UIImage(data: data)
            else {
                completeOnMain(nil)
                return
            }

            guard let size = size else {
                completeOnMain(image)
                return
            }

            let renderer = UIGraphicsImageRenderer(size: size)
            let resizedImage = renderer.image { (_) in
                image.draw(in: CGRect(origin: .zero, size: size))
            }

            completeOnMain(resizedImage)
        }
    }

}
