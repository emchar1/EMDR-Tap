//
//  MainMenuController.swift
//  EMDR Tap
//
//  Created by Eddie Char on 8/8/22.
//

import UIKit

class MainMenuController: UIViewController {
    
    // MARK: - Properties
    
    private var livingWithClarityLabel: UILabel!
    
    private var hostButton: MenuButton!
    private var joinButton: MenuButton!
    private var localButton: MenuButton!
    
    private lazy var vStack = UIStackView(arrangedSubviews: [hStack, localButton])
    private lazy var hStack = UIStackView(arrangedSubviews: [hostButton, joinButton])

    
    // MARK: - Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        layoutViews()
    }
    
    private func setupViews() {
        view.backgroundColor = UIColor(named: "menuBG")
        
        livingWithClarityLabel = UILabel()
        livingWithClarityLabel.text = "Living with Clarity"
        livingWithClarityLabel.textColor = UIColor(named: "menuTint")
        livingWithClarityLabel.textAlignment = .center
        livingWithClarityLabel.font = UIFont(name: "HelveticaNeue", size: 32)
        livingWithClarityLabel.translatesAutoresizingMaskIntoConstraints = false
        
        hostButton = MenuButton(title: "Host Session")
        hostButton.delegate = self
        hostButton.translatesAutoresizingMaskIntoConstraints = false
        
        joinButton = MenuButton(title: "Join Session")
        joinButton.delegate = self
        joinButton.translatesAutoresizingMaskIntoConstraints = false
        
        localButton = MenuButton(title: "Start Local Session")
        localButton.delegate = self
        localButton.translatesAutoresizingMaskIntoConstraints = false

        // Stacks must be setup AFTER the buttons!
        vStack.axis = .vertical
        vStack.distribution = .fillEqually
        vStack.spacing = 40
        vStack.translatesAutoresizingMaskIntoConstraints = false

        hStack.axis = .horizontal
        hStack.distribution = .fillEqually
        hStack.spacing = 40
        hStack.translatesAutoresizingMaskIntoConstraints = false

    }
    
    private func layoutViews() {
        let topBottomBorder: CGFloat = 60
        
        view.addSubview(livingWithClarityLabel)
        view.addSubview(vStack)
                
        NSLayoutConstraint.activate([
            livingWithClarityLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: topBottomBorder),
            livingWithClarityLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            
            vStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: vStack.bottomAnchor, constant: topBottomBorder),
            
            vStack.arrangedSubviews[0].widthAnchor.constraint(equalToConstant: 500),
            vStack.arrangedSubviews[0].heightAnchor.constraint(equalToConstant: 60),
            
        ])
    }
}


// MARK: - MenuButtonDelegate

extension MainMenuController: MenuButtonDelegate {
    func didTapButton(_ sender: UIButton) {
        switch sender.titleLabel?.text {
        case "Host Session":
            DataService.sessionType = .host
            DataService.setSessionID(Int.random(in: 0...9998))
            
            let vc = EMDRViewController()
            vc.hostID = DataService.sessionID
            present(vc, animated: true)
        case "Join Session":
            DataService.sessionType = .guest
            
            let vc = GuestJoinController()
            present(vc, animated: true)
        case "Start Local Session":
            DataService.sessionType = .local
            
            let vc = EMDRViewController()
            present(vc, animated: true)
        default:
            print("Unknown button pressed")
        }
    }
}
