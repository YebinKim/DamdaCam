//
//  InterfaceViewController.swift
//  DamdaCam
//
//  Created by 김예빈 on 2018. 12. 8..
//  Copyright © 2018년 김예빈. All rights reserved.
//

import UIKit
import AVKit
import FlexColorPicker
import CoreData

protocol InterfaceViewControllerDelegate {
    func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
    func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?)
    
    var shouldAutorotate: Bool { get }
    func resetTouches()
    func shouldHideTrashButton()->Bool
    func shouldHideUndoButton()->Bool
    
    func setPreviewSize()
    
    func takePhoto()
    func recordTapped(sender: UIButton?)
    func stopRecording()
    
    func clearStrokesTapped(sender: UIButton?)
    func undoLastStroke(sender: UIButton?)
    func setTouchState(_ state: Bool)
    func getTouchState() -> Bool
    func setStrokeSize(_ radius: Float)
    func getStrokeSize() -> Float
    func setStrokeNeon(_ state: Bool)
    func getStrokeNeon() -> Bool
    func setStrokeColor(_ selectedColor: CGColor)
    func getStrokeColor() -> CGColor
    
    func create3DText(message: String, depth: CGFloat, color: UIColor, align: Int)
    func create3DFigure(shape: String, fillState: Bool, width: CGFloat, depth: CGFloat, color: UIColor)
    
    func registerGestureRecognizers(view: UIView)
}

enum TrackingMessageType {
    case looking
    case lookingEscalated
    case anchorLost
}

class TouchView: UIView {
    var touchDelegate: InterfaceViewController?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchDelegate?.touchesBegan(touches, with: event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchDelegate?.touchesMoved(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let delegate = touchDelegate {
            delegate.touchesEnded(touches, with: event)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchDelegate?.touchesCancelled(touches, with: event)
    }
}

var pickedColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)

class InterfaceViewController: UIViewController, AVCapturePhotoCaptureDelegate, UITextViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var localRecords: [NSManagedObject] = []
    
    @IBOutlet weak var touchView: TouchView!
    
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
    
    // Stroke UI
    @IBOutlet weak var clearAllButton: UIButton!
    @IBOutlet weak var undoButton: UIButton!
    
    // Message UI
    @IBOutlet weak var messagesContainerView: UIView!
    @IBOutlet weak var drawPromptContainer: UIView!
    @IBOutlet weak var drawPromptLabel: UILabel!
    @IBOutlet weak var trackingPromptContainer: UIView!
    @IBOutlet weak var trackingPromptLabel: UILabel!
    @IBOutlet weak var trackingImage: UIImageView!
    @IBOutlet weak var trackingImageCenterConstraint: NSLayoutConstraint!
    @IBOutlet var trackingStartView: UIView!
    @IBOutlet var drawingStartView: UIView!
    @IBOutlet var remove3DView: UIImageView!
    
    // Drawing edit UI
    @IBOutlet var editView: UIView!
    @IBOutlet var drawingPenButton: UIButton!
    @IBOutlet var drawingPenOne: UIButton!
    @IBOutlet var drawingPenTwo: UIButton!
    @IBOutlet var drawingPenThree: UIButton!
    @IBOutlet var drawingPenPlus: UIButton!
    @IBOutlet var drawingPenStackView: [UIButton]! {
        didSet {
            drawingPenStackView.forEach {
                $0.isHidden = true
            }
        }
    }
    
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
    @IBOutlet var menuTextButton: UIButton!
    @IBOutlet var menuFigureButton: UIButton!
    @IBOutlet var menuBrushButton: UIButton!
    @IBOutlet var menuPaletteButton: UIButton!
    @IBOutlet var menuTextLabel: UILabel!
    @IBOutlet var menuFigureLabel: UILabel!
    @IBOutlet var menuBrushLabel: UILabel!
    @IBOutlet var menuPaletteLabel: UILabel!
    var textButtonCenter: CGPoint!
    var figureButtonCenter: CGPoint!
    var paletteButtonCenter: CGPoint!
    var brushButtonCenter: CGPoint!
    var textLabelCenter: CGPoint!
    var figureLabelCenter: CGPoint!
    var paletteLabelCenter: CGPoint!
    var brushLabelCenter: CGPoint!
    var textButtonState: Bool = false
    var figureButtonState: Bool = false
    var paletteButtonState: Bool = false
    var brushButtonState: Bool = false
    
    // Text Set
    @IBOutlet var textView: UIView!
    @IBOutlet var textXButton: UIButton!
    @IBOutlet var textField: UITextView!
    @IBOutlet var textPreviewColor: CircleShapedView!
    @IBOutlet var textPreviewColorButton: UIButton!
    @IBOutlet var textDepthLabel: UILabel!
    @IBOutlet var textDepthSlider: UISlider!
    @IBOutlet var textAlignLeftButton: UIButton!
    @IBOutlet var textAlignCenterButton: UIButton!
    @IBOutlet var textAlignRightButton: UIButton!
    var textDepth: Float = 2.0
    
    var firstSet3DState: Bool = true
    
    // Figure Set
    @IBOutlet var figureView: UIView!
    @IBOutlet var figureXButton: UIButton!
    @IBOutlet var figurePreview: UIView!
    @IBOutlet var figurePreviewColor: CircleShapedView!
    @IBOutlet var figurePreviewColorButton: UIButton!
    @IBOutlet var figureFillButton: ISRadioButton!
    @IBOutlet var figureStrokeButton: ISRadioButton!
    @IBOutlet var figureWidthTitle: UILabel!
    @IBOutlet var figureWidthLabel: UILabel!
    @IBOutlet var figureWidthSlider: UISlider!
    @IBOutlet var figureDepthLabel: UILabel!
    @IBOutlet var figureDepthSlider: UISlider!
    @IBOutlet var figureRectangleButton: UIButton!
    @IBOutlet var figureRoundedButton: UIButton!
    @IBOutlet var figureCircleButton: UIButton!
    @IBOutlet var figureTriangleButton: UIButton!
    @IBOutlet var figureHeartButton: UIButton!
    var figureWidth: CGFloat = 2.0
    var figureDepth: CGFloat = 2.0
    var figureShape: String!
    
    // Brush Set
    @IBOutlet var brushView: UIView!
    @IBOutlet var brushXButton: UIButton!
    @IBOutlet var brushPreview: UIView!
    @IBOutlet var brushBasicButton: ISRadioButton!
    @IBOutlet var brushNeonButton: ISRadioButton!
    @IBOutlet var brushWidthLabel: UILabel!
    @IBOutlet var brushWidthSlider: UISlider!
    var brushWidth: Float = 0.015
    
    // Palette Set
    @IBOutlet var paletteView: UIView!
    @IBOutlet var paletteXButton: UIButton!
    @IBOutlet var paletteRadialPicker: RadialPaletteControl!
    @IBOutlet var paletteRGBView: UIView!
    @IBOutlet var paletteRLabel: UILabel!
    @IBOutlet var paletteGLabel: UILabel!
    @IBOutlet var paletteBLabel: UILabel!
    @IBOutlet var paletteHSBView: UIView!
    @IBOutlet var paletteHLabel: UILabel!
    @IBOutlet var paletteSLabel: UILabel!
    @IBOutlet var paletteVLabel: UILabel!
    @IBOutlet var paletteCustomView: UIView!
    @IBOutlet var paletteCustomCollectionView: UICollectionView!
    @IBOutlet weak var paletteCustomFlowLayout: UICollectionViewFlowLayout!
    var customPaletteArray: [UIColor]!
    public let colorPicker = ColorPickerController()
    
    // preview palette setup
    @IBOutlet var previewPaletteView: UIView!
    @IBOutlet var previewXButton: UIButton!
    
    var touchDelegate: InterfaceViewControllerDelegate?
    var hasDrawnInSession: Bool = false
    var recordingTimer: Timer?
    
//    var captureSession = AVCaptureSession()
//    var backCamera: AVCaptureDevice?
//    var frontCamera: AVCaptureDevice?
//    var currentCamera: AVCaptureDevice?
//
//    var photoOutput: AVCapturePhotoOutput?
//    var orientation: AVCaptureVideoOrientation = .portrait
//
//    let context = CIContext()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 히히
        textField.text = "Text"
        
        // camera mode set
        let swipeModeRight: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(modePhoto))
        swipeModeRight.direction = .right
        self.modeSelected.addGestureRecognizer(swipeModeRight)
        
        let swipeModeLeft: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(modeVideo))
        swipeModeLeft.direction = .left
        self.modeSelected.addGestureRecognizer(swipeModeLeft)
        
        // record set
        let recordVideoStart: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(recordVideo))
        recordVideoStart.minimumPressDuration = 0.5
        recordButton.addGestureRecognizer(recordVideoStart)
        
        let swipeButtonDown: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(recordButtonDown))
        swipeButtonDown.direction = .down
        self.recordMoveButton.addGestureRecognizer(swipeButtonDown)
        
        let swipeButtonUp: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(recordButtonUp))
        swipeButtonUp.direction = .up
        self.recordMoveButton.addGestureRecognizer(swipeButtonUp)
        
        self.recordButton.layer.cornerRadius = 27.5
        self.recordBackgroundGradient()
        
        touchView.touchDelegate = self
        self.touchDelegate?.setStrokeSize(brushWidth)
        
        // Message Set
        trackingStartView.isHidden = true
        trackingStartView.alpha = 0.0
        trackingStartView.layer.cornerRadius = 17
        viewDropShadow(view: trackingStartView)
        
        drawingStartView.isHidden = true
        drawingStartView.alpha = 0.0
        drawingStartView.layer.cornerRadius = 17
        viewDropShadow(view: drawingStartView)
        
        remove3DView.isHidden = true
        remove3DView.alpha = 0.0
        
//        sizeButtonStackView.alpha = 0
        drawPromptContainer.alpha = 0
        
        // forces hiding of recording ui for global version
        drawingUIHidden(false)
        
//        selectSize(.medium)
        
        configureAccessibility()
        
//        setupDevice()
        //setupInputOutput()
        
        touchDelegate?.registerGestureRecognizers(view: editView)
        
        // Drawing Set
        drawingPenButton.layer.cornerRadius = 11
        drawingPenButton.backgroundColor = colorPicker.selectedColor
        buttonDropShadow(button: drawingPenButton)
        drawingPenButton.layer.borderWidth = 2
        drawingPenButton.layer.borderColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.5).cgColor
        drawingPenOne.layer.cornerRadius = 11
        drawingPenOne.backgroundColor = UIColor(red: 20/255, green: 126/255, blue: 250/255, alpha: 1.0)
        buttonDropShadow(button: drawingPenOne)
        drawingPenTwo.layer.cornerRadius = 11
        drawingPenTwo.backgroundColor = UIColor(red: 252/255, green: 210/255, blue: 40/255, alpha: 1.0)
        buttonDropShadow(button: drawingPenTwo)
        drawingPenThree.layer.cornerRadius = 11
        drawingPenThree.backgroundColor = UIColor(red: 252/255, green: 50/255, blue: 66/255, alpha: 1.0)
        buttonDropShadow(button: drawingPenThree)
        
        clearAllButton.layer.cornerRadius = 13
        buttonDropShadow(button: clearAllButton)
        
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
        oneClipButton.applyGradient(colors: [UIColor.white.cgColor, UIColor.white.cgColor], state: false)
        twoClipButton.applyGradient(colors: [UIColor.white.cgColor, UIColor.white.cgColor], state: false)
        threeClipButton.applyGradient(colors: [UIColor.white.cgColor, UIColor.white.cgColor], state: false)
        plusClipButton.applyGradient(colors: [UIColor.white.cgColor, UIColor.white.cgColor], state: false)
        
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
        textButtonCenter = menuTextButton.center
        figureButtonCenter = menuFigureButton.center
        brushButtonCenter = menuBrushButton.center
        paletteButtonCenter = menuPaletteButton.center
        textLabelCenter = menuTextLabel.center
        figureLabelCenter = menuFigureLabel.center
        brushLabelCenter = menuBrushLabel.center
        paletteLabelCenter = menuPaletteLabel.center
        menuTextLabel.alpha = 0.0
        menuFigureLabel.alpha = 0.0
        menuBrushLabel.alpha = 0.0
        menuPaletteLabel.alpha = 0.0
        
        menuView.isHidden = true
        menuView.alpha = 0.0
        addBackView(view: menuView, color: UIColor.black, alpha: 0.6, cornerRadius: 0)
        
        let tapMenuView: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MenuViewTap))
        menuView.addGestureRecognizer(tapMenuView)
        
        // Text Set
        addBackView(view: textView, color: UIColor.black, alpha: 0.6, cornerRadius: 10)
        textView.alpha = 0.0
        textView.layer.cornerRadius = 10
        textField.delegate = self as UITextViewDelegate
        textField.textAlignment = .center
        textField.centerVertically()
        alignSet(tapped: textAlignCenterButton)
        textDepthSlider.setThumbImage(UIImage(named: "thumb_slider"), for: .normal)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // Figure Set
        addBackView(view: figureView, color: UIColor.black, alpha: 0.6, cornerRadius: 10)
        figureView.alpha = 0.0
        figureView.layer.cornerRadius = 10
        figureFillButton.isSelected = true
        figureWidthTitle.textColor = UIColor(red: 169/255, green: 169/255, blue: 169/255, alpha: 1.0)
        figureWidthLabel.textColor = UIColor(red: 169/255, green: 169/255, blue: 169/255, alpha: 1.0)
        figureWidthSlider.isEnabled = false
        figureWidthSlider.setThumbImage(UIImage(named: "thumb_slider"), for: .normal)
        figureDepthSlider.setThumbImage(UIImage(named: "thumb_slider"), for: .normal)
        figureShape = "Rectangle"
        
        // Brush Set
        addBackView(view: brushView, color: UIColor.black, alpha: 0.6, cornerRadius: 10)
        brushView.alpha = 0.0
        brushView.layer.cornerRadius = 10
        brushBasicButton.isSelected = true
        brushWidthSlider.setThumbImage(UIImage(named: "thumb_slider"), for: .normal)
       
        // Palette Set
        addBackView(view: paletteView, color: UIColor.black, alpha: 0.6, cornerRadius: 10)
        paletteView.alpha = 0.0
        paletteView.layer.cornerRadius = 10
        viewDropShadow(view: paletteRadialPicker)
        createCustomPaletteArray()
        colorPicker.selectedColor = pickedColor
        
        // Preview Color Set
        previewPaletteView.layer.cornerRadius = 18
        viewDropShadow(view: previewPaletteView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        touchDelegate?.setPreviewSize()
        
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
        self.buttonAnimation(button: self.menuTextButton, label: self.menuTextLabel, buttonPosition: self.menuXButton.center, size: 0.5, labelPosition: self.menuXButton.center)
        self.buttonAnimation(button: self.menuFigureButton, label: self.menuFigureLabel, buttonPosition: self.menuXButton.center, size: 0.5, labelPosition: self.menuXButton.center)
        self.buttonAnimation(button: self.menuBrushButton, label: self.menuBrushLabel, buttonPosition: self.menuXButton.center, size: 0.5, labelPosition: self.menuXButton.center)
        self.buttonAnimation(button: self.menuPaletteButton, label: self.menuPaletteLabel, buttonPosition: self.menuXButton.center, size: 0.5, labelPosition: self.menuXButton.center)
        self.menuView.alpha = 0.0
        
        stopTrackingAnimation()
    }
    
    @objc func modePhoto(gestureRecognizer: UISwipeGestureRecognizer){
        self.changeModePhoto()
    }
    
    @objc func modeVideo(gestureRecognizer: UISwipeGestureRecognizer){
        self.changeModeVideo()
    }
    
    @objc func recordButtonDown(gestureRecognizer: UISwipeGestureRecognizer){
        UIView.animate(withDuration: Double(0.5), animations: {
            self.recordViewBottomConstraint.constant = 130
            self.view.layoutIfNeeded()
        })
    }
    
    @objc func recordButtonUp(gestureRecognizer: UISwipeGestureRecognizer){
        UIView.animate(withDuration: Double(0.5), animations: {
            self.recordViewBottomConstraint.constant = 0
            self.view.layoutIfNeeded()
        })
    }
    
//    override func viewDidLayoutSubviews() {
//        orientation = AVCaptureVideoOrientation(rawValue: UIApplication.shared.statusBarOrientation.rawValue)!
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var shouldAutorotate: Bool {
        get {
            if let del = touchDelegate, del.shouldAutorotate == false { return false }
            return true
        }
    }
    
    func configureAccessibility() {
        clearAllButton.accessibilityLabel = NSLocalizedString("menu_clear", comment: "Clear Drawing")
//        undoButton.accessibilityLabel = NSLocalizedString("content_description_undo", comment: "Undo")
//        chooseSizeButton.accessibilityLabel = NSLocalizedString("content_description_select_brush", comment: "Choose Brush Size")
//        largeBrushButton.accessibilityLabel = NSLocalizedString("content_description_large_brush", comment: "Large Brush")
//        mediumBrushButton.accessibilityLabel = NSLocalizedString("content_description_medium_brush", comment: "Medium Brush")
//        smallBrushButton.accessibilityLabel = NSLocalizedString("content_description_small_brush", comment: "Small Brush")
        
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchDelegate?.touchesBegan(touches, with: event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchDelegate?.touchesMoved(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let delegate = touchDelegate {
            delegate.touchesEnded(touches, with: event)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchDelegate?.touchesCancelled(touches, with: event)
    }
    
    @IBAction func recordTapped(_ sender: UIButton) {
        if selectedMode {
            print("still")
            touchDelegate?.takePhoto()
//            sessionOutput.capturePhoto(with: sessionOutputSetting, delegate: self as! AVCapturePhotoCaptureDelegate)
        } else {
            if !videoState {
                touchDelegate?.recordTapped(sender: sender)
                
                UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveLinear, .repeat, .autoreverse, .allowUserInteraction], animations: {
                    self.recordButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                    self.recordButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                })
            } else {
                touchDelegate?.stopRecording()
                recordButton.layer.removeAllAnimations()
            }
            
            videoState = !videoState
        }
    }
    
    @objc func recordVideo(gestureRecognizer: UILongPressGestureRecognizer){
//        print("video")
        if gestureRecognizer.state != .ended {
//            print("video start")
//            touchDelegate?.recordTapped(sender: recordButton)
//            recordingAnimation()
        } else {
//            print("video stop")
        }
    }
    
    func recordBackgroundGradient() {
        let loadingImages = (1...91).map { UIImage(named: "recordGradient/\($0).png")! }
        
        self.recordGradient.animationImages = loadingImages
        self.recordGradient.animationDuration = 3.0
        self.recordGradient.startAnimating()
    }
    
    @IBAction func drawingPenTapped(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3) {
            self.drawingPenStackView.forEach {
                $0.isHidden = !$0.isHidden
            }
        }
        
        touchDelegate?.setTouchState(true)
        editView.isHidden = true
        drawingPenButton.layer.borderWidth = 2
    }
    
    @IBAction func selectedDrawingPen(_ sender: UIButton) {
        if sender == drawingPenOne {
            pickedColor = UIColor(red: 20/255, green: 126/255, blue: 250/255, alpha: 1.0)
            colorPicker.selectedColor = pickedColor
            drawingPenButton.backgroundColor = pickedColor
            self.touchDelegate?.setStrokeColor(pickedColor.cgColor)
        }
        
        if sender == drawingPenTwo {
            pickedColor = UIColor(red: 252/255, green: 210/255, blue: 40/255, alpha: 1.0)
            colorPicker.selectedColor = pickedColor
            drawingPenButton.backgroundColor = pickedColor
            self.touchDelegate?.setStrokeColor(pickedColor.cgColor)
        }
        
        if sender == drawingPenThree {
            pickedColor = UIColor(red: 252/255, green: 50/255, blue: 66/255, alpha: 1.0)
            colorPicker.selectedColor = pickedColor
            drawingPenButton.backgroundColor = pickedColor
            self.touchDelegate?.setStrokeColor(pickedColor.cgColor)
        }
        
        touchDelegate?.setTouchState(true)
        editView.isHidden = true
        drawingPenButton.layer.borderWidth = 2
    }
    
    @IBAction func selectedDrawingPenColor(_ sender: UIButton) {
        palettebuttonTapped(menuPaletteButton)
    }
    
    @IBAction func clearAllStrokes(_ sender: UIButton) {
        touchDelegate?.clearStrokesTapped(sender: sender)
    }
    
    @IBAction func undoLastStroke(_ sender: UIButton) {
        touchDelegate?.undoLastStroke(sender: sender)
    }
    
    // Clip Set
    @IBAction func setClipLength(_ sender: UIButton) {
        if clipView.isHidden {
            self.clipView.isHidden = false
            
            UIView.animate(withDuration: 0.2, animations: {
                self.clipView.alpha = 0.85
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
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return 10
        } else {
            return 60
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
    
//    @IBAction func smallSizeTapped(_ sender: UIButton) {
//        selectSize(.small)
//    }
//
//    @IBAction func mediumSizeTapped(_ sender: UIButton) {
//        selectSize(.medium)
//    }
//
//    @IBAction func largeSizeTapped(_ sender: UIButton) {
//        selectSize(.large)
//    }
    
//    func selectSize(_ size: Radius) {
//        UIView.animate(withDuration: 0.25, animations: {
//            self.sizeButtonStackView.alpha = (UIAccessibility.isVoiceOverRunning) ? 1 : 0
//            if (self.sizeButtonStackView.alpha == 0) {
//                self.sizeStackViewBottomConstraint.constant = 10
//            }
//            self.view.layoutIfNeeded()
//        }) { (success) in
//            self.sizeStackViewBottomConstraint.constant = 18
//            switch size {
//            case .small:
//                self.chooseSizeButton.setImage(UIImage(named:"brushSmall"), for: .normal)
//
//            case .medium:
//                self.chooseSizeButton.setImage(UIImage(named:"brushMedium"), for: .normal)
//
//            case .large:
//                self.chooseSizeButton.setImage(UIImage(named:"brushLarge"), for: .normal)
//
//            }
//            self.touchDelegate?.strokeSizeChanged(size)
//        }
//    }
    
    func drawingUIHidden(_ isHidden: Bool) {
//        var forceHidden: Bool = false
        //#if JOIN_GLOBAL_ROOM
        //forceHidden = true
        //#endif
        
        // hide record from stage version only
//        recordButton.isHidden = (forceHidden) ? true : isHidden
//        touchView.isHidden = isHidden
//        chooseSizeButton.isHidden = isHidden
//        sizeButtonStackView.isHidden = isHidden
        
        // trash and undo are dependent on strokes for the visibility
        if let delegate = touchDelegate {
            clearAllButton.isHidden = (isHidden == true) ? true : delegate.shouldHideTrashButton()
//            undoButton.isHidden = (isHidden == true) ? true : delegate.shouldHideUndoButton()
        }
    }
    
    func showDrawingPrompt(isPaired: Bool = false) {
//        drawPromptLabel.text = ("화면에 손을 대고 \n이리저리 움직여보세요")
        touchView.accessibilityLabel = NSLocalizedString("draw_action_accessible", comment: "Draw")
        
        clearAllButton.isHidden = true
        drawingStartView.isHidden = false
//        drawPromptLabel.isHidden = hasDrawnInSession
        
        touchView.accessibilityHint = NSLocalizedString("draw_prompt_accessible", comment: "Double-tap and hold your finger and move around")
        
        UIView.animate(withDuration: 0.25) {
            self.drawingStartView.alpha = 0.8
            self.drawPromptContainer.alpha = 1.0
        }
    }
    
    func hideDrawingPrompt() {
        UIView.animate(withDuration: 0.25) {
            self.drawingStartView.alpha = 0.0
            self.drawPromptContainer.alpha = 0.0
        }
        DispatchQueue.main.async {
            self.drawingStartView.isHidden = false
            self.drawingUIHidden(false)
        }
    }
    
    /// When tracking state is .notavailable or .limited, start tracking animation
    func startTrackingAnimation(_ trackingMessage: TrackingMessageType = .looking) {
        switch trackingMessage {
        case .looking:
//            trackingPromptLabel.text = ("그림 그릴 공간을 구성하고 있어요")
            self.trackingStartView.isHidden = false
            
        case .lookingEscalated:
//            trackingPromptLabel.text = ("그림 그릴 공간을 찾을 수 없어요")
            self.trackingStartView.isHidden = false
            
        case .anchorLost:
//            trackingPromptLabel.text = ("앱을 다시 시작해주세요 :(")
            self.trackingStartView.isHidden = false
        }
        
///        trackingPromptContainer.alpha = 0
///        trackingPromptContainer.isHidden = false
        trackingPromptLabel.accessibilityLabel = trackingPromptLabel.text
        
        hideDrawingPrompt()
        
        // Fade in
        UIView.animate(withDuration: 0.25) {
            self.trackingPromptContainer.alpha = 1
        }
        
        // Loop right-left tracking animation
        UIView.animate(withDuration: 1.0, delay: 0, options: [.repeat, .curveEaseInOut, .autoreverse], animations: {
            self.trackingStartView.alpha = 0.8
            self.trackingImageCenterConstraint.constant = 15
            
            self.trackingPromptContainer.layoutIfNeeded()
        })
    }
    
    /// When tracking state is .normal, end tracking animation
    func stopTrackingAnimation() {
        // Fade out
        UIView.animate(withDuration: 0.25, animations: {
            self.trackingPromptContainer.alpha = 0
            self.trackingStartView.alpha = 0
            
            // Reset state
        }) { (isComplete) in
///            self.trackingPromptContainer.isHidden = true
            self.trackingImageCenterConstraint.constant = -15
            self.trackingPromptContainer.layoutIfNeeded()
            self.trackingPromptContainer.layer.removeAllAnimations()
        }
        
        DispatchQueue.main.async {
            self.trackingStartView.isHidden = true
        }
    }
    
    func recordingWillStart() {
        if clipTime != 0.0 {
            DispatchQueue.main.async {
                self.recordingTimer = Timer.scheduledTimer(withTimeInterval: self.clipTime, repeats: false, block: { (timer) in
                    DispatchQueue.main.async {
                        print(self.clipTime)
                        self.touchDelegate?.stopRecording()
                        self.recordButton.layer.removeAllAnimations()
                        self.recordButton.isEnabled = true
                    }
                })
                
                self.recordButton.isEnabled = false
                
//                UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveLinear, .repeat, .autoreverse], animations: {
//                    self.recordButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
//                    self.recordButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
//                })
            
//            self.recordBackgroundView.alpha = 1
//            self.recordBackgroundView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
//
//            UIView.animate(withDuration: 0.25, animations: {
//                self.recordBackgroundView.transform = .identity
//                self.recordIconView.layer.cornerRadius = 0
//            }, completion: { (success) in
//                self.progressCircle.play(duration: 10.0)
//            })
            }
        }
    }
    
    func recordingHasUpdated() {
        
    }
    
    func recordingHasEnded() {
        if let timer = recordingTimer {
            timer.invalidate()
        }
        recordingTimer = nil
        
//        DispatchQueue.main.async {
//            UIView.animate(withDuration: 0.25, animations: {
//                self.recordIconView.layer.cornerRadius = 6
//                self.recordBackgroundView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
//            }, completion: { (success) in
//            })
//        }
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
    
    // Menu Set
    @objc func MenuViewTap(gestureRecognizer: UITapGestureRecognizer){
        self.XbuttonTapped(menuXButtonOn)
        
        gestureRecognizer.cancelsTouchesInView = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            gestureRecognizer.cancelsTouchesInView = true
        }
    }
    
    @objc func OnMenuViewTap(gestureRecognizer: UITapGestureRecognizer){
        self.XbuttonTapped(menuXButtonOn)
        self.textViewXTapped(textXButton)
        self.figureViewXTapped(figureXButton)
        self.brushViewXTapped(brushXButton)
        self.paletteViewXTapped(paletteXButton)
        self.previewPaletteXTapped(previewXButton)
        
        gestureRecognizer.cancelsTouchesInView = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            gestureRecognizer.cancelsTouchesInView = true
        }
    }
    
    @IBAction func menuTapped(_ sender: UIButton) {
        touchDelegate?.setTouchState(false)
        editView.isHidden = false
        drawingPenButton.layer.borderWidth = 0
        
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
            self.buttonAnimation(button: self.menuTextButton, label: self.menuTextLabel, buttonPosition: self.textButtonCenter, size: 1.0, labelPosition: self.textLabelCenter)
        })
        UIView.animate(withDuration: 0.15, delay: 0.4, options: [.curveLinear], animations: {
            self.buttonAnimation(button: self.menuFigureButton, label: self.menuFigureLabel, buttonPosition: self.figureButtonCenter, size: 1.0, labelPosition: self.figureLabelCenter)
        })
        UIView.animate(withDuration: 0.15, delay: 0.5, options: [.curveLinear], animations: {
            self.buttonAnimation(button: self.menuBrushButton, label: self.menuBrushLabel, buttonPosition: self.brushButtonCenter, size: 1.0, labelPosition: self.brushLabelCenter)
        })
        UIView.animate(withDuration: 0.15, delay: 0.6, options: [.curveLinear], animations: {
            self.buttonAnimation(button: self.menuPaletteButton, label: self.menuPaletteLabel, buttonPosition: self.paletteButtonCenter, size: 1.0, labelPosition: self.paletteLabelCenter)
        })
        UIView.animate(withDuration: 0.2, delay: 0.7, options: [.curveLinear], animations: {
            self.menuXButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            self.menuXButtonOn.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            self.menuXButtonOn.alpha = 0.0
            
            self.menuTextLabel.alpha = 1.0
            self.menuFigureLabel.alpha = 1.0
            self.menuBrushLabel.alpha = 1.0
            self.menuPaletteLabel.alpha = 1.0
            
            self.menuXButton.isEnabled = true
            self.menuXButtonOn.isEnabled = true
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            self.menuXButton.isEnabled = true
            self.menuXButtonOn.isEnabled = true
        }
    }
    
    @IBAction func XbuttonTapped(_ sender: UIButton) {
        menuXButton.isEnabled = false
        menuXButtonOn.isEnabled = false
        
        UIView.animate(withDuration: 0.15, delay: 0.0, options: [.curveLinear], animations: {
            self.menuTextLabel.alpha = 0.0
            self.menuFigureLabel.alpha = 0.0
            self.menuBrushLabel.alpha = 0.0
            self.menuPaletteLabel.alpha = 0.0
            
            self.menuXButtonOn.alpha = 1.0
            self.menuXButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            self.menuXButton.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            self.menuXButtonOn.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            self.menuXButtonOn.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            self.menuXButton.alpha = 0.0
            self.buttonAnimation(button: self.menuTextButton, label: self.menuTextLabel, buttonPosition: self.menuXButton.center, size: 0.5, labelPosition: self.menuXButton.center)
        })
        UIView.animate(withDuration: 0.15, delay: 0.1, options: [.curveLinear], animations: {
            self.buttonAnimation(button: self.menuFigureButton, label: self.menuFigureLabel, buttonPosition: self.menuXButton.center, size: 0.5, labelPosition: self.menuXButton.center)
        })
        UIView.animate(withDuration: 0.15, delay: 0.2, options: [.curveLinear], animations: {
            self.buttonAnimation(button: self.menuBrushButton, label: self.menuBrushLabel, buttonPosition: self.menuXButton.center, size: 0.5, labelPosition: self.menuXButton.center)
        })
        UIView.animate(withDuration: 0.15, delay: 0.3, options: [.curveLinear], animations: {
            self.buttonAnimation(button: self.menuPaletteButton, label: self.menuPaletteLabel, buttonPosition: self.menuXButton.center, size: 0.5, labelPosition: self.menuXButton.center)
        })
        UIView.animate(withDuration: 0.15, delay: 0.4, options: [.curveLinear], animations: {
            self.menuXButton.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            self.menuXButtonOn.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            self.menuView.alpha = 0.0
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
            self.menuView.isHidden = true
            
            self.menuXButton.isEnabled = true
            self.menuXButtonOn.isEnabled = true
        }
    }
    
    @IBAction func textbuttonTapped(_ sender: UIButton) {
        let onTapMenuView: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(OnMenuViewTap))
        menuView.addGestureRecognizer(onTapMenuView)
        
        touchDelegate?.setTouchState(false)
        editView.isHidden = false
        drawingPenButton.layer.borderWidth = 0
        
        textPreviewColor.backgroundColor = colorPicker.selectedColor
        textField.textColor = colorPicker.selectedColor
        textDepthLabel.text = String(Int(textDepthSlider.value))
        
        textButtonState = true
        figureButtonState = false
        paletteButtonState = false
        brushButtonState = false
        
        previewPaletteView.frame.origin.y = 286.0
        
        buttonHide(state: true)
        textView.isHidden = false
        
        UIView.animate(withDuration: 0.2, animations: {
            self.textView.alpha = 1.0
        })
        
        self.menuButtonStateCheck()
    }
    
    @IBAction func figurebuttonTapped(_ sender: UIButton) {
        let onTapMenuView: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(OnMenuViewTap))
        menuView.addGestureRecognizer(onTapMenuView)
        
        touchDelegate?.setTouchState(false)
        editView.isHidden = false
        drawingPenButton.layer.borderWidth = 0
        
        figurePreview.layer.sublayers?[0].removeFromSuperlayer()
        drawShape(shape: figureShape)
        
        figurePreviewColor.backgroundColor = colorPicker.selectedColor
        figureWidthLabel.text = String(Int(figureWidthSlider.value))
        figureDepthLabel.text = String(Int(figureDepthSlider.value))
        
        previewPaletteView.frame.origin.y = 214.5
        
        textButtonState = false
        figureButtonState = true
        paletteButtonState = false
        brushButtonState = false
        
        buttonHide(state: true)
        figureView.isHidden = false
        
        UIView.animate(withDuration: 0.2, animations: {
            self.figureView.alpha = 1.0
        })
        
        self.menuButtonStateCheck()
    }
    
    @IBAction func brushbuttonTapped(_ sender: UIButton) {
        let onTapMenuView: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(OnMenuViewTap))
        menuView.addGestureRecognizer(onTapMenuView)
        
        touchDelegate?.setTouchState(false)
        editView.isHidden = false
        drawingPenButton.layer.borderWidth = 0
        
        brushPreview.layer.sublayers?[0].removeFromSuperlayer()
        drawLineShape()
        
        brushWidthLabel.text = String(Int(brushWidthSlider.value))
        
        textButtonState = false
        figureButtonState = false
        paletteButtonState = false
        brushButtonState = true
        
        buttonHide(state: true)
        brushView.isHidden = false
        
        UIView.animate(withDuration: 0.2, animations: {
            self.brushView.alpha = 1.0
        })
        
        self.menuButtonStateCheck()
    }
    
    @IBAction func palettebuttonTapped(_ sender: UIButton) {
        let onTapMenuView: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(OnMenuViewTap))
        menuView.addGestureRecognizer(onTapMenuView)
        
        touchDelegate?.setTouchState(false)
        editView.isHidden = false
        drawingPenButton.layer.borderWidth = 0
        
        paletteCustomCollectionView.reloadData()
        pickedColor = colorPicker.selectedColor
        createCustomPaletteArray()
        
        textButtonState = false
        figureButtonState = false
        paletteButtonState = true
        brushButtonState = false
        
        buttonHide(state: true)
        paletteView.isHidden = false
        
        UIView.animate(withDuration: 0.2, animations: {
            self.paletteView.alpha = 1.0
        })
        
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
    
    func buttonAnimation(button: UIButton, label: UILabel, buttonPosition: CGPoint, size: CGFloat, labelPosition: CGPoint) {
        button.center = buttonPosition
        label.center = labelPosition
        button.transform = CGAffineTransform(scaleX: size, y: size)
        label.transform = CGAffineTransform(scaleX: size, y: size)
    }
    
    func menuButtonStateCheck() {
        if (textButtonState) {
            UIView.animate(withDuration: 0.1) {
//                self.menuTextLabel.alpha = 1.0
            }
            self.menuSelectedOn(button: self.menuTextButton, changeImage: UIImage(named: "ic_text_on")!)
        } else {
            UIView.animate(withDuration: 0.1) {
//                self.menuTextLabel.alpha = 0.0
            }
            self.menuSelectedOff(button: self.menuTextButton, changeImage: UIImage(named: "ic_text_off")!)
        }
        
        if (figureButtonState) {
            UIView.animate(withDuration: 0.1) {
//                self.menuFigureLabel.alpha = 1.0
            }
            self.menuSelectedOn(button: self.menuFigureButton, changeImage: UIImage(named: "ic_figure_on")!)
        } else {
            UIView.animate(withDuration: 0.1) {
//                self.menuFigureLabel.alpha = 0.0
            }
            self.menuSelectedOff(button: self.menuFigureButton, changeImage: UIImage(named: "ic_figure_off")!)
        }
        
        if (brushButtonState) {
            UIView.animate(withDuration: 0.1) {
//                self.menuBrushLabel.alpha = 1.0
            }
            self.menuSelectedOn(button: self.menuBrushButton, changeImage: UIImage(named: "ic_brush_on")!)
        } else {
            UIView.animate(withDuration: 0.1) {
//                self.menuBrushLabel.alpha = 0.0
            }
            self.menuSelectedOff(button: self.menuBrushButton, changeImage: UIImage(named: "ic_brush_off")!)
        }
        
        if (paletteButtonState) {
            UIView.animate(withDuration: 0.1) {
//                self.menuPaletteLabel.alpha = 1.0
            }
            self.menuSelectedOn(button: self.menuPaletteButton, changeImage: UIImage(named: "ic_palette_on")!)
        } else {
            UIView.animate(withDuration: 0.1) {
//                self.menuPaletteLabel.alpha = 0.0
            }
            self.menuSelectedOff(button: self.menuPaletteButton, changeImage: UIImage(named: "ic_palette_off")!)
        }
    }
    
    func buttonHide(state: Bool) {
        menuXButton.isHidden = state
        menuXButtonOn.isHidden = state
        menuTextButton.isHidden = state
        menuFigureButton.isHidden = state
        menuBrushButton.isHidden = state
        menuPaletteButton.isHidden = state
        
        menuTextLabel.isHidden = state
        menuFigureLabel.isHidden = state
        menuBrushLabel.isHidden = state
        menuPaletteLabel.isHidden = state
    }
    
    // Text Set
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if textView.frame.origin.y == 198 {
                textView.frame.origin.y = keyboardSize.height / 2.0
                previewPaletteView.frame.origin.y = keyboardSize.height / 1.1
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if textView.frame.origin.y != 198 {
            textView.frame.origin.y = 198
            previewPaletteView.frame.origin.y = 286
        }
    }
    
    func alignSet(tapped: UIButton!) {
        if (tapped == textAlignLeftButton) {
            textField.textAlignment = .left
            textAlignLeftButton.setImage(UIImage(named: "textAlign_left_on"), for: .normal)
            textAlignCenterButton.setImage(UIImage(named: "textAlign_center_off"), for: .normal)
            textAlignRightButton.setImage(UIImage(named: "textAlign_right_off"), for: .normal)
        } else if (tapped == textAlignCenterButton) {
            textField.textAlignment = .center
            textAlignLeftButton.setImage(UIImage(named: "textAlign_left_off"), for: .normal)
            textAlignCenterButton.setImage(UIImage(named: "textAlign_center_on"), for: .normal)
            textAlignRightButton.setImage(UIImage(named: "textAlign_right_off"), for: .normal)
        } else if (tapped == textAlignRightButton) {
            textField.textAlignment = .right
        textAlignLeftButton.setImage(UIImage(named: "textAlign_left_off"), for: .normal)
        textAlignCenterButton.setImage(UIImage(named: "textAlign_center_off"), for: .normal)
        textAlignRightButton.setImage(UIImage(named: "textAlign_right_on"), for: .normal)
        }
    }
    
    @IBAction func textAlignTapped(_ sender: UIButton) {
        self.alignSet(tapped: sender)
    }
    
//    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//        if (text == "\n") {
//            self.textView.endEditing(true)
//            textView.resignFirstResponder()
//        }
//        return true
//    }
    
    @IBAction func textDepthChanged(_ sender: UISlider) {
        textDepthLabel.text = String(Int(sender.value))
        textDepth = sender.value
    }
    
    @IBAction func textViewXTapped(_ sender: UIButton) {
        buttonHide(state: false)
        
        UIView.animate(withDuration: 0.2, animations: {
            self.previewPaletteXTapped(self.previewXButton)
            self.textView.endEditing(true)
            self.textView.alpha = 0.0
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
            self.textView.isHidden = true
        }
    }
    
    @IBAction func textViewCheckTapped(_ sender: UIButton) {
        if firstSet3DState {
            remove3DView.isHidden = false
            firstSet3DState = !firstSet3DState
            
            UIView.animate(withDuration: 0.1, animations: {
                self.remove3DView.alpha = 0.8
            })
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                self.remove3DView.isHidden = true
            }
        }
        
        touchDelegate?.create3DText(message: textField.text, depth: CGFloat(textDepth), color: pickedColor, align: textField!.textAlignment.rawValue)
        
        buttonHide(state: false)
        self.XbuttonTapped(menuXButtonOn)
        
        UIView.animate(withDuration: 0.2, animations: {
            self.textView.endEditing(true)
            self.textView.alpha = 0.0
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
            self.textView.isHidden = true
        }
    }
    
    // Figure Set
    @IBAction func figureStateTapped(_ sender: UIButton) {
        if sender == figureFillButton {
            figureWidthTitle.textColor = UIColor(red: 169/255, green: 169/255, blue: 169/255, alpha: 1.0)
            figureWidthLabel.textColor = UIColor(red: 169/255, green: 169/255, blue: 169/255, alpha: 1.0)
            figureWidthSlider.isEnabled = false
        } else {
            figureWidthTitle.textColor = UIColor.white
            figureWidthLabel.textColor = UIColor.white
            figureWidthSlider.isEnabled = true
        }
        figurePreview.layer.sublayers?[0].removeFromSuperlayer()
        drawShape(shape: figureShape)
    }
    
    @IBAction func figureWidthChanged(_ sender: UISlider) {
        figurePreview.layer.sublayers?[0].removeFromSuperlayer()
        drawShape(shape: figureShape)
        figureWidthLabel.text = String(Int(sender.value))
        
        figureWidth = CGFloat(sender.value)
    }
    
    @IBAction func figureDepthChanged(_ sender: UISlider) {
        figurePreview.layer.sublayers?[0].removeFromSuperlayer()
        drawShape(shape: figureShape)
        figureDepthLabel.text = String(Int(sender.value))
        
        figureDepth = CGFloat(sender.value)
    }
    
    @IBAction func figureShapedSelected(_ sender: UIButton) {
        if sender == figureRectangleButton {
            figureShape = "Rectangle"
        }
        
        if sender == figureRoundedButton {
            figureShape = "Rounded"
        }
        
        if sender == figureCircleButton {
            figureShape = "Circle"
        }
        
        if sender == figureTriangleButton {
            figureShape = "Triangle"
        }
        
        if sender == figureHeartButton {
            figureShape = "Heart"
        }
        
        figurePreview.layer.sublayers?[0].removeFromSuperlayer()
        drawShape(shape: figureShape)
    }
    
    func drawShape(shape: String) {
        let layer = CAShapeLayer()
        var path = UIBezierPath()
        let originalRect = CGRect(x: 90.5, y: 23, width: 71.0, height: 71.0)
        
        if shape == "Rectangle" {
            path = UIBezierPath(rect: originalRect)
        }
        
        if shape == "Rounded" {
            path = UIBezierPath(roundedRect: originalRect, cornerRadius: 10.0)
        }
        
        if shape == "Circle" {
            path = UIBezierPath(arcCenter: CGPoint(x: originalRect.midX, y: originalRect.midY), radius: originalRect.width / 2, startAngle: CGFloat(0), endAngle: CGFloat(Double.pi * 2.0), clockwise: true)
        }
        
        if shape == "Triangle" {
            path = UIBezierPath()
            path.move(to: CGPoint(x: originalRect.minX, y: originalRect.maxY))
            path.addLine(to: CGPoint(x: originalRect.maxX, y: originalRect.maxY))
            path.addLine(to: CGPoint(x: originalRect.midX, y: originalRect.minY))
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
        }
        
        layer.path = path.cgPath
        
        if figureFillButton.isSelected {
            layer.fillColor = colorPicker.selectedColor.cgColor
            layer.strokeColor = UIColor.clear.cgColor
            layer.lineWidth = 0.0
        } else if figureStrokeButton.isSelected {
            layer.fillColor = UIColor.clear.cgColor
            layer.strokeColor = colorPicker.selectedColor.cgColor
            layer.lineWidth = figureWidth
        }
        
        figurePreview.layer.addSublayer(layer)
    }
    
    @IBAction func figureViewXTapped(_ sender: UIButton) {
        buttonHide(state: false)
        
        UIView.animate(withDuration: 0.2, animations: {
            self.previewPaletteXTapped(self.previewXButton)
            self.figureView.alpha = 0.0
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
            self.figureView.isHidden = true
        }
    }
    
    @IBAction func figureViewCheckTapped(_ sender: UIButton) {
        if firstSet3DState {
            remove3DView.isHidden = false
            firstSet3DState = !firstSet3DState
            
            UIView.animate(withDuration: 0.1, animations: {
                self.remove3DView.alpha = 0.8
            })
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                self.remove3DView.isHidden = true
            }
        }
        
        touchDelegate?.create3DFigure(shape: figureShape, fillState: figureFillButton.isSelected, width: figureWidth, depth: figureDepth, color: pickedColor)
        
        buttonHide(state: false)
        self.XbuttonTapped(menuXButtonOn)
        
        UIView.animate(withDuration: 0.2, animations: {
            self.figureView.alpha = 0.0
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
            self.figureView.isHidden = true
        }
    }
    
    // Brush Set
    @IBAction func brushStateTapped(_ sender: UIButton) {
        brushPreview.layer.sublayers?[0].removeFromSuperlayer()
        drawLineShape()
        
        self.touchDelegate?.setStrokeNeon(brushNeonButton.isSelected)
    }
    
    @IBAction func brushWidthChanged(_ sender: UISlider) {
        brushPreview.layer.sublayers?[0].removeFromSuperlayer()
        drawLineShape()
        brushWidthLabel.text = String(Int(sender.value))
        
        brushWidth = sender.value / 2000
    }
    
    func drawLineShape() {
        let shapeLayer = CAShapeLayer()
        shapeLayer.lineWidth = CGFloat(brushWidthSlider.value / 2)
        shapeLayer.lineCap = CAShapeLayerLineCap.round
        let path = CGMutablePath()
        path.addLines(between: [CGPoint(x: 30, y: 40),CGPoint(x: 220, y: 40)])
        shapeLayer.path = path
        
        if brushBasicButton.isSelected {
            shapeLayer.strokeColor = colorPicker.selectedColor.cgColor
            shapeLayer.shadowRadius = 0
            shapeLayer.shadowOpacity = 0
        } else {
            shapeLayer.strokeColor = UIColor.white.cgColor
            shapeLayer.shadowOffset = .zero
            shapeLayer.shadowColor = colorPicker.selectedColor.cgColor
            shapeLayer.shadowRadius = 7
            shapeLayer.shadowOpacity = 1
        }
        
        brushPreview.layer.addSublayer(shapeLayer)
    }
    
    @IBAction func brushViewXTapped(_ sender: UIButton) {
        brushWidth = (self.touchDelegate?.getStrokeSize())!
        
        buttonHide(state: false)
        
        UIView.animate(withDuration: 0.2, animations: {
            self.previewPaletteXTapped(self.previewXButton)
            self.brushView.alpha = 0.0
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
            self.brushView.isHidden = true
            
            self.touchDelegate?.setTouchState(true)
            self.editView.isHidden = true
            self.drawingPenButton.layer.borderWidth = 2
        }
    }
    
    @IBAction func brushViewCheckTapped(_ sender: UIButton) {
        self.touchDelegate?.setStrokeSize(brushWidth)
        
        buttonHide(state: false)
        self.XbuttonTapped(menuXButtonOn)
        
        UIView.animate(withDuration: 0.2, animations: {
            self.brushView.alpha = 0.0
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
            self.brushView.isHidden = true
            
            self.touchDelegate?.setTouchState(true)
            self.editView.isHidden = true
            self.drawingPenButton.layer.borderWidth = 2
        }
    }
    
    // Palette Set
    @IBAction func paletteRGBTapped(_ sender: UIButton) {
        paletteRGBView.isHidden = false
        paletteHSBView.isHidden = true
        paletteCustomView.isHidden = true
    }
    
    @IBAction func paletteHSBTapped(_ sender: UIButton) {
        paletteRGBView.isHidden = true
        paletteHSBView.isHidden = false
        paletteCustomView.isHidden = true
    }
    
    @IBAction func paletteCustomTapped(_ sender: UIButton) {
        paletteRGBView.isHidden = true
        paletteHSBView.isHidden = true
        paletteCustomView.isHidden = false
    }
    
    @IBOutlet public var colorPreview: ColorPreviewWithHex? {
        get {
            return colorPicker.colorPreview
        }
        set {
            colorPicker.colorPreview = newValue
        }
    }
    
    @IBOutlet open var customControl1: AbstractColorControl? {
        get {
            return colorPicker.customControl1
        }
        set {
            colorPicker.customControl1 = newValue
        }
    }
    
    @IBOutlet open var redSlider: RedSliderControl? {
        get {
            return colorPicker.redSlider
        }
        set {
            colorPicker.redSlider = newValue
        }
    }
    
    @IBOutlet open var greenSlider: GreenSliderControl? {
        get {
            return colorPicker.greenSlider
        }
        set {
            colorPicker.greenSlider = newValue
        }
    }
    
    @IBOutlet open var blueSlider: BlueSliderControl? {
        get {
            return colorPicker.blueSlider
        }
        set {
            colorPicker.blueSlider = newValue
        }
    }
    
    @IBOutlet weak var hueSlider: HueSliderControl? {
        get {
            return colorPicker.hueSlider
        }
        set {
            colorPicker.hueSlider = newValue
        }
    }
    
    @IBOutlet open var saturationSlider: SaturationSliderControl? {
        get {
            return colorPicker.saturationSlider
        }
        set {
            colorPicker.saturationSlider = newValue
        }
    }
    
    @IBOutlet open var brightnessSlider: BrightnessSliderControl? {
        get {
            return colorPicker.brightnessSlider
        }
        set {
            colorPicker.brightnessSlider = newValue
        }
    }
    
    func getContext() -> NSManagedObjectContext {
        return appDelegate.persistentContainer.viewContext
    }
    
    func createCustomPaletteArray() {
        customPaletteArray = Array()
        let context = self.getContext()
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CustomPalette")
        
        do {
            localRecords = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        for index in 0 ..< localRecords.count {
            let localRecord = localRecords[index]
            let hexToColor = UIColor(hex: localRecord.value(forKey: "colorHex") as! String)
            customPaletteArray.append(hexToColor!)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let CustomColor = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomColor", for: indexPath) as! CustomPaletteCollectionViewCell
        
        CustomColor.customColor.layer.cornerRadius = 4
        
        if indexPath.row < customPaletteArray.count {
            CustomColor.customColor.backgroundColor = customPaletteArray[indexPath.row]
        } else {
            CustomColor.customColor.backgroundColor = UIColor.clear
            CustomColor.customColor.layer.borderWidth = 1
            CustomColor.customColor.layer.borderColor = UIColor(red: 177/255, green: 177/255, blue: 177/255, alpha: 1.0).cgColor
        }
        
        return CustomColor
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 18
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let _ = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomColor", for: indexPath) as! CustomPaletteCollectionViewCell
        
        if indexPath.row < customPaletteArray.count {
            pickedColor = customPaletteArray[indexPath.row]
            colorPicker.selectedColor = pickedColor
            drawingPenButton.backgroundColor = pickedColor
            self.touchDelegate?.setStrokeColor(pickedColor.cgColor)
        }
    }
    
    @IBAction func paletteViewXTapped(_ sender: UIButton) {
        colorPicker.selectedColor = pickedColor
        
        buttonHide(state: false)
        
        UIView.animate(withDuration: 0.2, animations: {
            self.previewPaletteXTapped(self.previewXButton)
            self.paletteView.alpha = 0.0
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
            self.paletteView.isHidden = true
        }
    }
    
    @IBAction func paletteViewCheckTapped(_ sender: UIButton) {
        let context = self.getContext()
        let entity = NSEntityDescription.entity(forEntityName: "CustomPalette", in: context)
        
        // 중복 저장 방지
        var overlap: Bool = false
        
        for index in 0 ..< customPaletteArray.count {
            if colorPicker.selectedColor.hexValue() == customPaletteArray[index].hexValue() {
                overlap = true
            }
        }
        
        if !(overlap) {
            let object = NSManagedObject(entity: entity!, insertInto: context)
            let colorToHex = colorPicker.selectedColor.hexValue()
            object.setValue(colorToHex, forKey: "colorHex")
            
            do {
                try context.save()
                print("saved!")
            } catch let error as NSError {
                print("Could not save \(error), \(error.userInfo)")
            }
        }
        
        pickedColor = colorPicker.selectedColor
        drawingPenButton.backgroundColor = pickedColor
        self.touchDelegate?.setStrokeColor(pickedColor.cgColor)
        
        buttonHide(state: false)
        self.XbuttonTapped(menuXButtonOn)
        
        UIView.animate(withDuration: 0.2, animations: {
            self.paletteView.alpha = 0.0
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
            self.paletteView.isHidden = true
            
            self.touchDelegate?.setTouchState(true)
            self.editView.isHidden = true
            self.drawingPenButton.layer.borderWidth = 2
        }
    }
    
    // Preview Palette Set
    @IBOutlet open var radialHsbPalette: RadialPaletteControl? {
        get {
            return colorPicker.radialHsbPalette
        }
        set {
            colorPicker.radialHsbPalette = newValue
        }
    }
    
    @IBAction func previewPaletteOnTapped(_ sender: UIButton) {
        previewPaletteView.isHidden = false
        
        UIView.animate(withDuration: 0.2, animations: {
            self.previewPaletteView.alpha = 1.0
        })
    }
    
    @IBAction func previewPaletteXTapped(_ sender: UIButton) {
        let context = self.getContext()
        let entity = NSEntityDescription.entity(forEntityName: "CustomPalette", in: context)
        
        // 중복 저장 방지
        var overlap: Bool = false
        
        for index in 0 ..< customPaletteArray.count {
            if colorPicker.selectedColor.hexValue() == customPaletteArray[index].hexValue() {
                overlap = true
            }
        }
        
        if !(overlap) {
            let object = NSManagedObject(entity: entity!, insertInto: context)
            let colorToHex = colorPicker.selectedColor.hexValue()
            object.setValue(colorToHex, forKey: "colorHex")
            
            do {
                try context.save()
                print("saved!")
            } catch let error as NSError {
                print("Could not save \(error), \(error.userInfo)")
            }
        }
        
        pickedColor = colorPicker.selectedColor
        drawingPenButton.backgroundColor = pickedColor
        self.touchDelegate?.setStrokeColor(pickedColor.cgColor)
        
        figurePreviewColor.backgroundColor = colorPicker.selectedColor
        figurePreview.layer.sublayers?[0].removeFromSuperlayer()
        drawShape(shape: figureShape)
        
        textPreviewColor.backgroundColor = colorPicker.selectedColor
        textField.textColor = colorPicker.selectedColor
        
        UIView.animate(withDuration: 0.2, animations: {
            self.previewPaletteView.alpha = 0.0
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.previewPaletteView.isHidden = true
        }
    }
}
