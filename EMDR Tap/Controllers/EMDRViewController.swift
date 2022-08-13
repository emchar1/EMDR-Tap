//
//  EMDRViewController.swift
//  EMDR Tap
//
//  Created by Eddie Char on 7/22/22.
//

import UIKit

class EMDRViewController: UIViewController {
    
    // MARK: - Properties
    
    private var tapManager: TapManager!
    private var homeButton: CustomButton!
    
    
    // MARK: - Initialization

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        layoutViews()
        setupFirestoreListenerIfGuest()
    }
    
    private func setupViews() {
        tapManager = TapManager(in: view)
        
        homeButton = CustomButton(image: UIImage(systemName: "house.circle.fill"), asTemplate: true, shouldAnimatePress: true)
        homeButton.delegate = self
    }
    
    private func layoutViews() {
        let buttonPadding: CGFloat = 20
        let buttonSize: CGFloat = 30
        
        view.addSubview(homeButton)
        
        NSLayoutConstraint.activate([
            homeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: buttonPadding),
            view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: homeButton.trailingAnchor, constant: buttonPadding),
            homeButton.widthAnchor.constraint(equalToConstant: buttonSize),
            homeButton.heightAnchor.constraint(equalToConstant: buttonSize)
        ])
    }
    
    private func setupFirestoreListenerIfGuest() {
        guard DataService.sessionType == .guest else { return }
        
        
        DataService.listener = DataService.docRef.addSnapshotListener({ (snapshot, error) in
            guard error == nil else { return print("Error getting docs: \(error!)") }
            guard let snapshot = snapshot, let data = snapshot.data() else { return }
            
            guard let isPlaying = data["isPlaying"] as? Bool,
                  let currentImage = data["currentImage"] as? Int,
                  let speed = data["speed"] as? Double,
                  let duration = data["duration"] as? TimeInterval else { return }
            
            print("Good")
            
            if DataService.guestModel?.isPlaying != isPlaying {
                DataService.guestModel?.isPlaying = isPlaying
                
                self.tapManager.updateIfGuest_StartStop()
            }
            
            if DataService.guestModel?.currentImage != currentImage {
                DataService.guestModel?.currentImage = currentImage
            }
            
            if DataService.guestModel?.speed != Float(speed) {
                DataService.guestModel?.speed = Float(speed)
                
                self.tapManager.updateIfGuest_Speed()
            }
            
            if DataService.guestModel?.duration != duration {
                DataService.guestModel?.duration = duration
            }
            
            DataService.guestModel = FIRModel(id: DataService.docRef.documentID,
                                              isPlaying: isPlaying,
                                              speed: Float(speed),
                                              duration: duration,
                                              currentImage: currentImage)
            
        })
        
        print("Now go here")
    }
}


// MARK: - CustomButtonDelegate

extension EMDRViewController: CustomButtonDelegate {
    func didTapButton(_ button: CustomButton) {
        tapManager.didStopPlaying(restart: true)
        
        dismiss(animated: true)
    }
}
