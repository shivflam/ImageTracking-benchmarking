//
//  VideoARViewController.swift
//  IOU test
//
//  Created by Shiv Prakash on 27/11/24.
//

import ARKit
import UIKit
import AVFoundation
import SceneKit

class VideoARViewController: UIViewController, ARSCNViewDelegate {
    
    var sceneView: ARSCNView!
    var player: AVPlayer!
    var videoFrameExtractor: CADisplayLink?
    var referenceImage: UIImage?
    var frameCount = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize ARSCNView
        sceneView = ARSCNView(frame: view.bounds)
        view.addSubview(sceneView)

        // Configure ARKit for image tracking

        guard let cgImage = referenceImage?.cgImage else { return }
        let arReferenceImage = ARReferenceImage(cgImage, orientation: .up, physicalWidth: 0.2) // Adjust size

        let configuration = ARImageTrackingConfiguration()
        configuration.trackingImages = [arReferenceImage]
        configuration.maximumNumberOfTrackedImages = 1

        sceneView.session.run(configuration)
        sceneView.delegate = self

        // Load and play video
        playVideo(named: "RecordedVideo.MOV")
    }

    func playVideo(named videoName: String) {
        print("DEBUG: playVideo")
        guard let path = Bundle.main.path(forResource: videoName, ofType: nil) else { return }
        let url = URL(fileURLWithPath: path)
        print("DEBUG: video url \(url)")
        player = AVPlayer(url: url)
        player.play()

        // Add video to AR scene
        addVideoToARScene()
    }

    func addVideoToARScene() {
        print("DEBUG: addVideoToARScene")
        guard let player = player else { return }
        
        print("DEBUG: addingVideoToARScene")
        
        // Create a plane to render the video
        let videoPlane = SCNPlane(width: 0.4, height: 0.3)
        videoPlane.firstMaterial?.diffuse.contents = player
        videoPlane.firstMaterial?.isDoubleSided = true
        
        // Create a node for the plane
        let videoNode = SCNNode(geometry: videoPlane)
        videoNode.eulerAngles.x = -.pi / 2 // Rotate to horizontal position
        
        // Position video node relative to the tracked image
        videoNode.position = SCNVector3(0, 0, 0)
        
        // Add node to the scene when the image is detected
        sceneView.scene.rootNode.addChildNode(videoNode)
    }
    
    // ARSCNViewDelegate - Called when an image is detected
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        print("DEBUG: didAdd node")
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        
        // Create a bounding box for the detected image
        let boundingBox = createBoundingBox(for: imageAnchor.referenceImage)
        boundingBox.name = "BoundingBox" // Assign a name for later identification
        node.addChildNode(boundingBox)
        
        print("DEBUG: didAdd node")
        printBoundingBoxDetails(from: imageAnchor)
    }
    
    // Create a bounding box as an SCNNode
    /// Create a bounding box node for a reference image
    func createBoundingBox(for referenceImage: ARReferenceImage) -> SCNNode {
        // Create a semi-transparent plane with a red border
        let plane = SCNPlane(
            width: CGFloat(referenceImage.physicalSize.width),
            height: CGFloat(referenceImage.physicalSize.height)
        )
        
        // Add a red border
        let borderColor = UIColor.red
        let borderWidth: CGFloat = 0.1 // Adjust thickness as needed
        let imageSize = CGSize(
            width: plane.width * 1000,  // Scale up to avoid artifacts
            height: plane.height * 1000
        )
        
        let renderer = UIGraphicsImageRenderer(size: imageSize)
        let borderImage = renderer.image { context in
            let rect = CGRect(origin: .zero, size: imageSize)
            context.cgContext.setStrokeColor(borderColor.cgColor)
            context.cgContext.setLineWidth(borderWidth * imageSize.width)
            context.cgContext.stroke(rect)
        }
        
        plane.firstMaterial?.diffuse.contents = borderImage
        plane.firstMaterial?.isDoubleSided = true // Ensure visibility from both sides

        let planeNode = SCNNode(geometry: plane)
        planeNode.eulerAngles.x = -.pi / 2 // Rotate plane to align with the image
        
        return planeNode
    }
    
    // Print bounding box details
    func printBoundingBoxDetails(from imageAnchor: ARImageAnchor) {
        let transform = imageAnchor.transform
        let position = SCNVector3(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
        
        print("Bounding Box Center: \(position)")
        print("Bounding Box Size: \(imageAnchor.referenceImage.physicalSize)")
    }
    
    // Update bounding box on each frame
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        
        frameCount += 1
        print("DEBUG: frame count: \(self.frameCount)")
        
        printBoundingBoxDetails(from: imageAnchor)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        frameCount = 0
        sceneView.session.pause()
    }
}
