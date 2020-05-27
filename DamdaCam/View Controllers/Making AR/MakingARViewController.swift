//
//  MakingARViewController.swift
//  DamdaCam
//
//  Created by 김예빈 on 2019. 3. 30..
//  Copyright © 2019년 김예빈. All rights reserved.
//

import UIKit
import CoreData
import FlexColorPicker

class MakingARViewController: UIViewController {

    static let identifier: String = "MakingARViewController"
    
    var localRecords: [NSManagedObject] = []
    
    var lastPoint: CGPoint!
    var lineSize: CGFloat = 2.0
    var lineColor = UIColor(named: "white")?.cgColor
    
    @IBOutlet var drawingView: UIImageView!
    
    // Message Set
    @IBOutlet var drawingStartView: UIView!
    var drawingStartState: Bool = false
    
    // Menu Set
    @IBOutlet var menuView: UIView!
    @IBOutlet var backView: UIView!
    var openState: Bool = false
    var openMenuView: Bool = false
    @IBOutlet var menuDrawerButton: UIButton!
    @IBOutlet var menuDrawerButtonOn: UIButton!
    @IBOutlet var menuARMotionButton: UIButton!
    @IBOutlet var menuPaletteButton: UIButton!
    @IBOutlet var menuBrushButton: UIButton!
    @IBOutlet var menuFigureButton: UIButton!
    @IBOutlet var menuEraserButton: UIButton!
    var drawerButtonCenter: CGPoint!
    var ARMotionButtonCenter: CGPoint!
    var paletteButtonCenter: CGPoint!
    var brushButtonCenter: CGPoint!
    var figureButtonCenter: CGPoint!
    var eraserButtonCenter: CGPoint!
    var ARMotionButtonState: Bool = false
    var paletteButtonState: Bool = false
    var brushButtonState: Bool = false
    var figureButtonState: Bool = false
    var eraserButtonState: Bool = false
    
    // Save Set
    @IBOutlet var topView: UIView!
    @IBOutlet var saveMessageView: UIView!
    @IBOutlet var saveMessageButtonView: UIView!
    
    // Palette Set
    @IBOutlet var paletteView: UIView!
    @IBOutlet var paletteXButton: UIButton!
    @IBOutlet var paletteRadialPicker: RadialPaletteControl!
    @IBOutlet var paletteRGBView: UIView!
    @IBOutlet var paletteHSBView: UIView!
    @IBOutlet var paletteCustomView: UIView!
    @IBOutlet var paletteCustomCollectionView: UICollectionView!
    @IBOutlet weak var paletteCustomFlowLayout: UICollectionViewFlowLayout!
    var customPaletteArray: [UIColor]!
    public let colorPicker = ColorPickerController()
    
    // Brush Set
    @IBOutlet var brushView: UIView!
    @IBOutlet var brushXButton: UIButton!
    @IBOutlet var brushPreview: UIView!
    @IBOutlet var brushBasicButton: ISRadioButton!
    @IBOutlet var brushNeonButton: ISRadioButton!
    @IBOutlet var brushWidthLabel: UILabel!
    @IBOutlet var brushWidthSlider: UISlider!
    var brushWidth: Float = 15.0
    
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
    @IBOutlet var figureRectangleButton: UIButton!
    @IBOutlet var figureRoundedButton: UIButton!
    @IBOutlet var figureCircleButton: UIButton!
    @IBOutlet var figureTriangleButton: UIButton!
    @IBOutlet var figureHeartButton: UIButton!
    var figureWidth: CGFloat = 2.0
    var figureShape: String!
    let figureDrawView = FigureDrawView()
    
    // Erase Set
    var eraseState: Bool = false
    
    // preview palette setup
    @IBOutlet var previewPaletteView: UIView!
    @IBOutlet var previewXButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Drawing Set
        lineColor = colorPicker.selectedColor.cgColor
        lineSize = CGFloat(brushWidth)
        
        // Set drawing message
        initializeMessageView()
        // Set menu view
        initializeMenuView()
        // Set figure draw view
        initializeFigureDrawView()
        // Set save message
        initializeSaveMessageView()
        
        // Preview Color Set
        previewPaletteView.layer.cornerRadius = 18
        previewPaletteView.dropShadow()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.drawerButtonCenter = self.menuDrawerButton.center - CGPoint(x: 0, y: 60)
            self.ARMotionButtonCenter = self.menuARMotionButton.center
            self.paletteButtonCenter = self.menuPaletteButton.center
            self.brushButtonCenter = self.menuBrushButton.center
            self.figureButtonCenter = self.menuFigureButton.center
            self.eraserButtonCenter = self.menuEraserButton.center
            
            self.buttonAnimation(button: self.menuARMotionButton, position: self.drawerButtonCenter, size: 0.5)
            self.buttonAnimation(button: self.menuPaletteButton, position: self.drawerButtonCenter, size: 0.5)
            self.buttonAnimation(button: self.menuBrushButton, position: self.drawerButtonCenter, size: 0.5)
            self.buttonAnimation(button: self.menuFigureButton, position: self.drawerButtonCenter, size: 0.5)
            self.buttonAnimation(button: self.menuEraserButton, position: self.drawerButtonCenter, size: 0.5)
            self.menuDrawerButton.center = self.drawerButtonCenter
            self.menuDrawerButtonOn.center = self.drawerButtonCenter
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Message Set
        drawingStartView.isHidden = false
        UIView.animate(withDuration: 0.15, delay: 0.2, options: [.curveLinear], animations: {
            self.drawingStartView.alpha = 0.8
        })
    }
    
    private func initializeMessageView() {
        drawingStartView.alpha = 0.0
        drawingStartView.layer.cornerRadius = 17
        drawingStartView.dropShadow()
        drawingStartState = false
    }
    
    private func initializeMenuView() {
        menuButtonStateCheck()
        menuDrawerButton.dropShadow(opacity: 0.16, radius: 10.0, offset: CGSize(width: 1, height: 1))
        menuARMotionButton.dropShadow(opacity: 0.16, radius: 10.0, offset: CGSize(width: 1, height: 1))
        menuPaletteButton.dropShadow(opacity: 0.16, radius: 10.0, offset: CGSize(width: 1, height: 1))
        menuBrushButton.dropShadow(opacity: 0.16, radius: 10.0, offset: CGSize(width: 1, height: 1))
        menuFigureButton.dropShadow(opacity: 0.16, radius: 10.0, offset: CGSize(width: 1, height: 1))
        menuEraserButton.dropShadow(opacity: 0.16, radius: 10.0, offset: CGSize(width: 1, height: 1))
        
        backView.isHidden = true
        backView.alpha = 0.0
        
        registerMenuGestureRecognizer()
        
        initializePaletteView()
        initializeBrushView()
        initializefigureView()
    }
    
    private func initializeFigureDrawView() {
        figureDrawView.isHidden = true
        figureDrawView.frame = drawingView.bounds
        figureDrawView.backgroundColor = UIColor.clear
        view.addSubview(figureDrawView)
        
        registerDrawGestureRecognizer()
    }
    
    private func initializeSaveMessageView() {
        saveMessageView.isHidden = true
        saveMessageView.alpha = 0.0
        saveMessageView.layer.cornerRadius = 10
        saveMessageButtonView.layer.cornerRadius = 10
        saveMessageButtonView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        
        topView.dropShadow()
        saveMessageView.dropShadow()
        saveMessageButtonView.dropShadow()
    }
    
    private func initializePaletteView() {
        addBackView(view: paletteView, color: UIColor(named: "black"), alpha: 0.6, cornerRadius: 10)
        
        paletteView.alpha = 0.0
        paletteView.layer.cornerRadius = 10
        paletteRadialPicker.dropShadow()
        customPaletteArray = DamdaData.shared.customPaletteArray
        colorPicker.selectedColor = pickedColor
    }
    
    private func initializeBrushView() {
        addBackView(view: brushView, color: UIColor(named: "black"), alpha: 0.6, cornerRadius: 10)
        
        brushView.alpha = 0.0
        brushView.layer.cornerRadius = 10
        brushBasicButton.isSelected = true
        brushWidthSlider.setThumbImage(UIImage(named: "thumb_slider"), for: .normal)
    }
    
    private func initializefigureView() {
        addBackView(view: figureView, color: UIColor(named: "black"), alpha: 0.6, cornerRadius: 10)
        
        figureView.alpha = 0.0
        figureView.layer.cornerRadius = 10
        figureFillButton.isSelected = true
        figureWidthTitle.textColor = UIColor(named: "text_disable")
        figureWidthLabel.textColor = UIColor(named: "text_disable")
        figureWidthSlider.isEnabled = false
        figureWidthSlider.setThumbImage(UIImage(named: "thumb_slider"), for: .normal)
        figureShape = "Rectangle"
    }
    
    private func registerMenuGestureRecognizer() {
        let onTapMenuView: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(OnMenuViewTap))
        backView.addGestureRecognizer(onTapMenuView)
    }
    
    private func registerDrawGestureRecognizer() {
        let drawFigure: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(drawRectGesture))
        figureDrawView.addGestureRecognizer(drawFigure)
    }
    
    @IBAction func deleteDrawing(_ sender: UIButton) {
        drawingView.image = nil
    }
    
    @IBAction func saveDrawing(_ sender: UIButton) {
        let image = saveAsImage()
        let idString = UUID().uuidString
        
        saveMessageView.isHidden = false
        UIView.animate(withDuration: 0.2, delay: 0.0, options: [.curveLinear], animations: {
            self.saveMessageView.alpha = 1.0
        })
        
        saveImage(imageName: idString, image: image!)
    }
    
    func saveImage(imageName: String, image: UIImage) {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        let fileName = imageName
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        guard let data = image.pngData() else { return }
        
        let context = DamdaData.shared.context
        let entity = NSEntityDescription.entity(forEntityName: "MakingARData", in: context)

        // LocalRecord record를 새로 생성함
        let object = NSManagedObject(entity: entity!, insertInto: context)

        object.setValue(fileName, forKey: "idString")

        do {
            try context.save()
            print("saved!")
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
        
        //Checks if file exists, removes it if so.
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(atPath: fileURL.path)
                print("Removed old image")
            } catch let removeError {
                print("couldn't remove file at path", removeError)
            }
        }
        
        do {
            try data.write(to: fileURL)
        } catch let error {
            print("error saving file with error", error)
        }
    }
    
    func saveAsImage() -> UIImage? {
        UIGraphicsBeginImageContext(drawingView.bounds.size)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        UIColor.clear.set()
        context.fill(drawingView.bounds)
        
        drawingView.isOpaque = false
        drawingView.layer.isOpaque = false
        drawingView.backgroundColor = UIColor.clear
        drawingView.layer.backgroundColor = UIColor.clear.cgColor
        
        drawingView.layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        return image
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !drawingStartState {
            drawingStartView.alpha = 0.0
            
            DispatchQueue.main.async {
                self.drawingStartView.isHidden = true
                self.drawingStartState = true
            }
        }
        
        // 현재 발생한 터치 이벤트를 가져오기
        let touch = touches.first! as UITouch
        
        lastPoint = touch.location(in: drawingView)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if figureDrawView.isHidden && !(openMenuView) {
            // 그림을 그리기 위한 콘텍스트 생성
            UIGraphicsBeginImageContext(drawingView.frame.size)
            
            if eraseState {
                (UIGraphicsGetCurrentContext())!.setBlendMode(CGBlendMode.clear)
            } else if brushBasicButton.isSelected {
                (UIGraphicsGetCurrentContext())!.setBlendMode(CGBlendMode.normal)
                // 선 색상을 설정
                UIGraphicsGetCurrentContext()?.setStrokeColor(lineColor ?? UIColor.white.cgColor)
                UIGraphicsGetCurrentContext()?.setShadow(offset: CGSize(width: 0.0, height: 0.0), blur: 0.0, color: UIColor.clear.cgColor)
            } else {
                (UIGraphicsGetCurrentContext())!.setBlendMode(CGBlendMode.normal)
                // 네온 색상을 설정
                UIGraphicsGetCurrentContext()?.setStrokeColor(UIColor(named: "white")?.cgColor ?? UIColor.white.cgColor)
                UIGraphicsGetCurrentContext()?.setShadow(offset: CGSize(width: 0.0, height: 0.0), blur: 7.0, color: lineColor)
            }
            
            // 선 끝 모양을 라운드로 설정
            UIGraphicsGetCurrentContext()?.setLineCap(.round)
            // 선 두께를 설정
            UIGraphicsGetCurrentContext()?.setLineWidth(lineSize)
            
            let touch = touches.first! as UITouch
            // 현재의 터치 좌표 가져오기
            let currentPoint = touch.location(in: drawingView)
            
            // 현재 drawingView에 있는 전체 이미지를 drawingView 크기로 그림
            drawingView.draw(CGRect(x: 0, y: 0, width: drawingView.frame.size.width, height: drawingView.frame.size.height))
            
            UIGraphicsGetCurrentContext()?.move(to: CGPoint(x: lastPoint.x, y: lastPoint.y))
            UIGraphicsGetCurrentContext()?.addLine(to: CGPoint(x: currentPoint.x, y: currentPoint.y))
            // 추가한 선을 context에 그림
            UIGraphicsGetCurrentContext()?.strokePath()
            
            // 현재 콘텍스트에 그려진 이미지를 가지고 와서 이미지 뷰에 할당
            drawingView.image = UIGraphicsGetImageFromCurrentImageContext()
            // Drawing 종료
            UIGraphicsEndImageContext()
            
            lastPoint = currentPoint
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if figureDrawView.isHidden && !(openMenuView) {
            UIGraphicsBeginImageContext(drawingView.frame.size)
            
            if eraseState {
                (UIGraphicsGetCurrentContext())!.setBlendMode(CGBlendMode.clear)
            } else if brushBasicButton.isSelected {
                (UIGraphicsGetCurrentContext())!.setBlendMode(CGBlendMode.normal)
                // 선 색상을 설정
                UIGraphicsGetCurrentContext()?.setStrokeColor(lineColor ?? UIColor.white.cgColor)
                UIGraphicsGetCurrentContext()?.setShadow(offset: CGSize(width: 0.0, height: 0.0), blur: 0.0, color: UIColor.clear.cgColor)
            } else {
                (UIGraphicsGetCurrentContext())!.setBlendMode(CGBlendMode.normal)
                // 네온 색상을 설정
                UIGraphicsGetCurrentContext()?.setStrokeColor(UIColor(named: "white")?.cgColor ?? UIColor.white.cgColor)
                UIGraphicsGetCurrentContext()?.setShadow(offset: CGSize(width: 0.0, height: 0.0), blur: 7.0, color: lineColor)
            }
            
            UIGraphicsGetCurrentContext()?.setLineCap(.round)
            UIGraphicsGetCurrentContext()?.setLineWidth(lineSize)
            
            drawingView.draw(CGRect(x: 0, y: 0, width: drawingView.frame.size.width, height: drawingView.frame.size.height))
            
            UIGraphicsGetCurrentContext()?.move(to: CGPoint(x: lastPoint.x, y: lastPoint.y))
            UIGraphicsGetCurrentContext()?.addLine(to: CGPoint(x: lastPoint.x, y: lastPoint.y))
            UIGraphicsGetCurrentContext()?.strokePath()
            
            drawingView.image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
    }
    
    // Menu Set
    @objc func OnMenuViewTap(gestureRecognizer: UITapGestureRecognizer) {
        figureViewXTapped(figureXButton)
        brushViewXTapped(brushXButton)
        paletteViewXTapped(paletteXButton)
        previewPaletteXTapped(previewXButton)
        
        gestureRecognizer.cancelsTouchesInView = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            gestureRecognizer.cancelsTouchesInView = true
        }
    }
    
    @IBAction func drawerButtonTapped(_ sender: UIButton) {
        drawerButtonCenter = menuDrawerButton.center
        
        menuDrawerButtonOn.isEnabled = false
        menuDrawerButton.isEnabled = false
        
        if openState {
            UIView.animate(withDuration: 0.2, delay: 0.0, options: [.curveLinear], animations: {
                self.menuDrawerButtonOn.alpha = 1.0
                self.menuDrawerButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                self.menuDrawerButton.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                self.menuDrawerButtonOn.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                self.menuDrawerButtonOn.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                self.buttonAnimation(button: self.menuARMotionButton, position: self.drawerButtonCenter, size: 0.5)
            })
            UIView.animate(withDuration: 0.15, delay: 0.2, options: [.curveLinear], animations: {
                self.buttonAnimation(button: self.menuPaletteButton, position: self.drawerButtonCenter, size: 0.5)
            })
            UIView.animate(withDuration: 0.15, delay: 0.35, options: [.curveLinear], animations: {
                self.buttonAnimation(button: self.menuBrushButton, position: self.drawerButtonCenter, size: 0.5)
            })
            UIView.animate(withDuration: 0.15, delay: 0.5, options: [.curveLinear], animations: {
                self.buttonAnimation(button: self.menuFigureButton, position: self.drawerButtonCenter, size: 0.5)
            })
            UIView.animate(withDuration: 0.15, delay: 0.65, options: [.curveLinear], animations: {
                self.buttonAnimation(button: self.menuEraserButton, position: self.drawerButtonCenter, size: 0.5)
            })
            UIView.animate(withDuration: 0.15, delay: 0.8, options: [.curveLinear], animations: {
                self.menuDrawerButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            })
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                UIView.animate(withDuration: 0.2, delay: 0.0, options: [.curveLinear], animations: {
                    self.menuDrawerButton.center -= CGPoint(x: 0, y: 57)
                    self.menuDrawerButtonOn.center -= CGPoint(x: 0, y: 57)
                    self.menuARMotionButton.center -= CGPoint(x: 0, y: 57)
                    self.menuPaletteButton.center -= CGPoint(x: 0, y: 57)
                    self.menuBrushButton.center -= CGPoint(x: 0, y: 57)
                    self.menuFigureButton.center -= CGPoint(x: 0, y: 57)
                    self.menuEraserButton.center -= CGPoint(x: 0, y: 57)
                    
                    self.menuDrawerButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                    self.menuDrawerButton.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                    self.menuDrawerButtonOn.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                    self.menuDrawerButtonOn.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                    
                    self.menuDrawerButtonOn.isEnabled = true
                    self.menuDrawerButton.isEnabled = true
                })
            }
            
        } else {
            UIView.animate(withDuration: 0.2, delay: 0.0, options: [.curveLinear], animations: {
                self.menuDrawerButtonOn.alpha = 1.0
                self.menuDrawerButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                self.menuDrawerButton.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                self.menuDrawerButtonOn.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                self.menuDrawerButtonOn.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            })
            UIView.animate(withDuration: 0.15, delay: 0.2, options: [.curveLinear], animations: {
                self.buttonAnimation(button: self.menuARMotionButton, position: self.ARMotionButtonCenter, size: 1.0)
            })
            UIView.animate(withDuration: 0.15, delay: 0.35, options: [.curveLinear], animations: {
                self.buttonAnimation(button: self.menuPaletteButton, position: self.paletteButtonCenter, size: 1.0)
            })
            UIView.animate(withDuration: 0.15, delay: 0.5, options: [.curveLinear], animations: {
                self.buttonAnimation(button: self.menuBrushButton, position: self.brushButtonCenter, size: 1.0)
            })
            UIView.animate(withDuration: 0.15, delay: 0.65, options: [.curveLinear], animations: {
                self.buttonAnimation(button: self.menuFigureButton, position: self.figureButtonCenter, size: 1.0)
            })
            UIView.animate(withDuration: 0.15, delay: 0.8, options: [.curveLinear], animations: {
                self.buttonAnimation(button: self.menuEraserButton, position: self.eraserButtonCenter, size: 1.0)
            })
            UIView.animate(withDuration: 0.2, delay: 0.95, options: [.curveLinear], animations: {
                self.menuDrawerButton.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                self.menuDrawerButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                self.menuDrawerButtonOn.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                self.menuDrawerButtonOn.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                
                self.menuARMotionButton.dropShadow(opacity: 0.16, radius: 10.0, offset: CGSize(width: 1, height: 1))
                self.menuPaletteButton.dropShadow(opacity: 0.16, radius: 10.0, offset: CGSize(width: 1, height: 1))
                self.menuBrushButton.dropShadow(opacity: 0.16, radius: 10.0, offset: CGSize(width: 1, height: 1))
                self.menuFigureButton.dropShadow(opacity: 0.16, radius: 10.0, offset: CGSize(width: 1, height: 1))
                self.menuEraserButton.dropShadow(opacity: 0.16, radius: 10.0, offset: CGSize(width: 1, height: 1))
            })
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.95) {
                UIView.animate(withDuration: 0.2, delay: 0.0, options: [.curveLinear], animations: {
                    self.menuDrawerButton.center += CGPoint(x: 0, y: 57)
                    self.menuDrawerButtonOn.center += CGPoint(x: 0, y: 57)
                    self.menuDrawerButtonOn.alpha = 0.0
                    
                    self.menuDrawerButtonOn.isEnabled = true
                    self.menuDrawerButton.isEnabled = true
                })
            }
        }
        openState = !openState
    }
    
    @IBAction func ARMotionbuttonTapped(_ sender: UIButton) {
        eraseState = false
        openMenuView = true
        
        ARMotionButtonState = true
        paletteButtonState = false
        brushButtonState = false
        figureButtonState = false
        eraserButtonState = false
        
        menuButtonStateCheck()
    }
    
    @IBAction func palettebuttonTapped(_ sender: UIButton) {
        pickedColor = colorPicker.selectedColor
        customPaletteArray = DamdaData.shared.customPaletteArray
        
        backView.isHidden = false
        paletteView.isHidden = false
        
        eraseState = false
        openMenuView = true
        
        ARMotionButtonState = false
        paletteButtonState = true
        brushButtonState = false
        figureButtonState = false
        eraserButtonState = false
        
        UIView.animate(withDuration: 0.2, animations: {
            self.backView.alpha = 0.4
            self.paletteView.alpha = 1.0
        })
        
        menuButtonStateCheck()
    }
    
    @IBAction func brushbuttonTapped(_ sender: UIButton) {
        brushWidthLabel.text = String(Int(brushWidthSlider.value / 2))
        drawLineShape()
        
        backView.isHidden = false
        brushView.isHidden = false
        
        eraseState = false
        openMenuView = true
        
        ARMotionButtonState = false
        paletteButtonState = false
        brushButtonState = true
        figureButtonState = false
        eraserButtonState = false
        
        UIView.animate(withDuration: 0.2, animations: {
            self.backView.alpha = 0.4
            self.brushView.alpha = 1.0
        })
        
        menuButtonStateCheck()
    }
    
    @IBAction func figurebuttonTapped(_ sender: UIButton) {
        figurePreview.layer.sublayers?[0].removeFromSuperlayer()
        drawShape(shape: figureShape)
        
        figurePreviewColor.backgroundColor = colorPicker.selectedColor
        figureWidthLabel.text = String(Int(figureWidthSlider.value))
        
        backView.isHidden = false
        figureView.isHidden = false
        
        eraseState = false
        openMenuView = true
        
        ARMotionButtonState = false
        paletteButtonState = false
        brushButtonState = false
        figureButtonState = true
        eraserButtonState = false
        
        UIView.animate(withDuration: 0.2, animations: {
            self.backView.alpha = 0.4
            self.figureView.alpha = 1.0
        })
        
        menuButtonStateCheck()
    }
    
    @IBAction func eraserbuttonTapped(_ sender: UIButton) {
        eraseState = true
        
        ARMotionButtonState = false
        paletteButtonState = false
        brushButtonState = false
        figureButtonState = false
        eraserButtonState = true
        
        menuButtonStateCheck()
    }
    
    func menuSelectedOn(button: UIButton, changeImage: UIImage) {
        button.setImage(changeImage, for: .normal)
        
        UIView.animate(withDuration: 0.1) {
            button.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            button.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }
    }
    
    func menuSelectedOff(button: UIButton, changeImage: UIImage) {
        button.setImage(changeImage, for: .normal)
        
        UIView.animate(withDuration: 0.1) {
            button.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }
    }
    
    func addBackView(view: UIView, color: UIColor?, alpha: CGFloat, cornerRadius: CGFloat) {
        let backView = UIView()
        backView.frame = view.bounds
        backView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backView.backgroundColor = color
        backView.alpha = alpha
        backView.layer.cornerRadius = cornerRadius
        view.addSubview(backView)
        view.sendSubviewToBack(backView)
    }
    
    func buttonAnimation(button: UIButton, position: CGPoint, size: CGFloat) {
        button.center = position
        button.transform = CGAffineTransform(scaleX: size, y: size)
    }
    
    func menuButtonStateCheck() {
        if ARMotionButtonState {
            menuSelectedOn(button: menuARMotionButton, changeImage: UIImage(named: "ic_arMotion2_on")!)
        } else {
            menuSelectedOff(button: menuARMotionButton, changeImage: UIImage(named: "ic_arMotion2_off")!)
        }
        
        if paletteButtonState {
            menuSelectedOn(button: menuPaletteButton, changeImage: UIImage(named: "ic_palette_on")!)
        } else {
            menuSelectedOff(button: menuPaletteButton, changeImage: UIImage(named: "ic_palette_off")!)
        }
        
        if brushButtonState {
            menuSelectedOn(button: menuBrushButton, changeImage: UIImage(named: "ic_brush_on")!)
        } else {
            menuSelectedOff(button: menuBrushButton, changeImage: UIImage(named: "ic_brush_off")!)
        }
        
        if figureButtonState {
            menuSelectedOn(button: menuFigureButton, changeImage: UIImage(named: "ic_figure_on")!)
        } else {
            menuSelectedOff(button: menuFigureButton, changeImage: UIImage(named: "ic_figure_off")!)
        }
        
        if eraserButtonState {
            menuSelectedOn(button: menuEraserButton, changeImage: UIImage(named: "ic_eraser_on")!)
        } else {
            menuSelectedOff(button: menuEraserButton, changeImage: UIImage(named: "ic_eraser_off")!)
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
    
    @IBOutlet weak var hueSlider: HueUISliderColorControl! {
        didSet {
            colorPicker.controlDidSet(newValue: hueSlider, oldValue: oldValue)
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
    
    @IBAction func paletteViewXTapped(_ sender: UIButton) {
        colorPicker.selectedColor = pickedColor
        
        UIView.animate(withDuration: 0.2, animations: {
            self.previewPaletteXTapped(self.previewXButton)
            self.paletteView.alpha = 0.0
            self.backView.alpha = 0.0
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
            self.paletteView.isHidden = true
            self.backView.isHidden = true
            
            self.openMenuView = false
        }
    }
    
    @IBAction func paletteViewCheckTapped(_ sender: UIButton) {
        // FIXME: CoreData 모델화 진행중, CustomPalette save
        let context = DamdaData.shared.context
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
        lineColor = pickedColor.cgColor
        
        UIView.animate(withDuration: 0.2, animations: {
            self.paletteView.alpha = 0.0
            self.backView.alpha = 0.0
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
            self.paletteView.isHidden = true
            self.backView.isHidden = true
            
            self.openMenuView = false
        }
    }
    
    // Brush Set
    @IBAction func brushStateTapped(_ sender: UIButton) {
        brushPreview.layer.sublayers?[0].removeFromSuperlayer()
        drawLineShape()
    }
    
    @IBAction func brushWidthChanged(_ sender: UISlider) {
        brushPreview.layer.sublayers?[0].removeFromSuperlayer()
        drawLineShape()
        brushWidthLabel.text = String(Int(sender.value))
        
        brushWidth = sender.value
    }
    
    func drawLineShape() {
        let shapeLayer = CAShapeLayer()
        shapeLayer.lineWidth = CGFloat(brushWidthSlider.value / 2)
        shapeLayer.lineCap = CAShapeLayerLineCap.round
        let path = CGMutablePath()
        path.addLines(between: [CGPoint(x: 30, y: 40), CGPoint(x: 220, y: 40)])
        shapeLayer.path = path
        
        if brushBasicButton.isSelected {
            shapeLayer.strokeColor = colorPicker.selectedColor.cgColor
            shapeLayer.shadowRadius = 0
            shapeLayer.shadowOpacity = 0
        } else {
            shapeLayer.strokeColor = UIColor(named: "white")?.cgColor
            shapeLayer.shadowOffset = .zero
            shapeLayer.shadowColor = colorPicker.selectedColor.cgColor
            shapeLayer.shadowRadius = 7
            shapeLayer.shadowOpacity = 1
        }
        
        brushPreview.layer.addSublayer(shapeLayer)
    }
    
    @IBAction func brushViewXTapped(_ sender: UIButton) {
        brushWidth = Float(lineSize)
        
        UIView.animate(withDuration: 0.2, animations: {
            self.previewPaletteXTapped(self.previewXButton)
            self.brushView.alpha = 0.0
            self.backView.alpha = 0.0
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
            self.brushView.isHidden = true
            self.backView.isHidden = true
            
            self.openMenuView = false
        }
    }
    
    @IBAction func brushViewCheckTapped(_ sender: UIButton) {
        lineSize = CGFloat(brushWidth)
        
        UIView.animate(withDuration: 0.2, animations: {
            self.brushView.alpha = 0.0
            self.backView.alpha = 0.0
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
            self.brushView.isHidden = true
            self.backView.isHidden = true
            
            self.openMenuView = false
        }
    }
    
    // Figure Set
    @IBAction func figureStateTapped(_ sender: UIButton) {
        if sender == figureFillButton {
            figureWidthTitle.textColor = UIColor(named: "text_disable")
            figureWidthLabel.textColor = UIColor(named: "text_disable")
            figureWidthSlider.isEnabled = false
        } else {
            figureWidthTitle.textColor = UIColor(named: "white")
            figureWidthLabel.textColor = UIColor(named: "white")
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
            path = UIBezierPath(arcCenter: CGPoint(x: originalRect.midX,
                                                   y: originalRect.midY),
                                                   radius: originalRect.width / 2,
                                                   startAngle: CGFloat(0),
                                                   endAngle: CGFloat(Double.pi * 2.0),
                                                   clockwise: true)
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
    
    @objc func drawRectGesture(sender: UIPanGestureRecognizer) {
        var locationOfBeganTap: CGPoint
        var locationOfEndTap: CGPoint
        
        if sender.state == UIGestureRecognizer.State.began {
            locationOfBeganTap = sender.location(in: figureDrawView)
            figureDrawView.startPoint = locationOfBeganTap
            figureDrawView.endPoint = locationOfBeganTap
            figureDrawView.setTouchEnded(sendState: false)
            
        } else if sender.state == UIGestureRecognizer.State.ended {
            locationOfEndTap = sender.location(in: figureDrawView)
            figureDrawView.endPoint = sender.location(in: figureDrawView)
            figureDrawView.isHidden = true
            figureDrawView.setTouchEnded(sendState: true)
        } else {
            figureDrawView.endPoint = sender.location(in: figureDrawView)
            figureDrawView.setTouchEnded(sendState: false)
        }
    }
    
    @IBAction func figureViewXTapped(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2, animations: {
            self.previewPaletteXTapped(self.previewXButton)
            self.figureView.alpha = 0.0
            self.backView.alpha = 0.0
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
            self.figureView.isHidden = true
            self.backView.isHidden = true
            
            self.openMenuView = false
        }
    }
    
    @IBAction func figureViewCheckTapped(_ sender: UIButton) {
        figureDrawView.setDrawView(sendView: drawingView)
        figureDrawView.setShape(sendShape: figureShape)
        figureDrawView.setFillState(sendState: figureFillButton.isSelected)
        figureDrawView.setWidth(sendWidth: figureWidth)
        figureDrawView.setColor(sendColor: colorPicker.selectedColor)
        figureDrawView.isHidden = false
        
        UIView.animate(withDuration: 0.2, animations: {
            self.figureView.alpha = 0.0
            self.backView.alpha = 0.0
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
            self.figureView.isHidden = true
            self.backView.isHidden = true
            
            self.openMenuView = false
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
        // FIXME: CoreData 모델화 진행중, CustomPalette save
        let context = DamdaData.shared.context
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
        lineColor = pickedColor.cgColor
        
        figurePreviewColor.backgroundColor = colorPicker.selectedColor
        figurePreview.layer.sublayers?[0].removeFromSuperlayer()
        drawShape(shape: figureShape)
        
        UIView.animate(withDuration: 0.2, animations: {
            self.previewPaletteView.alpha = 0.0
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.previewPaletteView.isHidden = true
        }
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toARMotionNO" {
            guard let destVC = segue.destination as? ARMotionViewController else { return }
            destVC.toARMotionNO = true
        }
        
        if segue.identifier == "toARMotionYES" {
            guard let destVC = segue.destination as? ARMotionViewController else { return }
            destVC.toARMotionYES = true
        }
    }
}
