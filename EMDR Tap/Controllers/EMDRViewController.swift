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
}


// MARK: - CustomButtonDelegate

extension EMDRViewController: CustomButtonDelegate {
    func didTapButton(_ button: CustomButton) {
        tapManager.didStopPlaying(restart: true)
        
        dismiss(animated: true)
    }
}
