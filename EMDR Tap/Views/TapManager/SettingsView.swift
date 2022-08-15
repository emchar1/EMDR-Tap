//
//  SettingsView.swift
//  EMDR Tap
//
//  Created by Eddie Char on 7/23/22.
//

import UIKit

protocol SettingsViewDelegate: AnyObject {
    func playButtonTapped(_ button: CustomButton)
    func speedSliderChanged(_ slider: UISlider)
    func durationChanged(_ control: UISegmentedControl)
}

class SettingsView: UIView, CustomButtonDelegate {
    
    // MARK: - Properties
    
    static let infiniteDuration: TimeInterval = 0
    static let speedFactor: Float = 1.5
    static let durations: [TimeInterval] = [60, 5 * 60, SettingsView.infiniteDuration]
    
    private let dialSize: CGFloat = 40
    private let dialPadding: CGFloat = 50
    private let dialPaddingTop: CGFloat = 20
    private var isExpanded = true
    
    private var superView: UIView!
    private var settingsButton: CustomButton!
    private var speedSlider: UISlider!
    private var playButton: CustomButton!
    private var durationControl: UISegmentedControl!
    
    private var playButtonConstraint: NSLayoutConstraint!
    private var speedSliderConstraint: NSLayoutConstraint!
    private var durationConstraint: NSLayoutConstraint!
    
    var tapManagerControls: TapManagerControls!
    weak var delegate: SettingsViewDelegate?
    
    
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
        backgroundColor = UIColor(named: "settingsBG")?.withAlphaComponent(0.2)
        layer.cornerRadius = 20
        clipsToBounds = true
        
        settingsButton = CustomButton(image: UIImage(systemName: "gearshape.fill"))
        settingsButton.imageView?.transform = CGAffineTransform(rotationAngle: .pi)
        settingsButton.delegate = self
        
        playButton = CustomButton(image: UIImage(systemName: "play.fill"))
        playButton.tintColor = UIColor(named: "settingsPlay")
        playButton.delegate = self
        
        speedSlider = UISlider()
        speedSlider.value = SettingsView.getSliderValueForSpeed(tapManagerControls.speed)
        speedSlider.isContinuous = false
        speedSlider.addTarget(self, action: #selector(sliderDidChange(_:)), for: .valueChanged)
        speedSlider.translatesAutoresizingMaskIntoConstraints = false
        
        durationControl = UISegmentedControl(items: ["1 min", "5 mins", "∞"])
        durationControl.selectedSegmentIndex = SettingsView.getSelectedSegmentForDuration(tapManagerControls.duration)
        durationControl.addTarget(self, action: #selector(segmentedControlDidChange(_:)), for: .valueChanged)
        durationControl.translatesAutoresizingMaskIntoConstraints = false
        
        switch DataService.sessionType {
        case .guest:
            speedSlider.tintColor = UIColor(named: "guestTint")
            speedSlider.thumbTintColor = UIColor(named: "guestTint")
            durationControl.setTitleTextAttributes([.foregroundColor: UIColor(named: "guestTint") ?? UIColor.label], for: .normal)
        case .host:
            speedSlider.tintColor = UIColor(named: "hostTint")
            speedSlider.thumbTintColor = UIColor(named: "hostTint")
            durationControl.setTitleTextAttributes([.foregroundColor: UIColor(named: "hostTint") ?? UIColor.label], for: .normal)
        default:
            speedSlider.tintColor = UIColor(named: "localTint")
            speedSlider.thumbTintColor = UIColor(named: "localTint")
            durationControl.setTitleTextAttributes([.foregroundColor: UIColor(named: "localTint") ?? UIColor.label], for: .normal)
        }

        //MUST go last!
        setSpeed()
        setDuration()
    }
    
    private func layoutViews() {
        addSubview(settingsButton)
        addSubview(playButton)
        addSubview(speedSlider)
        addSubview(durationControl)
        
        playButtonConstraint = playButton.leadingAnchor.constraint(equalTo: leadingAnchor)
        speedSliderConstraint = speedSlider.leadingAnchor.constraint(equalTo: leadingAnchor)
        durationConstraint = durationControl.leadingAnchor.constraint(equalTo: leadingAnchor)
        updateConstraints(shouldShow: true)
        
        NSLayoutConstraint.activate([
            settingsButton.widthAnchor.constraint(equalToConstant: dialSize),
            settingsButton.heightAnchor.constraint(equalToConstant: dialSize),
            settingsButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: dialPadding),
            bottomAnchor.constraint(equalTo: settingsButton.bottomAnchor, constant: dialPadding),
            
            playButton.widthAnchor.constraint(equalToConstant: dialSize),
            playButton.heightAnchor.constraint(equalToConstant: dialSize),
            bottomAnchor.constraint(equalTo: playButton.bottomAnchor, constant: dialPadding),

            speedSlider.widthAnchor.constraint(equalToConstant: 2 * dialSize),
            bottomAnchor.constraint(equalTo: speedSlider.bottomAnchor, constant: dialPadding),
            
            durationControl.widthAnchor.constraint(equalToConstant: 4 * dialSize),
            bottomAnchor.constraint(equalTo: durationControl.bottomAnchor, constant: dialPadding),
        ])
    }
    
    
    // MARK: - Getters & Setters

    func getSpeed() -> Float {
        return tapManagerControls.speed
    }
    
    func getDuration() -> TimeInterval {
        return tapManagerControls.duration
    }
    
    func getViewHeight() -> CGFloat {
        return dialSize + dialPadding + dialPaddingTop
    }
    
    
    // MARK: - Helper Functions
    
    func updatePlayButton(isPlaying: Bool) {
        if isPlaying {
            playButton.setImage(UIImage(systemName: "stop.fill"), for: .normal)
            playButton.tintColor = UIColor(named: "settingsStop")
        }
        else {
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            playButton.tintColor = UIColor(named: "settingsPlay")
        }
    }
    
    static func getSpeedForSliderValue(_ value: Float) -> Float {
        return speedFactor - value
    }
    
    static func getSliderValueForSpeed(_ speed: Float) -> Float {
        return speedFactor - speed
    }

    static func getDurationForSelectedSegment(_ value: Int) -> TimeInterval {
        switch value {
        case 0: return durations[0]
        case 1: return durations[1]
        case 2: return durations[2]
        default: return -1
        }
    }
    
    static func getSelectedSegmentForDuration(_ duration: TimeInterval) -> Int {
        switch duration {
        case durations[0]: return 0
        case durations[1]: return 1
        case durations[2]: return 2
        default: return 0
        }
    }
    
    @objc private func sliderDidChange(_ sender: UISlider) {
        setSpeed()
        
        UserDefaults.standard.set(sender.value, forKey: "SliderValue")
        
        delegate?.speedSliderChanged(sender)
    }
    
    @objc private func segmentedControlDidChange(_ sender: UISegmentedControl) {
        setDuration()

        UserDefaults.standard.set(sender.selectedSegmentIndex, forKey: "SegmentedControlIndex")

        delegate?.durationChanged(sender)
    }
    
    private func setSpeed() {
        tapManagerControls.speed = SettingsView.getSpeedForSliderValue(speedSlider.value)
    }
    
    private func setDuration() {
        tapManagerControls.duration = SettingsView.getDurationForSelectedSegment(durationControl.selectedSegmentIndex)
    }
}
    
    
// MARK: - CustomButtonDelegate

extension SettingsView {
    func didTapButton(_ button: CustomButton) {
        switch button {
        case settingsButton:
            if isExpanded {
                updateConstraints(shouldShow: false)
                
                UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: { [unowned self] in
                    backgroundColor = UIColor(named: "settingsBG")?.withAlphaComponent(0)
                    settingsButton.imageView?.transform = CGAffineTransform(rotationAngle: -2 * .pi)
                    settingsButton.alpha = 0.5
                    playButton.alpha = 0
                    speedSlider.alpha = 0
                    durationControl.alpha = 0
                    
                    layoutIfNeeded()
                }, completion: nil)
            }
            else {
                updateConstraints(shouldShow: true)

                UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: { [unowned self] in
                    backgroundColor = UIColor(named: "settingsBG")?.withAlphaComponent(0.2)
                    settingsButton.imageView?.transform = CGAffineTransform(rotationAngle: .pi)
                    settingsButton.alpha = 1
                    playButton.alpha = 1
                    speedSlider.alpha = 1
                    durationControl.alpha = 1
                    
                    layoutIfNeeded()
                }, completion: nil)
            }
            
            isExpanded.toggle()
        case playButton:
            delegate?.playButtonTapped(playButton)
        default:
            print("Unknown button pressed.")
        }
    }
    
    private func updateConstraints(shouldShow: Bool) {
        if shouldShow {
            playButtonConstraint.constant = (superView.frame.width - dialSize) / 2
            speedSliderConstraint.constant = (superView.frame.width - dialSize) / 4
            durationConstraint.constant = (superView.frame.width - 2 * dialSize) * 3 / 4
        }
        else {
            playButtonConstraint.constant = dialSize
            speedSliderConstraint.constant = dialSize
            durationConstraint.constant = dialSize
        }
        
        playButtonConstraint.isActive = false
        playButtonConstraint.isActive = true
        
        speedSliderConstraint.isActive = false
        speedSliderConstraint.isActive = true
        
        durationConstraint.isActive = false
        durationConstraint.isActive = true
    }
}
