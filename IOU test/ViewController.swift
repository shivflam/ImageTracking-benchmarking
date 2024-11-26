//
//  ViewController.swift
//  IOU test
//
//  Created by Shiv Prakash on 26/11/24.
//

import UIKit
import Photos
import PhotosUI
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    @objc func uploadImageTapped() {
        openMediaPicker()
    }
    
    @objc func recordVideoTapped() {
        let storyborad = UIStoryboard(name: "Main", bundle: nil)
        if let recordVc = storyborad.instantiateViewController(withIdentifier: "RecordingViewController") as? RecordingViewController {
            
            self.navigationController?.pushViewController(recordVc, animated: true)
        }
    }
    
    @objc func downloadCSVTapped() {
        print("downloadCSV tapped")
    }
    
    func setupViews() {
        let uploadImageButton = UIButton()
        uploadImageButton.setTitle("Upload Image", for: .normal)
        uploadImageButton.setTitleColor(.white, for: .normal)
        uploadImageButton.backgroundColor = .blue
        uploadImageButton.translatesAutoresizingMaskIntoConstraints = false
        uploadImageButton.addTarget(self, action: #selector(uploadImageTapped), for: .touchUpInside)
        self.view.addSubview(uploadImageButton)
        
        // Set constraints
        NSLayoutConstraint.activate([
            uploadImageButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            uploadImageButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            uploadImageButton.widthAnchor.constraint(equalToConstant: 140), // Width = 100
            uploadImageButton.heightAnchor.constraint(equalToConstant: 40)  // Height = 40
        ])
        
        let recordButton = UIButton()
        recordButton.setTitle("Record Video", for: .normal)
        recordButton.setTitleColor(.white, for: .normal)
        recordButton.backgroundColor = .blue
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        recordButton.addTarget(self, action: #selector(recordVideoTapped), for: .touchUpInside)
        self.view.addSubview(recordButton)
        
        // Set constraints
        NSLayoutConstraint.activate([
            recordButton.topAnchor.constraint(equalTo: uploadImageButton.bottomAnchor, constant: 10),
            recordButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            recordButton.widthAnchor.constraint(equalToConstant: 140),
            recordButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        let downloadCsvTapped = UIButton()
        downloadCsvTapped.setTitle("Download CSV", for: .normal)
        downloadCsvTapped.setTitleColor(.white, for: .normal)
        downloadCsvTapped.backgroundColor = .blue
        downloadCsvTapped.translatesAutoresizingMaskIntoConstraints = false
        downloadCsvTapped.addTarget(self, action: #selector(recordVideoTapped), for: .touchUpInside)
        self.view.addSubview(downloadCsvTapped)
        
        // Set constraints
        NSLayoutConstraint.activate([
            downloadCsvTapped.topAnchor.constraint(equalTo: recordButton.bottomAnchor, constant: 10),
            downloadCsvTapped.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            downloadCsvTapped.widthAnchor.constraint(equalToConstant: 140),
            downloadCsvTapped.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Get photos permission
        
        setupViews()
        
        MediaPermission.shared.requestPhotoLibraryPermission { [weak self] check in
            
            guard let strongSelf = self else {
                return
            }
        }
        
        // Camera permission
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch cameraAuthorizationStatus {
        case .notDetermined:
            // Permission has not been requested yet
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    print("Camera access granted")
                    // Proceed with camera usage
                } else {
                    print("Camera access denied")
                    // Handle the case when the user denies permission
                }
            }
        case .authorized:
            print("Camera access already granted")
            // Proceed with camera usage
        case .denied:
            print("Camera access denied previously")
            // Handle the case when the user denied permission previously
            
        case .restricted:
            print("Camera access restricted")
            // Handle the case when camera usage is restricted (e.g., parental controls)
        @unknown default:
            print("Unknown camera authorization status")
        }
    }
    
    func openAppSettings() {
        if let appSettingsURL = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(appSettingsURL) {
                UIApplication.shared.open(appSettingsURL, options: [:], completionHandler: nil)
            }
        }
    }
    
    func openMediaPicker() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 0 // 0 means no limit
        config.filter = .any(of: [.images])

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
}

extension ViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)

        for result in results {
            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                // Handle image
                result.itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                    if let image = object as? UIImage {
                        DispatchQueue.main.async {
                            print("Selected image: \(image)")
                            
                            self.imageView.image = image
                        }
                    }
                }
            } else if result.itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                // Handle video
                result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { url, error in
                    if let videoURL = url {
                        DispatchQueue.main.async {
                            print("Selected video URL: \(videoURL)")
                            // Use the video
                        }
                    }
                }
            }
        }
    }
}
