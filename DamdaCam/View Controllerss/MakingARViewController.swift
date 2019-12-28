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

class MakingARViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var localRecords: [NSManagedObject] = []
    
    var lastPoint: CGPoint!
    var lineSize: CGFloat = 2.0
    var lineColor = UIColor.black.cgColor
    
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
    var drawerButtonCenter: CGPoint = CGPoint(x: 187.5, y: 605.5)
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
        
        // Message Set
        drawingStartView.alpha = 0.0
        drawingStartView.layer.cornerRadius = 17
        viewDropShadow(view: drawingStartView)
        drawingStartState = false
        
        // menu set
        self.menuButtonStateCheck()
        self.buttonDropShadow(button: menuDrawerButton)
        self.buttonDropShadow(button: menuARMotionButton)
        self.buttonDropShadow(button: menuPaletteButton)
        self.buttonDropShadow(button: menuBrushButton)
        self.buttonDropShadow(button: menuFigureButton)
        self.buttonDropShadow(button: menuEraserButton)
        ARMotionButtonCenter = menuARMotionButton.center
        paletteButtonCenter = menuPaletteButton.center
        brushButtonCenter = menuBrushButton.center
        figureButtonCenter = menuFigureButton.center
        eraserButtonCenter = menuEraserButton.center
        backView.isHidden = true
        backView.alpha = 0.0
        
        figureDrawView.isHidden = true
        figureDrawView.frame = drawingView.bounds
        figureDrawView.backgroundColor = UIColor.clear
        self.view.addSubview(figureDrawView)
        let drawFigure: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(drawRectGesture))
        figureDrawView.addGestureRecognizer(drawFigure)
        
        let onTapMenuView: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(OnMenuViewTap))
        backView.addGestureRecognizer(onTapMenuView)
        
        // Save Message
        saveMessageView.isHidden = true
        saveMessageView.alpha = 0.0
        saveMessageView.layer.cornerRadius = 10
        saveMessageButtonView.layer.cornerRadius = 10
        saveMessageButtonView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        viewDropShadow(view: topView)
        viewDropShadow(view: saveMessageView)
        viewDropShadow(view: saveMessageButtonView)

        // Palette Set
        addBackView(view: paletteView, color: UIColor.black, alpha: 0.6, cornerRadius: 10)
        paletteView.alpha = 0.0
        paletteView.layer.cornerRadius = 10
        viewDropShadow(view: paletteRadialPicker)
        createCustomPaletteArray()
        colorPicker.selectedColor = pickedColor
        
        // Brush Set
        addBackView(view: brushView, color: UIColor.black, alpha: 0.6, cornerRadius: 10)
        brushView.alpha = 0.0
        brushView.layer.cornerRadius = 10
        brushBasicButton.isSelected = true
        brushWidthSlider.setThumbImage(UIImage(named: "thumb_slider"), for: .normal)
        
        // Figure Set
        addBackView(view: figureView, color: UIColor.black, alpha: 0.6, cornerRadius: 10)
        figureView.alpha = 0.0
        figureView.layer.cornerRadius = 10
        figureFillButton.isSelected = true
        figureWidthTitle.textColor = UIColor(red: 169/255, green: 169/255, blue: 169/255, alpha: 1.0)
        figureWidthLabel.textColor = UIColor(red: 169/255, green: 169/255, blue: 169/255, alpha: 1.0)
        figureWidthSlider.isEnabled = false
        figureWidthSlider.setThumbImage(UIImage(named: "thumb_slider"), for: .normal)
        figureShape = "Rectangle"
//        figureDrawView.initGestureRecognizers()
        
        // Preview Color Set
        previewPaletteView.layer.cornerRadius = 18
        viewDropShadow(view: previewPaletteView)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    // Drawing Set
    func getContext() -> NSManagedObjectContext {
        return appDelegate.persistentContainer.viewContext
    }
    
    @IBAction func deleteDrawing(_ sender: UIButton) {
        drawingView.image = nil
    }
    
    @IBAction func saveDrawing(_ sender: UIButton) {
        let image = saveAsImage()
        let idString = UUID().uuidString
        
        self.saveMessageView.isHidden = false
        UIView.animate(withDuration: 0.2, delay: 0.0, options: [.curveLinear], animations: {
            self.saveMessageView.alpha = 1.0
        })
        
        self.saveImage(imageName: idString, image: image!)
    }
    
    func saveImage(imageName: String, image: UIImage) {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        let fileName = imageName
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        guard let data = image.pngData() else { return }
        
        let context = self.getContext()
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
    
    func loadImageFromDiskWith(fileName: String) -> UIImage? {
        let documentDirectory = FileManager.SearchPathDirectory.documentDirectory
        
        let userDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(documentDirectory, userDomainMask, true)
        
        if let dirPath = paths.first {
            let imageUrl = URL(fileURLWithPath: dirPath).appendingPathComponent(fileName)
            let image = UIImage(contentsOfFile: imageUrl.path)
            return image
        }
        
        return nil
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
                UIGraphicsGetCurrentContext()?.setStrokeColor(lineColor)
                UIGraphicsGetCurrentContext()?.setShadow(offset: CGSize(width: 0.0, height: 0.0), blur: 0.0, color: UIColor.clear.cgColor)
            } else {
                (UIGraphicsGetCurrentContext())!.setBlendMode(CGBlendMode.normal)
                // 네온 색상을 설정
                UIGraphicsGetCurrentContext()?.setStrokeColor(UIColor.white.cgColor)
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
                UIGraphicsGetCurrentContext()?.setStrokeColor(lineColor)
                UIGraphicsGetCurrentContext()?.setShadow(offset: CGSize(width: 0.0, height: 0.0), blur: 0.0, color: UIColor.clear.cgColor)
            } else {
                (UIGraphicsGetCurrentContext())!.setBlendMode(CGBlendMode.normal)
                // 네온 색상을 설정
                UIGraphicsGetCurrentContext()?.setStrokeColor(UIColor.white.cgColor)
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
    @objc func OnMenuViewTap(gestureRecognizer: UITapGestureRecognizer){
        self.figureViewXTapped(figureXButton)
        self.brushViewXTapped(brushXButton)
        self.paletteViewXTapped(paletteXButton)
        self.previewPaletteXTapped(previewXButton)
        
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
                
                self.buttonDropShadow(button: self.menuARMotionButton)
                self.buttonDropShadow(button: self.menuPaletteButton)
                self.buttonDropShadow(button: self.menuBrushButton)
                self.buttonDropShadow(button: self.menuFigureButton)
                self.buttonDropShadow(button: self.menuEraserButton)
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
        
        self.menuButtonStateCheck()
    }
    
    @IBAction func palettebuttonTapped(_ sender: UIButton) {
        pickedColor = colorPicker.selectedColor
        createCustomPaletteArray()
        
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
        
        self.menuButtonStateCheck()
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
        
        self.menuButtonStateCheck()
    }
    
    @IBAction func figurebuttonTapped(_ sender: UIButton) {
        figurePreview.layer.sublayers?[0].removeFromSuperlayer()
        drawShape(shape: figureShape)
        
        figurePreviewColor.backgroundColor = colorPicker.selectedColor
        figureWidthLabel.text = String(Int(figureWidthSlider.value))
        
        backView.isHidden = false
        self.figureView.isHidden = false
        
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
        
        self.menuButtonStateCheck()
    }
    
    @IBAction func eraserbuttonTapped(_ sender: UIButton) {
        eraseState = true
        
        ARMotionButtonState = false
        paletteButtonState = false
        brushButtonState = false
        figureButtonState = false
        eraserButtonState = true
        
        self.menuButtonStateCheck()
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
    
    func buttonAnimation(button: UIButton, position: CGPoint, size: CGFloat) {
        button.center = position
        button.transform = CGAffineTransform(scaleX: size, y: size)
    }
    
    func menuButtonStateCheck() {
        if (ARMotionButtonState) {
            self.menuSelectedOn(button: self.menuARMotionButton, changeImage: UIImage(named: "ic_ARMotion2_on")!)
        } else {
            self.menuSelectedOff(button: self.menuARMotionButton, changeImage: UIImage(named: "ic_ARMotion2_off")!)
        }
        
        if (paletteButtonState) {
            self.menuSelectedOn(button: self.menuPaletteButton, changeImage: UIImage(named: "ic_palette_on")!)
        } else {
            self.menuSelectedOff(button: self.menuPaletteButton, changeImage: UIImage(named: "ic_palette_off")!)
        }
        
        if (brushButtonState) {
            self.menuSelectedOn(button: self.menuBrushButton, changeImage: UIImage(named: "ic_brush_on")!)
        } else {
            self.menuSelectedOff(button: self.menuBrushButton, changeImage: UIImage(named: "ic_brush_off")!)
        }
        
        if (figureButtonState) {
            self.menuSelectedOn(button: self.menuFigureButton, changeImage: UIImage(named: "ic_figure_on")!)
        } else {
            self.menuSelectedOff(button: self.menuFigureButton, changeImage: UIImage(named: "ic_figure_off")!)
        }
        
        if (eraserButtonState) {
            self.menuSelectedOn(button: self.menuEraserButton, changeImage: UIImage(named: "ic_eraser_on")!)
        } else {
            self.menuSelectedOff(button: self.menuEraserButton, changeImage: UIImage(named: "ic_eraser_off")!)
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
//            self.touchDelegate?.setStrokeColor(customPaletteArray[indexPath.row].cgColor)
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
        } else{
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
//        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toARMotionNO") {
            let destVC = segue.destination as! ARMotionViewController
            destVC.toARMotionNO = true
        }
        
        if (segue.identifier == "toARMotionYES") {
            let destVC = segue.destination as! ARMotionViewController
            destVC.toARMotionYES = true
        }
    }
}

@IBDesignable
class FigureDrawView: UIView {
    var startPoint:CGPoint?{
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    var endPoint:CGPoint?{
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    var drawView: UIImageView!
    var shape: String!
    var fillState: Bool!
    var width: CGFloat!
    var color: UIColor!
    var touchEnded: Bool!

    // 도형 제스쳐?
    /*
    func initGestureRecognizers() {
        let panGR = UIPanGestureRecognizer(target: self, action: #selector(didPan))
        addGestureRecognizer(panGR)
        
        let pinchGR = UIPinchGestureRecognizer(target: self, action: #selector(didPinch))
        addGestureRecognizer(pinchGR)
        
        let rotationGR = UIRotationGestureRecognizer(target: self, action: #selector(didRotate))
        addGestureRecognizer(rotationGR)
    }
    
    @objc func didPan(panGR: UIPanGestureRecognizer) {
        
        self.superview!.bringSubviewToFront(self)
        
        let translation = panGR.translation(in: self)
        
        self.center.x += translation.x
        self.center.y += translation.y
        
        panGR.setTranslation(CGPoint.zero, in: self)
    }
    
    @objc func didPinch(pinchGR: UIPinchGestureRecognizer) {
        
        self.superview!.bringSubviewToFront(self)
        
        let scale = pinchGR.scale
        
        self.transform = CGAffineTransform(scaleX: scale, y: scale)
        
        pinchGR.scale = 1.0
    }
    
    @objc func didRotate(rotationGR: UIRotationGestureRecognizer) {
        
        self.superview!.bringSubviewToFront(self)
        
        let rotation = rotationGR.rotation
        
        self.transform = CGAffineTransform(rotationAngle: rotation)
        
        rotationGR.rotation = 0.0
    }
 */
    
    override func draw(_ rect: CGRect) {
        if (startPoint != nil && endPoint != nil) {
            let layer = CAShapeLayer()
            
            let path = drawPath(rect: CGRect(x: min(startPoint!.x, endPoint!.x), y: min(startPoint!.y, endPoint!.y), width: abs(startPoint!.x - endPoint!.x), height: abs(startPoint!.y - endPoint!.y)), shape: shape)
            
            UIColor.clear.setFill()
            path.stroke()
            path.lineWidth = 2.0
            
            if fillState {
                path.fill()
                color.setFill()
            } else {
                color.setStroke()
                path.lineWidth = width
            }
            
            if getTouchEnded() {
                if fillState {
                    layer.fillColor = color.cgColor
                    layer.strokeColor = UIColor.clear.cgColor
                    layer.lineWidth = 0.0
                } else {
                    layer.fillColor = UIColor.clear.cgColor
                    layer.strokeColor = color.cgColor
                    layer.lineWidth = width
                }
                
                layer.path = path.cgPath
                drawView.layer.addSublayer(layer)
            }
        }
    }
    
    func setDrawView(sendView: UIImageView) {
        drawView = sendView
    }
    
    func getDrawView() -> UIImageView {
        return drawView
    }
    
    func setShape(sendShape: String) {
        shape = sendShape
    }
    
    func getShape() -> String {
        return shape
    }
    
    func setFillState(sendState: Bool) {
        fillState = sendState
    }
    
    func getFillState() -> Bool {
        return fillState
    }
    
    func setWidth(sendWidth: CGFloat) {
        width = sendWidth
    }
    
    func getWidth() -> CGFloat {
        return width
    }
    
    func setColor(sendColor: UIColor) {
        color = sendColor
    }
    
    func getColor() -> UIColor {
        return color
    }
    
    func setTouchEnded(sendState: Bool) {
        touchEnded = sendState
    }
    
    func getTouchEnded() -> Bool {
        return touchEnded
    }
    
    func drawPath(rect: CGRect, shape: String) -> UIBezierPath {
        if shape == "Rectangle" {
            let path = UIBezierPath(rect: rect)
            
            return path
        }

        if shape == "Rounded" {
            let path = UIBezierPath(roundedRect: rect, cornerRadius: 10.0)
            
            return path
        }

        if shape == "Circle" {
            let path = UIBezierPath(arcCenter: CGPoint(x: rect.midX, y: rect.midY), radius: rect.width / 2, startAngle: CGFloat(0), endAngle: CGFloat(Double.pi * 2.0), clockwise: true)
            
            return path
        }

        if shape == "Triangle" {
            let path = UIBezierPath()
            path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
            path.close()

            return path
        }

        if shape == "Heart" {
            let path = UIBezierPath()
            let scale: Double = 1.0

            let scaledWidth = (rect.size.width * CGFloat(scale))
            let scaledXValue = rect.minX
            let scaledHeight = (rect.size.height * CGFloat(scale))
            let scaledYValue = rect.minY

            let scaledRect = CGRect(x: scaledXValue, y: scaledYValue, width: scaledWidth, height: scaledHeight)

            path.move(to: CGPoint(x: rect.midX, y: scaledRect.origin.y + scaledRect.size.height))


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

            path.addCurve(to: CGPoint(x: rect.midX, y: scaledRect.origin.y + scaledRect.size.height),
                          controlPoint1: CGPoint(x: scaledRect.origin.x + scaledRect.size.width, y: scaledRect.origin.y + (scaledRect.size.height/2)),
                          controlPoint2: CGPoint(x: scaledRect.origin.x + (scaledRect.size.width/2), y: scaledRect.origin.y + (scaledRect.size.height*3/4)) )

            path.close()
            
            return path
        }

        return UIBezierPath()
    }
}
