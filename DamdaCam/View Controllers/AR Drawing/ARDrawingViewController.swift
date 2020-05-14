//
//  ARDrawingViewController.swift
//  DamdaCam
//
//  Created by Yebin Kim on 2020/02/06.
//  Copyright © 2020 김예빈. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import ReplayKit

class ARDrawingViewController: UIViewController {
    
    static let identifier: String = "ARDrawingViewController"
    
    lazy var sceneView: ARSCNView = {
        let sceneView = ARSCNView()
        sceneView.frame = self.view.frame
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        
        return sceneView
    }()
    
    private var observers: [NSObjectProtocol] = []
    
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
                if strokes.count > 0 {
                    uiViewController?.hideDrawingPrompt()
                } else {
                    uiViewController?.showDrawingPrompt()
                }
                
                uiViewController?.drawingUIHidden(false)
                uiViewController?.stopTrackingAnimation()
                uiViewController?.messagesContainerView?.isHidden = true
                setStrokeVisibility(isHidden: false)
                UIAccessibility.post(notification: UIAccessibility.Notification.layoutChanged, argument: uiViewController?.touchView)
                
                sceneView.debugOptions = []
                
            case .TRACKING:
                uiViewController?.hideDrawingPrompt()
                uiViewController?.startTrackingAnimation(trackingMessage)
                
                // hiding fullBackground hides everything except close button
                setStrokeVisibility(isHidden: true)
                uiViewController?.touchView.isHidden = true
                UIAccessibility.post(notification: UIAccessibility.Notification.layoutChanged, argument: uiViewController?.trackingPromptLabel)
            }
            
            // if we're tracking and the mode changes, update our previous mode state
            if modeBeforeTracking != nil && mode != .TRACKING {
                print("Updating mode to return to after tracking: \(mode)")
                modeBeforeTracking = mode
            }
        }
    }
    
    // MARK: UI
    /// window with UI elements to keep them out of screen recording
    var uiWindow: UIWindow?
    
    /// view controller for ui elements
    var uiViewController: ARDrawingUIViewController?
    
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
        
        self.initializeSceneView()
        self.initializeHitNode()
        self.initializeLighting()
        self.initializeScreenRecorder()
        
        self.setupUI()
        self.setupNeon()
        
        self.addObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.uiWindow?.isHidden = false
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        self.configureARSession()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        self.sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
        self.resetTouches()
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        for observer in observers {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.touchPoint = .zero
    }
    
    // MARK: - View Configuration
    private func initializeSceneView() {
        self.sceneView.delegate = self
        self.sceneView.session.delegate = self
        self.sceneView.scene = SCNScene()
        
        self.view.addSubview(self.sceneView)
        
        NSLayoutConstraint.activate([
            self.sceneView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.sceneView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.sceneView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.sceneView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
    }
    
    private func initializeHitNode() {
        self.hitNode = SCNNode()
        self.hitNode!.position = SCNVector3Make(0, 0, -0.4)  // 드로잉 거리 조절
        self.sceneView.pointOfView?.addChildNode(hitNode!)
    }
    
    private func initializeLighting() {
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.shadowMode = .deferred
        ambientLight.light?.color = UIColor.white
        ambientLight.light?.type = SCNLight.LightType.ambient
        ambientLight.position = SCNVector3(x: 0, y: 5, z: 0)
        
        self.sceneView.scene.rootNode.addChildNode(ambientLight)
        self.sceneView.automaticallyUpdatesLighting = true
    }
    
    private func initializeScreenRecorder() {
        self.screenRecorder = RPScreenRecorder.shared()
        self.screenRecorder?.isMicrophoneEnabled = true
    }
    
    private func setupNeon() {
        if let path = Bundle.main.path(forResource: "NodeTechnique", ofType: "plist") {
            if let dict = NSDictionary(contentsOfFile: path), let dict2 = dict as? [String: AnyObject] {
                let technique = SCNTechnique(dictionary: dict2)
                sceneView.technique = technique
            }
        }
    }
    
    private func addObservers() {
        observers.append(NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil) { _ in
            self.touchPoint = .zero
        })
    }
    
    func configureARSession(options: ARSession.RunOptions = []) {
        if let configuration = self.sceneView.session.configuration {
            sceneView.session.run(configuration)
        } else {
            let configuration = ARWorldTrackingConfiguration()
            
            configuration.planeDetection = [.horizontal]
            configuration.isAutoFocusEnabled = false
            
            if #available(iOS 13.0, *) {
                if ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) {
                    configuration.frameSemantics = .personSegmentationWithDepth
                }
            }
            
            sceneView.session.run(configuration, options: options)
        }
    }
    
    /// Add new UIWindow with interface elements that forward touch events via the InterfaceViewControllerDelegate protocol
    func setupUI() {
        self.uiWindow = UIWindow(frame: UIScreen.main.bounds)
        let uiStoryboard = UIStoryboard(name: ARDrawingUIViewController.identifier, bundle: nil)
        self.uiViewController = uiStoryboard.instantiateInitialViewController() as? ARDrawingUIViewController
        self.uiViewController?.delegate = self
        self.uiWindow?.rootViewController = uiViewController
        self.uiWindow?.makeKeyAndVisible()
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
            guard stroke.points.last != nil, let strokeNode = stroke.node else {
                return
            }
            let offset = unprojectedPosition(for: stroke, at: touchPoint)
            let newPoint = strokeNode.convertPosition(offset, from: sceneView.scene.rootNode)
            
            stroke.lineWidth = strokeSize
            if stroke.add(point: newPoint, neonState: neonState) {
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
