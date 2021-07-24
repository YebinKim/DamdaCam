//
//  MenuTextView.swift
//  DamdaCam
//
//  Created by Yebin Kim on 2021/07/24.
//  Copyright © 2021 김예빈. All rights reserved.
//

import UIKit
import FlexColorPicker

protocol MenuTextViewDelegate: NSObjectProtocol {
    func menuTextViewCloseButtonTapped()
    func menuTextViewConfirmButtonTapped()
}

final class MenuTextView: UIView {

    static var identifier: String {
        return String(describing: self)
    }

    weak var delegate: MenuTextViewDelegate?

    private var observers: [NSObjectProtocol] = []

    @IBOutlet weak var backgroundView: UIView!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textColorView: CircleShapedView!
    @IBOutlet weak var textColorButton: UIButton!

    @IBOutlet weak var colorPickerView: UIView!
    @IBOutlet weak var colorPickerConfirmButton: UIButton!

    @IBOutlet weak var depthTitleLabel: UILabel!
    @IBOutlet weak var depthValueLabel: UILabel!
    @IBOutlet weak var depthSlider: UISlider!

    @IBOutlet weak var alignLeftButton: UIButton!
    @IBOutlet weak var alignCenterButton: UIButton!
    @IBOutlet weak var alignRightButton: UIButton!
    private lazy var alignButtonArray: [UIButton: NSTextAlignment] = {
        var dict: [UIButton: NSTextAlignment] = [:]
        guard let alignLeftButton = alignLeftButton,
              let alignCenterButton = alignCenterButton,
              let alignRightButton = alignRightButton else {
            return dict
        }
        dict[alignLeftButton] = NSTextAlignment.left
        dict[alignCenterButton] = NSTextAlignment.center
        dict[alignRightButton] = NSTextAlignment.right
        return dict
    }()

    private var inputText: String = "" {
        didSet {
            textView?.text = "Text"
        }
    }

    private var textDepth: Int = 0 {
        didSet {
            depthValueLabel?.text = String(textDepth)
        }
    }

    init() {
        super.init(frame: .zero)
        initFromNib()
        initializeValue()
        initializeView()

        addObservers()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        print("[deinit] MenuTextView")
        removeObservers()
    }

    private func addObservers() {
        let keyboardWillShowNotification = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: nil, using: keyboardWillShow(notification:))
        observers.append(keyboardWillShowNotification)

        let keyboardWillHideNotification = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil, using: keyboardWillHide(notification:))
        observers.append(keyboardWillHideNotification)
    }

    private func removeObservers() {
        for observer in observers {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    private func initializeValue() {
        inputText = "Text"
        textDepth = 2
    }

    private func initializeView() {
        self.clipsToBounds = true
        self.layer.cornerRadius = 10

        textView.delegate = self
        textView.textAlignment = .center
        textView.centerVertically()

        colorPickerView.layer.cornerRadius = 18

        depthSlider.setThumbImage(UIImage(named: "thumb_slider"), for: .normal)

        alignCenterButton.isSelected = true
    }

    @IBAction func alignButtonTapped(_ sender: UIButton) {
        alignLeftButton.isSelected = false
        alignCenterButton.isSelected = false
        alignRightButton.isSelected = false

        if let alignment = alignButtonArray[sender] {
            sender.isSelected = true
            textView.textAlignment = alignment
        }
    }

    @IBAction func depthSliderChanged(_ sender: UISlider) {
        textDepth = Int(depthSlider.value)
    }

    @IBAction func closeButtonTapped(_ sender: UIButton) {
        delegate?.menuTextViewCloseButtonTapped()
    }

    @IBAction func confirmButtonTapped(_ sender: UIButton) {
        delegate?.menuTextViewConfirmButtonTapped()
    }

    func keyboardWillShow(notification: Notification) {
        if let userInfo = notification.userInfo,
           let keyboardSize = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.frame.origin.y -= keyboardSize.height / 2.0
        }
    }

    func keyboardWillHide(notification: Notification) {
        if let userInfo = notification.userInfo,
           let keyboardSize = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.frame.origin.y += keyboardSize.height / 2.0
        }
    }
}

extension MenuTextView: UITextViewDelegate {}
