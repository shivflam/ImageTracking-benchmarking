//
//  GalleryPermission.swift
//  IOU test
//
//  Created by Shiv Prakash on 26/11/24.
//

import Foundation
import PhotosUI
import Photos

class MediaPermission {
    
    static let shared: MediaPermission = MediaPermission()
    
    private init() {}
    
    func requestPhotoLibraryPermission(completion: @escaping (Bool) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        switch status {
        case .notDetermined:
            // Request permission
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                DispatchQueue.main.async {
                    completion(newStatus == .authorized || newStatus == .limited)
                }
            }
        case .authorized, .limited:
            // Permission already granted
            completion(true)
        case .denied, .restricted:
            // Permission denied or restricted
            completion(false)
        @unknown default:
            completion(false)
        }
    }
}
