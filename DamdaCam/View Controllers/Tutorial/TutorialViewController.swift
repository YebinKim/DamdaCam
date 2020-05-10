//
//  TutorialViewController.swift
//  DamdaCam
//
//  Created by 김예빈 on 2019. 5. 21..
//  Copyright © 2019년 김예빈. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController {
    
    static let identifier: String = "TutorialViewController"
    
    // Tutorial View
    @IBOutlet weak var tutorialView: UIView!
    @IBOutlet weak var tutorialBG: UIImageView!
    @IBOutlet weak var tutorialSkipButton: UIButton!
    @IBOutlet weak var tutorialLaunchGif: UIImageView!
    @IBOutlet weak var tutorialLaunchLogo: UIImageView!
    @IBOutlet weak var tutorialGifView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var launchButton: UIButton!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var flowCircleStackView: UIStackView!
    @IBOutlet weak var tutirialLogoGif: UIImageView!
    @IBOutlet weak var tutorialLogo: UIImageView!
    var tutorialState: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initializeTutorial()
        self.registerGestureRecognizers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func initializeTutorial() {
        tutorialView.isHidden = false
        tutorialBG.image = UIImage(named: "launch_bg")
        tutorialSkipButton.isHidden = true
        tutorialLaunchGif.isHidden = false
        tutorialLaunchGif.loadGif(name: "Tutorial Gif/logoGif_1")
        tutorialLaunchLogo.isHidden = false
        tutorialGifView.isHidden = true
        titleLabel.isHidden = true
        descriptionLabel.isHidden = true
        launchButton.isHidden = false
        leftButton.isHidden = true
        rightButton.isHidden = true
        startButton.isHidden = true
        flowCircleStackView.isHidden = true
        tutirialLogoGif.isHidden = true
        tutorialLogo.isHidden = true
        tutorialState = 1
        setTutorialScreen(on: tutorialState)
    }
    
    private func registerGestureRecognizers() {
        let swipeTutorialRight: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeRight))
        swipeTutorialRight.direction = .right
        self.tutorialView.addGestureRecognizer(swipeTutorialRight)
        
        let swipeTutorialLeft: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeft))
        swipeTutorialLeft.direction = .left
        self.tutorialView.addGestureRecognizer(swipeTutorialLeft)
    }
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        let nextVC = ARDrawingViewController()
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @IBAction func tutorialFlowControlButton(_ sender: UIButton) {
        
        if sender == launchButton {
            tutorialSkipButton.isHidden = false
            tutorialLaunchGif.isHidden = true
            tutorialLaunchLogo.isHidden = true
            tutorialGifView.isHidden = false
            tutorialGifView.loadGif(name: "Tutorial Gif/tutorialGif_1")
            titleLabel.isHidden = false
            descriptionLabel.isHidden = false
            launchButton.isHidden = true
            rightButton.isHidden = false
            flowCircleStackView.isHidden = false
            tutirialLogoGif.isHidden = false
            tutirialLogoGif.loadGif(name: "Tutorial Gif/logoGif_2")
            tutorialLogo.isHidden = false
            tutorialState = 1
        }
        
        if sender == leftButton {
            swipeRight()
        }
        
        if sender == rightButton {
            swipeLeft()
        }
        
        if (sender == tutorialSkipButton) || (sender == startButton) {
            UIView.animate(withDuration: 0.2, animations: {
                self.tutorialView.alpha = 0.0
            })
            
            DispatchQueue.main.async {
                self.tutorialView.isHidden = true
            }
        }
    }
    
    private func setTutorialScreen(on idx: Int) {
        tutorialGifView.loadGif(name: "Tutorial Gif/tutorialGif_\(idx)")
        titleLabel.text = "Tutorial_Title_\(idx)".localized
        descriptionLabel.text = "Tutorial_Description_\(idx)".localized
        tutorialFlowAnimation(on: idx)
    }
    
    private func tutorialFlowAnimation(on idx: Int) {
        let subviews = flowCircleStackView.subviews.map { view in
            view as? UIImageView
        }
        for subview in subviews {
            subview?.image = #imageLiteral(resourceName: "tutorial_off")
        }
        
        let onIndex = idx - 1
        subviews[onIndex]?.alpha = 0.0
        
        UIView.animate(withDuration: 0.1, animations: {
            subviews[onIndex]?.image = #imageLiteral(resourceName: "tutorial_on")
            subviews[onIndex]?.alpha = 1.0
        })
    }
    
    @objc
    func swipeLeft() {
        if tutorialState == 3 {
            tutorialState += 1
            rightButton.isHidden = true
            startButton.isHidden = false
        } else if (tutorialState == 2) || (tutorialState == 1) {
            tutorialState += 1
            leftButton.isHidden = false
        }
        
        setTutorialScreen(on: tutorialState)
    }
    
    @objc
    func swipeRight() {
        if tutorialState == 2 {
            tutorialState -= 1
            leftButton.isHidden = true
        } else if (tutorialState == 3) || (tutorialState == 4) {
            tutorialState -= 1
            rightButton.isHidden = false
            startButton.isHidden = true
        }
        
        setTutorialScreen(on: tutorialState)
    }
    
}
