//
//  BallView.swift
//  EMDR Tap
//
//  Created by Eddie Char on 7/22/22.
//

import UIKit

enum BallDirection: Int {
    case left = -1
    case center = 0
    case right = 1
}


protocol BallViewDelegate: AnyObject {
    func didStartPlaying(restart: Bool)
    func didStopPlaying(restart: Bool)
    func didUpdateCurrentImage()
}

class BallView: UIView, CustomButtonDelegate {

    // MARK: - Properties
    
    private let ballSize: CGFloat = 80
    private let ballPadding: CGFloat = 50
    private let ballImages: [UIImage?] = [UIImage(systemName: "circle.fill"),
                                          UIImage(systemName: "star.fill"),
                                          UIImage(systemName: "moon.fill"),
                                          UIImage(systemName: "atom"),
                                          UIImage(systemName: "face.smiling"),
                                          UIImage(named: "EMDR-warren")]
//    private var currentImage = UserDefaults.standard.integer(forKey: "BallImage")
//    private var speed: TimeInterval = 1.0
//    private var isPlaying = false
    
    private var tapManagerControls: TapManagerControls!
    private var direction: BallDirection = .right
    private var timer: Timer?
    private var superView: UIView!
    private var ballButton: CustomButton!
    private var centerXConstraint: NSLayoutConstraint!
    
    
    weak var delegate: BallViewDelegate?

    
    // MARK: - Initialization
    
    init(in superView: UIView, tapManagerControls: TapManagerControls) {
        super.init(frame: .zero)
        
        self.superView = superView
        self.tapManagerControls = tapManagerControls
        
        setupViews()
        layoutViews()
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        timer = Timer()
        
        ballButton = CustomButton(image: ballImages[tapManagerControls.currentImage],
                                  asTemplate: (tapManagerControls.currentImage >= ballImages.count - 1 ? false : true),
                                  shouldAnimatePress: true)
        ballButton.isUserInteractionEnabled = DataService.sessionType != .guest ? true : false
        
        if DataService.sessionType != .guest {
            ballButton.delegate = self
        }
        
        centerXConstraint = ballButton.centerXAnchor.constraint(equalTo: leadingAnchor, constant: superView.frame.width / 2)
    }
    
    private func layoutViews() {
        addSubview(ballButton)
        
        NSLayoutConstraint.activate([
            ballButton.widthAnchor.constraint(equalToConstant: ballSize),
            ballButton.heightAnchor.constraint(equalToConstant: ballSize),
            ballButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            centerXConstraint,
        ])
    }
    
    
    // MARK: - Helper Functions
    
    func getIsPlaying() -> Bool {
        return tapManagerControls.isPlaying
    }
    
    func getCurrentImage() -> Int {
        return tapManagerControls.currentImage
    }
    
    func startPlaying(speed: TimeInterval, restart: Bool = true) {
        tapManagerControls.speed = Float(speed)
        tapManagerControls.isPlaying = true

        timer = Timer.scheduledTimer(timeInterval: speed, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)

        delegate?.didStartPlaying(restart: restart)
    }
    
    func stopPlaying(restart: Bool = true) {
        tapManagerControls.isPlaying = false
        
        if restart {
            direction = .right
            animateBall(direction: .center, completion: nil)
        }
        
        timer?.invalidate()
        
        delegate?.didStopPlaying(restart: restart)
    }
    
    private func animateBall(direction: BallDirection, completion: ((Bool) -> ())?) {
        switch direction {
        case .left:
            centerXConstraint.constant = ballSize / 2 + ballPadding
        case .center:
            centerXConstraint.constant = superView.frame.width / 2
        case .right:
            centerXConstraint.constant = superView.frame.width - ballSize / 2 - ballPadding
        }
        
        centerXConstraint.isActive = false
        centerXConstraint.isActive = true
                
        UIView.animate(withDuration: TimeInterval(tapManagerControls.speed), delay: 0, options: .curveEaseInOut, animations: {
            self.superView.layoutIfNeeded()
        }, completion: completion)
    }
    
    @objc private func timerAction() {
        animateBall(direction: direction, completion: nil)

        direction = direction == .right ? .left : .right
    }
}


// MARK: - CustomButtonDelegate

extension BallView {
    func didTapButton(_ sender: CustomButton) {
        tapManagerControls.currentImage = tapManagerControls.currentImage >= ballImages.count - 1 ? 0 : tapManagerControls.currentImage + 1
        
        ballButton.setImage(ballImages[tapManagerControls.currentImage]?.withRenderingMode((tapManagerControls.currentImage >= ballImages.count - 1) ? .alwaysOriginal : .alwaysTemplate), for: .normal)
     
        UserDefaults.standard.set(tapManagerControls.currentImage, forKey: "BallImage")
        
        delegate?.didUpdateCurrentImage()
    }
}
