//
//  ARMotionViewController.swift
//  DamdaCam
//
//  Created by 김예빈 on 2019. 3. 21..
//  Copyright © 2019년 김예빈. All rights reserved.
//

import UIKit
import AVKit
import Vision

import SceneKit
import Metron
import CoreData

class ARMotionViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureFileOutputRecordingDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate {

//    public struct Queue<T> {
//        internal var data = Array<T>()
//        public init() {}
//
//        var avg: Float = 0
//        var sum: Float = 0
//        let multiplier = Float(pow(10.0, 4.0))
//
//        public mutating func dequeue() -> T? {
//            return data.removeFirst()
//        }
//
//        public func peek() -> T? {
//            return data.first
//        }
//
//        public mutating func enqueue(element: T) {
//            data.append(element)
//
//            if data.count == 60 {
//                data.removeFirst()
//            }
//
//            sum = element as! Float
//            sum = round(sum * multiplier) / multiplier
//
//            for _ in 1 ... data.count {
//                avg += sum
//            }
//
//            avg /= Float(data.count)
//            avg = round(avg * multiplier) / multiplier
//        }
//
//        public mutating func clear() {
//            data.removeAll()
//        }
//
//        public var count: Int {
//            return data.count
//        }
//
//        public var capacity: Int {
//            get {
//                return data.capacity
//            }
//            set {
//                data.reserveCapacity(newValue)
//            }
//        }
//
//        public func isFull() -> Bool {
//            return count == data.capacity
//        }
//
//        public func isEmpty() -> Bool {
//            return data.isEmpty
//        }
//
//        public mutating func getMoveAverage() -> Float {
//            return avg
//        }
//    }
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var localRecords: [NSManagedObject] = []
    
    let ARView = SCNView()
    let ARscene = SCNScene()
    
    var headNode = SCNNode()
    var noseNode = SCNNode()
    var eatNode = SCNNode()
    var selectScene = SCNScene()
    
    var BGNode = SCNNode()
    
    var halfWidth: CGFloat!
    var halfHeight: CGFloat!
    
    // Main view for showing camera content.
//    @IBOutlet var previewView: UIView!
    @IBOutlet var previewView: UIImageView!
    @IBOutlet var iconView: UIView!
    
//    var MA_x = Queue<Float>()
//    var MA_y = Queue<Float>()
//    var MA_yaw = Queue<Float>()
//    var MA_roll = Queue<Float>()
//    var MA_Pitch = Queue<Float>()
    
    var ARNode_x: Float! = 0
    var ARNode_y: Float! = 0
    var ARNode_z: Float! = 0
    var checkedBlink = false // true -> 체크할 수 있는 상태
    
    // Face Position Detection
    var leftEye: [CGPoint] = []
    var rightEye: [CGPoint] = []
    var leftEyebrow: [CGPoint] = []
    var rightEyebrow: [CGPoint] = []
    var leftPupil: [CGPoint] = []
    var rightPupil: [CGPoint] = []
    var nose: [CGPoint] = []
    var outerLips: [CGPoint] = []
    var innerLips: [CGPoint] = []
    var medianLine: [CGPoint] = []
    var faceContour: [CGPoint] = []
    var noseCrest: [CGPoint] = []
    var boundingBox = CGRect.zero
    
    // Record UI
    @IBOutlet var recordView: UIView!
    @IBOutlet var recordModePhoto: UIButton!
    @IBOutlet var recordModeVideo: UIButton!
    @IBOutlet var recordMoveButton: UIButton!
    @IBOutlet var recordViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet var recordGradient: UIImageView!
    var selectedMode: Bool = true // true -> photo, false -> video
    var videoState: Bool = false
    @IBOutlet var modeSelected: UIView!
    
    var takePhoto = false
    let fileOutput = AVCaptureMovieFileOutput()
    
//    var screenRecorder: RPScreenRecorder?
//    var isRecording: Bool = false
    
    // Icon
    @IBOutlet var settingButton: UIButton!
    @IBOutlet var clipButton: UIButton!
    @IBOutlet var changeButton: UIButton!
    @IBOutlet var galleryButton: UIButton!
    @IBOutlet var menuButton: UIButton!
    
    // Clip
    var clipViewState: Bool! = false
    var clipTime: Double! = 0.0
    @IBOutlet var clipView: UIView!
    @IBOutlet var oneClipButton: UIButton!
    @IBOutlet var twoClipButton: UIButton!
    @IBOutlet var threeClipButton: UIButton!
    @IBOutlet var plusClipButton: UIButton!
    var oneClipState: Bool = false
    var twoClipState: Bool = false
    var threeClipState: Bool = false
    var plusClipState: Bool = false
    @IBOutlet var plusClipPicker: UIPickerView!
    @IBOutlet var clipViewDivideBar: UIView!
    
    // Menu
    @IBOutlet var menuView: UIView!
    @IBOutlet var menuXButton: UIButton!
    @IBOutlet var menuXButtonOn: UIButton!
    @IBOutlet var menuMakingARButton: UIButton!
    @IBOutlet var menuARMotionButton: UIButton!
    @IBOutlet var menuFilterButton: UIButton!
    @IBOutlet var menuMakingARLabel: UILabel!
    @IBOutlet var menuARMotionLabel: UILabel!
    @IBOutlet var menuFilterLabel: UILabel!
    var makingARButtonCenter: CGPoint!
    var ARMotionButtonCenter: CGPoint!
    var filterButtonCenter: CGPoint!
    var makingARLabelCenter: CGPoint!
    var ARMotionLabelCenter: CGPoint!
    var filterLabelCenter: CGPoint!
    var makingARButtonState: Bool = false
    var ARMotionButtonState: Bool = false
    var filterButtonState: Bool = false
    let tapGestureView = UIView()
    
    // ARMotion View
    @IBOutlet var ARMotionView: UIView!
    @IBOutlet var deleteARMotionButton: UIButton!
    @IBOutlet var myARMotionButton: UIButton!
    @IBOutlet var AllARMotionButton: UIButton!
    @IBOutlet var FaceARMotionButton: UIButton!
    @IBOutlet var BGARMotionButton: UIButton!
    @IBOutlet var ARMotionCollectionView: UICollectionView!
    @IBOutlet weak var ARMotionViewFlowLayout: UICollectionViewFlowLayout!
    var myARMotionArray: [UIImage]!
    var AllARMotionArray: [UIImage]!
    var FaceARMotionArray: [UIImage]!
    var BGARMotionArray: [UIImage]!
    var ARMotionViewState: Bool = false
    var toARMotionNO: Bool = false // toARMotionNO
    var toARMotionYES: Bool = false // toARMotionYES
    
    // Filter View
    @IBOutlet var filterView: UIView!
    @IBOutlet var filterBackView: UIView!
    @IBOutlet var filterPowerSlider: UISlider!
    @IBOutlet weak var filterCollectionView: UICollectionView!
    @IBOutlet weak var filterViewFlowLayout: UICollectionViewFlowLayout!
//    var filterArray: [UIImage]!
    var filterViewState: Bool = false
    let filterNameArray: [String] = ["CIPhotoEffectProcess", "CIPhotoEffectInstant", "Normal", "CIPhotoEffectMono", "CIPhotoEffectNoir", "CIPhotoEffectTonal", "CIPhotoEffectFade", "CIPhotoEffectChrome", "CIPhotoEffectTransfer"].sorted(by: >)
    let filterContext = CIContext()
    var selectedFilter = CIFilter(name: "CIComicEffect")
    
    @IBOutlet var filterBack: UIButton!
    @IBOutlet var filterTemp1: UIButton!
    @IBOutlet var filterTemp2: UIButton!
    @IBOutlet var filterTemp3: UIButton!
    @IBOutlet var filterTemp4: UIButton!
    
    // AVCapture variables to hold sequence data
    var session: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    var videoDataOutput: AVCaptureVideoDataOutput?
    var videoDataOutputQueue: DispatchQueue?
    
    var captureDevice: AVCaptureDevice?
    var captureDeviceResolution: CGSize = CGSize()
    
    // Layer UI for drawing Vision results
    var rootLayer: CALayer?
//    var detectionOverlayLayer: CALayer?
//    var detectedFaceRectangleShapeLayer: CAShapeLayer?
//    var detectedFaceLandmarksShapeLayer: CAShapeLayer?
    
    var recordingTimer: Timer?
    
    // Vision requests
    private var detectionRequests: [VNDetectFaceRectanglesRequest]?
    private var trackingRequests: [VNTrackObjectRequest]?
    
    lazy var sequenceRequestHandler = VNSequenceRequestHandler()
    
    // MARK: UIViewController overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ARView.frame = self.view.bounds
        ARView.backgroundColor = UIColor.clear
        previewLayer?.frame = self.view.bounds
        self.view.addSubview(ARView)
        
        halfWidth = self.view.bounds.width / 2
        halfHeight = self.view.bounds.height / 2
        
        self.view.bringSubviewToFront(iconView)
        
        self.session = self.setupAVCaptureSession()
//        self.photoOutput = AVCapturePhotoOutput()
//        self.session!.sessionPreset = AVCaptureSession.Preset.photo
//        self.session?.startRunning()
        
//        screenRecorder = RPScreenRecorder.shared()
//        screenRecorder?.isCameraEnabled = true
//        screenRecorder?.isMicrophoneEnabled = true
        
        // camera mode set
        let swipeModeRight: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(modePhoto))
        swipeModeRight.direction = .right
        self.modeSelected.addGestureRecognizer(swipeModeRight)
        
        let swipeModeLeft: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(modeVideo))
        swipeModeLeft.direction = .left
        self.modeSelected.addGestureRecognizer(swipeModeLeft)
        
        // record set
        let swipeButtonDown: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(recordButtonDown))
        swipeButtonDown.direction = .down
        self.recordMoveButton.addGestureRecognizer(swipeButtonDown)
        
        let swipeButtonUp: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(recordButtonUp))
        swipeButtonUp.direction = .up
        self.recordMoveButton.addGestureRecognizer(swipeButtonUp)
        
        self.recordButton.layer.cornerRadius = 27.5
        self.recordBackgroundGradient()
        
        // Clip Set
        clipButton.isHidden = true
        clipView.alpha = 0.0
        clipView.layer.cornerRadius = 5
        plusClipPicker.selectRow(5, inComponent: 0, animated: false)
        oneClipButton.layer.cornerRadius = 20
        self.iconDropShadow(button: oneClipButton, state: true)
        twoClipButton.layer.cornerRadius = 20
        self.iconDropShadow(button: twoClipButton, state: true)
        threeClipButton.layer.cornerRadius = 20
        self.iconDropShadow(button: threeClipButton, state: true)
        plusClipButton.layer.cornerRadius = 20
        self.iconDropShadow(button: plusClipButton, state: true)
        oneClipButton.applyGradient_rect(colors: [UIColor.white.cgColor, UIColor.white.cgColor], state: false)
        twoClipButton.applyGradient_rect(colors: [UIColor.white.cgColor, UIColor.white.cgColor], state: false)
        threeClipButton.applyGradient_rect(colors: [UIColor.white.cgColor, UIColor.white.cgColor], state: false)
        plusClipButton.applyGradient_rect(colors: [UIColor.white.cgColor, UIColor.white.cgColor], state: false)
        
        let secLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        secLabel.font = UIFont(name: "NotoSansCJKkr-Bold", size: 13.0)
        secLabel.textColor = UIColor(red: 84/255, green: 84/255, blue: 84/255, alpha: 1.0)
        secLabel.text = "m"
        secLabel.sizeToFit()
        secLabel.frame = CGRect(x: 81.0, y: 49.0, width: secLabel.bounds.width, height: secLabel.bounds.height)
        plusClipPicker.addSubview(secLabel)
        
        let minLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        minLabel.font = UIFont(name: "NotoSansCJKkr-Bold", size: 13.0)
        minLabel.textColor = UIColor(red: 84/255, green: 84/255, blue: 84/255, alpha: 1.0)
        minLabel.text = "s"
        minLabel.sizeToFit()
        minLabel.frame = CGRect(x: 210.0, y: 49.0, width: minLabel.bounds.width, height: minLabel.bounds.height)
        plusClipPicker.addSubview(minLabel)
        
        // Menu Set
        makingARButtonCenter = menuMakingARButton.center
        ARMotionButtonCenter = menuARMotionButton.center
        filterButtonCenter = menuFilterButton.center
        makingARLabelCenter = menuMakingARLabel.center
        ARMotionLabelCenter = menuARMotionLabel.center
        filterLabelCenter = menuFilterLabel.center
        menuMakingARLabel.alpha = 0.0
        menuARMotionLabel.alpha = 0.0
        menuFilterLabel.alpha = 0.0
        
        menuView.isHidden = true
        menuView.alpha = 0.0
        addBackView(view: menuView, color: UIColor.black, alpha: 0.6, cornerRadius: 0)
        
        self.view.addSubview(tapGestureView)
        tapGestureView.isHidden = true
        
        let tapMenuView: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MenuViewTap))
        menuView.addGestureRecognizer(tapMenuView)
        
        let swipeARMotionView: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(ARMotionViewSwipe))
        swipeARMotionView.direction = .down
        ARMotionView.addGestureRecognizer(swipeARMotionView)
        
        let swipeFilterView: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(filterViewSwipe))
        swipeFilterView.direction = .down
        filterView.addGestureRecognizer(swipeFilterView)
        
        let BGBlack = UIView()
        BGBlack.frame = ARMotionView.bounds
        BGBlack.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        BGBlack.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        let BGBar = UIView()
        BGBar.frame = CGRect(x: 0, y: 0, width: 375, height: 44)
        BGBar.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        BGBar.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
        ARMotionView.addSubview(BGBlack)
        ARMotionView.sendSubviewToBack(BGBlack)
        ARMotionView.addSubview(BGBar)
        ARMotionView.sendSubviewToBack(BGBar)
        
        let BGFilter = UIView()
        BGFilter.frame = filterView.bounds
        BGFilter.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        BGFilter.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        let BGfilterBar = UIView()
        BGfilterBar.frame = CGRect(x: 0, y: 0, width: 375, height: 44)
        BGfilterBar.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        BGfilterBar.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
        filterView.addSubview(BGFilter)
        filterView.sendSubviewToBack(BGFilter)
        filterView.addSubview(BGfilterBar)
        filterView.sendSubviewToBack(BGfilterBar)
        
        ARMotionSelectButtonTapped(AllARMotionButton)
        AllARMotionButton.layer.cornerRadius = 14
        FaceARMotionButton.layer.cornerRadius = 14
        BGARMotionButton.layer.cornerRadius = 14
        
        // ARMotion View Set
        createARMotionArray()
        ARMotionCollectionView.delegate = self
        ARMotionCollectionView.dataSource = self
        
        let deleteCell: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ARMotionCellLongPress))
        deleteCell.minimumPressDuration = 0.5
//        setFavorites.delegate = self
        deleteCell.delaysTouchesBegan = true
        self.ARMotionCollectionView?.addGestureRecognizer(deleteCell)
        
        let favoriteCell = UITapGestureRecognizer(target: self, action: #selector(ARMotionCellDoubleTab))
        favoriteCell.numberOfTapsRequired = 2
        self.ARMotionCollectionView?.addGestureRecognizer(favoriteCell)
        
        // Filter Set
        filterCollectionView.delegate = self
        filterCollectionView.dataSource = self
        filterPowerSlider.setThumbImage(UIImage(named: "thumb_slider"), for: .normal)
//        self.view.addSubview(filterCollectionView)
        
        filterTemp2.applyGradient_rect(colors: [UIColor(red: 16/255, green: 208/255, blue: 255/255, alpha: 0.5).cgColor, UIColor(red: 254/255, green: 156/255, blue: 255/255, alpha: 0.5).cgColor], state: false)
        filterTemp3.applyGradient_rect(colors: [UIColor(red: 254/255, green: 156/255, blue: 255/255, alpha: 0.5).cgColor, UIColor(red: 16/255, green: 208/255, blue: 255/255, alpha: 0.5).cgColor], state: false)
        filterTemp4.applyGradient_rect(colors: [UIColor(red: 5/255, green: 17/255, blue: 133/255, alpha: 0.5).cgColor, UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.3).cgColor], state: false)
        
        filterBack.isUserInteractionEnabled = false
        filterBack.applyGradient_rect(colors: [UIColor.clear.cgColor, UIColor.clear.cgColor], state: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if previewSize == 0 {
            previewView.frame = CGRect(x: 0, y: 0, width: 375, height: 667)
        } else if previewSize == 1 {
            previewView.frame = CGRect(x: 0, y: 60, width: 375, height: 440)
        } else if previewSize == 2 {
            previewView.frame = CGRect(x: 0, y: 0, width: 375, height: 500)
        }
        
        // Icon Set
        if previewSize == 0 {
            settingButton.setImage(UIImage(named: "ic_setup_wh"), for: .normal)
            clipButton.setImage(UIImage(named: "ic_clip_wh"), for: .normal)
            changeButton.setImage(UIImage(named: "ic_change_wh"), for: .normal)
            galleryButton.setImage(UIImage(named: "ic_gallery_wh"), for: .normal)
            menuButton.setImage(UIImage(named: "ic_menu_wh"), for: .normal)
            iconDropShadow(button: settingButton, state: true)
            iconDropShadow(button: clipButton, state: true)
            iconDropShadow(button: changeButton, state: true)
            iconDropShadow(button: galleryButton, state: true)
            iconDropShadow(button: menuButton, state: true)
            
            recordModePhoto.titleLabel?.textColor = UIColor.white
            recordModeVideo.titleLabel?.textColor = UIColor.white
            
            recordMoveButton.isHidden = false
        } else if previewSize == 1 {
            settingButton.setImage(UIImage(named: "ic_setup_bl"), for: .normal)
            clipButton.setImage(UIImage(named: "ic_clip_bl"), for: .normal)
            changeButton.setImage(UIImage(named: "ic_change_bl"), for: .normal)
            galleryButton.setImage(UIImage(named: "ic_gallery_bl"), for: .normal)
            menuButton.setImage(UIImage(named: "ic_menu_bl"), for: .normal)
            iconDropShadow(button: settingButton, state: false)
            iconDropShadow(button: clipButton, state: false)
            iconDropShadow(button: changeButton, state: false)
            iconDropShadow(button: galleryButton, state: false)
            iconDropShadow(button: menuButton, state: false)
            
            recordModePhoto.titleLabel?.textColor = UIColor(red: 84/255, green: 84/255, blue: 84/255, alpha: 1.0)
            recordModeVideo.titleLabel?.textColor = UIColor(red: 84/255, green: 84/255, blue: 84/255, alpha: 1.0)
            
            recordMoveButton.isHidden = true
        } else {
            settingButton.setImage(UIImage(named: "ic_setup_wh"), for: .normal)
            clipButton.setImage(UIImage(named: "ic_clip_wh"), for: .normal)
            changeButton.setImage(UIImage(named: "ic_change_wh"), for: .normal)
            galleryButton.setImage(UIImage(named: "ic_gallery_bl"), for: .normal)
            menuButton.setImage(UIImage(named: "ic_menu_bl"), for: .normal)
            iconDropShadow(button: settingButton, state: false)
            iconDropShadow(button: clipButton, state: false)
            iconDropShadow(button: changeButton, state: false)
            iconDropShadow(button: galleryButton, state: false)
            iconDropShadow(button: menuButton, state: false)
            
            recordModePhoto.titleLabel?.textColor = UIColor(red: 84/255, green: 84/255, blue: 84/255, alpha: 1.0)
            recordModeVideo.titleLabel?.textColor = UIColor(red: 84/255, green: 84/255, blue: 84/255, alpha: 1.0)
            
            recordMoveButton.isHidden = true
        }
        
        // Menu Set
        self.menuButtonStateCheck()
        self.menuXButtonOn.alpha = 1.0
        
        self.buttonAnimation(button: self.menuMakingARButton, label: self.menuMakingARLabel, buttonPosition: self.menuXButton.center, size: 0.5, labelPosition: self.menuXButton.center)
        self.buttonAnimation(button: self.menuARMotionButton, label: self.menuARMotionLabel, buttonPosition: self.menuXButton.center, size: 0.5, labelPosition: self.menuXButton.center)
        self.buttonAnimation(button: self.menuFilterButton, label: self.menuFilterLabel, buttonPosition: self.menuXButton.center, size: 0.5, labelPosition: self.menuXButton.center)
        self.menuView.alpha = 0.0
        
        // ARmotion Set
        ARMotionCreate()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            if self.toARMotionNO {
                self.ARMotionbuttonTapped(self.menuARMotionButton)
                self.toARMotionNO = false
            }
            
            if self.toARMotionYES {
                self.ARMotionSelected_newMakingAR()
                self.toARMotionYES = false
            }
        }
        
        self.session?.startRunning()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Ensure that the interface stays locked in Portrait.
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    // Ensure that the interface stays locked in Portrait.
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    @objc func modePhoto(gestureRecognizer: UISwipeGestureRecognizer){
        self.changeModePhoto()
    }
    
    @objc func modeVideo(gestureRecognizer: UISwipeGestureRecognizer){
        self.changeModeVideo()
    }
    
    func changeModePhoto() {
        UIView.animate(withDuration: Double(0.5), animations: {
            self.modeSelected.center += CGPoint(x: 58.0, y: 0.0)
        })
        
        clipButton.isHidden = true
        
        selectedMode = true
    }
    
    func changeModeVideo() {
        UIView.animate(withDuration: Double(0.5), animations: {
            self.modeSelected.center -= CGPoint(x: 58.0, y: 0.0)
        })
        
        clipButton.isHidden = false
        
        selectedMode = false
    }
    
    @IBAction func photoButtonTapped(_ sender: UIButton) {
        self.changeModePhoto()
    }
    
    @IBAction func videoButtonTapped(_ sender: UIButton) {
        self.changeModeVideo()
    }
    
    @objc func recordButtonDown(gestureRecognizer: UISwipeGestureRecognizer){
        UIView.animate(withDuration: Double(0.5), animations: {
            self.recordViewBottomConstraint.constant = -130
            self.view.layoutIfNeeded()
        })
    }
    
    @objc func recordButtonUp(gestureRecognizer: UISwipeGestureRecognizer){
        UIView.animate(withDuration: Double(0.5), animations: {
            self.recordViewBottomConstraint.constant = 0
            self.view.layoutIfNeeded()
        })
    }
    
//    override var shouldAutorotate: Bool {
//        get {
//            if let del = touchDelegate, del.shouldAutorotate == false { return false }
//            return true
//        }
//    }
    
    func configureAccessibility() {
        let key = NSAttributedString.Key.accessibilitySpeechIPANotation

        let attributedString = NSAttributedString(
            string: NSLocalizedString("content_description_record", comment: "Record"), attributes: [key: "record"]
        )

        recordButton.accessibilityAttributedLabel = attributedString
        recordButton.accessibilityHint = NSLocalizedString("content_description_record_accessible", comment: "Tap to record a video for ten seconds.")

        NotificationCenter.default.addObserver(self, selector: #selector(voiceOverStatusChanged), name: UIAccessibility.voiceOverStatusDidChangeNotification, object: nil)

        voiceOverStatusChanged()
    }
    
    @objc func voiceOverStatusChanged() {
        //        sizeButtonStackView.alpha = (UIAccessibility.isVoiceOverRunning) ? 1 : 0
    }
    
//    //MARK: - Check access
//    fileprivate func checkCameraAccess() {
//        var isCameraAuthStatusIsAuthorized = (AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == AVAuthorizationStatus.authorized)
//        var isMicAuthStatusIsAuthorized = (AVCaptureDevice.authorizationStatus(for: AVMediaType.audio) == AVAuthorizationStatus.authorized)
//
//        if isCameraAuthStatusIsAuthorized && isMicAuthStatusIsAuthorized {
//            initCamera()
//        } else {
//
//            var camSelected = false
//            var micSelected = false
//
//            AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
//                camSelected = true
//                if response {
//                    isCameraAuthStatusIsAuthorized = true
//                }
//
//                if micSelected {
//                    DispatchQueue.main.async {
//                        self.accessAlert(isCameraAuthStatusIsAuthorized, isMicAuthStatusIsAuthorized)
//                    }
//                }
//            }
//
//            AVCaptureDevice.requestAccess(for: AVMediaType.audio) { response in
//                micSelected = true
//                if response {
//                    isMicAuthStatusIsAuthorized = true
//                }
//
//                if camSelected {
//                    DispatchQueue.main.async {
//                        self.accessAlert(isCameraAuthStatusIsAuthorized, isMicAuthStatusIsAuthorized)
//                    }
//                }
//            }
//        }
//    }
//
//    fileprivate func accessAlert(_ isCameraAuthStatusIsAuthorized: Bool, _ isMicAuthStatusIsAuthorized: Bool) {
//        var alertDescription = ""
//
//        if isCameraAuthStatusIsAuthorized && isMicAuthStatusIsAuthorized {
//            initCamera()
//        } else if isCameraAuthStatusIsAuthorized == isMicAuthStatusIsAuthorized {
//            alertDescription = "Нужен доступ к камере и микрофону"
//        } else if isCameraAuthStatusIsAuthorized {
//            alertDescription = "Нужен доступ к микрофону"
//        } else if isMicAuthStatusIsAuthorized {
//            alertDescription = "Нужен доступ к камере"
//        }
//
//        if (alertDescription != "") {
//            let alert = UIAlertController(title: "Вы можете открыть доступ в Настройках", message: alertDescription, preferredStyle: UIAlertController.Style.alert)
//            alert.addAction(UIAlertAction(title: "Отмена", style: .default, handler: { (alert) -> Void in
//                self.dismiss(animated: true, completion: nil)
//            }))
//
//            alert.addAction(UIAlertAction(title: "Настройки", style: .cancel, handler: { (alert) -> Void in
//                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, completionHandler: { (void) -> Void in
//                    self.dismiss(animated: true, completion: nil)
//                })
//            }))
//
//            present(alert, animated: true, completion: nil)
//        }
//    }
//
//    //MARK: - Camera initialization
//    fileprivate func initCamera() {
////        do {
////            try frontCaptureDeviceInput = AVCaptureDeviceInput(device: cameraWithPosition(position : .front)!)
////        } catch {
////            print(error.localizedDescription)
////        }
////        do {
////            try backCaptureDeviceInput = AVCaptureDeviceInput(device: cameraWithPosition(position : .back)!)
////        } catch {
////            print(error.localizedDescription)
////        }
//
//        //remove loaded inputs to prevent app crush
//        if let inputs = session!.inputs as? [AVCaptureDeviceInput] {
//            for input in inputs {
//                session!.removeInput(input)
//            }
//        }
//
//        session!.sessionPreset = AVCaptureSession.Preset.high
////        self.session!.addInput(self.backCaptureDeviceInput)
//        if let audioInput = AVCaptureDevice.default(for: AVMediaType.audio) {
//            do {
//
//                try self.session!.addInput(AVCaptureDeviceInput(device: audioInput))
//            } catch {
//                print(error.localizedDescription)
//            }
//        }
//
////        previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
////        self.cameraView.frame = CGRect(x: 0, y: 0, width: self.screenWidth, height: self.screenHeight)
////        self.previewLayer?.frame = self.cameraView.frame
////        self.cameraView.layer.addSublayer(self.previewLayer!)
////        setDeviceOrientation()
////        session!.addOutput(self.movieFileOutput)
////        session!.addOutput(self.photoOutput)
//    }
//
//    fileprivate func deviceOrientation() -> AVCaptureVideoOrientation {
//        return .portrait
//    }
//
//    //MARK: - Toggle flashlight
//    func toggleTorch(on: Bool) {
//        guard let device = AVCaptureDevice.default(for: AVMediaType.video)
//            else {return}
//
//        if device.hasTorch {
//            do {
//                try device.lockForConfiguration()
//
//                if on == true {
//                    device.torchMode = .on
//                } else {
//                    device.torchMode = .off
//                }
//
//                device.unlockForConfiguration()
//            } catch {
//                print(error.localizedDescription)
//            }
//        } else {
//            print("Torch is not available")
//        }
//    }
//
    // MARK: - AVFondation Delegate & DataSource methods
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        UISaveVideoAtPathToSavedPhotosAlbum(outputFileURL.path, nil, nil, nil)
//        videoClipsPath.append(outputFileURL)
//        videoClipsDuration.append(output.recordedDuration.seconds)
//
//        if isStopButtonPressed || maxRecordDuration().seconds <= 1 {
//            mergeVideoClips()
//        }
//        else {
//            print("CameraVC: file location ", videoFileLocation())
//            movieFileOutput.maxRecordedDuration = maxRecordDuration()
//            movieFileOutput.startRecording(to: URL(fileURLWithPath: videoFileLocation()), recordingDelegate: self)
//        }
    }
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAtURL fileURL: NSURL!, fromConnections connections: [AnyObject]!) {
        print("capture output: started recording to \(fileURL)")
    }
//
//    //MARK: - Video clip merge and save
//    fileprivate func mergeVideoClips() {
//        let composition = AVMutableComposition()
//        let videoTrack = composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid)
//        let audioTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)
//        var time: Double = 0.0
//
////        stopCaptureTimer()
//        isStopButtonPressed = true
//
//        for duration in self.videoClipsDuration {
//            print("CameraVC: duration", duration)
//        }
//
//        for video in self.videoClipsPath {
//            let asset = AVAsset(url: video)
//
//            if let videoAssetTrack = asset.tracks(withMediaType: AVMediaType.video).first {
//                let audioAssetTrack = asset.tracks(withMediaType: AVMediaType.audio).first!
//                let atTime = CMTime(seconds: time, preferredTimescale:0)
//
//                do {
//                    try videoTrack?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: asset.duration) , of: videoAssetTrack, at: atTime)
//                    try audioTrack?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: asset.duration) , of: audioAssetTrack, at: atTime)
//                } catch let error {
//                    print(error.localizedDescription)
//                }
//
//                time +=  asset.duration.seconds
//            }
//        }
//
//        videoTrack!.preferredTransform = (videoTrack?.preferredTransform.rotated(by: .pi / 2))!
//
//
//
//        let url = URL(fileURLWithPath: NSTemporaryDirectory().appending("video").appending(".mov"))
//        let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality)
//
//        exporter?.outputURL = url
//        exporter?.shouldOptimizeForNetworkUse = true
//        exporter?.outputFileType = AVFileType.mov
//        exporter?.exportAsynchronously(completionHandler: { () -> Void in
//            DispatchQueue.main.async(execute: { () -> Void in
//                if self.isClosed == false {
//                    self.outputFileLocation = exporter?.outputURL
////                    if let destinationVC = UIStoryboard(name: "PreviewVC", bundle: nil).instantiateViewController(withIdentifier: "PreviewVC") as? PreviewVC {
////                        destinationVC.fileLocation = self.outputFileLocation
////                        self.present(destinationVC, animated: false, completion: nil)
////                    }
//                }
//            })
//        })
//    }
//
//
//    //MARK: - Video configure
//    fileprivate func maxRecordDuration() -> CMTime {
//        var current = 0.0
//        for duration in videoClipsDuration {
//            current += duration
//        }
//        let seconds = max(videoMaxDuration - Int(current),0)
//        let preferredTimeScale: Int32 = 1
//        return CMTimeMake(value: Int64(seconds), timescale: preferredTimeScale)
//    }
//    fileprivate func videoFileLocation() -> String {
//        return NSTemporaryDirectory().appending("mediafile").appending(String(videoClipsPath.count)).appending(".mov")
//    }
////    func startCaptureTimer() {
////        if capturePrgsTimer == nil {
////            capturePrgsTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(CameraVC.updateProgressView), userInfo: nil, repeats: true)
////        }
////    }
////    func stopCaptureTimer() {
////        if capturePrgsTimer != nil {
////            capturePrgsTimer?.invalidate()
////            capturePrgsTimer = nil
////            progressView.progress = 0.0
////        }
////    }
//
//    //MARK: - Shoot action
//    func shootButtonPressed() {
//        isStopButtonPressed = !isStopButtonPressed
//        if isStopButtonPressed {
////            stopCaptureTimer()
////            recBtnInteraction(isEnabled: false)
//            movieFileOutput.stopRecording()
//        }
//        else {
//            FileManager.default.clearTmpDirectory()
//            videoClipsPath.removeAll()
//            videoClipsDuration.removeAll()
//            movieFileOutput.maxRecordedDuration = maxRecordDuration()
//            movieFileOutput.startRecording(to: URL(fileURLWithPath: videoFileLocation()), recordingDelegate: self)
////            startCaptureTimer()
////            updateRecordButtonTitle()
//        }
//    }
//
//    //MARK: - Get image from buffer
//    func getImageFromSampleBuffer (buffer:CMSampleBuffer) -> UIImage? {
//        if let pixelBuffer = CMSampleBufferGetImageBuffer(buffer) {
//            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
//            let context = CIContext()
//
//            let imageRect = CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))
//
//            if let image = context.createCGImage(ciImage, from: imageRect) {
//                return UIImage(cgImage: image, scale: UIScreen.main.scale, orientation: .right)
//            }
//
//        }
//
//        return nil
//    }
//
    @IBAction func recordTapped(_ sender: UIButton) {
        if selectedMode {
            
            takePhoto = true
            
//            let settings = AVCapturePhotoSettings()
//            let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
//            let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
//                                 kCVPixelBufferWidthKey as String: 300,
//                                 kCVPixelBufferHeightKey as String: 300]
//            settings.previewPhotoFormat = previewFormat
//            self.photoOutput.capturePhoto(with: settings, delegate: self)
            //            sessionOutput.capturePhoto(with: sessionOutputSetting, delegate: self as! AVCapturePhotoCaptureDelegate)
        } else {
            if !videoState {
//                recordTapped(sender: sender)
                
                startVideoRecording()
                
                UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveLinear, .repeat, .autoreverse, .allowUserInteraction], animations: {
                    self.recordButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                    self.recordButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                })
            } else {
//                stopRecording()
                
                stopVideoRecording()
                
                recordButton.layer.removeAllAnimations()
            }
            
            videoState = !videoState
        }
    }
    
    func startVideoRecording(){
        session!.addOutput(fileOutput)
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as! NSString
        let outputPath = "\(documentsPath)/output.mp4"
        let outputFileUrl = NSURL(fileURLWithPath: outputPath)
        
        fileOutput.startRecording(to: outputFileUrl as URL, recordingDelegate: self)
    }
    
    func stopVideoRecording(){
        fileOutput.stopRecording()
    }
    
    func recordBackgroundGradient() {
        let loadingImages = (1...91).map { UIImage(named: "recordGradient/\($0).png")! }
        
        self.recordGradient.animationImages = loadingImages
        self.recordGradient.animationDuration = 3.0
        self.recordGradient.startAnimating()
    }
    
//    func recordTapped(sender: UIButton?) {
//        if screenRecorder?.isRecording == true {
//            // Reset record button accessibility label to original value
//            configureAccessibility()
//
//            stopRecording()
//        } else {
//            sender?.accessibilityLabel = NSLocalizedString("content_description_record_stop", comment: "Stop Recording")
//            startRecording()
//        }
//    }
//
//    func startRecording() {
//        screenRecorder?.startRecording(handler: { (error) in
//            guard error == nil else {
//                return
//            }
//            self.recordingWillStart()
//
//        })
//    }
//
//    func stopRecording() {
//        screenRecorder?.stopRecording(handler: { (previewViewController, error) in
//            DispatchQueue.main.async {
//                guard error == nil, let preview = previewViewController else {
//                    return
//                }
//                self.recordingHasEnded()
//                previewViewController?.previewControllerDelegate = self
//                previewViewController?.modalPresentationStyle = .overFullScreen
//
//                self.present(preview, animated: true, completion:nil)
////                self.uiWindow?.isHidden = true
//            }
//        })
//    }
//
//
//    func recordingWillStart() {
//        if clipTime != 0.0 {
//            DispatchQueue.main.async {
//                self.recordingTimer = Timer.scheduledTimer(withTimeInterval: self.clipTime, repeats: false, block: { (timer) in
//                    DispatchQueue.main.async {
//                        print(self.clipTime)
//                        self.stopRecording()
//                        self.recordButton.layer.removeAllAnimations()
//                        self.recordButton.isEnabled = true
//                    }
//                })
//
//                self.recordButton.isEnabled = false
//            }
//        }
//    }
//
//    func recordingHasUpdated() {
//
//    }
//
//    func recordingHasEnded() {
//        if let timer = recordingTimer {
//            timer.invalidate()
//        }
//        recordingTimer = nil
//    }
    
    // Face Position Datection
    func clear() {
        leftEye = []
        rightEye = []
        leftEyebrow = []
        rightEyebrow = []
        nose = []
        outerLips = []
        innerLips = []
        faceContour = []
        
        boundingBox = .zero
        
        DispatchQueue.main.async {
            self.previewView.setNeedsDisplay()
        }
    }
    
    func detectedFace(request: VNRequest, error: Error?) {
        // 1
        guard
            let results = request.results as? [VNFaceObservation],
            let result = results.first
            else {
                // 2
                self.clear()
                self.headNode.isHidden = true
                self.noseNode.isHidden = true
                return
        }
        
        self.headNode.isHidden = false
        self.noseNode.isHidden = false
        updateFaceView(for: result)
    }
    
    func convert(rect: CGRect) -> CGRect {
        // 1
        let origin = previewLayer.layerPointConverted(fromCaptureDevicePoint: rect.origin)
        
        // 2
        let size = previewLayer.layerPointConverted(fromCaptureDevicePoint: rect.size.cgPoint)
        
        // 3
        return CGRect(origin: origin, size: size.cgSize)
    }
    
    // 1
    func landmark(point: CGPoint, to rect: CGRect) -> CGPoint {
        // 2
        let absolute = point.absolutePoint(in: rect)
        
        // 3
        let converted = previewLayer.layerPointConverted(fromCaptureDevicePoint: absolute)
        
        // 4
        return converted
    }
    
    func landmark(points: [CGPoint]?, to rect: CGRect) -> [CGPoint]? {
        guard let points = points else {
            return nil
        }
        
        return points.compactMap { landmark(point: $0, to: rect) }
    }
    
    func updateFaceView(for result: VNFaceObservation) {
        defer {
            DispatchQueue.main.async {
                self.previewView.setNeedsDisplay()
            }
        }
        
        let box = result.boundingBox
        self.boundingBox = convert(rect: box)
        
        guard let landmarks = result.landmarks else {
            return
        }
        
        if let leftEye = landmark(
            points: landmarks.leftEye?.normalizedPoints,
            to: result.boundingBox) {
            self.leftEye = leftEye
        }
        
        if let rightEye = landmark(
            points: landmarks.rightEye?.normalizedPoints,
            to: result.boundingBox) {
            self.rightEye = rightEye
        }
        
        if let leftEyebrow = landmark(
            points: landmarks.leftEyebrow?.normalizedPoints,
            to: result.boundingBox) {
            self.leftEyebrow = leftEyebrow
        }
        
        if let rightEyebrow = landmark(
            points: landmarks.rightEyebrow?.normalizedPoints,
            to: result.boundingBox) {
            self.rightEyebrow = rightEyebrow
        }
        
        if let leftPupil = landmark(
            points: landmarks.leftPupil?.normalizedPoints,
            to: result.boundingBox) {
            self.leftPupil = leftPupil
        }
        
        if let rightPupil = landmark(
            points: landmarks.rightPupil?.normalizedPoints,
            to: result.boundingBox) {
            self.rightPupil = rightPupil
        }
        
        if let nose = landmark(
            points: landmarks.nose?.normalizedPoints,
            to: result.boundingBox) {
            self.nose = nose
        }
        
        if let outerLips = landmark(
            points: landmarks.outerLips?.normalizedPoints,
            to: result.boundingBox) {
            self.outerLips = outerLips
        }
        
        if let innerLips = landmark(
            points: landmarks.innerLips?.normalizedPoints,
            to: result.boundingBox) {
            self.innerLips = innerLips
        }
        
        if let medianLine = landmark(
            points: landmarks.medianLine?.normalizedPoints,
            to: result.boundingBox) {
            self.medianLine = medianLine
        }
        
        if let faceContour = landmark(
            points: landmarks.faceContour?.normalizedPoints,
            to: result.boundingBox) {
            self.faceContour = faceContour
        }
        
        if let noseCrest = landmark(
            points: landmarks.noseCrest?.normalizedPoints,
            to: result.boundingBox) {
            self.noseCrest = noseCrest
        }
        
        ARMotionMove()
    }
    
    // MARK: AVCapture Setup
    
    /// - Tag: CreateCaptureSession
    fileprivate func setupAVCaptureSession() -> AVCaptureSession? {
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
    
    func getImageFromSampleBuffer (buffer:CMSampleBuffer) -> UIImage? {
        if let pixelBuffer = CMSampleBufferGetImageBuffer(buffer) {
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            let context = CIContext()
            
            let imageRect = CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))
            
            if let image = context.createCGImage(ciImage, from: imageRect) {
                return UIImage(cgImage: image, scale: UIScreen.main.scale, orientation: .right)
            }
            
        }
        
        return nil
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
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
            
                UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
            }
        
        }
        
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
    
    func exifOrientationForDeviceOrientation(_ deviceOrientation: UIDeviceOrientation) -> CGImagePropertyOrientation {
        
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
    
    func exifOrientationForCurrentDeviceOrientation() -> CGImagePropertyOrientation {
        return exifOrientationForDeviceOrientation(UIDevice.current.orientation)
    }
    
    // ARMotion Set
    func ARMotionCreate() {
        ARNode_x = 0
        ARNode_y = 3.5
        ARNode_z = -5
        
        selectScene = SCNScene(named: "FaceAR.scnassets/z_prepare_head.scn")!
        headNode = (selectScene.rootNode.childNode(withName: "z_prepare_head", recursively: true))!
        
        selectScene = SCNScene(named: "FaceAR.scnassets/z_prepare_nose.scn")!
        noseNode = (selectScene.rootNode.childNode(withName: "z_prepare_nose", recursively: true))!
        
        ARscene.rootNode.addChildNode(headNode)
        ARscene.rootNode.addChildNode(noseNode)
        
        ARView.scene = ARscene
    }
    
    func ARMotionDelete() {
//        selectScene.rootNode.enumerateChildNodes { (node, stop) in
//            node.removeFromParentNode() }
        ARscene.rootNode.enumerateChildNodes { (node, stop) in
            node.removeFromParentNode()
            node.removeAllParticleSystems()
        }
    }
    
    func ARMotionMove() {
        let yaw_L = getAngle(first: (leftEye[0]), second: (medianLine[4]), third: (medianLine[0]))
        let yaw_R = getAngle(first: (rightEye[4]), second: (medianLine[4]), third: (medianLine[0]))
        let yaw = Float(yaw_L + yaw_R)
        let faceYaw = -normalizationYaw(source: yaw)
        
        let roll = Float(leftEye[0].y - rightEye[4].y)
        let faceRoll = normalizationRoll(source: roll)
        
        let pitch_1 = getGravityCenter(first: noseCrest[0], second: nose[2], third: nose[6])
        let pitch_2 = Float(noseCrest[2].y - pitch_1.y)
        let pitch = normalizationPitch(source: pitch_2) - 0.6 + faceRoll
        
        let faceSize = pointsDistance(faceContour[10], faceContour[0]) * 0.003
        let center = getGravityCenter                                                                                                                                 (first: leftPupil[0], second: rightPupil[0], third: innerLips[2])
        let facePos = normalizationPos(source: center)
        
        // FIXME - 삼각함수를 써보자
        let pos_x = Float(facePos.x) - (faceYaw) - (faceRoll * 3.2)
        let pos_y = -Float(facePos.y) - abs(faceRoll * 2.0) - abs(pitch / 2.0)
        
        let faceCenter = normalizationPos(source: nose[4])
        
        // head
        headNode.position = SCNVector3Make(pos_x + ARNode_x, pos_y + (ARNode_y * Float(faceSize * 2.0)), ARNode_z)
        headNode.scale = SCNVector3(faceSize, faceSize, faceSize)
        headNode.simdEulerAngles = float3(pitch, faceYaw, faceRoll)
        
        // nose
        noseNode.position = SCNVector3Make(Float(faceCenter.x), -Float(faceCenter.y - 1.3), ARNode_z)
        noseNode.scale = SCNVector3(faceSize, faceSize, faceSize)
        noseNode.simdEulerAngles = float3(pitch, faceYaw, faceRoll)
        
        // eat
        eatNode.position = SCNVector3Make(ARNode_x, ARNode_y, ARNode_z)
        eatNode.scale = SCNVector3(faceSize, faceSize, faceSize)
        eatNode.simdEulerAngles = float3(pitch - 1.0, faceYaw, faceRoll)
        
        // BGNode
        BGNode.simdEulerAngles = float3(0, faceYaw, 0)
        
        if checkedBlink {
            if detectMouthBlink() {
                ARMotionSelected_Mushroom()
                
//                UIView.animate(withDuration: 0, delay: 3.0, options: [.curveLinear], animations: {
//                    self.checkedBlink = true
//                })
            }
        }
    }
    
    func headNoseARMotion(x: Float, y: Float, z: Float) {
        
    }
    
    func mouthARMotion(x: Float, y: Float, z: Float) {
        
    }
    
    func eyeARMotion(x: Float, y: Float, z: Float) {
        
    }
    
    func normalizationPos(source: CGPoint) -> CGPoint {
        var result: CGPoint = CGPoint.init()
        
        result.x = source.x - halfWidth
        result.x *= 3.5 / halfWidth
        
        result.y = source.y - halfHeight
        result.y *= 6.2 / halfHeight
        
        return result
    }
    
    func normalizationPitch(source: Float) -> Float {
        var result: Float
        
        result = source * (.pi / 100)

        return result
    }
    
    func normalizationYaw(source: Float) -> Float {
        var result: Float
        
        result = source * (.pi / 75)
        
        return result
    }
    
    func normalizationRoll(source: Float) -> Float {
        var result: Float

        result = source * (.pi / 400)

        return result
    }
    
    // 세 점의 각
    func getAngle(first: CGPoint, second: CGPoint, third: CGPoint) -> CGFloat {
        let y_1 = (first.y + third.y) / 2
        let y_2 = second.y
        
        let vec1 = CGVector(dx: first.x - second.x, dy: y_2 - y_1)
        let vec2 = CGVector(dx: third.x - second.x, dy: y_2 - y_1)
        
        let theta1 = CGFloat(atan2f(Float(vec1.dx), Float(vec1.dy)))
        let theta2 = CGFloat(atan2f(Float(vec2.dx), Float(vec2.dy)))
        
        let angle = theta1 - theta2
        
        return CGFloat(Double(angle) / M_PI * 180)
    }
    
    // 두 점 사이의 거리
    func pointsDistance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        let xDist = a.x - b.x
        let yDist = a.y - b.y
        return CGFloat(sqrt(xDist * xDist + yDist * yDist))
    }
    
    // 세 점의 무게 중심
    func getGravityCenter(first: CGPoint, second: CGPoint, third: CGPoint) -> CGPoint {
        let d1 = CGPoint(x: second.y - first.y, y: second.x - first.x)
        let d2 = CGPoint(x: third.y - second.y, y: third.x - second.x)
        let k: CGFloat = d2.x * d1.y - d2.y * d1.x
        let s1 = CGPoint(x: (first.x + second.x) / 2, y: (first.y + second.y) / 2)
        let s2 = CGPoint(x: (first.x + third.x) / 2, y: (first.y + third.y) / 2)
        let l: CGFloat = d1.x * (s2.y - s1.y) - d1.y * (s2.x - s1.x)
        let m: CGFloat = l / k
        let center = CGPoint(x: s2.x + m * d2.x, y: s2.y + m * d2.y)
        
        return center
    }
    
    // 세 점의 외심
    func getCircumcenter(first: CGPoint, second: CGPoint, third: CGPoint) -> CGPoint {
        return Triangle.init(a: first, b: second, c: third).circumcenter
    }
    
//    func detectEyeBlink() -> Bool {
//        let blink = leftEye[6].y - leftEye[2].y
//        return
//    }
    
    func detectMouthBlink() -> Bool {
        let blink = innerLips[4].y - innerLips[1].y
        
        print(blink)
        
        if blink > 10 {
            return true
        } else {
            return false
        }
    }
    
    func ARMotionSelected_Heart() {
        ARNode_x = 0
        ARNode_y = 3.5
        ARNode_z = -5
        
        selectScene = SCNScene(named: "FaceAR.scnassets/Heart.scn")!
        headNode = (selectScene.rootNode.childNode(withName: "Heart", recursively: true))!
        
        ARscene.rootNode.addChildNode(headNode)
    }
    
    func ARMotionSelected_Angel() {
        ARNode_x = 0
        ARNode_y = 0
        ARNode_z = -5
        
        selectScene = SCNScene(named: "FaceAR.scnassets/Angel.scn")!
        headNode = (selectScene.rootNode.childNode(withName: "Angel", recursively: true))!
        
        ARscene.rootNode.addChildNode(headNode)
    }
    
    func ARMotionSelected_Rabbit() {
        ARNode_x = 0
        ARNode_y = 3.5
        ARNode_z = -5
        
        selectScene = SCNScene(named: "FaceAR.scnassets/Rabbit_head.scn")!
        headNode = (selectScene.rootNode.childNode(withName: "Rabbit_head", recursively: true))!
        
        selectScene = SCNScene(named: "FaceAR.scnassets/Rabbit_nose.scn")!
        noseNode = (selectScene.rootNode.childNode(withName: "Rabbit_nose", recursively: true))!
        
        ARscene.rootNode.addChildNode(headNode)
        ARscene.rootNode.addChildNode(noseNode)
    }
    
    func ARMotionSelected_Cat() {
        ARNode_x = 0
        ARNode_y = 3.5
        ARNode_z = -5
        
        selectScene = SCNScene(named: "FaceAR.scnassets/Cat_head.scn")!
        headNode = (selectScene.rootNode.childNode(withName: "Cat_head", recursively: true))!
        
        selectScene = SCNScene(named: "FaceAR.scnassets/Cat_nose.scn")!
        noseNode = (selectScene.rootNode.childNode(withName: "Cat_nose", recursively: true))!
        
        ARscene.rootNode.addChildNode(headNode)
        ARscene.rootNode.addChildNode(noseNode)
    }
    
    func ARMotionSelected_Mouse() {
        ARNode_x = 0
        ARNode_y = 3.5
        ARNode_z = -5
        
        selectScene = SCNScene(named: "FaceAR.scnassets/Mouse_head.scn")!
        headNode = (selectScene.rootNode.childNode(withName: "Mouse_head", recursively: true))!
        
        selectScene = SCNScene(named: "FaceAR.scnassets/Mouse_nose.scn")!
        noseNode = (selectScene.rootNode.childNode(withName: "Mouse_nose", recursively: true))!
        
        ARscene.rootNode.addChildNode(headNode)
        ARscene.rootNode.addChildNode(noseNode)
    }
    
    func ARMotionSelected_Peach() {
        ARNode_x = 0
        ARNode_y = 4.35
        ARNode_z = -5
        
        selectScene = SCNScene(named: "FaceAR.scnassets/Peach.scn")!
        headNode = (selectScene.rootNode.childNode(withName: "Peach", recursively: true))!
        
        ARscene.rootNode.addChildNode(headNode)
    }
    
    func ARMotionSelected_BAAAM() {
        ARNode_x = 0
        ARNode_y = 4
        ARNode_z = -5
        
        selectScene = SCNScene(named: "FaceAR.scnassets/BAAAM.scn")!
        headNode = (selectScene.rootNode.childNode(withName: "BAAAM", recursively: true))!
        
        ARscene.rootNode.addChildNode(headNode)
    }
    
    func ARMotionSelected_Mushroom() {
        ARNode_x = 0
        ARNode_y = 2.5
        ARNode_z = -5
        
        if checkedBlink {
            self.ARMotionDelete()
            
            selectScene = SCNScene(named: "FaceAR.scnassets/Mushroom1_head.scn")!
            headNode = (selectScene.rootNode.childNode(withName: "Mushroom1_head", recursively: true))!
            
            selectScene = SCNScene(named: "FaceAR.scnassets/Mushroom1_nose.scn")!
            noseNode = (selectScene.rootNode.childNode(withName: "Mushroom1_nose", recursively: true))!
            
            ARscene.rootNode.addChildNode(headNode)
            ARscene.rootNode.addChildNode(noseNode)
            
            checkedBlink = false
        } else {
            self.ARMotionDelete()
        
            selectScene = SCNScene(named: "FaceAR.scnassets/Mushroom2.scn")!
            headNode = (selectScene.rootNode.childNode(withName: "Mushroom2", recursively: true))!
        
            ARscene.rootNode.addChildNode(headNode)
        }
    }
    
    func ARMotionSelected_Doughnut() {
        ARNode_x = 0
        ARNode_y = -4
        ARNode_z = -5
        
        selectScene = SCNScene(named: "FaceAR.scnassets/Doughnut1.scn")!
        eatNode = (selectScene.rootNode.childNode(withName: "Doughnut1", recursively: true))!
        
        ARscene.rootNode.addChildNode(eatNode)
    }
    
    func ARMotionSelected_Flower() {
        ARNode_x = 0
        ARNode_y = 0
        ARNode_z = -5
        
        selectScene = SCNScene(named: "FaceAR.scnassets/Flower3.scn")!
        noseNode = (selectScene.rootNode.childNode(withName: "Flower3", recursively: true))!
        
        ARscene.rootNode.addChildNode(noseNode)
    }
    
    func ARMotionSelected_Snow() {
        let particle1 = SCNParticleSystem(named: "BGAR.scnassets/Snow_1.scnp", inDirectory: nil)
        let particle2 = SCNParticleSystem(named: "BGAR.scnassets/Snow_2.scnp", inDirectory: nil)
        let particle3 = SCNParticleSystem(named: "BGAR.scnassets/Snow_3.scnp", inDirectory: nil)
        let particle4 = SCNParticleSystem(named: "BGAR.scnassets/Snow_4.scnp", inDirectory: nil)
//        particle1?.loops = true // 반복함
//        particle2?.loops = true // 반복함
//        particle3?.loops = true // 반복함
//        particle4?.loops = true // 반복함
        
        BGNode.addParticleSystem(particle1!)
        BGNode.addParticleSystem(particle2!)
        BGNode.addParticleSystem(particle3!)
        BGNode.addParticleSystem(particle4!)
        BGNode.position = SCNVector3(0, 0, 0)
        ARscene.rootNode.addChildNode(BGNode)
    }
    
    func ARMotionSelected_Blossom() {
        let particle1 = SCNParticleSystem(named: "BGAR.scnassets/Blossom_1.scnp", inDirectory: nil)
        let particle2 = SCNParticleSystem(named: "BGAR.scnassets/Blossom_2.scnp", inDirectory: nil)
        let particle3 = SCNParticleSystem(named: "BGAR.scnassets/Blossom_3.scnp", inDirectory: nil)
        
        BGNode.addParticleSystem(particle1!)
        BGNode.addParticleSystem(particle2!)
        BGNode.addParticleSystem(particle3!)
        BGNode.position = SCNVector3(0, 0, 0)
        ARscene.rootNode.addChildNode(BGNode)
    }
    
    func ARMotionSelected_Rain() {
        let particle1 = SCNParticleSystem(named: "BGAR.scnassets/Rain_1.scnp", inDirectory: nil)
        let particle2 = SCNParticleSystem(named: "BGAR.scnassets/Rain_2.scnp", inDirectory: nil)
        let particle3 = SCNParticleSystem(named: "BGAR.scnassets/Rain_3.scnp", inDirectory: nil)
        let particle4 = SCNParticleSystem(named: "BGAR.scnassets/Rain_4.scnp", inDirectory: nil)
        let particle5 = SCNParticleSystem(named: "BGAR.scnassets/Rain_5.scnp", inDirectory: nil)
        
        BGNode.addParticleSystem(particle1!)
        BGNode.addParticleSystem(particle2!)
        BGNode.addParticleSystem(particle3!)
        BGNode.addParticleSystem(particle4!)
        BGNode.addParticleSystem(particle5!)
        BGNode.position = SCNVector3(0, 0, 0)
        ARscene.rootNode.addChildNode(BGNode)
    }
    
    func ARMotionSelected_Fish() {
        let particle1 = SCNParticleSystem(named: "BGAR.scnassets/Fish_1.scnp", inDirectory: nil)
        let particle2 = SCNParticleSystem(named: "BGAR.scnassets/Fish_2.scnp", inDirectory: nil)
        let particle3 = SCNParticleSystem(named: "BGAR.scnassets/Fish_3.scnp", inDirectory: nil)
        let particle4 = SCNParticleSystem(named: "BGAR.scnassets/Fish_4.scnp", inDirectory: nil)
        let particle5 = SCNParticleSystem(named: "BGAR.scnassets/Fish_5.scnp", inDirectory: nil)
        
        BGNode.addParticleSystem(particle1!)
        BGNode.addParticleSystem(particle2!)
        BGNode.addParticleSystem(particle3!)
        BGNode.addParticleSystem(particle4!)
        BGNode.addParticleSystem(particle5!)
        BGNode.position = SCNVector3(0, 0, 0)
        ARscene.rootNode.addChildNode(BGNode)
    }
    
    func ARMotionSelected_Greenery() {
        let particle1 = SCNParticleSystem(named: "BGAR.scnassets/Greenery_1.scnp", inDirectory: nil)
        let particle2 = SCNParticleSystem(named: "BGAR.scnassets/Greenery_2.scnp", inDirectory: nil)
        let particle3 = SCNParticleSystem(named: "BGAR.scnassets/Greenery_3.scnp", inDirectory: nil)
        let particle4 = SCNParticleSystem(named: "BGAR.scnassets/Greenery_4.scnp", inDirectory: nil)
        
        BGNode.addParticleSystem(particle1!)
        BGNode.addParticleSystem(particle2!)
        BGNode.addParticleSystem(particle3!)
        BGNode.addParticleSystem(particle4!)
        BGNode.position = SCNVector3(0, 0, 0)
        ARscene.rootNode.addChildNode(BGNode)
    }
    
    func ARMotionSelected_Fruits() {
        let particle1 = SCNParticleSystem(named: "BGAR.scnassets/Fruit_1.scnp", inDirectory: nil)
        let particle2 = SCNParticleSystem(named: "BGAR.scnassets/Fruit_2.scnp", inDirectory: nil)
        let particle3 = SCNParticleSystem(named: "BGAR.scnassets/Fruit_3.scnp", inDirectory: nil)
        let particle4 = SCNParticleSystem(named: "BGAR.scnassets/Fruit_4.scnp", inDirectory: nil)
        let particle5 = SCNParticleSystem(named: "BGAR.scnassets/Fruit_5.scnp", inDirectory: nil)
        
        BGNode.addParticleSystem(particle1!)
        BGNode.addParticleSystem(particle2!)
        BGNode.addParticleSystem(particle3!)
        BGNode.addParticleSystem(particle4!)
        BGNode.addParticleSystem(particle5!)
        BGNode.position = SCNVector3(0, 0, 0)
        ARscene.rootNode.addChildNode(BGNode)
    }
    
    func ARMotionSelected_Glow() {
        let particle1 = SCNParticleSystem(named: "BGAR.scnassets/Glow_1.scnp", inDirectory: nil)
        let particle2 = SCNParticleSystem(named: "BGAR.scnassets/Glow_2.scnp", inDirectory: nil)
        let particle3 = SCNParticleSystem(named: "BGAR.scnassets/Glow_3.scnp", inDirectory: nil)
        let particle4 = SCNParticleSystem(named: "BGAR.scnassets/Glow_4.scnp", inDirectory: nil)
        
        BGNode.addParticleSystem(particle1!)
        BGNode.addParticleSystem(particle2!)
        BGNode.addParticleSystem(particle3!)
        BGNode.addParticleSystem(particle4!)
        BGNode.position = SCNVector3(0, 0, 0)
        ARscene.rootNode.addChildNode(BGNode)
    }
    
    func ARMotionSelected_MakingAR(index: Int) {
        let node = SCNNode(geometry: SCNPlane(width: 10.0, height: 17.7))
        node.geometry?.materials.first?.diffuse.contents = FaceARMotionArray[index]
        
        noseNode = node
        
        ARscene.rootNode.addChildNode(noseNode)
    }
    
    func ARMotionSelected_newMakingAR() {
        let node = SCNNode(geometry: SCNPlane(width: 10.0, height: 17.7))
        node.geometry?.materials.first?.diffuse.contents = FaceARMotionArray[FaceARMotionArray.count - 1]
        
        noseNode = node
        
        ARscene.rootNode.addChildNode(noseNode)
    }
    
    // Clip Set
    @IBAction func setClipLength(_ sender: UIButton) {
        if clipView.isHidden {
            self.clipView.isHidden = false
            
            UIView.animate(withDuration: 0.2, animations: {
                self.clipView.alpha = 1.0
            })
        } else {
            UIView.animate(withDuration: 0.2, animations: {
                self.clipView.alpha = 0.0
            })
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.clipView.isHidden = true
            }
        }
    }
    
    @IBAction func clipOneButtonTapped(_ sender: UIButton) {
        if (oneClipState) {
            clipTime = 0.0
            oneClipState = false
        } else {
            clipTime = 5.0
            oneClipState = true
            twoClipState = false
            threeClipState = false
            plusClipState = false
        }
        
        clipButtonStateCheck()
        
        if (clipViewState) {
            clipView.layer.frame = CGRect(x: 54.5 , y: 56, width: clipView.frame.width, height: clipView.frame.height / 3)
            clipViewDivideBar.isHidden = true
            plusClipPicker.isHidden = true
            clipViewState = false
        }
    }
    
    @IBAction func clipTwoButtonTapped(_ sender: UIButton) {
        if (twoClipState) {
            clipTime = 0.0
            twoClipState = false
        } else {
            clipTime = 10.0
            oneClipState = false
            twoClipState = true
            threeClipState = false
            plusClipState = false
        }
        
        clipButtonStateCheck()
        
        if (clipViewState) {
            clipView.layer.frame = CGRect(x: 54.5 , y: 56, width: clipView.frame.width, height: clipView.frame.height / 3)
            clipViewDivideBar.isHidden = true
            plusClipPicker.isHidden = true
            clipViewState = false
        }
    }
    
    @IBAction func clipThreeButtonTapped(_ sender: UIButton) {
        if (threeClipState) {
            clipTime = 0.0
            threeClipState = false
        } else {
            clipTime = 30.0
            oneClipState = false
            twoClipState = false
            threeClipState = true
            plusClipState = false
        }
        
        clipButtonStateCheck()
        
        if (clipViewState) {
            clipView.layer.frame = CGRect(x: 54.5 , y: 56, width: clipView.frame.width, height: clipView.frame.height / 3)
            clipViewDivideBar.isHidden = true
            plusClipPicker.isHidden = true
            clipViewState = false
        }
    }
    
    @IBAction func clipPlusButtonTapped(_ sender: UIButton) {
        if (plusClipState) {
            clipTime = 0.0
            plusClipState = false
        } else {
            oneClipState = false
            twoClipState = false
            threeClipState = false
            plusClipState = true
        }
        
        clipButtonStateCheck()
        
        if (clipViewState) {
            clipView.layer.frame = CGRect(x: 54.5 , y: 56, width: clipView.frame.width, height: clipView.frame.height / 3)
            clipViewDivideBar.isHidden = true
            plusClipPicker.isHidden = true
            clipViewState = false
        } else {
            clipView.layer.frame = CGRect(x: 54.5, y: 56, width: clipView.frame.width, height: clipView.frame.height * 3)
            clipViewDivideBar.isHidden = false
            plusClipPicker.isHidden = false
            clipViewState = true
        }
    }
    
    func clipButtonStateCheck() {
        if (oneClipState) {
            oneClipButton.setTitleColor(UIColor.white, for: .normal)
            oneClipButton.applyGradient(colors: [UIColor(red: 16/255, green: 208/255, blue: 255/255, alpha: 1.0).cgColor, UIColor(red: 254/255, green: 156/255, blue: 255/255, alpha: 1.0).cgColor], state: true)
        } else {
            oneClipButton.setTitleColor(UIColor(red: 84/255, green: 84/255, blue: 84/255, alpha: 1.0), for: .normal)
            oneClipButton.applyGradient(colors: [UIColor.white.cgColor, UIColor.white.cgColor], state: true)
        }
        
        if (twoClipState) {
            twoClipButton.setTitleColor(UIColor.white, for: .normal)
            twoClipButton.applyGradient(colors: [UIColor(red: 16/255, green: 208/255, blue: 255/255, alpha: 1.0).cgColor, UIColor(red: 254/255, green: 156/255, blue: 255/255, alpha: 1.0).cgColor], state: true)
        } else {
            twoClipButton.setTitleColor(UIColor(red: 84/255, green: 84/255, blue: 84/255, alpha: 1.0), for: .normal)
            twoClipButton.applyGradient(colors: [UIColor.white.cgColor, UIColor.white.cgColor], state: true)
        }
        
        if (threeClipState) {
            threeClipButton.setTitleColor(UIColor.white, for: .normal)
            threeClipButton.applyGradient(colors: [UIColor(red: 16/255, green: 208/255, blue: 255/255, alpha: 1.0).cgColor, UIColor(red: 254/255, green: 156/255, blue: 255/255, alpha: 1.0).cgColor], state: true)
        } else {
            threeClipButton.setTitleColor(UIColor(red: 84/255, green: 84/255, blue: 84/255, alpha: 1.0), for: .normal)
            threeClipButton.applyGradient(colors: [UIColor.white.cgColor, UIColor.white.cgColor], state: true)
        }
        
        if (plusClipState) {
            plusClipButton.setTitleColor(UIColor.white, for: .normal)
            plusClipButton.applyGradient(colors: [UIColor(red: 16/255, green: 208/255, blue: 255/255, alpha: 1.0).cgColor, UIColor(red: 254/255, green: 156/255, blue: 255/255, alpha: 1.0).cgColor], state: true)
        } else {
            plusClipButton.setTitleColor(UIColor(red: 84/255, green: 84/255, blue: 84/255, alpha: 1.0), for: .normal)
            plusClipButton.applyGradient(colors: [UIColor.white.cgColor, UIColor.white.cgColor], state: true)
        }
        
        print(oneClipState)
        print(twoClipState)
        print(threeClipState)
        print(plusClipState)
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return 60
        } else {
            return 10
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let title = UILabel()
        title.font = UIFont(name: "NotoSansCJKkr-Regular", size: 15.0)
        title.textColor = UIColor(red: 84.0/255.0, green: 84.0/255.0, blue: 84.0/255.0, alpha: 1.0)
        title.text = String(row)
        title.textAlignment = .center
        
        if component == 0 {
            return title
        }
        else {
            return title
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        clipTime = (Double(plusClipPicker.selectedRow(inComponent: 0)) * 60.0) + Double(plusClipPicker.selectedRow(inComponent: 1))
    }
    
    // Menu Set
    @objc func MenuViewTap(gestureRecognizer: UITapGestureRecognizer){
        XbuttonTapped(menuXButtonOn)
        
        if (ARMotionViewState) {
            ARMotionViewState = false
            
            UIView.animate(withDuration: 0.2, animations: {
                self.buttonHide(state: true)
                self.ARMotionView.center += CGPoint(x: 0, y: 230)
                
                self.view.layoutIfNeeded()
            })
        }
        
        if (filterViewState) {
            filterViewState = false
            
            UIView.animate(withDuration: 0.2, animations: {
                self.buttonHide(state: true)
                self.filterBackView.center += CGPoint(x: 0, y: 207.5)
                
                self.filterPowerSlider.isHidden = true
                
                self.view.layoutIfNeeded()
            })
        }
    }
    
    @objc func ARMotionViewSwipe(gestureRecognizer: UISwipeGestureRecognizer){
        XbuttonTapped(menuXButtonOn)
        
        if (ARMotionViewState) {
            ARMotionViewState = false
            
            UIView.animate(withDuration: 0.2, animations: {
                self.buttonHide(state: true)
                self.ARMotionView.center += CGPoint(x: 0, y: 230)
                
                self.view.layoutIfNeeded()
            })
        }
    }
    
    @objc func filterViewSwipe(gestureRecognizer: UISwipeGestureRecognizer){
        XbuttonTapped(menuXButtonOn)
        
        if (filterViewState) {
            filterViewState = false
            
            UIView.animate(withDuration: 0.2, animations: {
                self.buttonHide(state: true)
                self.filterBackView.center += CGPoint(x: 0, y: 207.5)
                
                self.filterPowerSlider.isHidden = true
                
                self.view.layoutIfNeeded()
            })
        }
    }
    
    @IBAction func menuTapped(_ sender: UIButton) {
        buttonHide(state: false)
        
        menuXButton.isEnabled = false
        menuXButtonOn.isEnabled = false
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: [.curveLinear], animations: {
            self.menuView.isHidden = false
            self.menuView.alpha = 1.0
            self.menuXButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            self.menuXButton.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            self.menuXButtonOn.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            self.menuXButtonOn.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            self.menuXButton.alpha = 1.0
        })
        
        UIView.animate(withDuration: 0.15, delay: 0.3, options: [.curveLinear], animations: {
            self.buttonAnimation(button: self.menuMakingARButton, label: self.menuMakingARLabel, buttonPosition: self.makingARButtonCenter, size: 1.0, labelPosition: self.makingARLabelCenter)
        })
        UIView.animate(withDuration: 0.15, delay: 0.4, options: [.curveLinear], animations: {
            self.buttonAnimation(button: self.menuARMotionButton, label: self.menuARMotionLabel, buttonPosition: self.ARMotionButtonCenter, size: 1.0, labelPosition: self.ARMotionLabelCenter)
        })
        UIView.animate(withDuration: 0.15, delay: 0.5, options: [.curveLinear], animations: {
            self.buttonAnimation(button: self.menuFilterButton, label: self.menuFilterLabel, buttonPosition: self.filterButtonCenter, size: 1.0, labelPosition: self.filterLabelCenter)
        })
        UIView.animate(withDuration: 0.2, delay: 0.6, options: [.curveLinear], animations: {
            self.menuXButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            self.menuXButtonOn.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            self.menuXButtonOn.alpha = 0.0
            
            self.menuMakingARLabel.alpha = 1.0
            self.menuARMotionLabel.alpha = 1.0
            self.menuFilterLabel.alpha = 1.0
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.menuXButton.isEnabled = true
            self.menuXButtonOn.isEnabled = true
        }
    }
    
    @IBAction func XbuttonTapped(_ sender: UIButton) {
        tapGestureView.isHidden = true
        
        menuXButton.isEnabled = false
        menuXButtonOn.isEnabled = false
        
        UIView.animate(withDuration: 0.15, delay: 0.0, options: [.curveLinear], animations: {
            self.menuMakingARLabel.alpha = 0.0
            self.menuARMotionLabel.alpha = 0.0
            self.menuFilterLabel.alpha = 0.0
            
            self.menuXButtonOn.alpha = 1.0
            self.menuXButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            self.menuXButton.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            self.menuXButtonOn.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            self.menuXButtonOn.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            self.menuXButton.alpha = 0.0
            self.buttonAnimation(button: self.menuMakingARButton, label: self.menuMakingARLabel, buttonPosition: self.menuXButton.center, size: 0.5, labelPosition: self.menuXButton.center)
        })
        UIView.animate(withDuration: 0.15, delay: 0.1, options: [.curveLinear], animations: {
            self.buttonAnimation(button: self.menuARMotionButton, label: self.menuARMotionLabel, buttonPosition: self.menuXButton.center, size: 0.5, labelPosition: self.menuXButton.center)
        })
        UIView.animate(withDuration: 0.15, delay: 0.2, options: [.curveLinear], animations: {
            self.buttonAnimation(button: self.menuFilterButton, label: self.menuFilterLabel, buttonPosition: self.menuXButton.center, size: 0.5, labelPosition: self.menuXButton.center)
        })
        UIView.animate(withDuration: 0.15, delay: 0.3, options: [.curveLinear], animations: {
            self.menuXButton.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            self.menuXButtonOn.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            self.menuView.alpha = 0.0
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            self.menuView.isHidden = true
            
            self.menuXButton.isEnabled = true
            self.menuXButtonOn.isEnabled = true
        }
    }
    
    @IBAction func MakingARbuttonTapped(_ sender: UIButton) {
//        let storyboard = UIStoryboard(name: "UI", bundle: nil)
//        let nextView = storyboard.instantiateViewController(withIdentifier: "MakingARView")
//        nextView.modalPresentationStyle = UIModalPresentationStyle.fullScreen
//        nextView.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        
        makingARButtonState = true
        ARMotionButtonState = false
        filterButtonState = false
        
        self.menuButtonStateCheck()
    }

    @IBAction func ARMotionbuttonTapped(_ sender: UIButton) {
        let indexPaths = [IndexPath]()
        ARMotionCollectionView.reloadItems(at: indexPaths)
        
        let tapMenuView: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MenuViewTap))
        tapGestureView.addGestureRecognizer(tapMenuView)
        tapGestureView.isHidden = false
        tapGestureView.frame = CGRect(x: 0, y: 0, width: 375, height: 437)
        
        makingARButtonState = false
        ARMotionButtonState = true
        filterButtonState = false
        
        UIView.animate(withDuration: 0.2) {
            self.menuView.alpha = 0.0
            self.buttonHide(state: true)
            self.ARMotionView.center -= CGPoint(x: 0, y: 230)
            self.ARMotionViewState = true
        }
        
        self.menuButtonStateCheck()
    }
    
    @IBAction func fiterbuttonTapped(_ sender: UIButton) {
        let tapMenuView: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MenuViewTap))
        tapGestureView.addGestureRecognizer(tapMenuView)
        tapGestureView.isHidden = false
        tapGestureView.frame = CGRect(x: 0, y: 0, width: 375, height: 437)
        
        makingARButtonState = false
        ARMotionButtonState = false
        filterButtonState = true
        
        UIView.animate(withDuration: 0.2) {
            self.menuView.alpha = 0.0
            self.buttonHide(state: true)
            self.filterBackView.center -= CGPoint(x: 0, y: 207.5)
            self.filterViewState = true
        }
        
        self.menuButtonStateCheck()
    }
    
    func menuSelectedOn(button: UIButton, changeImage: UIImage) {
        button.setImage(changeImage, for: .normal)
        
        UIView.animate(withDuration: 0.1) {
            button.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            button.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            self.buttonDropShadow(button: button)
        }
    }
    
    func menuSelectedOff(button: UIButton, changeImage: UIImage) {
        button.setImage(changeImage, for: .normal)
        
        UIView.animate(withDuration: 0.1) {
            button.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            button.layer.shadowOpacity = 0.0
        }
    }

    func iconDropShadow(button: UIButton, state: Bool) {
        if state {
            button.layer.shadowColor = UIColor.black.cgColor
            button.layer.shadowOffset = CGSize(width: 0, height: 0)
            button.layer.shadowRadius = 1
            button.layer.shadowOpacity = 0.3
        } else {
            button.layer.shadowOpacity = 0
        }
    }
    
    func labelDropShadow(label: UIButton, state: Bool) {
        if state {
            label.layer.shadowColor = UIColor.black.cgColor
            label.layer.shadowOffset = CGSize(width: 0, height: 0)
            label.layer.shadowRadius = 1
            label.layer.shadowOpacity = 0.3
        } else {
            label.layer.shadowOpacity = 0
        }
    }
    
    func viewDropShadow(view: UIView) {
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.layer.shadowRadius = 1
        view.layer.shadowOpacity = 0.15
    }
    
    func buttonDropShadow(button: UIButton) {
        button.layer.shadowOpacity = 0.16
        button.layer.shadowRadius = 10.0
        button.layer.shadowOffset = CGSize(width: 1, height: 1)
        button.layer.shadowColor = UIColor.black.cgColor
    }
    
    func addBackView(view: UIView, color: UIColor, alpha: CGFloat, cornerRadius: CGFloat) {
        let backView = UIView()
        backView.frame = view.bounds
        backView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backView.backgroundColor = color
        backView.alpha = alpha
        backView.layer.cornerRadius = cornerRadius
        view.addSubview(backView)
        view.sendSubviewToBack(backView)
    }
    
    func buttonAnimation(button: UIButton, label: UILabel, buttonPosition: CGPoint, size: CGFloat, labelPosition: CGPoint) {
        button.center = buttonPosition
        label.center = labelPosition
        button.transform = CGAffineTransform(scaleX: size, y: size)
        label.transform = CGAffineTransform(scaleX: size, y: size)
    }
    
    func menuButtonStateCheck() {
        if (makingARButtonState) {
            UIView.animate(withDuration: 0.1) {
//                self.menuMakingARLabel.alpha = 1.0
            }
            self.menuSelectedOn(button: self.menuMakingARButton, changeImage: UIImage(named: "ic_makingAR_on")!)
        } else {
            UIView.animate(withDuration: 0.1) {
//                self.menuMakingARLabel.alpha = 0.0
            }
            self.menuSelectedOff(button: self.menuMakingARButton, changeImage: UIImage(named: "ic_makingAR_off")!)
        }
        
        if (ARMotionButtonState) {
            UIView.animate(withDuration: 0.1) {
//                self.menuARMotionLabel.alpha = 1.0
            }
            self.menuSelectedOn(button: self.menuARMotionButton, changeImage: UIImage(named: "ic_ARMotion_on")!)
        } else {
            UIView.animate(withDuration: 0.1) {
//                self.menuARMotionLabel.alpha = 0.0
            }
            self.menuSelectedOff(button: self.menuARMotionButton, changeImage: UIImage(named: "ic_ARMotion_off")!)
        }
        
        if (filterButtonState) {
            UIView.animate(withDuration: 0.1) {
//                self.menuFilterLabel.alpha = 1.0
            }
            self.menuSelectedOn(button: self.menuFilterButton, changeImage: UIImage(named: "ic_filter_on")!)
        } else {
            UIView.animate(withDuration: 0.1) {
//                self.menuFilterLabel.alpha = 0.0
            }
            self.menuSelectedOff(button: self.menuFilterButton, changeImage: UIImage(named: "ic_filter_off")!)
        }
    }
    
    func buttonHide(state: Bool) {
        menuXButton.isHidden = state
        menuXButtonOn.isHidden = state
        menuMakingARButton.isHidden = state
        menuARMotionButton.isHidden = state
        menuFilterButton.isHidden = state
        
        menuMakingARLabel.isHidden = state
        menuARMotionLabel.isHidden = state
        menuFilterLabel.isHidden = state
    }
    
    // ARMotion View
    @IBAction func ARMotionDeleteButtonTapped(_ sender: UIButton) {
        createARMotionArray()
        
        UIView.animate(withDuration: 0.2) {
//            self.blurView.alpha = 0.8
//            self.buttonHide()
//            self.ARMotionView.center += CGPoint(x: 0, y: 230)
            
            self.ARMotionDelete()
        }
    }
    
    @IBAction func ARMotionSelectButtonTapped(_ sender: UIButton) {
        myARMotionButton.isSelected = false
        AllARMotionButton.isSelected = false
        FaceARMotionButton.isSelected = false
        BGARMotionButton.isSelected = false
        
        AllARMotionButton.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.38)
        FaceARMotionButton.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.38)
        BGARMotionButton.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.38)
        
        if sender == myARMotionButton {
            myARMotionButton.isSelected = true
            
        } else if sender == AllARMotionButton {
            AllARMotionButton.isSelected = true
            AllARMotionButton.backgroundColor = UIColor.white
            
        } else if sender == FaceARMotionButton {
            FaceARMotionButton.isSelected = true
            FaceARMotionButton.backgroundColor = UIColor.white
            
        } else if sender == BGARMotionButton {
            BGARMotionButton.isSelected = true
            BGARMotionButton.backgroundColor = UIColor.white
        }
        
        DispatchQueue.main.async {
            self.ARMotionCollectionView.reloadData()
        }
    }
    
    // ARMotion View + Filter View
    func getContext() -> NSManagedObjectContext {
        return appDelegate.persistentContainer.viewContext
    }
    
    func createARMotionArray() {
        AllARMotionArray = Array()
        FaceARMotionArray = Array()
        BGARMotionArray = Array()
        
        FaceARMotionArray = [UIImage(named: "FaceAR_Heart")!, UIImage(named: "FaceAR_Angel")!, UIImage(named: "FaceAR_Rabbit")!, UIImage(named: "FaceAR_Cat")!, UIImage(named: "FaceAR_Mouse")!, UIImage(named: "FaceAR_Peach")!, UIImage(named: "FaceAR_BAAAM")!, UIImage(named: "FaceAR_Mushroom")!, UIImage(named: "FaceAR_Doughnut")!, UIImage(named: "FaceAR_Flower")!]
        
        BGARMotionArray = [UIImage(named: "BGAR_Snow")!, UIImage(named: "BGAR_Blossom")!, UIImage(named: "BGAR_Rain")!, UIImage(named: "BGAR_Fish")!, UIImage(named: "BGAR_Greenery")!, UIImage(named: "BGAR_Fruits")!, UIImage(named: "BGAR_Glow")!]
        
        let MakingARInstance = MakingARViewController()
        let context = self.getContext()
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "MakingARData")
        
        do {
            localRecords = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        for index in 0 ..< localRecords.count {
            let localRecord = localRecords[index]
            FaceARMotionArray.append(MakingARInstance.loadImageFromDiskWith(fileName: localRecord.value(forKey: "idString") as! String)!)
        }
        
        AllARMotionArray = FaceARMotionArray + BGARMotionArray
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.ARMotionCollectionView {
            let ARMotionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ARMotionCell", for: indexPath) as! ARMotionCollectionViewCell
            
//            ARMotionCell.stateChangeButton.isHidden = true
//            ARMotionCell.stateChangeButton.alpha = 0.0
            
            ARMotionCell.layer.shadowOpacity = 0.6
            ARMotionCell.layer.shadowRadius = 1
            ARMotionCell.layer.shadowColor = UIColor.darkGray.cgColor
            ARMotionCell.layer.shadowOffset = CGSize(width: 1, height: 1)
            
            if myARMotionButton.isSelected {
                ARMotionCell.previewImage.image = myARMotionArray[indexPath.row]
                
                return ARMotionCell
            } else if AllARMotionButton.isSelected {
                ARMotionCell.previewImage.image = AllARMotionArray[indexPath.row]
                
                return ARMotionCell
            } else if FaceARMotionButton.isSelected {
                ARMotionCell.previewImage.image = FaceARMotionArray[indexPath.row]
                
                return ARMotionCell
            } else {    // if BGARMotionButton.isSelected
                ARMotionCell.previewImage.image = BGARMotionArray[indexPath.row]
                
                return ARMotionCell
            }
        } else {
            let filterCell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCell", for: indexPath) as! FilterCollectionViewCell
            
            filterCell.filterPreviewImage.image = UIImage(named: "filter_image")
            if indexPath.row > 0 {
                filterCell.filterNameLabel.text = "damda\(indexPath.row)"
            }
            
            return filterCell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.ARMotionCollectionView {
            if myARMotionButton.isSelected {
                return myARMotionArray.count
            } else if AllARMotionButton.isSelected {
                return AllARMotionArray.count
            } else if FaceARMotionButton.isSelected {
                return FaceARMotionArray.count
            } else if BGARMotionButton.isSelected {
                return BGARMotionArray.count
            }
        }
        
        if collectionView == self.filterCollectionView {
            return 0
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.ARMotionCollectionView {
            _ = collectionView.dequeueReusableCell(withReuseIdentifier: "ARMotionCell", for: indexPath) as! ARMotionCollectionViewCell
            
            let BGARMotionIndex = FaceARMotionArray.count
            
            self.ARMotionDelete()
            checkedBlink = false
            
            if myARMotionButton.isSelected {
                
            } else if AllARMotionButton.isSelected {
                if (indexPath.row == 0) {
                    self.ARMotionSelected_Heart()
                } else if (indexPath.row == 1) {
                    self.ARMotionSelected_Angel()
                } else if (indexPath.row == 2) {
                    self.ARMotionSelected_Rabbit()
                } else if (indexPath.row == 3) {
                    self.ARMotionSelected_Cat()
                } else if (indexPath.row == 4) {
                    self.ARMotionSelected_Mouse()
                } else if (indexPath.row == 5) {
                    self.ARMotionSelected_Peach()
                } else if (indexPath.row == 6) {
                    self.ARMotionSelected_BAAAM()
                } else if (indexPath.row == 7) {
                    self.ARMotionSelected_Mushroom()
                    checkedBlink = true
                } else if (indexPath.row == 8) {
                    self.ARMotionSelected_Doughnut()
                } else if (indexPath.row == 9) {
                    self.ARMotionSelected_Flower()
                } else if (indexPath.row == BGARMotionIndex) {
                    self.ARMotionSelected_Snow()
                } else if (indexPath.row == BGARMotionIndex + 1) {
                    self.ARMotionSelected_Blossom()
                } else if (indexPath.row == BGARMotionIndex + 2) {
                    self.ARMotionSelected_Rain()
                } else if (indexPath.row == BGARMotionIndex + 3) {
                    self.ARMotionSelected_Fish()
                } else if (indexPath.row == BGARMotionIndex + 4) {
                    self.ARMotionSelected_Greenery()
                } else if (indexPath.row == BGARMotionIndex + 5) {
                    self.ARMotionSelected_Fruits()
                } else if (indexPath.row == BGARMotionIndex + 6) {
                    self.ARMotionSelected_Glow()
                } else {
                    self.ARMotionSelected_MakingAR(index: indexPath.row)
                }
            } else if FaceARMotionButton.isSelected {
                if (indexPath.row == 0) {
                    self.ARMotionSelected_Heart()
                } else if (indexPath.row == 1) {
                    self.ARMotionSelected_Angel()
                } else if (indexPath.row == 2) {
                    self.ARMotionSelected_Rabbit()
                } else if (indexPath.row == 3) {
                    self.ARMotionSelected_Cat()
                } else if (indexPath.row == 4) {
                    self.ARMotionSelected_Mouse()
                } else if (indexPath.row == 5) {
                    self.ARMotionSelected_Peach()
                } else if (indexPath.row == 6) {
                    self.ARMotionSelected_BAAAM()
                } else if (indexPath.row == 7) {
                    self.ARMotionSelected_Mushroom()
                    checkedBlink = true
                } else if (indexPath.row == 8) {
                    self.ARMotionSelected_Doughnut()
                } else if (indexPath.row == 9) {
                    self.ARMotionSelected_Flower()
                } else {
                    self.ARMotionSelected_MakingAR(index: indexPath.row)
                }
            } else {    // if BGARMotionButton.isSelected
                if (indexPath.row == 0) {
                    self.ARMotionSelected_Snow()
                } else if (indexPath.row == 1) {
                    self.ARMotionSelected_Blossom()
                } else if (indexPath.row == 2) {
                    self.ARMotionSelected_Rain()
                } else if (indexPath.row == 3) {
                    self.ARMotionSelected_Fish()
                } else if (indexPath.row == 4) {
                    self.ARMotionSelected_Greenery()
                } else if (indexPath.row == 5) {
                    self.ARMotionSelected_Fruits()
                } else if (indexPath.row == 6) {
                    self.ARMotionSelected_Glow()
                }
            }
        }
    }
    
    @objc func ARMotionCellLongPress(gesture : UILongPressGestureRecognizer!) {
        if gesture.state != .ended {
            return
        }
        
        let p = gesture.location(in: self.ARMotionCollectionView)
        
        if let indexPath = self.ARMotionCollectionView.indexPathForItem(at: p) {
            // get the cell at indexPath (the one you long pressed)
            let cell = self.ARMotionCollectionView.cellForItem(at: indexPath)
            // do stuff with the cell
            
            let ARMotionCell = ARMotionCollectionView.dequeueReusableCell(withReuseIdentifier: "ARMotionCell", for: indexPath) as! ARMotionCollectionViewCell
            
            if (AllARMotionButton.isSelected || FaceARMotionButton.isSelected) {
                if (indexPath.row > 9) {
//                    ARMotionCell.stateChangeButton.setImage(UIImage(named: "ic_mini_x"), for: .normal)
//                    ARMotionCell.stateChangeButton.isHidden = false
                    
//                    UIView.animate(withDuration: Double(0.5), animations: {
//                        ARMotionCell.stateChangeButton.alpha = 1.0
//                    })
                }
            }
            print(indexPath)
        } else {
            print("couldn't find index path")
        }
    }
    
    @objc func ARMotionCellDoubleTab(gesture : UITapGestureRecognizer!) {
        let p = gesture.location(in: self.ARMotionCollectionView)
        
        if let indexPath = self.ARMotionCollectionView.indexPathForItem(at: p) {
            // get the cell at indexPath (the one you long pressed)
            let cell = self.ARMotionCollectionView.cellForItem(at: indexPath)
            // do stuff with the cell
            print(indexPath)
        } else {
            print("couldn't find index path")
        }
    }
    
    @IBAction func filterTempAction(_ sender: UIButton) {
        if sender == filterTemp1 {
            filterPowerSlider.isHidden = true
            filterBack.applyGradient_rect(colors: [UIColor.clear.cgColor, UIColor.clear.cgColor], state: true)
        } else if sender == filterTemp2 {
            filterPowerSlider.isHidden = false
            filterBack.applyGradient_rect(colors: [UIColor(red: 16/255, green: 208/255, blue: 255/255, alpha: 0.5).cgColor, UIColor(red: 254/255, green: 156/255, blue: 255/255, alpha: 0.5).cgColor], state: true)
        } else if sender == filterTemp3 {
            filterPowerSlider.isHidden = false
            filterBack.applyGradient_rect(colors: [UIColor(red: 254/255, green: 156/255, blue: 255/255, alpha: 0.5).cgColor, UIColor(red: 16/255, green: 208/255, blue: 255/255, alpha: 0.5).cgColor], state: true)
        } else if sender == filterTemp4 {
            filterPowerSlider.isHidden = false
            filterBack.applyGradient_rect(colors: [UIColor(red: 5/255, green: 17/255, blue: 133/255, alpha: 0.5).cgColor, UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.3).cgColor], state: true)
        }
    }
    
    @IBAction func filterPowerSet(_ sender: UISlider) {
        filterBack.alpha = CGFloat(sender.value)
    }
}

extension ARMotionViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        if let sampleBuffer = photoSampleBuffer, let previewBuffer = previewPhotoSampleBuffer, let dataImage = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer, previewPhotoSampleBuffer: previewBuffer) {
            let image = UIImage(data: dataImage)!
//            CustomPhotoAlbum.sharedInstance.save(image: image)
//            self.takenImage.image = image
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)

        }
    }
    
//    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
//
//        if let error = error {
//            print("Error Saving ARMotion Scene \(error)")
//        } else {
//            print("ARMotion Scene Successfully Saved")
//        }
//    }
}

extension FileManager {
    func clearTmpDirectory() {
        do {
            let tmpDirectory = try contentsOfDirectory(atPath: NSTemporaryDirectory())
            try tmpDirectory.forEach {[unowned self] file in
                let path = String.init(format: "%@%@", NSTemporaryDirectory(), file)
                try self.removeItem(atPath: path)
            }
        } catch {
            print(error)
        }
    }
}


//// MARK: - ReplayKit Preview Delegate
//extension ARMotionViewController : RPPreviewViewControllerDelegate {
//
//    func previewController(_ previewController: RPPreviewViewController, didFinishWithActivityTypes activityTypes: Set<String>) {
//        if activityTypes.contains(UIActivity.ActivityType.postToVimeo.rawValue)
//            || activityTypes.contains(UIActivity.ActivityType.postToFlickr.rawValue)
//            || activityTypes.contains(UIActivity.ActivityType.postToWeibo.rawValue)
//            || activityTypes.contains(UIActivity.ActivityType.postToTwitter.rawValue)
//            || activityTypes.contains(UIActivity.ActivityType.postToFacebook.rawValue)
//            || activityTypes.contains(UIActivity.ActivityType.mail.rawValue)
//            || activityTypes.contains(UIActivity.ActivityType.message.rawValue) {
//
//        }
//
//        //        uiViewController?.progressCircle.reset()
//        //        uiViewController?.recordBackgroundView.alpha = 0
//
//        previewController.dismiss(animated: true) {
//
////            self.uiWindow?.isHidden = false
//
//        }
//    }
//}
//
//// MARK: - RPScreenRecorderDelegate
//extension ARMotionViewController: RPScreenRecorderDelegate {
//    func screenRecorderDidChangeAvailability(_ screenRecorder: RPScreenRecorder) {
//        if screenRecorder.isAvailable == false {
//            let alert = UIAlertController.init(title: "Screen Recording Failed", message: "Screen Recorder is no longer available.", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
//                self.dismiss(animated: true, completion: nil)
//            }))
//            self.present(self, animated: true, completion: nil)
//        }
//    }
//}
