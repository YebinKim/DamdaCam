//
//  ARMotionViewController+extension.swift
//  DamdaCam
//
//  Created by Yebin Kim on 2020/01/27.
//  Copyright © 2020 김예빈. All rights reserved.
//

import UIKit
import Vision

extension ARMotionViewController: AVCapturePhotoCaptureDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureFileOutputRecordingDelegate {
    
    // MARK: - AVFondation Delegate & DataSource methods
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        UISaveVideoAtPathToSavedPhotosAlbum(outputFileURL.path, nil, nil, nil)
    }
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAtURL fileURL: NSURL!, fromConnections connections: [AnyObject]!) {
        print("capture output: started recording to \(fileURL)")
    }
    
    // MARK: AVCapture Setup
    /// - Tag: CreateCaptureSession
    func setupAVCaptureSession() -> AVCaptureSession? {
        let captureSession = AVCaptureSession()
        do {
            let inputDevice = try self.configureFrontCamera(for: captureSession)
            self.configureVideoDataOutput(for: inputDevice.device, resolution: inputDevice.resolution, captureSession: captureSession)
            self.designatePreviewLayer(for: captureSession)
            return captureSession
        } catch let executionError as NSError {
            self.presentError(executionError)
        } catch {
            self.presentErrorAlert(message: "An unexpected failure has occured")
        }
        
        self.teardownAVCapture()
        
        return nil
    }
    
    /// - Tag: ConfigureDeviceResolution
    fileprivate func highestResolution420Format(for device: AVCaptureDevice) -> (format: AVCaptureDevice.Format, resolution: CGSize)? {
        var highestResolutionFormat: AVCaptureDevice.Format? = nil
        var highestResolutionDimensions = CMVideoDimensions(width: 0, height: 0)
        
        for format in device.formats {
            let deviceFormat = format as AVCaptureDevice.Format
            
            let deviceFormatDescription = deviceFormat.formatDescription
            if CMFormatDescriptionGetMediaSubType(deviceFormatDescription) == kCVPixelFormatType_420YpCbCr8BiPlanarFullRange {
                let candidateDimensions = CMVideoFormatDescriptionGetDimensions(deviceFormatDescription)
                if (highestResolutionFormat == nil) || (candidateDimensions.width > highestResolutionDimensions.width) {
                    highestResolutionFormat = deviceFormat
                    highestResolutionDimensions = candidateDimensions
                }
            }
        }
        
        if highestResolutionFormat != nil {
            let resolution = CGSize(width: CGFloat(highestResolutionDimensions.width), height: CGFloat(highestResolutionDimensions.height))
            return (highestResolutionFormat!, resolution)
        }
        
        return nil
    }
    
    fileprivate func configureFrontCamera(for captureSession: AVCaptureSession) throws -> (device: AVCaptureDevice, resolution: CGSize) {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .front)
        
        if let device = deviceDiscoverySession.devices.first {
            
            //            session?.sessionPreset = AVCaptureSession.Preset.hd1280x720
            
            if let deviceInput = try? AVCaptureDeviceInput(device: device) {
                if captureSession.canAddInput(deviceInput) {
                    captureSession.addInput(deviceInput)
                }
                
                if let highestResolution = self.highestResolution420Format(for: device) {
                    try device.lockForConfiguration()
                    device.activeFormat = highestResolution.format
                    device.unlockForConfiguration()
                    
                    return (device, highestResolution.resolution)
                }
            }
        }
        
        throw NSError(domain: "ViewController", code: 1, userInfo: nil)
    }
    
    /// - Tag: CreateSerialDispatchQueue
    fileprivate func configureVideoDataOutput(for inputDevice: AVCaptureDevice, resolution: CGSize, captureSession: AVCaptureSession) {
        
        let videoDataOutput = AVCaptureVideoDataOutput()
        videoDataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString):NSNumber(value:kCVPixelFormatType_32BGRA)] as [String : Any]
        
        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        
        // Create a serial dispatch queue used for the sample buffer delegate as well as when a still image is captured.
        // A serial dispatch queue must be used to guarantee that video frames will be delivered in order.
        let videoDataOutputQueue = DispatchQueue(label: "com.example.apple-samplecode.VisionFaceTrack")
        //        videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sample buffer delegate", attributes: []))
        
        if captureSession.canAddOutput(videoDataOutput) {
            captureSession.addOutput(videoDataOutput)
        }
        
        captureSession.commitConfiguration()
        
        //        captureSession.addOutput(self.movieFileOutput)
        //        captureSession.addOutput(self.photoOutput)
        
        videoDataOutput.connection(with: .video)?.isEnabled = true
        
        if let captureConnection = videoDataOutput.connection(with: AVMediaType.video) {
            if captureConnection.isCameraIntrinsicMatrixDeliverySupported {
                captureConnection.isCameraIntrinsicMatrixDeliveryEnabled = true
            }
        }
        
        self.videoDataOutput = videoDataOutput
        self.videoDataOutputQueue = videoDataOutputQueue
        
        self.captureDevice = inputDevice
        self.captureDeviceResolution = resolution
    }
    
    fileprivate func getImageFromSampleBuffer (buffer:CMSampleBuffer) -> UIImage? {
        if let pixelBuffer = CMSampleBufferGetImageBuffer(buffer) {
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            let context = CIContext()
            
            let imageRect = CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))
            
            if let image = context.createCGImage(ciImage, from: imageRect) {
                return UIImage(cgImage: image, scale: UIScreen.main.scale, orientation: .leftMirrored)
            }
            
        }
        
        return nil
    }
    
    fileprivate func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // 1
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        // 2
        let detectFaceRequest = VNDetectFaceLandmarksRequest(completionHandler: detectedFace)
        
        // 3
        do {
            try sequenceRequestHandler.perform(
                [detectFaceRequest],
                on: imageBuffer,
                orientation: .downMirrored) // 정규화되는 방향
        } catch {
            print(error.localizedDescription)
        }
        
        if takePhoto {
            takePhoto = !takePhoto
            
            if let image = self.getImageFromSampleBuffer(buffer: sampleBuffer) {
                
                let snapShot = ARView.snapshot()
                let ARMotionImage = self.composite(image: image, overlay: snapShot, scaleOverlay: true)
                
                //                let filterShot = UIImage.init(view: self.filterBack)
                //                let filteredImage = self.composite(image: ARMotionImage!, overlay: filterShot, scaleOverlay: true)
                
                UIImageWriteToSavedPhotosAlbum(ARMotionImage!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
            }
            
        }
        
        // FIXME: 필터 기능 구현
        //        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        //        let cameraImage = CIImage(cvImageBuffer: pixelBuffer!)
        //
        //        selectedFilter!.setValue(cameraImage, forKey: kCIInputImageKey)
        //
        //        let cgImage = self.filterContext.createCGImage(selectedFilter!.outputImage!, from: cameraImage.extent)!
        //
        //        DispatchQueue.main.async {
        //            let filteredImage = UIImage(cgImage: cgImage)
        //            self.previewView.image = filteredImage
        //        }
        
        //        let cameraImage = CIImage(cvImageBuffer: imageBuffer)
        //        selectedFilter!.setValue(cameraImage, forKey: kCIInputImageKey)
        //        let cgImage = filterContext.createCGImage(selectedFilter!.outputImage!, from: cameraImage.extent)!
        //        let filteredImage = UIImage(ciImage: selectedFilter!.value(forKey: kCIOutputImageKey) as! CIImage)
        
        //        DispatchQueue.main.async {
        //            let filteredImage = UIImage(cgImage: filteredImage)
        //            self.previewView.image = filteredImage
        //        }
    }
    
    fileprivate func composite(image:UIImage, overlay:(UIImage), scaleOverlay: Bool = false) -> UIImage? {
        UIGraphicsBeginImageContext(image.size)
        var rect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        image.draw(in: rect)
        if scaleOverlay == false {
            rect = CGRect(x: 0, y: 0, width: overlay.size.width, height: overlay.size.height)
        }
        overlay.draw(in: rect)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        
        if let error = error {
            print("Error Saving ARMotion Scene \(error)")
        } else {
            print("ARMotion Scene Successfully Saved")
        }
    }
    
    /// - Tag: DesignatePreviewLayer
    fileprivate func designatePreviewLayer(for captureSession: AVCaptureSession) {
        let videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewLayer = videoPreviewLayer
        
        videoPreviewLayer.name = "CameraPreview"
        videoPreviewLayer.backgroundColor = UIColor.black.cgColor
        videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        if let previewRootLayer = self.previewView?.layer {
            self.rootLayer = previewRootLayer
            
            previewRootLayer.masksToBounds = true
            videoPreviewLayer.frame = previewRootLayer.bounds
            previewRootLayer.addSublayer(videoPreviewLayer)
        }
    }
    
    // Removes infrastructure for AVCapture as part of cleanup.
    fileprivate func teardownAVCapture() {
        self.videoDataOutput = nil
        self.videoDataOutputQueue = nil
        
        if let previewLayer = self.previewLayer {
            previewLayer.removeFromSuperlayer()
            self.previewLayer = nil
        }
    }
    
    // MARK: Helper Methods for Error Presentation
    
    fileprivate func presentErrorAlert(withTitle title: String = "Unexpected Failure", message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        self.present(alertController, animated: true)
    }
    
    fileprivate func presentError(_ error: NSError) {
        self.presentErrorAlert(withTitle: "Failed with error \(error.code)", message: error.localizedDescription)
    }
    
    // MARK: Helper Methods for Handling Device Orientation & EXIF
    
    fileprivate func radiansForDegrees(_ degrees: CGFloat) -> CGFloat {
        return CGFloat(Double(degrees) * Double.pi / 180.0)
    }
    
    fileprivate func exifOrientationForDeviceOrientation(_ deviceOrientation: UIDeviceOrientation) -> CGImagePropertyOrientation {
        
        switch deviceOrientation {
        case .portraitUpsideDown:
            return .rightMirrored
            
        case .landscapeLeft:
            return .downMirrored
            
        case .landscapeRight:
            return .upMirrored
            
        default:
            return .leftMirrored
        }
    }
    
    fileprivate func exifOrientationForCurrentDeviceOrientation() -> CGImagePropertyOrientation {
        return exifOrientationForDeviceOrientation(UIDevice.current.orientation)
    }
}

extension ARMotionViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func initializePickerView() {
        self.ARMotionCollectionView.delegate = self
        self.ARMotionCollectionView.dataSource = self
    }
}

extension ARMotionViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func initializeCollectionView() {
        self.filterCollectionView.delegate = self
        self.filterCollectionView.dataSource = self
    }
}
