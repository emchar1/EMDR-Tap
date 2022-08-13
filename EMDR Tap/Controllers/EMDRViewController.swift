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
    private var hostIDLabel: UILabel!
    private var guestHasBeenSetUp = false
    var hostID: Int?
    
    
    // MARK: - Initialization

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if DataService.sessionType != .guest {
            //Set this up the usual way if not a guest
            setupViews()
            layoutViews()
        }
        else {
            //Otherwise, set it up in completion handler so we can capture the DataModel from Firestore
            setupFirestoreListenerIfGuest()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        //MUST call this when exiting the view, otherwise things don't get reset!!
        DataService.listener?.remove()
    }
        
    private func setupViews() {
        tapManager = TapManager(in: view)
        
        homeButton = CustomButton(image: UIImage(systemName: "house.circle.fill"), asTemplate: true, shouldAnimatePress: true)
        homeButton.delegate = self
        
        hostIDLabel = UILabel()
        hostIDLabel.text = hostID != nil ? "Host ID: " + String(format: "%04d", hostID!) : ""
        hostIDLabel.textColor = UIColor(named: "buttonColor")
        hostIDLabel.font = UIFont(name: "Georgia-Bold", size: 20)
        hostIDLabel.translatesAutoresizingMaskIntoConstraints = false
        
    }
        
    private func layoutViews() {
        let buttonPadding: CGFloat = 20
        let buttonSize: CGFloat = 30
        
        view.addSubview(homeButton)
        view.addSubview(hostIDLabel)
        
        NSLayoutConstraint.activate([
            homeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: buttonPadding),
            view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: homeButton.trailingAnchor, constant: buttonPadding),
            homeButton.widthAnchor.constraint(equalToConstant: buttonSize),
            homeButton.heightAnchor.constraint(equalToConstant: buttonSize),
            
            hostIDLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: buttonPadding),
            hostIDLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: buttonPadding),
            hostIDLabel.widthAnchor.constraint(equalToConstant: 200),
            hostIDLabel.heightAnchor.constraint(equalToConstant: buttonSize)
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
            
            print("Listener passed the vibe check...")
            
            //Also, only set this up initially!
            if !self.guestHasBeenSetUp {
                DataService.guestModel = FIRModel(id: DataService.docRef.documentID,
                                                  isPlaying: isPlaying,
                                                  speed: Float(speed),
                                                  duration: duration,
                                                  currentImage: currentImage)
                self.setupViews()
                self.layoutViews()
                self.guestHasBeenSetUp = true
                
                print("Initial setupViews for guest")
            }
            
            if DataService.guestModel?.isPlaying != isPlaying {
                DataService.guestModel?.isPlaying = isPlaying
                self.tapManager.updateIfGuest_StartStop()
            }
            
            if DataService.guestModel?.currentImage != currentImage {
                DataService.guestModel?.currentImage = currentImage
                self.tapManager.updateIfGuest_BallImage()
            }
            
            if DataService.guestModel?.speed != Float(speed) {
                DataService.guestModel?.speed = Float(speed)
                self.tapManager.updateIfGuest_Speed()
            }
            
            if DataService.guestModel?.duration != duration {
                DataService.guestModel?.duration = duration
                self.tapManager.updateIfGuest_Duration()
            }
        })
        
        print("Printing outside of the Listener loop...")
    }
}


// MARK: - CustomButtonDelegate

extension EMDRViewController: CustomButtonDelegate {
    func didTapButton(_ button: CustomButton) {
        tapManager.didStopPlaying(restart: true)
        
        DataService.guestModel = nil
        
        if DataService.sessionType == .guest {
            self.presentingViewController?.presentingViewController?.dismiss(animated: true)
        }
        else {
            dismiss(animated: true)
        }
    }
}
