//
//  arMotionViewController.swift
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

class ARMotionViewController: UIViewController {

    static let identifier: String = "ARMotionViewController"
    
    let arView = SCNView()
    let arScene = SCNScene()
    
    var headNode = SCNNode()
    var noseNode = SCNNode()
    var eatNode = SCNNode()
    
    var bgNode = SCNNode()
    
    // Main view for showing camera content.
    @IBOutlet var previewView: UIView!
    @IBOutlet var iconView: UIView!
    
    var arNode_x: Float = 0
    var arNode_y: Float = 0
    var arNode_z: Float = 0
    var isBlink = false // true -> 체크할 수 있는 상태
    
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
    var arMotionButtonCenter: CGPoint!
    var filterButtonCenter: CGPoint!
    var makingARLabelCenter: CGPoint!
    var arMotionLabelCenter: CGPoint!
    var filterLabelCenter: CGPoint!
    var makingARButtonState: Bool = false
    var arMotionButtonState: Bool = false
    var filterButtonState: Bool = false
    
    let tapBackView: UIView = {
        let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: 375, height: 437)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    // arMotion View
    @IBOutlet var arMotionView: UIView!
    @IBOutlet var deleteARMotionButton: UIButton!
    @IBOutlet var myARMotionButton: UIButton!
    @IBOutlet var allARMotionButton: UIButton!
    @IBOutlet var faceARMotionButton: UIButton!
    @IBOutlet var bgARMotionButton: UIButton!
    @IBOutlet var arMotionCollectionView: UICollectionView!
    @IBOutlet weak var arMotionViewFlowLayout: UICollectionViewFlowLayout!
    var arMotionViewState: Bool = false
    var toARMotionNO: Bool = false // toarMotionNO
    var toARMotionYES: Bool = false // toarMotionYES
    
    // Filter View
    @IBOutlet var filterView: UIView!
    @IBOutlet var filterBackView: UIView!
    @IBOutlet var filterPowerSlider: UISlider!
    @IBOutlet weak var filterCollectionView: UICollectionView!
    @IBOutlet weak var filterViewFlowLayout: UICollectionViewFlowLayout!
    //    var filterArray: [UIImage]!
    var filterViewState: Bool = false
    //    let filterNameArray: [String] = ["CIPhotoEffectProcess", "CIPhotoEffectInstant",
    //                                     "Normal", "CIPhotoEffectMono", "CIPhotoEffectNoir",
    //                                     "CIPhotoEffectTonal", "CIPhotoEffectFade",
    //                                     "CIPhotoEffectChrome", "CIPhotoEffectTransfer"].sorted(by: >)
    let filterContext = CIContext()
    var selectedFilter = CIFilter(name: "CIComicEffect")
    
    @IBOutlet var filterBack: UIView!
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
    
    var recordingTimer: Timer?
    
    // Vision requests
    private var detectionRequests: [VNDetectFaceRectanglesRequest]?
    private var trackingRequests: [VNTrackObjectRequest]?
    
    lazy var sequenceRequestHandler = VNSequenceRequestHandler()
    
    private var halfWidth: CGFloat?
    private var halfHeight: CGFloat?
    
    var faceARMotionArray: [UIImage] {
        var array = [UIImage]()
        
        for kind in FaceARMotion.Kind.allCases {
            if let image = UIImage(named: "FaceAR_\(kind)") {
                array.append(image)
            }
        }
        
        if let makingARArray = DamdaData.shared.makingARArray {
            array.append(contentsOf: makingARArray)
        }
        
        return array
    }
    
    var bgARMotionArray: [UIImage] {
        var array = [UIImage]()
        
        for kind in BGARMotion.Kind.allCases {
            if let image = UIImage(named: "BGAR_\(kind)") {
                array.append(image)
            }
        }
        
        return array
    }
    
    var allARMotionArray: [UIImage] {
        var array = [UIImage]()
        
        array.append(contentsOf: self.faceARMotionArray)
        array.append(contentsOf: self.bgARMotionArray)
        
        return array
    }
    
    // MARK: UIViewController overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.isUserInteractionEnabled = false
        
        // Set ARSCNView
        self.initializeARView()
        // Set Record Button
        self.initializeRecordButton()
        // Set clip View
        self.initializeClipView()
        // Set menu view
        self.initializeMenuView()
        // Set Tap Gesture View on ARMotionView and FilterView
        self.initializeTapBackView()
        
        self.initializeARMotionView()
        self.initializeFilterView()
        
        self.previewLayer?.frame = self.view.bounds
        
        self.session = self.setupAVCaptureSession()
        
        self.halfWidth = self.view.bounds.width / 2
        self.halfHeight = self.view.bounds.height / 2
        
        self.registerUIGestureRecognizers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.async {
            self.setPreviewSize()
            self.updateUIIcon()
        }
        
        // Menu Set
        self.menuButtonStateCheck()
        self.menuXButtonOn.alpha = 1.0
        
        self.buttonAnimation(button: self.menuMakingARButton, label: self.menuMakingARLabel, buttonPosition: self.menuXButton.center, size: 0.5, labelPosition: self.menuXButton.center)
        self.buttonAnimation(button: self.menuARMotionButton, label: self.menuARMotionLabel, buttonPosition: self.menuXButton.center, size: 0.5, labelPosition: self.menuXButton.center)
        self.buttonAnimation(button: self.menuFilterButton, label: self.menuFilterLabel, buttonPosition: self.menuXButton.center, size: 0.5, labelPosition: self.menuXButton.center)
        self.menuView.alpha = 0.0
        
        // ARmotion Set
        self.arMotionCreate()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            if self.toARMotionNO {
                self.arMotionbuttonTapped(self.menuARMotionButton)
                self.toARMotionNO = false
            }
            
            if self.toARMotionYES {
                self.arMotionSelected_newMakingAR()
                self.toARMotionYES = false
            }
        }
        
        self.session?.startRunning()
        
        self.view.bringSubviewToFront(iconView)
        self.view.bringSubviewToFront(tapBackView)
        
        self.view.isUserInteractionEnabled = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func registerUIGestureRecognizers() {
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
        
        // menu set
        let dismissMenuView: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissMenu))
        self.menuView.addGestureRecognizer(dismissMenuView)
        
        let dismissCollectionView: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissCollection))
        self.tapBackView.addGestureRecognizer(dismissCollectionView)
    }
    
    private func initializeARView() {
        self.arView.frame = self.view.bounds
        self.arView.backgroundColor = UIColor.clear
        
        self.view.addSubview(arView)
    }
    
    private func initializeRecordButton() {
        self.recordButton.layer.cornerRadius = 27.5
        self.recordBackgroundGradient()
    }
    
    private func initializeClipView() {
        self.clipButton.isHidden = true
        self.clipView.alpha = 0.0
        self.clipView.layer.cornerRadius = 5
        
        self.oneClipButton.layer.cornerRadius = 20
        self.twoClipButton.layer.cornerRadius = 20
        self.threeClipButton.layer.cornerRadius = 20
        self.plusClipButton.layer.cornerRadius = 20
        
        self.oneClipButton.dropShadow(state: true)
        self.twoClipButton.dropShadow(state: true)
        self.threeClipButton.dropShadow(state: true)
        self.plusClipButton.dropShadow(state: true)
        
        self.oneClipButton.applyGradient(colors: [Properties.shared.color.white.cgColor, Properties.shared.color.white.cgColor], state: false)
        self.twoClipButton.applyGradient(colors: [Properties.shared.color.white.cgColor, Properties.shared.color.white.cgColor], state: false)
        self.threeClipButton.applyGradient(colors: [Properties.shared.color.white.cgColor, Properties.shared.color.white.cgColor], state: false)
        self.plusClipButton.applyGradient(colors: [Properties.shared.color.white.cgColor, Properties.shared.color.white.cgColor], state: false)
        
        self.plusClipPicker.selectRow(5, inComponent: 0, animated: false)
        
        let secLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        secLabel.font = Properties.shared.font.bold(13.0)
        secLabel.textColor = Properties.shared.color.darkGray
        secLabel.text = "m"
        secLabel.sizeToFit()
        secLabel.frame = CGRect(x: 81.0, y: 49.0, width: secLabel.bounds.width, height: secLabel.bounds.height)
        plusClipPicker.addSubview(secLabel)
        
        let minLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        minLabel.font = Properties.shared.font.bold(13.0)
        minLabel.textColor = Properties.shared.color.darkGray
        minLabel.text = "s"
        minLabel.sizeToFit()
        minLabel.frame = CGRect(x: 210.0, y: 49.0, width: minLabel.bounds.width, height: minLabel.bounds.height)
        plusClipPicker.addSubview(minLabel)
    }
    
    private func initializeMenuView() {
        self.makingARButtonCenter = self.menuMakingARButton.center
        self.arMotionButtonCenter = self.menuARMotionButton.center
        self.filterButtonCenter = self.menuFilterButton.center
        self.makingARLabelCenter = self.menuMakingARLabel.center
        self.arMotionLabelCenter = self.menuARMotionLabel.center
        self.filterLabelCenter = self.menuFilterLabel.center
        self.menuMakingARLabel.alpha = 0.0
        self.menuARMotionLabel.alpha = 0.0
        self.menuFilterLabel.alpha = 0.0
        
        self.menuView.isHidden = true
        self.menuView.alpha = 0.0
        addBackView(view: menuView, color: Properties.shared.color.black, alpha: 0.6, cornerRadius: 0)
    }
    
    private func initializeTapBackView() {
        self.view.addSubview(self.tapBackView)
        self.tapBackView.isHidden = true
    }
    
    private func initializeARMotionView() {
        let BGBlack = UIView()
        BGBlack.frame = self.arMotionView.bounds
        BGBlack.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        BGBlack.backgroundColor = Properties.shared.color.view_background
        
        let BGBar = UIView()
        BGBar.frame = CGRect(x: 0, y: 0, width: 375, height: 44)
        BGBar.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        BGBar.backgroundColor = Properties.shared.color.bar_background
        
        self.arMotionView.addSubview(BGBlack)
        self.arMotionView.sendSubviewToBack(BGBlack)
        self.arMotionView.addSubview(BGBar)
        self.arMotionView.sendSubviewToBack(BGBar)
        
        self.initializeARMotionButton()
        self.arMotionSelectButtonTapped(self.allARMotionButton)
        
        self.initializeARMotionCollectionView()
        
        self.registerARMotionViewGestureRecognizers()
    }
    
    private func initializeARMotionCollectionView() {
        self.arMotionCollectionView.delegate = self
        self.arMotionCollectionView.dataSource = self
    }
    
    private func initializeARMotionButton() {
        self.allARMotionButton.layer.cornerRadius = 14
        self.faceARMotionButton.layer.cornerRadius = 14
        self.bgARMotionButton.layer.cornerRadius = 14
    }
    
    private func initializeFilterView() {
        let BGFilter = UIView()
        BGFilter.frame = self.filterView.bounds
        BGFilter.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        BGFilter.backgroundColor = Properties.shared.color.view_background
        
        let BGfilterBar = UIView()
        BGfilterBar.frame = CGRect(x: 0, y: 0, width: 375, height: 44)
        BGfilterBar.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        BGfilterBar.backgroundColor = Properties.shared.color.bar_background
        
        self.filterView.addSubview(BGFilter)
        self.filterView.sendSubviewToBack(BGFilter)
        self.filterView.addSubview(BGfilterBar)
        self.filterView.sendSubviewToBack(BGfilterBar)
        
        self.initializeFilterCollectionView()
        
        // FIXME: Temp Spec
        filterTemp2.applyGradient_rect(colors: [UIColor(red: 16/255, green: 208/255, blue: 255/255, alpha: 0.5).cgColor,
                                                UIColor(red: 254/255, green: 156/255, blue: 255/255, alpha: 0.5).cgColor],
                                                state: false)
        filterTemp3.applyGradient_rect(colors: [UIColor(red: 254/255, green: 156/255, blue: 255/255, alpha: 0.5).cgColor,
                                                UIColor(red: 16/255, green: 208/255, blue: 255/255, alpha: 0.5).cgColor],
                                                state: false)
        filterTemp4.applyGradient_rect(colors: [UIColor(red: 5/255, green: 17/255, blue: 133/255, alpha: 0.5).cgColor,
                                                UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.3).cgColor],
                                                state: false)
        
        filterBack.isUserInteractionEnabled = false
        filterBack.applyGradient_view(colors: [UIColor.clear.cgColor, UIColor.clear.cgColor], state: false)
        
        self.registerFilterViewGestureRecognizers()
    }
    
    private func initializeFilterCollectionView() {
        self.filterCollectionView.delegate = self
        self.filterCollectionView.dataSource = self
        self.filterPowerSlider.setThumbImage(UIImage(named: "thumb_slider"), for: .normal)
        self.view.addSubview(filterCollectionView)
    }
    
    func setPreviewSize() {
        if previewSize == 0 {
            previewView.frame = CGRect(x: 0, y: 0, width: 375, height: 667)
        } else if previewSize == 1 {
            previewView.frame = CGRect(x: 0, y: 60, width: 375, height: 440)
        } else if previewSize == 2 {
            previewView.frame = CGRect(x: 0, y: 0, width: 375, height: 500)
        }
    }
    
    func updateUIIcon() {
        if previewSize == 0 {
            settingButton.setImage(UIImage(named: "ic_setup_wh"), for: .normal)
            clipButton.setImage(UIImage(named: "ic_clip_wh"), for: .normal)
            changeButton.setImage(UIImage(named: "ic_change_wh"), for: .normal)
            galleryButton.setImage(UIImage(named: "ic_gallery_wh"), for: .normal)
            menuButton.setImage(UIImage(named: "ic_menu_wh"), for: .normal)
            self.settingButton.dropShadow(state: true)
            self.clipButton.dropShadow(state: true)
            self.changeButton.dropShadow(state: true)
            self.galleryButton.dropShadow(state: true)
            self.menuButton.dropShadow(state: true)
            
            recordModePhoto.titleLabel?.textColor = Properties.shared.color.white
            recordModeVideo.titleLabel?.textColor = Properties.shared.color.white
            
            recordMoveButton.isHidden = false
        } else if previewSize == 1 {
            settingButton.setImage(UIImage(named: "ic_setup_bl"), for: .normal)
            clipButton.setImage(UIImage(named: "ic_clip_bl"), for: .normal)
            changeButton.setImage(UIImage(named: "ic_change_bl"), for: .normal)
            galleryButton.setImage(UIImage(named: "ic_gallery_bl"), for: .normal)
            menuButton.setImage(UIImage(named: "ic_menu_bl"), for: .normal)
            self.settingButton.dropShadow(state: false)
            self.clipButton.dropShadow(state: false)
            self.changeButton.dropShadow(state: false)
            self.galleryButton.dropShadow(state: false)
            self.menuButton.dropShadow(state: false)
            
            recordModePhoto.titleLabel?.textColor = Properties.shared.color.darkGray
            recordModeVideo.titleLabel?.textColor = Properties.shared.color.darkGray
            
            recordMoveButton.isHidden = true
        } else {
            settingButton.setImage(UIImage(named: "ic_setup_wh"), for: .normal)
            clipButton.setImage(UIImage(named: "ic_clip_wh"), for: .normal)
            changeButton.setImage(UIImage(named: "ic_change_wh"), for: .normal)
            galleryButton.setImage(UIImage(named: "ic_gallery_bl"), for: .normal)
            menuButton.setImage(UIImage(named: "ic_menu_bl"), for: .normal)
            self.settingButton.dropShadow(state: false)
            self.clipButton.dropShadow(state: false)
            self.changeButton.dropShadow(state: false)
            self.galleryButton.dropShadow(state: false)
            self.menuButton.dropShadow(state: false)
            
            recordModePhoto.titleLabel?.textColor = Properties.shared.color.darkGray
            recordModeVideo.titleLabel?.textColor = Properties.shared.color.darkGray
            
            recordMoveButton.isHidden = true
        }
    }
    
    private func registerARMotionViewGestureRecognizers() {
        let swipeARMotionView: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(dismissCollection))
        swipeARMotionView.direction = .down
        self.arMotionView.addGestureRecognizer(swipeARMotionView)
        
        // TODO: - Cell 구현부로 이동
        let deleteCell: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(arMotionCellLongPress))
        deleteCell.minimumPressDuration = 0.5
        deleteCell.delaysTouchesBegan = true
        self.arMotionCollectionView?.addGestureRecognizer(deleteCell)
        
        let favoriteCell = UITapGestureRecognizer(target: self, action: #selector(arMotionCellDoubleTab))
        favoriteCell.numberOfTapsRequired = 2
        self.arMotionCollectionView?.addGestureRecognizer(favoriteCell)
    }
    
    private func registerFilterViewGestureRecognizers() {
        let swipeFilterView: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(dismissCollection))
        swipeFilterView.direction = .down
        filterView.addGestureRecognizer(swipeFilterView)
    }
    
    // Ensure that the interface stays locked in Portrait.
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    // Ensure that the interface stays locked in Portrait.
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    @objc func modePhoto(gestureRecognizer: UISwipeGestureRecognizer) {
        self.changeModePhoto()
    }
    
    @objc func modeVideo(gestureRecognizer: UISwipeGestureRecognizer) {
        self.changeModeVideo()
    }
    
    @IBAction func changeButtonTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func makingARButtonTapped(_ sender: UIButton) {
        self.navigationController?.pushFromStoryboard(MakingARViewController.identifier)
    }
    
    @IBAction func settingButtonTapped(_ sender: UIButton) {
        self.navigationController?.pushFromStoryboard(SettingTableViewController.identifier)
    }
    
    @IBAction func galleryButtonTapped(_ sender: UIButton) {
        self.presentFromStoryboard(GalleryViewController.identifier)
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
    
    @objc func recordButtonDown(gestureRecognizer: UISwipeGestureRecognizer) {
        UIView.animate(withDuration: Double(0.5), animations: {
            self.recordViewBottomConstraint.constant = -130
            self.view.layoutIfNeeded()
        })
    }
    
    @objc func recordButtonUp(gestureRecognizer: UISwipeGestureRecognizer) {
        UIView.animate(withDuration: Double(0.5), animations: {
            self.recordViewBottomConstraint.constant = 0
            self.view.layoutIfNeeded()
        })
    }
    
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

    // MARK: Accessibility
    //    func configureAccessibility() {
    //        let key = NSAttributedString.Key.accessibilitySpeechIPANotation
    //
    //        let attributedString = NSAttributedString(
    //            string: NSLocalizedString("content_description_record", comment: "Record"), attributes: [key: "record"]
    //        )
    //
    //        recordButton.accessibilityAttributedLabel = attributedString
    //        recordButton.accessibilityHint = NSLocalizedString("content_description_record_accessible", comment: "Tap to record a video for ten seconds.")
    //
    //        NotificationCenter.default.addObserver(self, selector: #selector(voiceOverStatusChanged), name: UIAccessibility.voiceOverStatusDidChangeNotification, object: nil)
    //
    //        voiceOverStatusChanged()
    //    }
    
    //    @objc func voiceOverStatusChanged() {
    //        sizeButtonStackView.alpha = (UIAccessibility.isVoiceOverRunning) ? 1 : 0
    //    }
    
    // MARK: Check access
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
    
    @IBAction func recordTapped(_ sender: UIButton) {
        if selectedMode {
            takePhoto = true
        } else {
            if !videoState {
                startVideoRecording()
                
                UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveLinear, .repeat, .autoreverse, .allowUserInteraction], animations: {
                    self.recordButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                    self.recordButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                })
            } else {
                self.stopVideoRecording()
                recordButton.layer.removeAllAnimations()
            }
            
            videoState = !videoState
        }
    }
    
    func startVideoRecording() {
        guard let session = self.session else { return }
        
        session.addOutput(self.fileOutput)
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        let outputPath = "\(documentsPath)/output.mp4"
        let outputFileUrl = NSURL(fileURLWithPath: outputPath)
        
        self.fileOutput.startRecording(to: outputFileUrl as URL, recordingDelegate: self)
    }
    
    func stopVideoRecording() {
        self.fileOutput.stopRecording()
    }
    
    func recordBackgroundGradient() {
        let loadingImages = (1...91).map { UIImage(named: "recordGradient/\($0).png")! }
        
        self.recordGradient.animationImages = loadingImages
        self.recordGradient.animationDuration = 3.0
        self.recordGradient.startAnimating()
    }
    
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
        guard
            let results = request.results as? [VNFaceObservation],
            let result = results.first
            else {
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
        let origin = previewLayer.layerPointConverted(fromCaptureDevicePoint: rect.origin)
        let size = previewLayer.layerPointConverted(fromCaptureDevicePoint: rect.size.cgPoint)
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
        
        arMotionMove()
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
        var highestResolutionFormat: AVCaptureDevice.Format?
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
    
    func compositeImages(images: [UIImage]) -> UIImage? {
        var compositeImage: UIImage?
        
        if images.count > 0 {
            let size: CGSize = CGSize(width: images[0].size.width, height: images[0].size.height)
            UIGraphicsBeginImageContext(size)
            
            for image in images {
                let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                image.draw(in: rect)
            }
            
            compositeImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        return compositeImage
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        
        if let error = error {
            print("Error Saving arMotion Scene \(error)")
        } else {
            print("arMotion Scene Successfully Saved")
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
    
    // arMotion Set
    func arMotionCreate() {
        self.arNode_x = 0
        self.arNode_y = 3.5
        self.arNode_z = -5
        
        guard let headScene = SCNScene(named: "FaceAR.scnassets/z_prepare_head.scn"),
              let noseScene = SCNScene(named: "FaceAR.scnassets/z_prepare_nose.scn") else { return }
        
        self.headNode = headScene.rootNode.childNode(withName: "z_prepare_head", recursively: false) ?? SCNNode()
        self.noseNode = noseScene.rootNode.childNode(withName: "z_prepare_nose", recursively: false) ?? SCNNode()
        
        self.arScene.rootNode.addChildNode(headNode)
        self.arScene.rootNode.addChildNode(noseNode)
        
        arView.scene = arScene
    }
    
    func arMotionDelete() {
        arScene.rootNode.enumerateChildNodes { (node, _) in
            node.removeFromParentNode()
            node.removeAllParticleSystems()
        }
    }
    
    func arMotionMove() {
        let yaw_L = getAngle(first: (leftEye[4]), second: (medianLine[4]), third: (medianLine[0]))
        let yaw_R = getAngle(first: (rightEye[4]), second: (medianLine[4]), third: (medianLine[0]))
        let yaw = Float(yaw_L + yaw_R)
        let faceYaw = -normalizationYaw(source: yaw)
        
        let roll = Float(leftEye[0].y - rightEye[4].y)
        let faceRoll = normalizationRoll(source: roll)
        
        let pitch_1 = getGravityCenter(first: noseCrest[0], second: nose[2], third: nose[6])
        let pitch_2 = Float(noseCrest[2].y - pitch_1.y)
        let pitch = normalizationPitch(source: pitch_2) - 0.6 + faceRoll
        
        let faceSize = pointsDistance(faceContour[10], faceContour[0]) * 0.003
        let center = getGravityCenter(first: leftPupil[0], second: rightPupil[0], third: innerLips[2])
        let facePos = normalizationPos(source: center)
        
        let pos_x = Float(facePos.x) - (faceYaw) - (faceRoll * 3.2)
        let pos_y = -Float(facePos.y) - abs(faceRoll * 2.0) - abs(pitch / 2.0)
        
        let faceCenter = normalizationPos(source: nose[4])
        
        // head
        headNode.position = SCNVector3Make(pos_x + arNode_x, pos_y + (arNode_y * Float(faceSize * 2.0)), arNode_z)
        headNode.scale = SCNVector3(faceSize, faceSize, faceSize)
        headNode.simdEulerAngles = float3(pitch, faceYaw, faceRoll)
        
        // nose
        noseNode.position = SCNVector3Make(Float(faceCenter.x), -Float(faceCenter.y - 1.3), arNode_z)
        noseNode.scale = SCNVector3(faceSize, faceSize, faceSize)
        noseNode.simdEulerAngles = float3(pitch, faceYaw, faceRoll)
        
        // eat
        eatNode.position = SCNVector3Make(arNode_x, arNode_y, arNode_z)
        eatNode.scale = SCNVector3(faceSize, faceSize, faceSize)
        eatNode.simdEulerAngles = float3(pitch - 1.0, faceYaw, faceRoll)
        
        // bgNode
        bgNode.simdEulerAngles = float3(0, faceYaw, 0)
        
        if isBlink {
            if detectMouthBlink() {
                //                arMotionSelected_Mushroom()
                
                //                UIView.animate(withDuration: 0, delay: 3.0, options: [.curveLinear], animations: {
                //                    self.checkedBlink = true
                //                })
            }
        }
    }
    
    func normalizationPos(source: CGPoint) -> CGPoint {
        guard let halfWidth = self.halfWidth, let halfHeight = self.halfHeight else { return CGPoint.zero }
        
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
        
        return CGFloat(Double(angle) / .pi * 180)
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
    
    func loadARMotionNode(_ name: String, position: SCNVector3, isHead: Bool) {
        
        if isHead {
            guard let headScene = SCNScene(named: "FaceAR.scnassets/\(name)_head.scn"),
                let noseScene = SCNScene(named: "FaceAR.scnassets/\(name)_nose.scn") else { return }
            
            self.arNode_x = position.x
            self.arNode_y = position.y
            self.arNode_z = position.z
            
            self.headNode = headScene.rootNode.childNode(withName: "\(name)_head", recursively: false) ?? SCNNode()
            self.noseNode = noseScene.rootNode.childNode(withName: "\(name)_nose", recursively: false) ?? SCNNode()
            
            self.headNode.position = position
            self.noseNode.position = position
            
            self.arScene.rootNode.addChildNode(headNode)
            self.arScene.rootNode.addChildNode(noseNode)
        } else {
            loadARMotionNode(name, position: position)
        }
    }
    
    func loadARMotionNode(_ name: String, position: SCNVector3) {
        guard let scene = SCNScene(named: "FaceAR.scnassets/\(name).scn") else { return }
        
        self.arNode_x = position.x
        self.arNode_y = position.y
        self.arNode_z = position.z
        
        self.headNode = scene.rootNode.childNode(withName: "\(name)", recursively: false) ?? SCNNode()
        self.headNode.position = position
        self.arScene.rootNode.addChildNode(self.headNode)
    }
    
    func loadBGMotionNode(_ name: String) {
        
        self.bgNode = SCNNode()
        var count = 1
        
        while let particle = SCNParticleSystem(named: "BGAR.scnassets/\(name)_\(count).scnp", inDirectory: nil) {
            particle.warmupDuration = 10
            self.bgNode.addParticleSystem(particle)
            
            count += 1
        }
        
        self.bgNode.position = SCNVector3(x: 0, y: 5, z: 0)
        
        self.arScene.rootNode.addChildNode(self.bgNode)
    }
    
    func arMotionSelected_MakingAR(index: Int) {
        let node = SCNNode(geometry: SCNPlane(width: 10.0, height: 17.7))
        node.geometry?.materials.first?.diffuse.contents = faceARMotionArray[index]
        
        noseNode = node
        
        arScene.rootNode.addChildNode(noseNode)
    }
    
    func arMotionSelected_newMakingAR() {
        let node = SCNNode(geometry: SCNPlane(width: 10.0, height: 17.7))
        node.geometry?.materials.first?.diffuse.contents = faceARMotionArray[faceARMotionArray.count - 1]
        
        noseNode = node
        
        arScene.rootNode.addChildNode(noseNode)
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
        if oneClipState {
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
        
        if clipViewState {
            clipView.layer.frame = CGRect(x: 54.5, y: 56, width: clipView.frame.width, height: clipView.frame.height / 3)
            clipViewDivideBar.isHidden = true
            plusClipPicker.isHidden = true
            clipViewState = false
        }
    }
    
    @IBAction func clipTwoButtonTapped(_ sender: UIButton) {
        if twoClipState {
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
        
        if clipViewState {
            clipView.layer.frame = CGRect(x: 54.5, y: 56, width: clipView.frame.width, height: clipView.frame.height / 3)
            clipViewDivideBar.isHidden = true
            plusClipPicker.isHidden = true
            clipViewState = false
        }
    }
    
    @IBAction func clipThreeButtonTapped(_ sender: UIButton) {
        if threeClipState {
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
        
        if clipViewState {
            clipView.layer.frame = CGRect(x: 54.5, y: 56, width: clipView.frame.width, height: clipView.frame.height / 3)
            clipViewDivideBar.isHidden = true
            plusClipPicker.isHidden = true
            clipViewState = false
        }
    }
    
    @IBAction func clipPlusButtonTapped(_ sender: UIButton) {
        if plusClipState {
            clipTime = 0.0
            plusClipState = false
        } else {
            oneClipState = false
            twoClipState = false
            threeClipState = false
            plusClipState = true
        }
        
        clipButtonStateCheck()
        
        if clipViewState {
            clipView.layer.frame = CGRect(x: 54.5, y: 56, width: clipView.frame.width, height: clipView.frame.height / 3)
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
        if oneClipState {
            oneClipButton.setTitleColor(Properties.shared.color.white, for: .normal)
            oneClipButton.applyGradient(colors: [Properties.shared.color.main_blue.cgColor, Properties.shared.color.main_pink.cgColor], state: true)
        } else {
            oneClipButton.setTitleColor(Properties.shared.color.darkGray, for: .normal)
            oneClipButton.applyGradient(colors: [Properties.shared.color.white.cgColor, Properties.shared.color.white.cgColor], state: true)
        }
        
        if twoClipState {
            twoClipButton.setTitleColor(Properties.shared.color.white, for: .normal)
            twoClipButton.applyGradient(colors: [Properties.shared.color.main_blue.cgColor, Properties.shared.color.main_pink.cgColor], state: true)
        } else {
            twoClipButton.setTitleColor(Properties.shared.color.darkGray, for: .normal)
            twoClipButton.applyGradient(colors: [Properties.shared.color.white.cgColor, Properties.shared.color.white.cgColor], state: true)
        }
        
        if threeClipState {
            threeClipButton.setTitleColor(Properties.shared.color.white, for: .normal)
            threeClipButton.applyGradient(colors: [Properties.shared.color.main_blue.cgColor, Properties.shared.color.main_pink.cgColor], state: true)
        } else {
            threeClipButton.setTitleColor(Properties.shared.color.darkGray, for: .normal)
            threeClipButton.applyGradient(colors: [Properties.shared.color.white.cgColor, Properties.shared.color.white.cgColor], state: true)
        }
        
        if plusClipState {
            plusClipButton.setTitleColor(Properties.shared.color.white, for: .normal)
            plusClipButton.applyGradient(colors: [Properties.shared.color.main_blue.cgColor, Properties.shared.color.main_pink.cgColor], state: true)
        } else {
            plusClipButton.setTitleColor(Properties.shared.color.darkGray, for: .normal)
            plusClipButton.applyGradient(colors: [Properties.shared.color.white.cgColor, Properties.shared.color.white.cgColor], state: true)
        }
    }
    
    // Menu Set
    @objc func dismissMenu(gestureRecognizer: UITapGestureRecognizer) {
        XbuttonTapped(menuXButtonOn)
    }
    
    @objc func dismissCollection(gestureRecognizer: Any) {
        XbuttonTapped(menuXButtonOn)
        
        if arMotionViewState {
            arMotionViewState = false
            
            UIView.animate(withDuration: 0.2, animations: {
                self.buttonHide(state: true)
                self.arMotionView.center += CGPoint(x: 0, y: 230)
                
                self.view.layoutIfNeeded()
            })
        }
        
        if arMotionViewState {
            arMotionViewState = false
            
            UIView.animate(withDuration: 0.2, animations: {
                self.buttonHide(state: true)
                self.arMotionView.center += CGPoint(x: 0, y: 230)
                
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
            self.buttonAnimation(button: self.menuARMotionButton, label: self.menuARMotionLabel, buttonPosition: self.arMotionButtonCenter, size: 1.0, labelPosition: self.arMotionLabelCenter)
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
        tapBackView.isHidden = true
        
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
    
    @IBAction func makingARbuttonTapped(_ sender: UIButton) {
        makingARButtonState = true
        arMotionButtonState = false
        filterButtonState = false
        
        self.menuButtonStateCheck()
    }
    
    @IBAction func arMotionbuttonTapped(_ sender: UIButton) {
        let indexPaths = [IndexPath]()
        arMotionCollectionView.reloadItems(at: indexPaths)
        
        tapBackView.isHidden = false
        
        makingARButtonState = false
        arMotionButtonState = true
        filterButtonState = false
        
        UIView.animate(withDuration: 0.2) {
            self.menuView.alpha = 0.0
            self.buttonHide(state: true)
            self.arMotionView.center -= CGPoint(x: 0, y: 230)
            self.arMotionViewState = true
        }
        
        self.menuButtonStateCheck()
    }
    
    @IBAction func fiterbuttonTapped(_ sender: UIButton) {
        tapBackView.isHidden = false
        
        makingARButtonState = false
        arMotionButtonState = false
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
            button.dropShadow(opacity: 0.16, radius: 10.0, offset: CGSize(width: 1, height: 1))
        }
    }
    
    func menuSelectedOff(button: UIButton, changeImage: UIImage) {
        button.setImage(changeImage, for: .normal)
        
        UIView.animate(withDuration: 0.1) {
            button.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            button.layer.shadowOpacity = 0.0
        }
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
        if makingARButtonState {
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
        
        if arMotionButtonState {
            UIView.animate(withDuration: 0.1) {
                //                self.menuARMotionLabel.alpha = 1.0
            }
            self.menuSelectedOn(button: self.menuARMotionButton, changeImage: UIImage(named: "ic_arMotion_on")!)
        } else {
            UIView.animate(withDuration: 0.1) {
                //                self.menuARMotionLabel.alpha = 0.0
            }
            self.menuSelectedOff(button: self.menuARMotionButton, changeImage: UIImage(named: "ic_arMotion_off")!)
        }
        
        if filterButtonState {
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
    
    // arMotion View
    @IBAction func arMotionDeleteButtonTapped(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2) {
            self.arMotionDelete()
        }
    }
    
    @IBAction func arMotionSelectButtonTapped(_ sender: UIButton) {
        myARMotionButton.isSelected = false
        allARMotionButton.isSelected = false
        faceARMotionButton.isSelected = false
        bgARMotionButton.isSelected = false
        
        allARMotionButton.backgroundColor = Properties.shared.color.button_background
        faceARMotionButton.backgroundColor = Properties.shared.color.button_background
        bgARMotionButton.backgroundColor = Properties.shared.color.button_background
        
        if sender == myARMotionButton {
            myARMotionButton.isSelected = true
            
        } else if sender == allARMotionButton {
            allARMotionButton.isSelected = true
            allARMotionButton.backgroundColor = Properties.shared.color.white
            
        } else if sender == faceARMotionButton {
            faceARMotionButton.isSelected = true
            faceARMotionButton.backgroundColor = Properties.shared.color.white
            
        } else if sender == bgARMotionButton {
            bgARMotionButton.isSelected = true
            bgARMotionButton.backgroundColor = Properties.shared.color.white
        }
        
        DispatchQueue.main.async {
            self.arMotionCollectionView.reloadData()
        }
    }
    
    @IBAction func filterTempAction(_ sender: UIButton) {
        // FIXME: Temp Spec
        if sender == filterTemp1 {
            filterPowerSlider.isHidden = true
            filterBack.applyGradient_view(colors: [UIColor.clear.cgColor, UIColor.clear.cgColor], state: true)
        } else if sender == filterTemp2 {
            filterPowerSlider.isHidden = false
            filterBack.applyGradient_view(colors: [UIColor(red: 16/255, green: 208/255, blue: 255/255, alpha: 0.5).cgColor,
                                                   UIColor(red: 254/255, green: 156/255, blue: 255/255, alpha: 0.5).cgColor],
                                                   state: true)
        } else if sender == filterTemp3 {
            filterPowerSlider.isHidden = false
            filterBack.applyGradient_view(colors: [UIColor(red: 254/255, green: 156/255, blue: 255/255, alpha: 0.5).cgColor,
                                                   UIColor(red: 16/255, green: 208/255, blue: 255/255, alpha: 0.5).cgColor],
                                                   state: true)
        } else if sender == filterTemp4 {
            filterPowerSlider.isHidden = false
            filterBack.applyGradient_view(colors: [UIColor(red: 5/255, green: 17/255, blue: 133/255, alpha: 0.5).cgColor,
                                                   UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.3).cgColor],
                                                   state: true)
        }
    }
    
    @IBAction func filterPowerSet(_ sender: UISlider) {
        filterBack.alpha = CGFloat(sender.value)
    }
    
}
