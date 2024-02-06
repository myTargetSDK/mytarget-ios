//
//  ImageLoader.swift
//  myTargetDemo
//
//  Created by Alexander Vorobyev on 14.02.2023.
//  Copyright © 2023 Mail.ru Group. All rights reserved.
//

import UIKit

enum ImageLoaderError: Error {
    case unknown
}

final class ImageLoader {
    static let shared = ImageLoader()

    private var cache: [URL: UIImage] = [:]
    private var activeTasks: [UUID: URLSessionDataTask] = [:]

    private init() { }

    func loadImage(url: URL, completion: @escaping (Result<UIImage, Error>) -> Void) -> UUID? {
        if let image = cache[url] {
            completion(.success(image))
            return nil
        }

        let uuid = UUID()

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            self?.activeTasks[uuid] = nil

            if let image = data.flatMap({ UIImage(data: $0) }) {
                self?.cache[url] = image
                completion(.success(image))
            } else {
                completion(.failure(error ?? ImageLoaderError.unknown))
            }
        }
        task.resume()

        activeTasks[uuid] = task
        return uuid
    }

    func cancelLoading(by uuid: UUID) {
        activeTasks[uuid]?.cancel()
        activeTasks[uuid] = nil
    }
}
