//
//  GuestJoinController.swift
//  EMDR Tap
//
//  Created by Eddie Char on 8/11/22.
//

import UIKit

class GuestJoinController: UIViewController {

    // MARK: - Properties
    
    private var homeButton: CustomButton!
    private var loginView: LoginView!
    

    // MARK: - Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        layoutViews()
    }
    
    private func setupViews() {
        view.backgroundColor = UIColor(named: "menuBG")

        homeButton = CustomButton(image: UIImage(systemName: "house.circle.fill"), asTemplate: true, shouldAnimatePress: true)
        homeButton.imageView?.tintColor = UIColor(named: "menuTint")
        homeButton.delegate = self
        
        loginView = LoginView()
        loginView.delegate = self
        loginView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func layoutViews() {
        let buttonPadding: CGFloat = 20
        let buttonSize: CGFloat = 30
        
        view.addSubview(homeButton)
        view.addSubview(loginView)

        NSLayoutConstraint.activate([
            homeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: buttonPadding),
            view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: homeButton.trailingAnchor, constant: buttonPadding),
            homeButton.widthAnchor.constraint(equalToConstant: buttonSize),
            homeButton.heightAnchor.constraint(equalToConstant: buttonSize),

            loginView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: buttonPadding),
            loginView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 100),
            view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: loginView.trailingAnchor, constant: 100),
            view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: loginView.bottomAnchor, constant: buttonPadding)
        ])
    }
}



// MARK: - CustomButtonDelegate

extension GuestJoinController: CustomButtonDelegate {
    func didTapButton(_ button: CustomButton) {
        dismiss(animated: true)
    }
}


// MARK: - LoginViewDelegate

extension GuestJoinController: LoginViewDelegate {
    func didTapReturn(_ sessionID: Int) {
        DataService.setSessionID(sessionID)
        
        DataService.docRef.getDocument { snapshot, error in
            guard let snapshot = snapshot else { return }
            guard snapshot.exists else {
                self.loginView.updateStatus("Invalid Session ID")
                Haptics.playInvalidSessionID()
                return
            }

            AudioPlayer.playSound(filename: TapSounds.proceedJoin)
            
            let vc = EMDRViewController()
            self.present(vc, animated: true)
        }
    }
    
}
