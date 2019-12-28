//
//  ViewController.swift
//  DamdaCam
//
//  Created by 김예빈 on 2018. 11. 28..
//  Copyright © 2018년 김예빈. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import ReplayKit

enum ViewMode {
    case DRAW
    case TRACKING
}

var previewSize: Int = 0

class ViewController: UIViewController {
    
    @IBOutlet var sceneView: ARSCNView!
    let configuration = ARWorldTrackingConfiguration()
    
    // AR Drawing
    /// store current touch location in view
    var touchPoint: CGPoint = .zero
    var touchState: Bool = true
    var movingNow = false
    var tappedObjectNode = SCNNode()
    
    /// SCNNode floating in front of camera the distance drawing begins
    var hitNode: SCNNode?
    
    /// array of strokes a user has drawn in current session
    var strokes: [Stroke] = [Stroke]()
    
    var shouldRetryAnchorResolve = false
    
    /// Currently selected stroke size
    var strokeSize: Float = 0.0010
    
    var neonState: Bool = false
    var color: CGColor = UIColor.white.cgColor
    
    /// After 3 seconds of tracking changes trackingMessage to escalated value
    var trackingMessageTimer: Timer?
    
    /// When session returns from interruption, hold time to limit relocalization
    var resumeFromInterruptionTimer: Timer?
    
    /// When in limited tracking mode, hold previous mode to return to
    var modeBeforeTracking: ViewMode?
    
    /// Most situations we show the looking message, but when relocalizing and currently paired, show anchorLost type
    var trackingMessage: TrackingMessageType = .looking
    
    /// capture first time establish tracking
    var hasInitialTracking = false
    
    var mode: ViewMode = .DRAW {
        didSet {
            switch mode {
            case .DRAW:
                if (strokes.count > 0) {
                    uiViewController?.hideDrawingPrompt()
                } else {
                    uiViewController?.showDrawingPrompt()
                }
                
                uiViewController?.drawingUIHidden(false)
                uiViewController?.stopTrackingAnimation()
                uiViewController?.messagesContainerView?.isHidden = true
                setStrokeVisibility(isHidden: false)
                UIAccessibility.post(notification: UIAccessibility.Notification.layoutChanged, argument: uiViewController?.touchView)
                
                //#if DEBUG
                //sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin]
                //#else
                sceneView.debugOptions = []
                //#endif
                
            case .TRACKING:
                uiViewController?.hideDrawingPrompt()
                uiViewController?.startTrackingAnimation(trackingMessage)
                
                // hiding fullBackground hides everything except close button
                setStrokeVisibility(isHidden: true)
                uiViewController?.touchView.isHidden = true
                UIAccessibility.post(notification: UIAccessibility.Notification.layoutChanged, argument: uiViewController?.trackingPromptLabel)
            }
            
            // if we're tracking and the mode changes, update our previous mode state
            if (modeBeforeTracking != nil && mode != .TRACKING) {
                print("Updating mode to return to after tracking: \(mode)")
                modeBeforeTracking = mode
            }
        }
    }
    
    // MARK: UI
    /// window with UI elements to keep them out of screen recording
    var uiWindow: UIWindow?
    
    /// view controller for ui elements
    var uiViewController: InterfaceViewController?
    
    
    // Video
    
    /// ReplayKit shared screen recorder
    var screenRecorder: RPScreenRecorder?
    
    /// writes CMSampleBuffer for screen recording
    var assetWriter: AVAssetWriter?
    
    /// holds asset writer settings for media
    var assetWriterInput: AVAssetWriterInput?
    
    /// temporary bool for toggling recording state
    var isRecording: Bool = false
    
    // MARK: - View State
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.sceneView.showsStatistics = true   // 프레임 정보와 렌더링 정보를 표시
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        hitNode = SCNNode()
        hitNode!.position = SCNVector3Make(0, 0, -0.4)  // 드로잉 거리 조절
        sceneView.pointOfView?.addChildNode(hitNode!)
        
//        self.registerGestureRecognizers()
        
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.shadowMode = .deferred
        ambientLight.light?.color = UIColor.white
        ambientLight.light?.type = SCNLight.LightType.ambient
        ambientLight.position = SCNVector3(x: 0,y: 5,z: 0)
        sceneView.scene.rootNode.addChildNode(ambientLight)
        sceneView.automaticallyUpdatesLighting = true   // lighting 설정
        
        setupUI()
        screenRecorder = RPScreenRecorder.shared()
        screenRecorder?.isMicrophoneEnabled = true
        
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil) { (notification) in
            self.touchPoint = .zero
        }
        
        // Neon Set
        if let path = Bundle.main.path(forResource: "NodeTechnique", ofType: "plist") {
            if let dict = NSDictionary(contentsOfFile: path)  {
                let dict2 = dict as! [String : AnyObject]
                let technique = SCNTechnique(dictionary:dict2)
                sceneView.technique = technique
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureARSession()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
        resetTouches()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        touchPoint = .zero
    }
    
    // MARK: - View Configuration
    
    func configureARSession(runOptions: ARSession.RunOptions = []) {
        // Create a session configuration
        configuration.planeDetection = [.horizontal]
        //  configuration.isAutoFocusEnabled = false
        
        // Run the view's session
        sceneView.session.run(configuration, options: runOptions)
        sceneView.session.delegate = self
    }
    
    /// Add new UIWindow with interface elements that forward touch events via the InterfaceViewControllerDelegate protocol
    func setupUI() {
        uiWindow = UIWindow(frame: UIScreen.main.bounds)
        let uiStoryboard = UIStoryboard(name: "UI", bundle: nil)
        uiViewController = uiStoryboard.instantiateInitialViewController() as? InterfaceViewController
        uiViewController?.touchDelegate = self
        uiWindow?.rootViewController = uiViewController
        
        uiWindow?.makeKeyAndVisible()
    }
    
    // MARK: - Stroke Code
    
    /// Places anchor on hitNode plane at point
    func makeAnchor(at point: CGPoint) -> ARAnchor? {
        
        guard let hitNode = hitNode else {
            return nil
        }
        let projectedOrigin = sceneView.projectPoint(hitNode.worldPosition)
        let offset = sceneView.unprojectPoint(SCNVector3Make(Float(point.x), Float(point.y), projectedOrigin.z))
        
        var blankTransform = matrix_float4x4(1)
        //        var transform = hitNode.simdWorldTransform
        blankTransform.columns.3.x = offset.x
        blankTransform.columns.3.y = offset.y
        blankTransform.columns.3.z = offset.z
        
        return ARAnchor(transform: blankTransform)
    }
    
    /// Updates stroke with new SCNVector3 point, and regenerates line geometry
    func updateLine(for stroke: Stroke) {
        if touchState {
            guard let _ = stroke.points.last, let strokeNode = stroke.node else {
                return
            }
            let offset = unprojectedPosition(for: stroke, at: touchPoint)
            let newPoint = strokeNode.convertPosition(offset, from: sceneView.scene.rootNode)
            
            stroke.lineWidth = strokeSize
            if (stroke.add(point: newPoint, neonState: neonState)) {
                updateGeometry(stroke)
            }
//            print("Total Points: \(stroke.points.count)")
        }
    }
    
    func updateGeometry(_ stroke: Stroke) {
        if touchState {
            if stroke.positionsVec3.count > 4 {
                let vectors = stroke.positionsVec3
                let sides = stroke.mSide
                let width = stroke.mLineWidth
                let lengths = stroke.mLength
                let totalLength = (stroke.drawnLocally) ? stroke.totalLength : stroke.animatedLength
                let line = LineGeometry(vectors: vectors,
                                        sides: sides,
                                        width: width,
                                        lengths: lengths,
                                        endCapPosition: totalLength,
                                        color: color)
                
                stroke.node?.geometry = line
                uiViewController?.hasDrawnInSession = true
                uiViewController?.hideDrawingPrompt()
            }
        }
    }
    
    // Stroke Helper Methods
    func unprojectedPosition(for stroke: Stroke, at touch: CGPoint) -> SCNVector3 {
        guard let hitNode = self.hitNode else {
            return SCNVector3Zero
        }
        
        let projectedOrigin = sceneView.projectPoint(hitNode.worldPosition)
        let offset = sceneView.unprojectPoint(SCNVector3Make(Float(touch.x), Float(touch.y), projectedOrigin.z))
        
        return offset
    }
    
    /// Checks user's strokes for match, then partner's strokes
    func getStroke(for anchor: ARAnchor) -> Stroke? {
        let matchStrokeArray = strokes.filter { (stroke) -> Bool in
            return stroke.anchor == anchor
        }
        
        return matchStrokeArray.first
    }
    
    /// Checks user's strokes for match, then partner's strokes
    func getStroke(for node: SCNNode) -> Stroke? {
        let matchStrokeArray = strokes.filter { (stroke) -> Bool in
            return stroke.node == node
        }
        
        return matchStrokeArray.first
    }
    
    func setStrokeVisibility(isHidden: Bool) {
        strokes.forEach { stroke in
            stroke.node?.isHidden = isHidden
        }
    }
}

// MARK: - ReplayKit Preview Delegate
extension ViewController : RPPreviewViewControllerDelegate {
    
    func previewController(_ previewController: RPPreviewViewController, didFinishWithActivityTypes activityTypes: Set<String>) {
        if activityTypes.contains(UIActivity.ActivityType.postToVimeo.rawValue)
            || activityTypes.contains(UIActivity.ActivityType.postToFlickr.rawValue)
            || activityTypes.contains(UIActivity.ActivityType.postToWeibo.rawValue)
            || activityTypes.contains(UIActivity.ActivityType.postToTwitter.rawValue)
            || activityTypes.contains(UIActivity.ActivityType.postToFacebook.rawValue)
            || activityTypes.contains(UIActivity.ActivityType.mail.rawValue)
            || activityTypes.contains(UIActivity.ActivityType.message.rawValue) {
            
        }
        
//        uiViewController?.progressCircle.reset()
//        uiViewController?.recordBackgroundView.alpha = 0
        
        previewController.dismiss(animated: true) {
            
            self.uiWindow?.isHidden = false
            
        }
    }
}

// MARK: - RPScreenRecorderDelegate
extension ViewController: RPScreenRecorderDelegate {
    func screenRecorderDidChangeAvailability(_ screenRecorder: RPScreenRecorder) {
        if screenRecorder.isAvailable == false {
            let alert = UIAlertController.init(title: "Screen Recording Failed", message: "Screen Recorder is no longer available.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                self.dismiss(animated: true, completion: nil)
            }))
            self.present(self, animated: true, completion: nil)
        }
    }
}

extension SCNNode {
    func setHighlighted( _ highlighted : Bool = true, _ highlightedBitMask : Int = 2 ) {
        categoryBitMask = highlightedBitMask
        for child in self.childNodes {
            child.setHighlighted()
        }
    }
}

extension CGColor {
    var red: Float {
        let ciColor = CIColor(cgColor: self)
        return Float(ciColor.red)
    }
    
    var green: Float {
        let ciColor = CIColor(cgColor: self)
        return Float(ciColor.green)
    }
    
    var blue: Float {
        let ciColor = CIColor(cgColor: self)
        return Float(ciColor.blue)
    }
    
    var alpha: Float {
        let ciColor = CIColor(cgColor: self)
        return Float(ciColor.alpha)
    }
    
    var components: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        let ciColor = CIColor(cgColor: self)
        return (ciColor.red, ciColor.green, ciColor.blue, ciColor.alpha)
    }
}

extension UIColor {
    
    convenience init?(hex: String) {
        var hexNormalized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexNormalized = hexNormalized.replacingOccurrences(of: "#", with: "")
        
        // Helpers
        var rgb: UInt32 = 0
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0
        let length = hexNormalized.characters.count
        
        // Create Scanner
        Scanner(string: hexNormalized).scanHexInt32(&rgb)
        
        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0
            
        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0
            
        } else {
            return nil
        }
        
        self.init(red: r, green: g, blue: b, alpha: a)
    }
}
