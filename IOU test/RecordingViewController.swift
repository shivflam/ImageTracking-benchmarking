//
//  RecordingViewController.swift
//  IOU test
//
//  Created by Shiv Prakash on 26/11/24.
//

import UIKit
import AVFoundation

class RecordingViewController: UIViewController {
    
    var captureSession: AVCaptureSession!
    var videoOutput: AVCaptureMovieFileOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var isRecording = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }
    
    func setupCamera() {
        // Initialize capture session
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .hd4K3840x2160
        
        // Set up the camera
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("No camera found")
            return
        }
        guard let videoInput = try? AVCaptureDeviceInput(device: videoDevice) else {
            print("Unable to access camera")
            return
        }
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        }
        
        // Set up audio
        let audioDevice = AVCaptureDevice.default(for: .audio)
        guard let audioInput = try? AVCaptureDeviceInput(device: audioDevice!) else {
            print("Unable to access microphone")
            return
        }
        if captureSession.canAddInput(audioInput) {
            captureSession.addInput(audioInput)
        }
        
        // Set up video output
        videoOutput = AVCaptureMovieFileOutput()
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }
        
        // Add preview layer
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)
        
        // Start the capture session
        captureSession.startRunning()
        
        // Add record button
        setupRecordButton()
    }
    
    func setupRecordButton() {
        let recordButton = UIButton(frame: CGRect(x: (view.frame.width - 80) / 2, y: view.frame.height - 100, width: 80, height: 80))
        recordButton.backgroundColor = .red
        recordButton.layer.cornerRadius = 40
        recordButton.addTarget(self, action: #selector(recordButtonTapped), for: .touchUpInside)
        view.addSubview(recordButton)
    }
    
    @objc func recordButtonTapped() {
            if isRecording {
                stopRecording()
            } else {
                startRecording()
            }
        }
    
    func startRecording() {
        let outputPath = NSTemporaryDirectory() + "output.mov"
        let outputURL = URL(fileURLWithPath: outputPath)
        videoOutput.startRecording(to: outputURL, recordingDelegate: self)
        isRecording = true
    }
    
    func stopRecording() {
        videoOutput.stopRecording()
        isRecording = false
    }
}

// MARK: - AVCaptureFileOutputRecordingDelegate
extension RecordingViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("Recording error: \(error.localizedDescription)")
        } else {
            print("Video recorded to: \(outputFileURL)")
            // Optionally, save to photo library
            UISaveVideoAtPathToSavedPhotosAlbum(outputFileURL.path, nil, nil, nil)
        }
    }
}
