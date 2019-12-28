//
//  ViewController+InterfaceViewControllerDelegate.swift
//  DamdaCam
//
//  Created by 김예빈 on 2018. 12. 8..
//  Copyright © 2018년 김예빈. All rights reserved.
//

import UIKit
import SceneKit
import CoreMedia
import AVFoundation
import ReplayKit

let sm = "float u = _surface.diffuseTexcoord.x; \n" +
    "float v = _surface.diffuseTexcoord.y; \n" +
    "int u100 = int(u * 100); \n" +
    "int v100 = int(v * 100); \n" +
    "if (u100 % 99 == 0 || v100 % 99 == 0) { \n" +
    "  // do nothing \n" +
    "} else { \n" +
    "    discard_fragment(); \n" +
"} \n"

extension ViewController: InterfaceViewControllerDelegate {
    // MARK: - Handle Touch
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touchInView = touches.first?.location(in: sceneView), mode == .DRAW else {
            return
        }
        
        // hold onto touch location for projection
        touchPoint = touchInView
        
        // begin a neㅇ stroke
        let stroke = Stroke()
        print("Touch")
        if let anchor = makeAnchor(at:touchPoint) {
            stroke.anchor = anchor
            stroke.points.append(SCNVector3Zero)
            stroke.touchStart = touchPoint
            stroke.lineWidth = strokeSize
            
            strokes.append(stroke)
//            self.uiViewController?.undoButton.isHidden = shouldHideUndoButton()
//            self.uiViewController?.clearAllButton.isHidden = shouldHideTrashButton()
            sceneView.session.add(anchor: anchor)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touchInView = touches.first?.location(in: sceneView), mode == .DRAW, touchPoint != .zero else {
            return
        }
        
        // hold onto touch location for projection
        touchPoint = touchInView
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchPoint = CGPoint.zero
        strokes.last?.resetMemory()
        
        // for some reason putting this in the touchesBegan does not trigger
        UIAccessibility.post(notification: UIAccessibility.Notification.layoutChanged, argument: nil)
        
    }
    
    override var shouldAutorotate: Bool {
        get {
            if let recorder = screenRecorder, recorder.isRecording { return false }
            return true
        }
    }
    
    func setPreviewSize() {
        if previewSize == 0 {
            sceneView.frame = CGRect(x: 0, y: 0, width: 375, height: 667)
        } else if previewSize == 1 {
            sceneView.frame = CGRect(x: 0, y: 60, width: 375, height: 440)
        } else if previewSize == 2 {
            sceneView.frame = CGRect(x: 0, y: 0, width: 375, height: 500)
        }
    }
    
    // MARK: - UI Methods
    
    func takePhoto() {
        //1. Create A Snapshot
        let snapShot = sceneView.snapshot()
        
        //2. Save It The Photos Album
        UIImageWriteToSavedPhotosAlbum(snapShot, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        
        if let error = error {
            print("Error Saving ARDrawing Scene \(error)")
        } else {
            print("ARDrawing Scene Successfully Saved")
        }
    }
    
    func recordTapped(sender: UIButton?) {
        resetTouches()
        
        if screenRecorder?.isRecording == true {
            // Reset record button accessibility label to original value
            uiViewController?.configureAccessibility()
            
            stopRecording()
        } else {
            sender?.accessibilityLabel = NSLocalizedString("content_description_record_stop", comment: "Stop Recording")
            startRecording()
        }
    }
    
    func startRecording() {
        screenRecorder?.startRecording(handler: { (error) in
            guard error == nil else {
                return
            }
            self.uiViewController?.recordingWillStart()
            
        })
    }
    
    func stopRecording() {
//        uiViewController?.progressCircle.stop()
        screenRecorder?.stopRecording(handler: { (previewViewController, error) in
            DispatchQueue.main.async {
                guard error == nil, let preview = previewViewController else {
                    return
                }
                self.uiViewController?.recordingHasEnded()
                previewViewController?.previewControllerDelegate = self
                previewViewController?.modalPresentationStyle = .overFullScreen
                
                self.present(preview, animated: true, completion:nil)
                self.uiWindow?.isHidden = true
            }
        })
    }
    
    /// Remove anchor for last stroke.
    /// Stroke cleanup in renderer(renderer:didRemove:for:) delegate call
    func undoLastStroke(sender: UIButton?) {
        resetTouches()
        
        if let lastStroke = strokes.last {
            if let anchor = lastStroke.anchor {
                sceneView.session.remove(anchor: anchor)
            }
        }
    }
    
    /// Loops through strokes removing anchor for each stroke.
    /// Stroke cleanup in renderer(renderer:didRemove:for:) delegate call
    func clearStrokesTapped(sender: UIButton?) {
        resetTouches()
        
//        let clearMessageKey = "드로잉을 모두 지울까요?"
//        let clearTitleKey = "드로잉 지우기"
//
//        let alertController = UIAlertController(
//            title: NSLocalizedString(clearTitleKey, comment: "Clear Drawing"),
//            message: NSLocalizedString(clearMessageKey, comment: "Clear your drawing?"),
//            preferredStyle: .alert)
//        let cancelAction = UIAlertAction(title: NSLocalizedString("아니요", comment: "Cancel"), style: .cancel) { (cancelAction) in
//            alertController.dismiss(animated: true, completion: nil)
//        }
//
//        let okAction = UIAlertAction(title: NSLocalizedString("네", comment: "Clear"), style: .destructive) { (okAction) in
//            alertController.dismiss(animated: true, completion: nil)
            self.clearAllStrokes()
//
//            if self.mode == .DRAW {
//                self.uiViewController?.showDrawingPrompt()
//            }
//        }
//        alertController.addAction(cancelAction)
//        alertController.addAction(okAction)
//        self.uiViewController?.present(alertController, animated: true, completion: nil)
    }
    
    func clearAllStrokes() {
        for stroke in self.strokes {
            if let anchor = stroke.anchor {
                self.sceneView.session.remove(anchor: anchor)
            }
        }
    }
    
    func setTouchState(_ state: Bool) {
        touchState = state
    }
    
    func getTouchState() -> Bool {
        return touchState
    }
    
    func setStrokeSize(_ radius: Float) {
        strokeSize = radius
    }
    
    func getStrokeSize() -> Float {
        return strokeSize
    }
    
    func setStrokeNeon(_ state: Bool) {
        neonState = state
    }
    
    func getStrokeNeon() -> Bool {
        return neonState
    }
    
    func setStrokeColor(_ selectedColor: CGColor) {
        color = selectedColor
    }
    
    func getStrokeColor() -> CGColor {
        return color
    }
    
    func shouldHideTrashButton()->Bool {
        if (strokes.count > 0) {
            return false
        }
        return true
//        return false
    }

    func shouldHideUndoButton()->Bool {
        if (strokes.count > 0) {
            return false
        }
        return true
    }
    
    func resetTouches() {
        touchPoint = .zero
    }
    
    // Text Set
    func create3DText(message: String, depth: CGFloat, color: UIColor, align: Int) {
        let text = SCNText(string: message, extrusionDepth: depth)
        text.firstMaterial?.diffuse.contents = color
        text.font = UIFont(name: "NotoSansCJKkr-Regular", size: 5.0)
        text.alignmentMode = CATextLayerAlignmentMode.center.rawValue
        
        guard let pointOfView = sceneView.pointOfView else {return}
        let transform = pointOfView.transform   // 변환행렬
        let orientation = SCNVector3(-transform.m31 / 2.0, -transform.m32 / 2.0, -transform.m33 / 2.0)   // 방향은 3번째 열에 정보를 담고 있음, 일반적인 오른손잡이 규칙에 따를 수 있게 값을 뒤집어줌
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)  // 위치는 4번째 열에 정보를 담고 있음
        let frontOfCamera = orientation + location  // CNVector 타입에 일반적인 + 연산자 사용 불가능하기 때문에 연산자 오버로딩, 드로잉이 될 위치
        
        let node = SCNNode()
        node.position = frontOfCamera
        node.orientation = pointOfView.orientation
        node.scale = SCNVector3(x: 0.05, y: 0.05, z: 0.05)
        node.geometry = text
        
        node.light = SCNLight()
        node.light?.type = SCNLight.LightType.directional
        node.light?.color = UIColor.white
        node.light?.castsShadow = true
        node.light?.automaticallyAdjustsShadowProjection = true
        node.light?.shadowSampleCount = 64
        node.light?.shadowRadius = 16
        node.light?.shadowMode = .deferred
        node.light?.shadowMapSize = CGSize(width: 2048, height: 2048)
        node.light?.shadowColor = UIColor.black.withAlphaComponent(0.75)
        
        if align == 0 {
            let (minVec, maxVec) = node.boundingBox
            node.pivot = SCNMatrix4MakeTranslation(0, (maxVec.y - minVec.y) / 2 + minVec.y, 0)
        } else if align == 1 {
            let (minVec, maxVec) = node.boundingBox
            node.pivot = SCNMatrix4MakeTranslation((maxVec.x - minVec.x) / 2 + minVec.x, (maxVec.y - minVec.y) / 2 + minVec.y, 0)
        } else if align == 2 {
            let (minVec, maxVec) = node.boundingBox
            node.pivot = SCNMatrix4MakeTranslation(maxVec.x, (maxVec.y - minVec.y) / 2 + minVec.y, 0)
        }
        
        sceneView.scene.rootNode.addChildNode(node)
    }
    
    // Figure Set
    func create3DFigure(shape: String, fillState: Bool, width: CGFloat, depth: CGFloat, color: UIColor) {
        guard let pointOfView = sceneView.pointOfView else {return}
        let transform = pointOfView.transform
        let orientation = SCNVector3(-transform.m31 / 2.0, -transform.m32 / 2.0, -transform.m33 / 2.0)
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        let frontOfCamera = orientation + location
        
        let node = SCNNode()
        let layer = CALayer()
        
        let centerPoint = CGPoint(x: CGFloat(frontOfCamera.x), y: CGFloat(frontOfCamera.y))
        let path = draw3DShape(shape: shape, centerPoint: centerPoint)
        let nodeShape = SCNShape(path: path, extrusionDepth: depth)
        
        if shape == "Rectangle" {
            node.geometry = SCNBox(width: 5.0, height: 5.0, length: depth, chamferRadius: 0.0)
            layer.frame = CGRect(x: 0, y: 0, width: 5.0, height: 5.0)
        }
        
        if shape == "Rounded" {
            node.geometry = SCNBox(width: 5.0, height: 5.0, length: depth, chamferRadius: 2.0)
            layer.frame = CGRect(x: 0, y: 0, width: 5.0, height: 5.0)
            layer.cornerRadius = 2.0
        }
        
        if shape == "Circle" {
            node.geometry = SCNSphere(radius: width)
        }
        
        if shape == "Triangle" || shape == "Heart" {
            node.geometry = nodeShape
        }
        
        if fillState {
//            layer.backgroundColor = color.cgColor
            
            let material = SCNMaterial()
            material.diffuse.contents = color
            material.isDoubleSided = true
            node.geometry!.materials = [material]
        } else {
//            layer.borderColor = color.cgColor
//            layer.borderWidth = width * 100
            
            let material = SCNMaterial()
            material.diffuse.contents = color
            material.isDoubleSided = true
            node.geometry!.materials = [material]
        }
        
        node.position = frontOfCamera
        node.orientation = pointOfView.orientation
        node.scale = SCNVector3(x: 0.05, y: 0.05, z: 0.05)
        
        node.light = SCNLight()
        node.light?.type = SCNLight.LightType.directional
        node.light?.color = UIColor.white
        node.light?.castsShadow = true
        node.light?.automaticallyAdjustsShadowProjection = true
        node.light?.shadowSampleCount = 64
        node.light?.shadowRadius = 16
        node.light?.shadowMode = .deferred
        node.light?.shadowMapSize = CGSize(width: 2048, height: 2048)
        node.light?.shadowColor = UIColor.black.withAlphaComponent(0.75)
        
        sceneView.scene.rootNode.addChildNode(node)
    }
    
    func draw3DShape(shape: String, centerPoint: CGPoint) -> UIBezierPath {
        var path = UIBezierPath()
        let originalRect = CGRect(center: centerPoint, size: CGSize(width: 5.0, height: 5.0))
        
        if shape == "Triangle" {
            path = UIBezierPath()
            path.move(to: CGPoint(x: originalRect.minX, y: originalRect.minY))
            path.addLine(to: CGPoint(x: originalRect.maxX, y: originalRect.minY))
            path.addLine(to: CGPoint(x: originalRect.midX, y: originalRect.maxX))
            path.close()
        }
        
        if shape == "Heart" {
            path = UIBezierPath()
            let scale: Double = 1.0
            
            let scaledWidth = (originalRect.size.width * CGFloat(scale))
            let scaledXValue = originalRect.minX
            let scaledHeight = (originalRect.size.height * CGFloat(scale))
            let scaledYValue = originalRect.minY
            
            let scaledRect = CGRect(x: scaledXValue, y: scaledYValue, width: scaledWidth, height: scaledHeight)
            
            path.move(to: CGPoint(x: originalRect.midX, y: scaledRect.origin.y + scaledRect.size.height))
            
            
            path.addCurve(to: CGPoint(x: scaledRect.origin.x, y: scaledRect.origin.y + (scaledRect.size.height/4)),
                          controlPoint1: CGPoint(x: scaledRect.origin.x + (scaledRect.size.width/2), y: scaledRect.origin.y + (scaledRect.size.height*3/4)) ,
                          controlPoint2: CGPoint(x: scaledRect.origin.x, y: scaledRect.origin.y + (scaledRect.size.height/2)) )
            
            path.addArc(withCenter: CGPoint(x: scaledRect.origin.x + (scaledRect.size.width/4),y: scaledRect.origin.y + (scaledRect.size.height/4)),
                        radius: (scaledRect.size.width/4),
                        startAngle: CGFloat(Double.pi),
                        endAngle: 0,
                        clockwise: true)
            
            path.addArc(withCenter: CGPoint(x: scaledRect.origin.x + (scaledRect.size.width * 3/4),y: scaledRect.origin.y + (scaledRect.size.height/4)),
                        radius: (scaledRect.size.width/4),
                        startAngle: CGFloat(Double.pi),
                        endAngle: 0,
                        clockwise: true)
            
            path.addCurve(to: CGPoint(x: originalRect.midX, y: scaledRect.origin.y + scaledRect.size.height),
                          controlPoint1: CGPoint(x: scaledRect.origin.x + scaledRect.size.width, y: scaledRect.origin.y + (scaledRect.size.height/2)),
                          controlPoint2: CGPoint(x: scaledRect.origin.x + (scaledRect.size.width/2), y: scaledRect.origin.y + (scaledRect.size.height*3/4)) )
            
            path.close()
            path.apply(CGAffineTransform(rotationAngle: .pi))
        }
        
        return path
    }
}

func +(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
    
}

extension Int {
    
    var degreesToRadians: Double { return Double(self) * .pi/180}
}
