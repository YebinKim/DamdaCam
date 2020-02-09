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
    @IBOutlet var tutorialView: UIView!
    @IBOutlet var tutorialBG: UIImageView!
    @IBOutlet var tutorialLaunchGif: UIImageView!
    @IBOutlet var tutorialLaunchLogo: UIImageView!
    @IBOutlet var tutorialGifView: UIImageView!
    @IBOutlet var tutorialLaunchButton: UIButton!   // 0
    @IBOutlet var tutorialSkipButton: UIButton!     // 1
    @IBOutlet var tutorialLeftButton: UIButton!     // 2
    @IBOutlet var tutorialRightButton: UIButton!    // 3
    @IBOutlet var tutorialStartButton: UIButton!    // 4
    @IBOutlet var tutorialFlowCircle: UIImageView!
    @IBOutlet var tutirialLogoGif: UIImageView!
    @IBOutlet var tutorialLogo: UIImageView!
    var tutorialState: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTutorial()
        
        let swipeTutorialRight: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeRight))
        swipeTutorialRight.direction = .right
        self.tutorialView.addGestureRecognizer(swipeTutorialRight)
        
        let swipeTutorialLeft: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeft))
        swipeTutorialLeft.direction = .left
        self.tutorialView.addGestureRecognizer(swipeTutorialLeft)
    }
    
    func setTutorial() {
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
        tutorialFlowCircle.isHidden = true
        tutirialLogoGif.isHidden = true
        tutorialLogo.isHidden = true
        tutorialState = 0
    }
    
    @IBAction func startButtonTapped(_ sender: UIButton) {
        self.showStoryboard()
    }
    
    @IBAction func skipButtonTapped(_ sender: UIButton) {
        self.showStoryboard()
    }
    
    @IBAction func tutorialFlowControlButton(_ sender: UIButton) {
        
        if sender == tutorialLaunchButton {
            tutorialBG.image = UIImage(named: "tutorial_1")
            tutorialLaunchGif.isHidden = true
            tutorialLaunchLogo.isHidden = true
            tutorialGifView.isHidden = false
            tutorialGifView.loadGif(name: "Tutorial Gif/tutorialGif_1")
            tutorialLaunchButton.isHidden = true
            tutorialSkipButton.isHidden = false
            tutorialRightButton.isHidden = false
            tutorialFlowCircle.isHidden = false
            tutirialLogoGif.isHidden = false
            tutirialLogoGif.loadGif(name: "Tutorial Gif/logoGif_2")
            tutorialLogo.isHidden = false
            tutorialState = 1
        }
        
        if sender == tutorialRightButton {
            if tutorialState == 4 {
                
            } else if tutorialState == 3 {
                tutorialState += 1
                tutorialBG.image = UIImage(named: "tutorial_\(tutorialState)")
                tutorialGifView.loadGif(name: "Tutorial Gif/tutorialGif_\(tutorialState)")
                tutorialRightButton.isHidden = true
                tutorialStartButton.isHidden = false
                tutorialFlowCircle.isHidden = true
                tutorialFlowCircle.alpha = 0.0
                tutorialFlowCircle.frame.origin.x += 30
                
                UIView.animate(withDuration: 0.1, animations: {
                    self.tutorialFlowCircle.isHidden = false
                    self.tutorialFlowCircle.alpha = 1.0
                })
            } else {
                tutorialState += 1
                tutorialBG.image = UIImage(named: "tutorial_\(tutorialState)")
                tutorialGifView.loadGif(name: "Tutorial Gif/tutorialGif_\(tutorialState)")
                tutorialLeftButton.isHidden = false
                tutorialFlowCircle.isHidden = true
                tutorialFlowCircle.alpha = 0.0
                tutorialFlowCircle.frame.origin.x += 30
                
                UIView.animate(withDuration: 0.1, animations: {
                    self.tutorialFlowCircle.isHidden = false
                    self.tutorialFlowCircle.alpha = 1.0
                })
            }
        }
        
        if sender == tutorialLeftButton {
            if tutorialState == 1 {
                
            } else if tutorialState == 2 {
                tutorialState -= 1
                tutorialBG.image = UIImage(named: "tutorial_\(tutorialState)")
                tutorialGifView.loadGif(name: "Tutorial Gif/tutorialGif_\(tutorialState)")
                tutorialLeftButton.isHidden = true
                tutorialFlowCircle.isHidden = true
                tutorialFlowCircle.alpha = 0.0
                tutorialFlowCircle.frame.origin.x -= 30
                
                UIView.animate(withDuration: 0.1, animations: {
                    self.tutorialFlowCircle.isHidden = false
                    self.tutorialFlowCircle.alpha = 1.0
                })
            } else {
                tutorialState -= 1
                tutorialBG.image = UIImage(named: "tutorial_\(tutorialState)")
                tutorialGifView.loadGif(name: "Tutorial Gif/tutorialGif_\(tutorialState)")
                tutorialRightButton.isHidden = false
                tutorialStartButton.isHidden = true
                
                tutorialFlowCircle.isHidden = true
                tutorialFlowCircle.alpha = 0.0
                tutorialFlowCircle.frame.origin.x -= 30
                
                UIView.animate(withDuration: 0.1, animations: {
                    self.tutorialFlowCircle.isHidden = false
                    self.tutorialFlowCircle.alpha = 1.0
                })
            }
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
    
    @objc func swipeRight(gestureRecognizer: UISwipeGestureRecognizer) {
        
        if tutorialState == 1 {
            
        } else if tutorialState == 2 {
            tutorialState -= 1
            tutorialBG.image = UIImage(named: "tutorial_\(tutorialState)")
            tutorialGifView.loadGif(name: "Tutorial Gif/tutorialGif_\(tutorialState)")
            tutorialLeftButton.isHidden = true
            tutorialFlowCircle.isHidden = true
            tutorialFlowCircle.alpha = 0.0
            tutorialFlowCircle.frame.origin.x -= 30
            
            UIView.animate(withDuration: 0.1, animations: {
                self.tutorialFlowCircle.isHidden = false
                self.tutorialFlowCircle.alpha = 1.0
            })
        } else if (tutorialState == 3) || (tutorialState == 4) {
            tutorialState -= 1
            tutorialBG.image = UIImage(named: "tutorial_\(tutorialState)")
            tutorialGifView.loadGif(name: "Tutorial Gif/tutorialGif_\(tutorialState)")
            tutorialRightButton.isHidden = false
            tutorialStartButton.isHidden = true
            tutorialFlowCircle.isHidden = true
            tutorialFlowCircle.alpha = 0.0
            tutorialFlowCircle.frame.origin.x -= 30
            
            UIView.animate(withDuration: 0.1, animations: {
                self.tutorialFlowCircle.isHidden = false
                self.tutorialFlowCircle.alpha = 1.0
            })
        }
    }
    
    @objc func swipeLeft(gestureRecognizer: UISwipeGestureRecognizer) {
        
        if tutorialState == 4 {
            
        } else if tutorialState == 3 {
            tutorialState += 1
            tutorialBG.image = UIImage(named: "tutorial_\(tutorialState)")
            tutorialGifView.loadGif(name: "Tutorial Gif/tutorialGif_\(tutorialState)")
            tutorialRightButton.isHidden = true
            tutorialStartButton.isHidden = false
            tutorialFlowCircle.isHidden = true
            tutorialFlowCircle.alpha = 0.0
            tutorialFlowCircle.frame.origin.x += 30
            
            UIView.animate(withDuration: 0.1, animations: {
                self.tutorialFlowCircle.isHidden = false
                self.tutorialFlowCircle.alpha = 1.0
            })
        } else if (tutorialState == 2) || (tutorialState == 1) {
            tutorialState += 1
            tutorialBG.image = UIImage(named: "tutorial_\(tutorialState)")
            tutorialGifView.loadGif(name: "Tutorial Gif/tutorialGif_\(tutorialState)")
            tutorialLeftButton.isHidden = false
            tutorialFlowCircle.isHidden = true
            tutorialFlowCircle.alpha = 0.0
            tutorialFlowCircle.frame.origin.x += 30
            
            UIView.animate(withDuration: 0.1, animations: {
                self.tutorialFlowCircle.isHidden = false
                self.tutorialFlowCircle.alpha = 1.0
            })
        }
    }
    
    // FIXME: Change to NavigationController structure
    func showStoryboard() {
        let nextVC = ARDrawingViewController()
        nextVC.modalPresentationStyle = .fullScreen
        self.present(nextVC, animated: true)
    }
}
