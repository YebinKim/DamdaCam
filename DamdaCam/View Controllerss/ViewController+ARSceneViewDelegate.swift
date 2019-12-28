//
//  ViewController+ARSceneViewDelegate.swift
//  DamdaCam
//
//  Created by 김예빈 on 2018. 12. 8..
//  Copyright © 2018년 김예빈. All rights reserved.
//

import ARKit

extension ViewController: ARSCNViewDelegate, ARSessionDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        node.simdTransform = anchor.transform
        
        if let stroke = getStroke(for: anchor) {
            print ("did add: \(node.position)")
            print ("stroke first position: \(stroke.points[0])")
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
            
            if (strokes.contains(stroke)) {
                if let index = strokes.index(of: stroke) {
                    strokes.remove(at: index)
                }
            }
            stroke.cleanup()
            
//            print("Stroke removed.  Total strokes=\(strokes.count)")
            
            DispatchQueue.main.async {
                self.uiViewController?.clearAllButton.isHidden = self.shouldHideTrashButton()
                if (self.mode == .DRAW && self.strokes.count == 0) { self.uiViewController?.showDrawingPrompt() }
                UIAccessibility.post(notification: UIAccessibility.Notification.layoutChanged, argument: nil)
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if (touchPoint != .zero) {
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
            if (!hasInitialTracking) {
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
    func shouldShowTrackingIndicator()->Bool {
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
        
        if (arError.code == .cameraUnauthorized) {
            let alertController = UIAlertController(title: NSLocalizedString("error_resuming_session", comment: "Sorry something went wrong"), message: NSLocalizedString("error_camera_not_available", comment: "Sorry, something went wrong. Please try again."), preferredStyle: .alert)
            let okAction = UIAlertAction(title: NSLocalizedString("ok", comment: "OK"), style: .default) { (action) in
                alertController.dismiss(animated: true, completion: nil)
            }
            alertController.addAction(okAction)
            uiViewController?.present(alertController, animated: true, completion: nil)
        }
        
        //        displayErrorMessage(title: "We're sorry!", message: sessionErrorMsg, allowRestart: isRecoverable)
    }
    
    func registerGestureRecognizers(view: UIView) {
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
    
    @objc func nodePan(sender: UIPanGestureRecognizer){
        guard let pointOfView = self.sceneView.pointOfView else {return}
        let transform = pointOfView.transform
        let orientation = SCNVector3(-transform.m31 / 2.0, -transform.m32 / 2.0, -transform.m33 / 2.0)
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        let frontOfCamera = orientation + location
        
        let sceneView = self.sceneView!
        let panLocation = sender.location(in: sceneView)
        
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
        
        let sceneView = self.sceneView!
        let tapLocation = sender.location(in: sceneView)
        
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
        
        let sceneView = self.sceneView!
        let holdLocation = sender.location(in: sceneView)
        
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
        
        let sceneView = self.sceneView!
        let pinchLocation = sender.location(in: sceneView)
        
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
