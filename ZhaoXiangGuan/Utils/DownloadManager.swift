//
//  DownloadManager.swift
//  ZhaoXiangGuan
//
//  下载管理器 - 管理下载历史记录
//

import Foundation
import UIKit
import Photos

class DownloadManager {

    static let shared = DownloadManager()

    private let downloadHistoryKey = "download_history"
    private let downloadsFolderName = "造像馆"

    private init() {
        createDownloadsFolderIfNeeded()
    }

    // MARK: - 下载记录管理

    /// 保存下载记录
    func saveDownload(style: ArtStyle, imageData: Data) {
        let record: [String: Any] = [
            "style": style.rawValue,
            "category": style.category.rawValue,
            "imageData": imageData,
            "timestamp": Date().timeIntervalSince1970
        ]

        var history = getDownloadHistory()
        history.append(record)

        // 限制记录数量（最多保存100条）
        if history.count > 100 {
            history = Array(history.suffix(100))
        }

        if let data = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(data, forKey: downloadHistoryKey)
        }
    }

    /// 获取下载历史
    func getDownloadHistory() -> [[String: Any]] {
        guard let data = UserDefaults.standard.data(forKey: downloadHistoryKey),
              let history = try? JSONDecoder().decode([DownloadRecord].self, from: data) else {
            return []
        }

        // 转换为字典格式
        return history.map { record in
            [
                "style": record.style,
                "category": record.category,
                "timestamp": record.timestamp,
                "imageData": record.imageData
            ]
        }
    }

    /// 获取下载的图片列表
    func getDownloadedItems() -> [DownloadedItem] {
        let history = getDownloadHistory()

        return history.compactMap { record in
            guard let styleName = record["style"] as? String,
                  let style = ArtStyle.allCases.first(where: { $0.rawValue == styleName }),
                  let imageData = record["imageData"] as? Data,
                  let timestamp = record["timestamp"] as? TimeInterval else {
                return nil
            }

            return DownloadedItem(
                style: style,
                imageData: imageData,
                downloadDate: Date(timeIntervalSince1970: timestamp)
            )
        }
    }

    /// 删除下载记录
    func deleteDownload(at index: Int) {
        var history = getDownloadHistory()
        if index < history.count {
            history.remove(at: index)

            if let data = try? JSONSerialization.data(withJSONObject: history, options: []) {
                UserDefaults.standard.set(data, forKey: downloadHistoryKey)
            }
        }
    }

    /// 清空所有下载记录
    func clearAllDownloads() {
        UserDefaults.standard.removeObject(forKey: downloadHistoryKey)
    }

    // MARK: - 相册管理

    /// 保存图片到相册
    func saveToPhotoLibrary(image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .authorized, .limited:
                // 检查是否需要创建自定义相册
                self.checkAndCreateAlbum { albumResult in
                    switch albumResult {
                    case .success(let collection):
                        // 保存图片到相册
                        self.saveImage(image, toCollection: collection, completion: completion)
                    case .failure(let error):
                        // 如果创建相册失败，直接保存到相机胶卷
                        self.saveImageToCameraRoll(image, completion: completion)
                    }
                }
            default:
                completion(.failure(NSError(domain: "DownloadManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "没有相册权限"])))
            }
        }
    }

    /// 检查并创建自定义相册
    private func checkAndCreateAlbum(completion: @escaping (Result<PHAssetCollection, Error>) -> Void) {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", downloadsFolderName)
        let collections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)

        if let collection = collections.firstObject {
            completion(.success(collection))
        } else {
            PHPhotoLibrary.shared().performChanges({
                PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: self.downloadsFolderName)
            }) { success, error in
                if success {
                    // 重新获取创建的相册
                    let fetchOptions = PHFetchOptions()
                    fetchOptions.predicate = NSPredicate(format: "title = %@", self.downloadsFolderName)
                    let collections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
                    if let collection = collections.firstObject {
                        completion(.success(collection))
                    } else {
                        completion(.failure(NSError(domain: "DownloadManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "无法找到创建的相册"])))
                    }
                } else {
                    completion(.failure(error ?? NSError(domain: "DownloadManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "创建相册失败"])))
                }
            }
        }
    }

    /// 保存图片到指定相册
    private func saveImage(_ image: UIImage, toCollection collection: PHAssetCollection, completion: @escaping (Result<String, Error>) -> Void) {
        var placeholder: PHObjectPlaceholder?

        PHPhotoLibrary.shared().performChanges({
            let creationRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            guard let collectionChangeRequest = PHAssetCollectionChangeRequest(for: collection),
                  let assetPlaceholder = creationRequest.placeholderForCreatedAsset else {
                return
            }
            placeholder = assetPlaceholder
            collectionChangeRequest.addAssets([assetPlaceholder] as NSArray)
        }) { success, error in
            DispatchQueue.main.async {
                if success, let placeholder = placeholder {
                    completion(.success(placeholder.localIdentifier))
                } else {
                    completion(.failure(error ?? NSError(domain: "DownloadManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "保存图片失败"])))
                }
            }
        }
    }

    /// 保存图片到相机胶卷
    private func saveImageToCameraRoll(_ image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        var placeholder: PHObjectPlaceholder?

        PHPhotoLibrary.shared().performChanges({
            let creationRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            placeholder = creationRequest.placeholderForCreatedAsset
        }) { success, error in
            DispatchQueue.main.async {
                if success, let placeholder = placeholder {
                    completion(.success(placeholder.localIdentifier))
                } else {
                    completion(.failure(error ?? NSError(domain: "DownloadManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "保存图片失败"])))
                }
            }
        }
    }

    /// 创建下载文件夹（iOS 14+需要）
    private func createDownloadsFolderIfNeeded() {
        // 在iOS 14+中，可以创建自定义相册
        // 这里的实现依赖于上面的checkAndCreateAlbum方法
    }
}

// MARK: - 下载记录模型

struct DownloadRecord: Codable {
    let style: String
    let category: String
    let imageData: Data
    let timestamp: TimeInterval
}
