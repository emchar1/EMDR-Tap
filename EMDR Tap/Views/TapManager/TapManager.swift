//
//  TapManager.swift
//  EMDR Tap
//
//  Created by Eddie Char on 7/22/22.
//

import UIKit

class TapManager {

    // MARK: - Properties
    
    private var controls: TapManagerControls!
    
    private let timerInterval: TimeInterval = 1.0
    private var timer: Timer?
    private var superView: UIView!
    private var ballView: BallView!
    private var settingsView: SettingsView!

    private var startTime: TimeInterval = Date.timeIntervalSinceReferenceDate
    private var currentTime: TimeInterval { Date.timeIntervalSinceReferenceDate }
    private var elapsedTime: TimeInterval { currentTime - startTime }
    
    
//    //Controls
//    private var controlIsPlaying: Bool!
//    private var controlSpeed: Float!
//    private var controlDuration: TimeInterval!
//    private var controlCurrentImage: Int!
    

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
        
        // FIXME: - How to make use of controls based on sessionType???
        if DataService.sessionType == .guest, let model = DataService.guestModel {
            controls = TapManagerControls(isPlaying: model.isPlaying, speed: model.speed, duration: model.duration, currentImage: model.currentImage)
        }
        else {
            //isPlaying should always start out false - ball
            //speed set in settings
            //duration - settings
            //currentImage - ball
            
            let sliderValue = UserDefaults.standard.object(forKey: "SliderValue") as? Float ?? 0.5
            let durationControlValue = UserDefaults.standard.integer(forKey: "SegmentedControlIndex")
            let currentImageValue = UserDefaults.standard.integer(forKey: "BallImage")
            
            controls = TapManagerControls(isPlaying: false,
                                          speed: SettingsView.getSpeedForSliderValue(sliderValue),
                                          duration: SettingsView.getDurationForSelectedSegment(durationControlValue),
                                          currentImage: currentImageValue)
        }

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
                                                          isPlaying: ballView.getIsPlaying(),
                                                          speed: settingsView.getSpeed(),
                                                          duration: settingsView.getDuration(),
                                                          currentImage: ballView.getCurrentImage()))
        } catch {
            print("Error writing to Firestore: \(error)")
        }
    }
    


    func updateIfGuest_StartStop() {
        guard DataService.sessionType == .guest, let model = DataService.guestModel else { return }
        print("model.isPlaying: \(model.isPlaying)")
        if !model.isPlaying {
            ballView.stopPlaying()
        }
        else {
            ballView.startPlaying(speed: TimeInterval(model.speed))
            startTime = currentTime
        }

        settingsView.updatePlayButton(isPlaying: model.isPlaying)
    }
    
    func updateIfGuest_Speed() {
        guard DataService.sessionType == .guest, let model = DataService.guestModel else { return }

        if model.isPlaying {
            ballView.stopPlaying(restart: false)
            ballView.startPlaying(speed: TimeInterval(model.speed), restart: false)
        }
    }
    
//    func updatIfGuest_Duration() {
//        guard DataService.sessionType == .guest, let model = DataService.guestModel else { return }
//
//    }
    
    
//    func updateIfGuest_BallImage() {
//        guard DataService.sessionType == .guest, let model = DataService.guestModel else { return }
//
//        
//    }
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
