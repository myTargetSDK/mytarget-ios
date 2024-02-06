//
//  AudioPlayer+Loader.swift
//  myTargetDemo
//
//  Created by igor.sorokin on 06.02.2023.
//  Copyright © 2023 Mail.ru Group. All rights reserved.
//

import Foundation

extension AudioPlayer {

    struct DownloadTask {
        let url: URL
        private let task: URLSessionDownloadTask

        init(url: URL, task: URLSessionDownloadTask) {
            self.url = url
            self.task = task
        }

        func cancel() {
            task.cancel()
        }
    }

    final class Loader {

        enum DownloadError: Error {
            case noLocation
            case writeToDirectory
        }

        enum Constants {
            static let cacheCapacity: Int = 100_000_000 // 0.1 Gb
            static let cacheDiskCapacity: Int = 500_000_000 // 0.5 Gb
        }

        private lazy var documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

        private lazy var cache: URLCache = {
            let cachesURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            let diskCacheURL = cachesURL.appendingPathComponent("AudioCache")
            let cache = URLCache(memoryCapacity: Constants.cacheCapacity,
                                 diskCapacity: Constants.cacheDiskCapacity,
                                 diskPath: diskCacheURL.absoluteString)
            return cache
        }()

        private lazy var session: URLSession = {
            let config = URLSessionConfiguration.default
            config.urlCache = cache
            return URLSession(configuration: config)
        }()

        func download(url: URL, completion: @escaping (Result<URL, Error>) -> Void) -> DownloadTask {
            let request = URLRequest(url: url)
            let task = session.downloadTask(with: request) { [weak self] tmpLocation, response, error in
                guard let self = self else {
                    return
                }

                guard let tmpLocation = tmpLocation else {
                    DispatchQueue.main.async {
                        completion(.failure(error ?? DownloadError.noLocation))
                    }
                    return
                }

                // Store data in cache
                if
                    self.cache.cachedResponse(for: request) == nil,
                    let response = response,
                    let data = try? Data(contentsOf: tmpLocation, options: [.mappedIfSafe]) {

                    self.cache.storeCachedResponse(CachedURLResponse(response: response, data: data), for: request)
                }

                // Move file to target location
                let newLocation = self.documentDirectory.appendingPathExtension(url.lastPathComponent)

                let result: Result<URL, Error>
                if let location = try? FileManager.default.replaceItemAt(newLocation, withItemAt: tmpLocation) {
                    result = .success(location)
                } else {
                    result = .failure(DownloadError.writeToDirectory)
                }

                DispatchQueue.main.async {
                    completion(result)
                }
            }

            task.resume()
            return DownloadTask(url: url, task: task)
        }
    }

}
