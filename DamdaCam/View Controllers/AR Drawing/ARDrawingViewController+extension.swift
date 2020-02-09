//
//  ARDrawingViewController+extension.swift
//  DamdaCam
//
//  Created by Yebin Kim on 2020/01/24.
//  Copyright © 2020 김예빈. All rights reserved.
//

import ARKit
import ReplayKit

extension ARDrawingViewController: ARDrawingUIViewControllerDelegate {
    
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
        if let anchor = makeAnchor(at: touchPoint) {
            stroke.anchor = anchor
            stroke.points.append(SCNVector3Zero)
            stroke.touchStart = touchPoint
            stroke.lineWidth = strokeSize
            
            strokes.append(stroke)
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
        if let recorder = screenRecorder, recorder.isRecording { return false }
        return true
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
        let snapShot = sceneView.snapshot()
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
            self.uiViewController?.configureAccessibility()
            
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
        //        progressCircle.stop()
        screenRecorder?.stopRecording(handler: { (previewViewController, error) in
            DispatchQueue.main.async {
                guard error == nil, let preview = previewViewController else {
                    return
                }
                self.uiViewController?.recordingHasEnded()
                previewViewController?.previewControllerDelegate = self as RPPreviewViewControllerDelegate
                previewViewController?.modalPresentationStyle = .overFullScreen
                
                self.present(preview, animated: true, completion: nil)
                self.uiWindow?.isHidden = true
            }
        })
    }
    
    func undoLastStroke(sender: UIButton?) {
        resetTouches()
        
        if let lastStroke = strokes.last {
            if let anchor = lastStroke.anchor {
                sceneView.session.remove(anchor: anchor)
            }
        }
    }
    
    func clearStrokesTapped(sender: UIButton?) {
        self.resetTouches()
        self.clearAllStrokes()
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
    
    func shouldHideTrashButton() -> Bool {
        if strokes.count > 0 {
            return false
        }
        return true
    }
    
    func shouldHideUndoButton() -> Bool {
        if strokes.count > 0 {
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
        text.font = Properties.shared.font.regular(5.0)
        text.alignmentMode = CATextLayerAlignmentMode.center.rawValue
        
        guard let pointOfView = sceneView.pointOfView else {return}
        let transform = pointOfView.transform   // 변환 행렬
        let orientation = SCNVector3(-transform.m31 / 2.0, -transform.m32 / 2.0, -transform.m33 / 2.0)   // 방향은 3번째 열에 정보를 담고 있음, 일반적인 오른손잡이 규칙에 따를 수 있게 값을 뒤집어줌
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)  // 위치는 4번째 열에 정보를 담고 있음
        let frontOfCamera: SCNVector3 = orientation + location  // CNVector 타입에 일반적인 + 연산자 사용 불가능하기 때문에 연산자 오버로딩, 드로잉이 될 위치
        
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
    func create3DFigure(_ figure: Figure) {
        guard let pointOfView = sceneView.pointOfView else {return}
        let transform = pointOfView.transform
        let orientation = SCNVector3(-transform.m31 / 2.0, -transform.m32 / 2.0, -transform.m33 / 2.0)
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        let frontOfCamera: SCNVector3 = orientation + location
        
        let node = SCNNode()
        let layer = CALayer()
        
        switch figure.shape {
        case .rectangle:
            node.geometry = SCNBox(width: 5.0, height: 5.0, length: figure.depth, chamferRadius: 0.0)
            layer.frame = CGRect(x: 0, y: 0, width: 5.0, height: 5.0)
        case .rounded:
            node.geometry = SCNBox(width: 5.0, height: 5.0, length: figure.depth, chamferRadius: 2.0)
            layer.frame = CGRect(x: 0, y: 0, width: 5.0, height: 5.0)
            layer.cornerRadius = 2.0
        case .circle:
            node.geometry = SCNSphere(radius: figure.width)
        case .triangle, .heart:
            let centerPoint = CGPoint(x: CGFloat(frontOfCamera.x), y: CGFloat(frontOfCamera.y))
            let path = draw3DShape(figure, centerPoint: centerPoint)
            let nodeShape = SCNShape(path: path, extrusionDepth: figure.depth)
            node.geometry = nodeShape
        }
        
        if figure.fillState {
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
    
    func draw3DShape(_ figure: Figure, centerPoint: CGPoint) -> UIBezierPath {
        var path = UIBezierPath()
        let originalRect = CGRect(center: centerPoint, size: CGSize(width: 5.0, height: 5.0))
        
        switch figure.shape {
        case .triangle:
            path = UIBezierPath()
            path.move(to: CGPoint(x: originalRect.minX, y: originalRect.minY))
            path.addLine(to: CGPoint(x: originalRect.maxX, y: originalRect.minY))
            path.addLine(to: CGPoint(x: originalRect.midX, y: originalRect.maxX))
            path.close()
            
        case .heart:
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
            
            path.addArc(withCenter: CGPoint(x: scaledRect.origin.x + (scaledRect.size.width/4), y: scaledRect.origin.y + (scaledRect.size.height/4)),
                        radius: (scaledRect.size.width/4),
                        startAngle: CGFloat(Double.pi),
                        endAngle: 0,
                        clockwise: true)
            
            path.addArc(withCenter: CGPoint(x: scaledRect.origin.x + (scaledRect.size.width * 3/4), y: scaledRect.origin.y + (scaledRect.size.height/4)),
                        radius: (scaledRect.size.width/4),
                        startAngle: CGFloat(Double.pi),
                        endAngle: 0,
                        clockwise: true)
            
            path.addCurve(to: CGPoint(x: originalRect.midX, y: scaledRect.origin.y + scaledRect.size.height),
                          controlPoint1: CGPoint(x: scaledRect.origin.x + scaledRect.size.width, y: scaledRect.origin.y + (scaledRect.size.height/2)),
                          controlPoint2: CGPoint(x: scaledRect.origin.x + (scaledRect.size.width/2), y: scaledRect.origin.y + (scaledRect.size.height*3/4)) )
            
            path.close()
            path.apply(CGAffineTransform(rotationAngle: .pi))
            
        default: break
        }
        
        return path
    }
    
}

extension ARDrawingViewController: ARSCNViewDelegate, ARSessionDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        node.simdTransform = anchor.transform
        
        if let stroke = getStroke(for: anchor) {
            print("did add: \(node.position)")
            print("stroke first position: \(stroke.points[0])")
            stroke.node = node
            
            DispatchQueue.main.async {
                self.updateGeometry(stroke)
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let stroke = getStroke(for: anchor) {
            print("Renderer did update node transform: \(node.transform) and anchorTranform: \(anchor.transform)")
            stroke.node = node
            
            DispatchQueue.main.async {
                self.updateGeometry(stroke)
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        if let stroke = getStroke(for: node) {
            
            if strokes.contains(stroke) {
                if let index = strokes.index(of: stroke) {
                    strokes.remove(at: index)
                }
            }
            stroke.cleanup()
            
            //            print("Stroke removed.  Total strokes=\(strokes.count)")
            
            DispatchQueue.main.async {
                self.uiViewController?.clearAllButton.isHidden = self.shouldHideTrashButton()
                if self.mode == .DRAW && self.strokes.count == 0 {
                    self.uiViewController?.showDrawingPrompt()
                }
                UIAccessibility.post(notification: UIAccessibility.Notification.layoutChanged, argument: nil)
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if touchPoint != .zero {
            if let stroke = strokes.last {
                DispatchQueue.main.async {
                    self.updateLine(for: stroke)
                }
            }
        }
        
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        switch camera.trackingState {
        case .notAvailable:
            print("No tracking")
            if shouldShowTrackingIndicator() {
                enterTrackingState()
            }
            
        case .limited(let reason):
            print("Limited tracking")
            if shouldShowTrackingIndicator() {
                if reason == .relocalizing {
                    NSLog("Relocalizing...")
                    
                    // while relocalizing after interruption, only attempt for 5 seconds, then reset, and only when not paired
                    if strokes.count > 0 && resumeFromInterruptionTimer == nil {
                        resumeFromInterruptionTimer = Timer(timeInterval: 5, repeats: false, block: { (timer) in
                            NSLog("Resetting ARSession because relocalizing took too long")
                            DispatchQueue.main.async {
                                self.resumeFromInterruptionTimer?.invalidate()
                                self.resumeFromInterruptionTimer = nil
                                self.configureARSession(runOptions: [ARSession.RunOptions.resetTracking])
                            }
                        })
                        RunLoop.main.add(resumeFromInterruptionTimer!, forMode: RunLoop.Mode.default)
                    } else { // if strokes.count == 0 {
                        // only do the timer if user has drawn strokes
                        self.configureARSession(runOptions: [.resetTracking, .removeExistingAnchors])
                    }
                }
                enterTrackingState()
            }
            
        case .normal:
            if !hasInitialTracking {
                hasInitialTracking = true
            }
            if !shouldShowTrackingIndicator() {
                exitTrackingState()
            }
        }
    }
    
    /// Hold onto tracking mode exiting (unless it is already .TRACKING) enter .TRACKING and start animation
    func enterTrackingState() {
        print("ViewController: enterTrackingState")
        resetTouches()
        
        trackingMessage = .looking
        
        if trackingMessageTimer == nil {
            trackingMessage = .looking
            
            trackingMessageTimer = Timer(timeInterval: 3, repeats: false, block: { (timer) in
                self.trackingMessage = .lookingEscalated
                
                // need to set mode again to update tracking message
                self.mode = .TRACKING
                
                self.trackingMessageTimer?.invalidate()
                self.trackingMessageTimer = nil
            })
            RunLoop.main.add(trackingMessageTimer!, forMode: RunLoop.Mode.default)
        }
        
        if mode != .TRACKING {
            print("Entering tracking with mode: \(mode)")
            modeBeforeTracking = mode
        }
        mode = .TRACKING
    }
    
    /// Clean up when returning to normal tracking
    func exitTrackingState() {
        print("ViewController: exitTrackingState")
        
        if resumeFromInterruptionTimer != nil { print("Relocalizing successful.") }
        
        trackingMessageTimer?.invalidate()
        trackingMessageTimer = nil
        
        resumeFromInterruptionTimer?.invalidate()
        resumeFromInterruptionTimer = nil
        
        // Restore previous mode set in enterTrackingState and updated in mode changes
        if let previousMode = modeBeforeTracking {
            mode = previousMode
            modeBeforeTracking = nil
        }
    }
    
    /// In pair mode, only show tracking indicator in certain states
    func shouldShowTrackingIndicator() -> Bool {
        var shouldShow = false
        if let trackingState = sceneView.session.currentFrame?.camera.trackingState {
            switch trackingState {
            case .limited:
                shouldShow = true
            default:
                break
            }
        }
        // when rejoining after background, continue to show tracking message even when no longer tracking until cloud anchor is re-resolved
        if shouldRetryAnchorResolve { shouldShow = true }
        
        return shouldShow
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        guard let arError = error as? ARError else { return }
        
        let nsError = error as NSError
        var sessionErrorMsg = "\(nsError.localizedDescription) \(nsError.localizedFailureReason ?? "")"
        if let recoveryOptions = nsError.localizedRecoveryOptions {
            for option in recoveryOptions {
                sessionErrorMsg.append("\(option).")
            }
        }
        
        let isRecoverable = (arError.code == .worldTrackingFailed)
        if isRecoverable {
            sessionErrorMsg += "\nYou can try resetting the session or quit the application."
        } else {
            sessionErrorMsg += "\nThis is an unrecoverable error that requires to quit the application."
        }
        
        if arError.code == .cameraUnauthorized {
            let alertController = UIAlertController(title: NSLocalizedString("error_resuming_session",
                                                    comment: "Sorry something went wrong"),
                                                    message: NSLocalizedString("error_camera_not_available",
                                                    comment: "Sorry, something went wrong. Please try again."),
                                                    preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: NSLocalizedString("ok", comment: "OK"), style: .default) { _ in
                alertController.dismiss(animated: true, completion: nil)
            }
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
        }
        
        //        displayErrorMessage(title: "We're sorry!", message: sessionErrorMsg, allowRestart: isRecoverable)
    }
    
    func registerNodeGestureRecognizers(view: UIView) {
        //        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(nodePan))
        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(nodeRemove))
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(nodeScale))
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(nodeMove))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2     // 더블탭
        longPressGestureRecognizer.minimumPressDuration = 0.2   // longPress 딜레이 시간 설정
        //        view.addGestureRecognizer(panGestureRecognizer)
        view.addGestureRecognizer(doubleTapGestureRecognizer)
        view.addGestureRecognizer(pinchGestureRecognizer)
        view.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    @objc func nodePan(sender: UIPanGestureRecognizer) {
        guard let pointOfView = self.sceneView.pointOfView else {return}
        let transform = pointOfView.transform
        let orientation = SCNVector3(-transform.m31 / 2.0, -transform.m32 / 2.0, -transform.m33 / 2.0)
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        let frontOfCamera = orientation + location
        
        let panLocation = sender.location(in: self.sceneView)
        let hitTest = sceneView.hitTest(panLocation)
        
        if !hitTest.isEmpty {
            //            if(movingNow){
            let result = hitTest.first!
            result.node.position = frontOfCamera
            //                tappedObjectNode.position = result
            //            } else {
            // view is the view containing the sceneView
            //                let hitResults = sceneView.hitTest(sender.location(in: view), options: nil)
            //                if hitResults.count > 0 {
            //                    movingNow = false
            //                }
            //            }
        }
    }
    
    @objc func nodeRemove(sender: UITapGestureRecognizer) {
        sender.cancelsTouchesInView = false
        
        let tapLocation = sender.location(in: self.sceneView)
        let hitTest = sceneView.hitTest(tapLocation)   // 오브젝트의 위치와 손가락 위치가 같을 때만 대입
        
        if !hitTest.isEmpty {
            let result = hitTest.first!
            result.node.removeFromParentNode()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            sender.cancelsTouchesInView = true
        }
    }
    
    @objc func nodeMove(sender: UILongPressGestureRecognizer) {
        sender.cancelsTouchesInView = false
        
        guard let pointOfView = self.sceneView.pointOfView else {return}
        let transform = pointOfView.transform
        let orientation = SCNVector3(-transform.m31 / 2.0, -transform.m32 / 2.0, -transform.m33 / 2.0)
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        let frontOfCamera = orientation + location
        
        let holdLocation = sender.location(in: self.sceneView)
        let hitTest = sceneView.hitTest(holdLocation)   // 오브젝트의 위치와 손가락 위치가 같을 때만 대입
        
        if !hitTest.isEmpty {
            let result = hitTest.first!
            if sender.state != .ended {
                result.node.position = frontOfCamera
                //                movingNow = true
                //                tappedObjectNode = result.node
                //                let rotation = SCNAction.rotateBy(x: 0, y: CGFloat(360.degreesToRadians), z: 0, duration: 1)
                //                let forever = SCNAction.repeatForever(rotation)
                //                result.node.runAction(forever)  // 오브젝트 회전
            } else {
                //                result.node.removeAllActions()
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            sender.cancelsTouchesInView = true
        }
    }
    
    @objc func nodeScale(sender: UIPinchGestureRecognizer) {
        sender.cancelsTouchesInView = false
        
        let pinchLocation = sender.location(in: self.sceneView)
        
        let hitTest = sceneView.hitTest(pinchLocation)  // 오브젝트의 위치와 pinch 위치가 같을 때만 대입
        
        // hitTest에 값이 있을 때 -> 오브젝트의 위치와 hitTest 위치가 같을 때
        if !hitTest.isEmpty {
            let results = hitTest.first!
            let node = results.node
            
            // pinch 거리에 따라 오브젝트 크기 조절
            let pinchAction = SCNAction.scale(by: sender.scale, duration: 0)    // duration: 0 -> pinch 하는 즉시 크기가 조절됨(딜레이가 없음)
            print(sender.scale)
            node.runAction(pinchAction) // 오브젝트 크기가 조절됨
            sender.scale = 1.0  // 값이 기하급수적으로 커지지 않도록 기준값을 1.0 으로 설정
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            sender.cancelsTouchesInView = true
        }
    }
}

// MARK: - ReplayKit Preview Delegate
extension ARDrawingViewController: RPPreviewViewControllerDelegate {
    
    func previewController(_ previewController: RPPreviewViewController, didFinishWithActivityTypes activityTypes: Set<String>) {
        if activityTypes.contains(UIActivity.ActivityType.postToVimeo.rawValue)
            || activityTypes.contains(UIActivity.ActivityType.postToFlickr.rawValue)
            || activityTypes.contains(UIActivity.ActivityType.postToWeibo.rawValue)
            || activityTypes.contains(UIActivity.ActivityType.postToTwitter.rawValue)
            || activityTypes.contains(UIActivity.ActivityType.postToFacebook.rawValue)
            || activityTypes.contains(UIActivity.ActivityType.mail.rawValue)
            || activityTypes.contains(UIActivity.ActivityType.message.rawValue) {
            
        }
        
        //        progressCircle.reset()
        //        recordBackgroundView.alpha = 0
        
        previewController.dismiss(animated: true) {
            
            self.uiWindow?.isHidden = false
            
        }
    }
}

// MARK: - RPScreenRecorderDelegate
extension ARDrawingViewController: RPScreenRecorderDelegate {
    func screenRecorderDidChangeAvailability(_ screenRecorder: RPScreenRecorder) {
        if screenRecorder.isAvailable == false {
            let alert = UIAlertController.init(title: "Screen Recording Failed", message: "Screen Recorder is no longer available.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
                self.dismiss(animated: true, completion: nil)
            }))
            self.present(self, animated: true, completion: nil)
        }
    }
}
