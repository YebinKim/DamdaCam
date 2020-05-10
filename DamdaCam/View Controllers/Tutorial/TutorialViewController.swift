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
    @IBOutlet weak var tutorialLaunchGif: UIImageView!
    @IBOutlet weak var tutorialLaunchLogo: UIImageView!
    @IBOutlet weak var tutorialGifView: UIImageView!
    @IBOutlet weak var tutorialLaunchButton: UIButton!   // 0
    @IBOutlet weak var tutorialSkipButton: UIButton!     // 1
    @IBOutlet weak var tutorialLeftButton: UIButton!     // 2
    @IBOutlet weak var tutorialRightButton: UIButton!    // 3
    @IBOutlet weak var tutorialStartButton: UIButton!    // 4
    @IBOutlet weak var tutorialFlowCircleStackView: UIStackView!
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
        tutorialLaunchGif.isHidden = false
        tutorialLaunchGif.loadGif(name: "Tutorial Gif/logoGif_1")
        tutorialLaunchLogo.isHidden = false
        tutorialGifView.isHidden = true
        tutorialLaunchButton.isHidden = false
        tutorialSkipButton.isHidden = true
        tutorialLeftButton.isHidden = true
        tutorialRightButton.isHidden = true
        tutorialStartButton.isHidden = true
        tutorialFlowCircleStackView.isHidden = true
        tutirialLogoGif.isHidden = true
        tutorialLogo.isHidden = true
        tutorialState = 1
        tutorialFlowAnimation(tutorialState)
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
        
        if sender == tutorialLaunchButton {
            tutorialLaunchGif.isHidden = true
            tutorialLaunchLogo.isHidden = true
            tutorialGifView.isHidden = false
            tutorialGifView.loadGif(name: "Tutorial Gif/tutorialGif_1")
            tutorialLaunchButton.isHidden = true
            tutorialSkipButton.isHidden = false
            tutorialRightButton.isHidden = false
            tutorialFlowCircleStackView.isHidden = false
            tutirialLogoGif.isHidden = false
            tutirialLogoGif.loadGif(name: "Tutorial Gif/logoGif_2")
            tutorialLogo.isHidden = false
            tutorialState = 1
        }
        
        if sender == tutorialRightButton {
            if tutorialState == 4 {
                
            } else if tutorialState == 3 {
                tutorialState += 1
                tutorialGifView.loadGif(name: "Tutorial Gif/tutorialGif_\(tutorialState)")
                tutorialRightButton.isHidden = true
                tutorialStartButton.isHidden = false
            } else {
                tutorialState += 1
                tutorialGifView.loadGif(name: "Tutorial Gif/tutorialGif_\(tutorialState)")
                tutorialLeftButton.isHidden = false
            }
            
            tutorialFlowAnimation(tutorialState)
        }
        
        if sender == tutorialLeftButton {
            if tutorialState == 1 {
                
            } else if tutorialState == 2 {
                tutorialState -= 1
                tutorialGifView.loadGif(name: "Tutorial Gif/tutorialGif_\(tutorialState)")
                tutorialLeftButton.isHidden = true
            } else {
                tutorialState -= 1
                tutorialGifView.loadGif(name: "Tutorial Gif/tutorialGif_\(tutorialState)")
                tutorialRightButton.isHidden = false
                tutorialStartButton.isHidden = true
            }
            
            tutorialFlowAnimation(tutorialState)
        }
        
        if (sender == tutorialSkipButton) || (sender == tutorialStartButton) {
            UIView.animate(withDuration: 0.2, animations: {
                self.tutorialView.alpha = 0.0
            })
            
            DispatchQueue.main.async {
                self.tutorialView.isHidden = true
            }
        }
    }
    
    private func tutorialFlowAnimation(_ onIndex: Int) {
        let subviews = tutorialFlowCircleStackView.subviews.map { view in
            view as? UIImageView
        }
        for subview in subviews {
            subview?.image = #imageLiteral(resourceName: "tutorial_off")
        }
        
        let onIndex = onIndex - 1
        subviews[onIndex]?.alpha = 0.0
        
        UIView.animate(withDuration: 0.1, animations: {
            subviews[onIndex]?.image = #imageLiteral(resourceName: "tutorial_on")
            subviews[onIndex]?.alpha = 1.0
        })
    }
    
    @objc
    func swipeRight(gestureRecognizer: UISwipeGestureRecognizer) {
        
        if tutorialState == 1 {
            
        } else if tutorialState == 2 {
            tutorialState -= 1
            tutorialGifView.loadGif(name: "Tutorial Gif/tutorialGif_\(tutorialState)")
            tutorialLeftButton.isHidden = true
        } else if (tutorialState == 3) || (tutorialState == 4) {
            tutorialState -= 1
            tutorialGifView.loadGif(name: "Tutorial Gif/tutorialGif_\(tutorialState)")
            tutorialRightButton.isHidden = false
            tutorialStartButton.isHidden = true
        }
        
        tutorialFlowAnimation(tutorialState)
    }
    
    @objc
    func swipeLeft(gestureRecognizer: UISwipeGestureRecognizer) {
        
        if tutorialState == 4 {
            
        } else if tutorialState == 3 {
            tutorialState += 1
            tutorialGifView.loadGif(name: "Tutorial Gif/tutorialGif_\(tutorialState)")
            tutorialRightButton.isHidden = true
            tutorialStartButton.isHidden = false
        } else if (tutorialState == 2) || (tutorialState == 1) {
            tutorialState += 1
            tutorialGifView.loadGif(name: "Tutorial Gif/tutorialGif_\(tutorialState)")
            tutorialLeftButton.isHidden = false
        }
        
        tutorialFlowAnimation(tutorialState)
    }
    
}
