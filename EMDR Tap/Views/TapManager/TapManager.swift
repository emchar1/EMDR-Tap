//
//  TapManager.swift
//  EMDR Tap
//
//  Created by Eddie Char on 7/22/22.
//

import UIKit

class TapManager {

    // MARK: - Properties
        
    private let timerInterval: TimeInterval = 1
    private var timer: Timer?
    private var superView: UIView!
    private var ballView: BallView!
    private var settingsView: SettingsView!
    private var controls: TapManagerControls!
    private var elapsedLabel: UILabel!

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
        
        switch DataService.sessionType {
        case .guest: self.superView.backgroundColor = UIColor(named: "guestBG")
        case .host: self.superView.backgroundColor = UIColor(named: "hostBG")
        default: self.superView.backgroundColor = UIColor(named: "localBG")
        }
        
        if DataService.sessionType == .guest, let model = DataService.guestModel {
            controls = TapManagerControls(isPlaying: model.isPlaying, speed: model.speed, duration: model.duration, currentImage: model.currentImage)
            print("Setting up controls for GUEST in TapManager.")
        }
        else {
            let sliderValue = UserDefaults.standard.object(forKey: "SliderValue") as? Float ?? 0.5
            let durationControlValue = UserDefaults.standard.integer(forKey: "SegmentedControlIndex")
            let currentImageValue = UserDefaults.standard.integer(forKey: "BallImage")
            
            controls = TapManagerControls(isPlaying: false,
                                          speed: SettingsView.getSpeedForSliderValue(sliderValue),
                                          duration: SettingsView.getDurationForSelectedSegment(durationControlValue),
                                          currentImage: currentImageValue)
            print("Setting up controls for NON-GUEST in TapManager.")
        }

        ballView = BallView(in: superView, tapManagerControls: controls)
        ballView.translatesAutoresizingMaskIntoConstraints = false

        settingsView = SettingsView(in: superView, tapManagerControls: controls)
        settingsView.translatesAutoresizingMaskIntoConstraints = false
        
        elapsedLabel = UILabel()
        elapsedLabel.font = .secondo
        elapsedLabel.textAlignment = .center
        elapsedLabel.translatesAutoresizingMaskIntoConstraints = false

        //These MUST appear last!
        updateElapsedLabel(duration: settingsView.getDuration())
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

        
        //Only add the Settings control if it's NOT a guest
        guard DataService.sessionType != .guest else { return }
            
        superView.addSubview(settingsView)
        superView.addSubview(elapsedLabel)
            
        NSLayoutConstraint.activate([
            settingsView.leadingAnchor.constraint(equalTo: superView.leadingAnchor),
            superView.trailingAnchor.constraint(equalTo: settingsView.trailingAnchor),
            superView.bottomAnchor.constraint(equalTo: settingsView.bottomAnchor),
            settingsView.heightAnchor.constraint(equalToConstant: settingsView.getViewHeight()),
            
            elapsedLabel.centerXAnchor.constraint(equalTo: superView.centerXAnchor),
            elapsedLabel.topAnchor.constraint(equalTo: superView.safeAreaLayoutGuide.topAnchor, constant: 20)
        ])
    }
    
    // MARK: - Firestore
    
    private func setFirebaseModelIfHost() {
        guard DataService.sessionType == .host else { return }
        
        do {
            try DataService.docRef.setData(from: FIRModel(id: DataService.docRef.documentID,
                                                          isPlaying: ballView.getIsPlaying(),
                                                          speed: settingsView.getSpeed(),
                                                          duration: settingsView.getDuration(),
                                                          currentImage: ballView.getCurrentImage()))
        } catch {
            print("Error writing to Firestore: \(error)")
        }
    }
    
    func updateIfGuest_StartStop() {
        guard DataService.sessionType == .guest else { return print("Not a Guest. Exiting.")}
        guard let model = DataService.guestModel else { return print("DataService.guestModel is nil.") }

        updateBallMovement(isPlaying: !model.isPlaying, speed: model.speed) //isPlaying is reversed here...
    }
    
    func updateIfGuest_Speed() {
        guard DataService.sessionType == .guest else { return print("Not a Guest. Exiting.")}
        guard let model = DataService.guestModel else { return print("DataService.guestModel is nil.") }

        updateSpeed(isPlaying: model.isPlaying, speed: model.speed)
    }
    
    func updateIfGuest_Duration() {
        guard DataService.sessionType == .guest else { return print("Not a Guest. Exiting.")}
        guard let model = DataService.guestModel else { return print("DataService.guestModel is nil.") }

        settingsView.tapManagerControls.duration = model.duration
    }
    
    
    func updateIfGuest_BallImage() {
        guard DataService.sessionType == .guest else { return print("Not a Guest. Exiting.")}
        guard let model = DataService.guestModel else { return print("DataService.guestModel is nil.") }

        ballView.tapManagerControls.currentImage = model.currentImage
        ballView.setBallImage(model.currentImage)
    }
    
    
    // MARK: - Helper Functions
    
    func stopAllPlaying() {
        ballView.stopPlaying()
        timer?.invalidate()
        settingsView.updatePlayButton(isPlaying: false)
        updateElapsedLabel(duration: settingsView.getDuration())

        setFirebaseModelIfHost()
    }
    
    private func updateBallMovement(isPlaying: Bool, speed: Float) {
        if isPlaying {
            ballView.stopPlaying()
        }
        else {
            ballView.startPlaying(speed: TimeInterval(speed))
            startTime = currentTime
        }
        
        settingsView.updatePlayButton(isPlaying: !isPlaying)
    }
    
    private func updateSpeed(isPlaying: Bool, speed: Float) {
        if isPlaying {
            ballView.stopPlaying(restart: false)
            ballView.startPlaying(speed: TimeInterval(speed), restart: false)
        }
    }
}



extension TapManager: SettingsViewDelegate, BallViewDelegate {
    
    // MARK: - SettingsViewDelegate

    func playButtonTapped(_ button: CustomButton) {
        updateBallMovement(isPlaying: ballView.getIsPlaying(), speed: settingsView.getSpeed())
        updateElapsedLabel(duration: settingsView.getDuration())

        setFirebaseModelIfHost()
    }
        
    func speedSliderChanged(_ slider: UISlider) {
        updateSpeed(isPlaying: ballView.getIsPlaying(), speed: settingsView.getSpeed())
        
        setFirebaseModelIfHost()
    }
    
    func durationChanged(_ control: UISegmentedControl) {
        updateElapsedLabel(duration: ballView.getIsPlaying() ? getRemainingDuration() : settingsView.getDuration())
        
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
        updateElapsedLabel(duration: getRemainingDuration())

        if !(settingsView.getDuration() == SettingsView.infiniteDuration || elapsedTime < settingsView.getDuration()) {
            stopAllPlaying()
        }
    }
    
    private func updateElapsedLabel(duration: TimeInterval) {
        guard settingsView.getDuration() != SettingsView.infiniteDuration else {
            elapsedLabel.text = "--:--"
            elapsedLabel.textColor = .label
            return
        }
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 0

        let minutes = numberFormatter.string(from: NSNumber(value: (duration / 60).rounded(.towardZero)))!
        let seconds = numberFormatter.string(from: NSNumber(value: duration.truncatingRemainder(dividingBy: 60)))!

        elapsedLabel.textColor = duration <= 5 ? .systemRed : .label
        elapsedLabel.text = "\(minutes)" + ":" + (seconds.count < 2 ? "0" + seconds : seconds)
    }
    
    private func getRemainingDuration() -> TimeInterval {
        return max(round(settingsView.getDuration() - elapsedTime), 0)
    }
}
