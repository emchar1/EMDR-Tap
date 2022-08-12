//
//  TapManager.swift
//  EMDR Tap
//
//  Created by Eddie Char on 7/22/22.
//

import UIKit

class TapManager {

    // MARK: - Properties
    
    private let timerInterval: TimeInterval = 1.0
    private var timer: Timer?
    private var superView: UIView!
    private var ballView: BallView!
    private var settingsView: SettingsView!

    private var startTime: TimeInterval = Date.timeIntervalSinceReferenceDate
    private var currentTime: TimeInterval { Date.timeIntervalSinceReferenceDate }
    private var elapsedTime: TimeInterval { currentTime - startTime }
    

    // MARK: - Initialization

    init(in superView: UIView) {
        self.superView = superView
        
        setupViews()
        layoutViews()
        setFirebaseModelIfHost()
    }
    
    private func setupViews() {
        timer = Timer()
        
        self.superView.backgroundColor = UIColor(named: "bgColor")

        ballView = BallView(in: superView)
        ballView.translatesAutoresizingMaskIntoConstraints = false

        settingsView = SettingsView(in: superView)
        settingsView.translatesAutoresizingMaskIntoConstraints = false

        //These MUST appear last!
        ballView.delegate = self
        settingsView.delegate = self
    }
    
    private func layoutViews() {
        superView.addSubview(ballView)
        
        NSLayoutConstraint.activate([
            ballView.topAnchor.constraint(equalTo: superView.topAnchor),
            ballView.leadingAnchor.constraint(equalTo: superView.leadingAnchor),
            superView.trailingAnchor.constraint(equalTo: ballView.trailingAnchor),
            superView.bottomAnchor.constraint(equalTo: ballView.bottomAnchor)
        ])

        
        guard DataService.sessionType != .guest else { return }
            
        superView.addSubview(settingsView)
            
        NSLayoutConstraint.activate([
            settingsView.leadingAnchor.constraint(equalTo: superView.leadingAnchor),
            superView.trailingAnchor.constraint(equalTo: settingsView.trailingAnchor),
            superView.bottomAnchor.constraint(equalTo: settingsView.bottomAnchor),
            settingsView.heightAnchor.constraint(equalToConstant: settingsView.getViewHeight())
        ])
    }
    
    // MARK: - Firestore
    
    private func setFirebaseModelIfHost() {
        guard DataService.sessionType == .host else { return }
        
        
        do {
            try DataService.docRef.setData(from: FIRModel(id: DataService.docRef.documentID,
                                                          speed: settingsView.getSpeed(),
                                                          duration: settingsView.getDuration(),
                                                          isPlaying: ballView.getIsPlaying(),
                                                          currentImage: ballView.getCurrentImage()))
        } catch {
            print("Error writing to Firestore: \(error)")
        }
    }
}



extension TapManager: SettingsViewDelegate, BallViewDelegate {
    
    // MARK: - SettingsViewDelegate

    func playButtonTapped(_ button: CustomButton) {
        if ballView.getIsPlaying() {
            ballView.stopPlaying()
        }
        else {
            ballView.startPlaying(speed: TimeInterval(settingsView.getSpeed()))
            startTime = currentTime
        }

        settingsView.updatePlayButton(isPlaying: ballView.getIsPlaying())
        
        setFirebaseModelIfHost()
    }
        
    func speedSliderChanged(_ slider: UISlider) {
        if ballView.getIsPlaying() {
            ballView.stopPlaying(restart: false)
            ballView.startPlaying(speed: TimeInterval(settingsView.getSpeed()), restart: false)
        }
        
        setFirebaseModelIfHost()
    }
    
    func durationChanged(_ control: UISegmentedControl) {
        setFirebaseModelIfHost()
    }
    
    
    // MARK: - BallViewDelegate
    
    func didStartPlaying(restart: Bool) {
        if restart {
            startTime = currentTime
            
            timer = Timer.scheduledTimer(timeInterval: timerInterval, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        }

        print("Play started via TapManager")
    }
    
    func didStopPlaying(restart: Bool) {
        if restart {
            timer?.invalidate()
        }

        print("Play stopped via TapManager")
    }
    
    func didUpdateCurrentImage() {
        setFirebaseModelIfHost()
    }
    
    @objc private func timerAction() {
        guard settingsView.getDuration() == SettingsView.infiniteDuration || elapsedTime < settingsView.getDuration() else {
            ballView.stopPlaying()
            timer?.invalidate()
            settingsView.updatePlayButton(isPlaying: false)
            return
        }
        
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 0

        print("\(numberFormatter.string(from: NSNumber(value: elapsedTime))!)/\(numberFormatter.string(from: NSNumber(value: settingsView.getDuration()))!)")
    }
}
